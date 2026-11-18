local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s("block", {
    t('{{block "'),
    i(1, "name"),
    t({ '" .}}', "    " }),
    i(0),
    t({ "", "{{end}}" }),
  }),
  s("define", {
    t('{{define "'),
    i(1, "name"),
    t({ '"}}', "    " }),
    i(0),
    t({ "", "{{end}}" }),
  }),
  s("template", {
    t('{{template "'),
    i(1, "name"),
    t('" .}}'),
  }),
  s("if", {
    t("{{if "),
    i(1, "condition"),
    t({ "}}", "    " }),
    i(0),
    t({ "", "{{end}}" }),
  }),
  s("range", {
    t("{{range "),
    i(1, ".Items"),
    t({ "}}", "    " }),
    i(0),
    t({ "", "{{end}}" }),
  }),
  s("with", {
    t("{{with "),
    i(1, ".Value"),
    t({ "}}", "    " }),
    i(0),
    t({ "", "{{end}}" }),
  }),
  s("dot", { t("{{ ."), i(1, "Field"), t(" }}") }),
}
