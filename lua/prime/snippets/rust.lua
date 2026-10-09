local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s("if", { t("if "), i(1, "cond"), t(" {"), t({ "", "\t" }), i(0), t({ "", "}" }) }),
  s("ise", { t("if "), i(1, "cond"), t(" {"), t({ "", "\t" }), i(2), t({ "", "} else {" }), t({ "", "\t" }), i(0), t({ "", "}" }) }),
  s("for", { t("for "), i(1, "item"), t(" in "), i(2, "iter"), t(" {"), t({ "", "\t" }), i(0), t({ "", "}" }) }),
  s("fori", { t("for "), i(1, "i"), t(" in 0.."), i(2, "n"), t(" {"), t({ "", "\t" }), i(0), t({ "", "}" }) }),
  s("while", { t("while "), i(1, "cond"), t(" {"), t({ "", "\t" }), i(0), t({ "", "}" }) }),
  s("fn", { t("fn "), i(1, "name"), t("("), i(2, "args"), t(") -> "), i(3, "Ret"), t(" {"), t({ "", "\t" }), i(0), t({ "", "}" }) }),
  s("match", { t("match "), i(1, "expr"), t(" {"), t({ "", "\t" }), i(2, "Pat"), t(" => "), i(0), t(","), t({ "", "}" }) }),
}