; extends

; Highlight HTML markup inside Go text templates (.tmpl/.gotmpl) that
; contain tags. Pure text is left untouched.
((text) @injection.content
  (#match? @injection.content "<[a-zA-Z!/]")
  (#set! injection.language "html"))
