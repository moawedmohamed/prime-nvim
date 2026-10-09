local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s("if", { t("if ("), i(1, "cond"), t(") {"), t({ "", "\t" }), i(0), t({ "", "}" }) }),
  s("ise", { t("if ("), i(1, "cond"), t(") {"), t({ "", "\t" }), i(2), t({ "", "} else {" }), t({ "", "\t" }), i(0), t({ "", "}" }) }),
  s("for", { t("for (int "), i(1, "i"), t(" = 0; "), i(1), t(" < "), i(2, "n"), t("; "), i(1), t("++) {"), t({ "", "\t" }), i(0), t({ "", "}" }) }),
  s("while", { t("while ("), i(1, "cond"), t(") {"), t({ "", "\t" }), i(0), t({ "", "}" }) }),
  s("struct", { t("typedef struct {"), t({ "", "\t" }), i(1, "type"), t(" "), i(2, "field"), t(";"), t({ "", "} " }), i(3, "Name"), t(";") }),
  s("main", { t("int main() {"), t({ "", "\t" }), i(0, "return 0;"), t({ "", "}" }) }),
}