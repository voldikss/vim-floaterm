" vim:fdm=indent
" ========================================================================
" Description: plugin/floaterm.vim
" Author: voldikss
" GitHub: https://github.com/voldikss/vim-floaterm
" ========================================================================

let g:floaterm_type       = get(g:, 'floaterm_type', v:null)
let g:floaterm_width      = get(g:, 'floaterm_width', v:null)
let g:floaterm_height     = get(g:, 'floaterm_height', v:null)
let g:floaterm_winblend   = get(g:, 'floaterm_winblend', 0)
let g:floaterm_position   = get(g:, 'floaterm_position', 'auto')
let g:floaterm_background = get(g:, 'floaterm_background', v:null)

let g:floaterm_keymap_new    = get(g:, 'floaterm_keymap_new', v:null)
let g:floaterm_keymap_prev   = get(g:, 'floaterm_keymap_prev', v:null)
let g:floaterm_keymap_next   = get(g:, 'floaterm_keymap_next', v:null)
let g:floaterm_keymap_toggle = get(g:, 'floaterm_keymap_toggle', v:null)

command! -nargs=0 FloatermToggle call floaterm#doAction('toggle')
command! -nargs=0 FloatermNew    call floaterm#doAction('new')
command! -nargs=0 FloatermPrev   call floaterm#doAction('prev')
command! -nargs=0 FloatermNext   call floaterm#doAction('next')

function! s:installKeymap()
  exe printf('noremap  <silent> %s :FloatermNew<CR>', g:floaterm_keymap_new)
  exe printf('noremap! <silent> %s <Esc>:FloatermNew<CR>', g:floaterm_keymap_new)
  exe printf('tnoremap <silent> %s <C-\><C-n>:FloatermNew<CR>', g:floaterm_keymap_new)
  exe printf('noremap  <silent> %s :FloatermPrev<CR>', g:floaterm_keymap_prev)
  exe printf('noremap! <silent> %s <Esc>:FloatermPrev<CR>', g:floaterm_keymap_prev)
  exe printf('tnoremap <silent> %s <C-\><C-n>:FloatermPrev<CR>', g:floaterm_keymap_prev)
  exe printf('noremap  <silent> %s :FloatermNext<CR>', g:floaterm_keymap_next)
  exe printf('noremap! <silent> %s <Esc>:FloatermNext<CR>', g:floaterm_keymap_next)
  exe printf('tnoremap <silent> %s <C-\><C-n>:FloatermNext<CR>', g:floaterm_keymap_next)
  exe printf('noremap  <silent> %s  :FloatermToggle<CR>', g:floaterm_keymap_toggle)
  exe printf('noremap! <silent> %s  <Esc>:FloatermToggle<CR>', g:floaterm_keymap_toggle)
  exe printf('tnoremap <silent> %s  <C-\><C-n>:FloatermToggle<CR>', g:floaterm_keymap_toggle)
endfunction
call s:installKeymap()
