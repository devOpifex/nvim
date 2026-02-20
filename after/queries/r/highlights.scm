;extends

((comment) @keyword.directive
  (#lua-match? @keyword.directive "^#>")
  (#set! priority 101))
