" vim:fdm=indent
" ========================================================================
" Description: plugin/floaterm.vim
" Author: voldikss
" GitHub: https://github.com/voldikss/vim-floaterm
" ========================================================================

let g:floaterm_type = get(g:, 'floaterm_type', 'floating')
let g:floaterm_width = get(g:, 'floaterm_width', &columns)
let g:floaterm_height = get(g:, 'floaterm_height', winheight(0)/2)

command! -nargs=0 ToggleTerminal call floaterm#toggleTerminal(g:floaterm_height, g:floaterm_width)
