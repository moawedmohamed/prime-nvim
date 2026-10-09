local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s("if", { t("if "), i(1, "cond"), t(" {"), t({ "", "\t" }), i(0), t({ "", "}" }) }),
  s("ise", { t("if "), i(1, "cond"), t(" {"), t({ "", "\t" }), i(2), t({ "", "} else {" }), t({ "", "\t" }), i(0), t({ "", "}" }) }),
  s("for", { t("for _, "), i(1, "v"), t(" := range "), i(2, "xs"), t(" {"), t({ "", "\t" }), i(0), t({ "", "}" }) }),
  s("fori", { t("for "), i(1, "i"), t(" := 0; "), i(1), t(" < "), i(2, "n"), t("; "), i(1), t("++ {"), t({ "", "\t" }), i(0), t({ "", "}" }) }),
  s("func", { t("func "), i(1, "Name"), t("("), i(2, "args"), t(") "), i(3, "type"), t(" {"), t({ "", "\t" }), i(0), t({ "", "}" }) }),
  s("struct", { t("type "), i(1, "Name"), t(" struct {"), t({ "", "\t" }), i(2, "Field"), t(" "), i(3, "type"), t({ "", "}" }) }),
}