local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s("if", { t("if "), i(1, "cond"), t(" then"), t({ "", "\t" }), i(0), t({ "", "end" }) }),
  s("ise", { t("if "), i(1, "cond"), t(" then"), t({ "", "\t" }), i(2), t({ "", "else" }), t({ "", "\t" }), i(0), t({ "", "end" }) }),
  s("for", { t("for "), i(1, "i"), t(" = 1, "), i(2, "n"), t(" do"), t({ "", "\t" }), i(0), t({ "", "end" }) }),
  s("forg", { t("for "), i(1, "k"), t(", "), i(2, "v"), t(" in pairs("), i(3, "t"), t(") do"), t({ "", "\t" }), i(0), t({ "", "end" }) }),
  s("while", { t("while "), i(1, "cond"), t(" do"), t({ "", "\t" }), i(0), t({ "", "end" }) }),
  s("function", { t("local function "), i(1, "name"), t("("), i(2, "args"), t(")"), t({ "", "\t" }), i(0), t({ "", "end" }) }),
  s("fn", { t("local "), i(1, "v"), t(" = function("), i(2, "args"), t(")"), t({ "", "\t" }), i(0), t({ "", "end" }) }),
}