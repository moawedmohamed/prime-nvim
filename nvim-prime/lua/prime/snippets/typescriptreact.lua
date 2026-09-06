local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s("if", { t("if ("), i(1, "cond"), t(") {"), t({ "", "\t" }), i(0), t({ "", "}" }) }),
  s("ise", { t("if ("), i(1, "cond"), t(") {"), t({ "", "\t" }), i(2), t({ "", "} else {" }), t({ "", "\t" }), i(0), t({ "", "}" }) }),
  s("for", { t("for (const "), i(1, "item"), t(" of "), i(2, "list"), t(") {"), t({ "", "\t" }), i(0), t({ "", "}" }) }),
  s("fori", { t("for (let "), i(1, "i"), t(" = 0; "), i(1), t(" < "), i(2, "n"), t("; "), i(1), t("++) {"), t({ "", "\t" }), i(0), t({ "", "}" }) }),
  s("while", { t("while ("), i(1, "cond"), t(") {"), t({ "", "\t" }), i(0), t({ "", "}" }) }),
  s("func", { t("function "), i(1, "name"), t("("), i(2, "args"), t(") {"), t({ "", "\t" }), i(0), t({ "", "}" }) }),
  s("arrow", { t("const "), i(1, "name"), t(" = ("), i(2, "args"), t(") => {"), t({ "", "\t" }), i(0), t({ "", "}" }) }),
  s("class", { t("class "), i(1, "Name"), t(" {"), t({ "", "constructor(" }), i(2, "args"), t(") {"), t({ "", "\t\t" }), i(0), t({ "", "\t}" }), t({ "", "}" }) }),
}