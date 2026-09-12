; ~/.config/nvim/queries/python/injections.scm

; Inject markdown into triple-quoted strings that are used as statements
(expression_statement
  (string) @injection.content
  (#set! injection.language "markdown"))
