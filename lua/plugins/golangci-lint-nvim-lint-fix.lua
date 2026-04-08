local function norm(path)
  return vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))
end

local function find_go_root(path)
  local found = vim.fs.find({ "go.work", "go.mod" }, { path = path, upward = true })
  if not found or not found[1] then
    return nil
  end
  return vim.fn.fnamemodify(found[1], ":h")
end

local function package_target()
  local filename = vim.api.nvim_buf_get_name(0)
  local pkg_dir = vim.fn.fnamemodify(filename, ":h")
  local rel = vim.fn.fnamemodify(pkg_dir, ":.")
  return rel == "" and "." or rel
end

local ignored_duplicate_linters = {
  unusedfunc = true,
  typecheck = true,
  govet = true,
  staticcheck = true,
}

local disabled_warning_linters = {
}

return {
  {
    "mfussenegger/nvim-lint",
    optional = true,
    init = function()
      local group = vim.api.nvim_create_augroup("go-golangci-lint", { clear = true })

      vim.api.nvim_create_autocmd("BufWritePost", {
        group = group,
        pattern = "*.go",
        callback = function(args)
          local ok, lint = pcall(require, "lint")
          if not ok then
            return
          end

          local cwd = find_go_root(args.file) or vim.fn.fnamemodify(args.file, ":h")
          lint.try_lint("golangcilint", { cwd = cwd, ignore_errors = true })
        end,
      })

      vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        group = group,
        pattern = "*.go",
        callback = function(args)
          local ok, lint = pcall(require, "lint")
          if not ok then
            return
          end

          vim.diagnostic.reset(lint.get_namespace("golangcilint"), args.buf)
        end,
      })
    end,
    opts = function(_, opts)
      opts = opts or {}
      opts.linters = opts.linters or {}
      opts.linters_by_ft = opts.linters_by_ft or {}

      local go_linters = opts.linters_by_ft.go or {}
      opts.linters_by_ft.go = vim.tbl_filter(function(name)
        return name ~= "golangcilint"
      end, go_linters)

      local severities = {
        error = vim.diagnostic.severity.ERROR,
        warning = vim.diagnostic.severity.WARN,
        refactor = vim.diagnostic.severity.INFO,
        convention = vim.diagnostic.severity.HINT,
      }

      opts.linters.golangcilint = vim.tbl_deep_extend("force", opts.linters.golangcilint or {}, {
        -- Prefer Mason binary to avoid PATH issues.
        cmd = function()
          local mason_cmd = vim.fn.stdpath("data") .. "/mason/bin/golangci-lint"
          if vim.fn.executable(mason_cmd) == 1 then
            return mason_cmd
          end
          return "golangci-lint"
        end,

        -- Don’t lint unnamed buffers.
        condition = function(ctx)
          return ctx.filename and ctx.filename ~= ""
        end,

        append_fname = false,
        stream = "stdout",

        -- Force JSON output to stdout for golangci-lint v2+.
        args = {
          "run",
          "--output.json.path=stdout",
          -- Overwrite values possibly set in .golangci.yml
          "--output.text.path=",
          "--output.tab.path=",
          "--output.html.path=",
          "--output.checkstyle.path=",
          "--output.code-climate.path=",
          "--output.junit-xml.path=",
          "--output.teamcity.path=",
          "--output.sarif.path=",
          "--issues-exit-code=0",
          "--show-stats=false",
          "--path-mode=abs",
          package_target,
        },

        -- nvim-lint upstream parser currently throws on non-JSON output.
        -- Make it resilient so help/error output can’t crash diagnostics.
        parser = function(output, bufnr, cwd)
          if not output or output == "" then
            return {}
          end

          local ok, decoded = pcall(vim.json.decode, output)
          if not ok or type(decoded) ~= "table" then
            local first = (output:match("^([^\n]+)") or ""):sub(1, 200)
            vim.notify_once(
              "golangci-lint: expected JSON output but got non-JSON (first line): " .. first,
              vim.log.levels.WARN,
              { title = "nvim-lint" }
            )
            return {}
          end

          local issues = decoded.Issues
          if issues == nil or type(issues) == "userdata" then
            return {}
          end

          local curfile = vim.api.nvim_buf_get_name(bufnr)
          local curfile_norm = norm(curfile)

          local diagnostics = {}
          for _, item in ipairs(issues) do
            local severity = (item.Severity or "warning"):lower()

            if severity == "error" then
              goto continue
            end

            if ignored_duplicate_linters[item.FromLinter] then
              goto continue
            end

            if disabled_warning_linters[item.FromLinter] then
              goto continue
            end

            local pos = item.Pos or {}
            local filename = pos.Filename
            if type(filename) == "string" and filename ~= "" then
              local linted_abs
              if vim.fs and vim.fs.is_absolute and vim.fs.is_absolute(filename) then
                linted_abs = filename
              else
                linted_abs = (cwd and cwd ~= "") and (cwd .. "/" .. filename) or filename
              end

              local linted_norm = norm(linted_abs)

              if curfile_norm == norm(filename) or curfile_norm == linted_norm then
                local sev = severities[severity] or severities.warning
                local line = tonumber(pos.Line) or 1
                local col = tonumber(pos.Column) or 1

                table.insert(diagnostics, {
                  lnum = math.max(line - 1, 0),
                  col = math.max(col - 1, 0),
                  end_lnum = math.max(line - 1, 0),
                  end_col = math.max(col - 1, 0),
                  severity = sev,
                  source = item.FromLinter or "golangci-lint",
                  message = item.Text or "",
                })
              end
            end

            ::continue::
          end

          return diagnostics
        end,
      })

      return opts
    end,
  },
}
