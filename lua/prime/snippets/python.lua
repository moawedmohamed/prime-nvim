local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s("if", { t("if "), i(1, "cond"), t(":"), t({ "", "\t" }), i(0, "pass") }),
  s("ise", { t("if "), i(1, "cond"), t(":"), t({ "", "\t" }), i(2, "pass"), t({ "", "else:" }), t({ "", "\t" }), i(0, "pass") }),
  s("for", { t("for "), i(1, "item"), t(" in "), i(2, "items"), t(":"), t({ "", "\t" }), i(0, "pass") }),
  s("fori", { t("for "), i(1, "i"), t(" in range("), i(2, "n"), t("):"), t({ "", "\t" }), i(0, "pass") }),
  s("while", { t("while "), i(1, "cond"), t(":"), t({ "", "\t" }), i(0, "pass") }),
  s("def", { t("def "), i(1, "name"), t("("), i(2, "args"), t("):"), t({ "", "\t" }), i(0, "pass") }),
  s("class", { t("class "), i(1, "Name"), t(":"), t({ "", "def __init__(self, " }), i(2, "args"), t("):"), t({ "", "\t\t" }), i(0, "pass") }),
}