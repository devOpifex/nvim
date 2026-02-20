" R preprocessor directives
syntax match rPreprocessor /#>\s\+\S.*/ containedin=rComment
highlight rPreprocessor guifg=#7A7A7A gui=bold ctermfg=243 cterm=bold
