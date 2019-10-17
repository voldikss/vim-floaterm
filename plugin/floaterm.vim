" vim:fdm=indent
" ========================================================================
" Description: plugin/floaterm.vim
" Author: voldikss
" GitHub: https://github.com/voldikss/vim-floaterm
" ========================================================================

let g:floaterm_type = get(g:, 'floaterm_type', 'floating')
let g:floaterm_width = get(g:, 'floaterm_width', v:null)
let g:floaterm_height = get(g:, 'floaterm_height', v:null)
let g:floaterm_winblend = get(g:, 'floaterm_winblend', 0)
let g:floaterm_position = get(g:, 'floaterm_position', 'auto')
let g:floaterm_background = get(g:, 'floaterm_background', v:null)

command! -nargs=0 FloatermToggle call floaterm#toggleTerminal(g:floaterm_height, g:floaterm_width)
