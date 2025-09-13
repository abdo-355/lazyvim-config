local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local d = ls.dynamic_node
local c = ls.choice_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

-- Smart error handling that adapts to function return types
s("smart_err", {
  i(1, "val"), t(", "), i(2, "err"), t(" := "), i(3, "f"), t("("), i(4), t(")"),
  t({ "", "if " }), f(function(args) return args[1] end, { 2 }), t({ " != nil {", "\treturn " }),
  d(5, function(args)
    -- Dynamic node that determines return values based on function context
    local err_arg = args[1][1]
    local func_arg = args[2][1]
    
    -- Simple heuristic: if function starts with "New" or "Create", return nil, err
    if func_arg:match("^[Nn]ew") or func_arg:match("^[Cc]reate") then
      return ls.snippet_node(nil, { t("nil, "), rep(2) })
    else
      return ls.snippet_node(nil, { rep(2) })
    end
  end, { 2, 3 }),
  t({ "", "}" }), i(0),
}),

-- HTTP handler with common patterns
s("httphandler", {
  t("func "), i(1, "handlerName"), t("(w http.ResponseWriter, r *http.Request) {"),
  t({ "", "\t" }),
  c(2, {
    t("// Handle GET request"),
    t("// Handle POST request"),
    t("// Handle PUT request"),
    t("// Handle DELETE request"),
  }),
  t({ "", "\t" }),
  c(3, {
    fmt([[
      if r.Method != "GET" {
        http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
        return
      }
    ]], {}),
    fmt([[
      if r.Method != "POST" {
        http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
        return
      }
    ]], {}),
    t(""),
  }),
  t({ "", "\t" }),
  i(0),
  t({ "", "}" }),
}),

-- Context-aware error handling
s("ctx_err", {
  t("ctx, cancel := context.WithTimeout(context.Background(), "), i(1, "5*time.Second"), t(")"),
  t({ "", "defer cancel()", "" }),
  t("result, err := "), i(2, "operation"), t("(ctx, "), i(3), t(")"),
  t({ "", "if err != nil {" }),
  t({ "", "\treturn fmt.Errorf(\"failed to " }), rep(2), t(": %w\", err)"),
  t({ "", "}" }),
  t({ "", "" }),
  i(0),
}),

-- Database transaction pattern
s("dbtx", {
  t("tx, err := "), i(1, "db"), t(".Begin()"),
  t({ "", "if err != nil {" }),
  t({ "", "\treturn fmt.Errorf(\"failed to begin transaction: %w\", err)" }),
  t({ "", "}" }),
  t({ "", "defer func() {" }),
  t({ "", "\tif err := tx.Rollback(); err != nil {" }),
  t({ "", "\t\tlog.Printf(\"failed to rollback transaction: %v\", err)" }),
  t({ "", "\t}" }),
  t({ "", "}()" }),
  t({ "", "" }),
  i(0),
  t({ "", "" }),
  t("if err := tx.Commit(); err != nil {" }),
  t({ "", "\treturn fmt.Errorf(\"failed to commit transaction: %w\", err)" }),
  t({ "", "}" }),
}),

-- Channel pattern with context
s("chan_ctx", {
  t("type "), i(1, "Result"), t(" struct {"),
  t({ "", "\tData " }), i(2, "interface{}"), t({ "", "\tErr  error" }),
  t({ "", "}" }),
  t({ "", "" }),
  t("func "), i(3, "process"), t("(ctx context.Context, input "), i(4, "InputType"), t(") <-chan "), rep(1), t(" {"),
  t({ "", "\tresultChan := make(chan " }), rep(1), t(", 1)"),
  t({ "", "\tgo func() {" }),
  t({ "", "\t\tdefer close(resultChan)" }),
  t({ "", "\t\t" }),
  t("select {" }),
  t({ "", "\t\tcase <-ctx.Done():" }),
  t({ "", "\t\t\tresultChan <- " }), rep(1), t("{Err: ctx.Err()}"),
  t({ "", "\t\t\treturn" }),
  t({ "", "\t\tdefault:" }),
  t({ "", "\t\t\t// Process input" }),
  t({ "", "\t\t\t" }), i(0),
  t({ "", "\t\t}" }),
  t({ "", "\t}()" }),
  t({ "", "\treturn resultChan" }),
  t({ "", "}" }),
}),

-- Worker pool pattern
s("worker_pool", {
  t("func "), i(1, "processWorkers"), t("(jobs <-chan "), i(2, "Job"), t(", results chan<- "), i(3, "Result"), t(", numWorkers int) {"),
  t({ "", "\tvar wg sync.WaitGroup" }),
  t({ "", "" }),
  t({ "", "\tfor i := 0; i < numWorkers; i++ {" }),
  t({ "", "\t\twg.Add(1)" }),
  t({ "", "\t\tgo func(workerID int) {" }),
  t({ "", "\t\t\tdefer wg.Done()" }),
  t({ "", "\t\t\tfor job := range jobs {" }),
  t({ "", "\t\t\t\t// Process job" }),
  t({ "", "\t\t\t\tresult := " }), i(4, "processJob"), t("(job)"),
  t({ "", "\t\t\t\tresults <- result" }),
  t({ "", "\t\t\t}" }),
  t({ "", "\t\t}(i)" }),
  t({ "", "\t}" }),
  t({ "", "" }),
  t({ "", "\tgo func() {" }),
  t({ "", "\t\twg.Wait()" }),
  t({ "", "\t\tclose(results)" }),
  t({ "", "\t}()" }),
  t({ "", "}" }),
}),

-- Retry pattern with exponential backoff
s("retry", {
  t("func "), i(1, "retryOperation"), t("(maxRetries int, operation func() error) error {" }),
  t({ "", "\tvar lastErr error" }),
  t({ "", "\tbackoff := " }), i(2, "time.Second"),
  t({ "", "" }),
  t({ "", "\tfor attempt := 0; attempt < maxRetries; attempt++ {" }),
  t({ "", "\t\tif err := operation(); err != nil {" }),
  t({ "", "\t\t\tlastErr = err" }),
  t({ "", "\t\t\tif attempt < maxRetries-1 {" }),
  t({ "", "\t\t\t\ttime.Sleep(backoff)" }),
  t({ "", "\t\t\t\tbackoff *= 2" }),
  t({ "", "\t\t\t}" }),
  t({ "", "\t\t\tcontinue" }),
  t({ "", "\t\t}" }),
  t({ "", "\t\treturn nil" }),
  t({ "", "\t}" }),
  t({ "", "\treturn fmt.Errorf(\"operation failed after %d attempts: %w\", maxRetries, lastErr)" }),
  t({ "", "}" }),
}),

-- Configuration struct with validation
s("config", {
  t("type "), i(1, "Config"), t(" struct {"),
  t({ "", "\t" }), i(2, "Field"), t(" "), i(3, "string"), t(" `yaml:\"" }), rep(2), t("\" validate:\"required\"`"),
  t({ "", "}" }),
  t({ "", "" }),
  t("func (c *"), rep(1), t(") Validate() error {" }),
  t({ "", "\tif c." }), rep(2), t(" == \"\" {" }),
  t({ "", "\t\treturn fmt.Errorf(\"" }), rep(2), t(" is required\")" }),
  t({ "", "\t}" }),
  t({ "", "\treturn nil" }),
  t({ "", "}" }),
}),

-- Middleware chain pattern
s("middleware_chain", {
  t("type "), i(1, "Middleware"), t(" func(http.Handler) http.Handler"),
  t({ "", "" }),
  t("func "), i(2, "chain"), t("(middlewares ..."), rep(1), t(") "), rep(1), t(" {" }),
  t({ "", "\treturn func(final http.Handler) http.Handler {" }),
  t({ "", "\t\tfor i := len(middlewares) - 1; i >= 0; i-- {" }),
  t({ "", "\t\t\tfinal = middlewares[i](final)" }),
  t({ "", "\t\t}" }),
  t({ "", "\t\treturn final" }),
  t({ "", "\t}" }),
  t({ "", "}" }),
}),

-- Generic repository pattern
s("repository", {
  t("type "), i(1, "Repository"), t("[T any] interface {" }),
  t({ "", "\tCreate(ctx context.Context, entity T) (T, error)" }),
  t({ "", "\tGetByID(ctx context.Context, id " }), i(2, "string"), t(") (T, error)" }),
  t({ "", "\tUpdate(ctx context.Context, entity T) (T, error)" }),
  t({ "", "\tDelete(ctx context.Context, id " }), rep(2), t(") error" }),
  t({ "", "\tList(ctx context.Context, limit, offset int) ([]T, error)" }),
  t({ "", "}" }),
}),

-- Service layer pattern
s("service", {
  t("type "), i(1, "Service"), t(" struct {" }),
  t({ "", "\trepo " }), i(2, "Repository"), t({ "", "\tlogger *log.Logger" }),
  t({ "", "}" }),
  t({ "", "" }),
  t("func New"), rep(1), t("(repo "), rep(2), t(", logger *log.Logger) *"), rep(1), t(" {" }),
  t({ "", "\treturn &"), rep(1), t("{" }),
  t({ "", "\t\trepo:   repo," }),
  t({ "", "\t\tlogger: logger," }),
  t({ "", "\t}" }),
  t({ "", "}" }),
  t({ "", "" }),
  t("func (s *"), rep(1), t(") "), i(3, "Method"), t("(ctx context.Context, "), i(4), t(") ("), i(5), t(", error) {" }),
  t({ "", "\ts.logger.Printf(\"executing " }), rep(3), t("\")" }),
  t({ "", "\t" }),
  i(0),
  t({ "", "}" }),
})
