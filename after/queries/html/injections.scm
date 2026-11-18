; extends

; Highlight Go template actions ({{ ... }}) inside HTML files using the
; gotmpl parser. The HTML treesitter parser treats these actions as text.
((text) @injection.content
  (#match? @injection.content "\\{\\{")
  (#set! injection.language "gotmpl"))
