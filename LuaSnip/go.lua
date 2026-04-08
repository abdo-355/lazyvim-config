local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local d = ls.dynamic_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

return {
  s("smart_err", {
    i(1, "val"),
    t(", "),
    i(2, "err"),
    t(" := "),
    i(3, "f"),
    t("("),
    i(4),
    t(")"),
    t({ "", "if " }),
    f(function(args)
      return args[1][1]
    end, { 2 }),
    t({ " != nil {", "\treturn " }),
    d(5, function(args)
      local func_arg = args[2][1]
      if func_arg:match("^[Nn]ew") or func_arg:match("^[Cc]reate") then
        return ls.snippet_node(nil, { t("nil, "), rep(2) })
      end
      return ls.snippet_node(nil, { rep(2) })
    end, { 2, 3 }),
    t({ "", "}" }),
    i(0),
  }),
  s("httphandler", {
    t("func "),
    i(1, "handlerName"),
    t("(w http.ResponseWriter, r *http.Request) {"),
    t({ "", "\t" }),
    i(0),
    t({ "", "}" }),
  }),
  s("ctx_err", {
    t("ctx, cancel := context.WithTimeout(context.Background(), "),
    i(1, "5*time.Second"),
    t(")"),
    t({ "", "defer cancel()", "" }),
    t("result, err := "),
    i(2, "operation"),
    t("(ctx, "),
    i(3),
    t(")"),
    t({ "", "if err != nil {", "\treturn fmt.Errorf(\"failed to " }),
    rep(2),
    t({ ': %w", err)', "", "}", "" }),
    i(0),
  }),
  s("dbtx", fmt([[
tx, err := {}.Begin()
if err != nil {{
	return fmt.Errorf("failed to begin transaction: %w", err)
}}
defer func() {{
	if err := tx.Rollback(); err != nil {{
		log.Printf("failed to rollback transaction: %v", err)
	}}
}}()

{}

if err := tx.Commit(); err != nil {{
	return fmt.Errorf("failed to commit transaction: %w", err)
}}
]], { i(1, "db"), i(0) })),
  s("retry", fmt([[
func {}(maxRetries int, operation func() error) error {{
	var lastErr error
	backoff := {}

	for attempt := 0; attempt < maxRetries; attempt++ {{
		if err := operation(); err != nil {{
			lastErr = err
			if attempt < maxRetries-1 {{
				time.Sleep(backoff)
				backoff *= 2
			}}
			continue
		}}
		return nil
	}}

	return fmt.Errorf("operation failed after %d attempts: %w", maxRetries, lastErr)
}}
]], { i(1, "retryOperation"), i(2, "time.Second") })),
}
