" vim:sw=2:
" ============================================================================
" FileName: plugin/floaterm.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

scriptencoding utf-8

let g:floaterm_wintype       = get(g:, 'floaterm_wintype', v:null)
let g:floaterm_wintitle      = get(g:, 'floaterm_wintitle', v:true)
let g:floaterm_width         = get(g:, 'floaterm_width', v:null)
let g:floaterm_height        = get(g:, 'floaterm_height', v:null)
let g:floaterm_winblend      = get(g:, 'floaterm_winblend', 0)
let g:floaterm_position      = get(g:, 'floaterm_position', 'center')
let g:floaterm_borderchars   = get(g:, 'floaterm_borderchars', ['─', '│', '─', '│', '┌', '┐', '┘', '└'])
let g:floaterm_rootmarkers   = get(g:, 'floaterm_rootmarkers', [])
let g:floaterm_autoinsert    = get(g:, 'floaterm_autoinsert', v:true)
let g:floaterm_open_command  = get(g:, 'floaterm_open_command', 'edit')
let g:floaterm_gitcommit     = get(g:, 'floaterm_gitcommit', v:null)

let g:floaterm_keymap_new    = get(g:, 'floaterm_keymap_new', v:null)
let g:floaterm_keymap_prev   = get(g:, 'floaterm_keymap_prev', v:null)
let g:floaterm_keymap_next   = get(g:, 'floaterm_keymap_next', v:null)
let g:floaterm_keymap_toggle = get(g:, 'floaterm_keymap_toggle', v:null)

command! -nargs=0           FloatermPrev   call floaterm#prev()
command! -nargs=0           FloatermNext   call floaterm#next()
command! -nargs=* -complete=customlist,floaterm#cmdline#complete
                          \ FloatermNew    call floaterm#new(<f-args>)
command! -nargs=* -complete=customlist,floaterm#cmdline#complete
                          \ FloatermUpdate call floaterm#update(<f-args>)
command! -nargs=? -complete=customlist,floaterm#cmdline#floaterm_names
                          \ FloatermToggle call floaterm#toggle(<f-args>)
command! -nargs=? -range -bang -complete=customlist,floaterm#cmdline#floaterm_names
                          \ FloatermSend   call floaterm#send('<bang>', <line1>, <line2>, <f-args>)

hi def link Floaterm       Normal
hi def link FloatermBorder Normal

function! s:install_keymap()
  if g:floaterm_keymap_new != v:null
    exe printf('nnoremap  <silent> %s :FloatermNew<CR>', g:floaterm_keymap_new)
    exe printf('tnoremap <silent> %s <C-\><C-n>:FloatermNew<CR>', g:floaterm_keymap_new)
  endif
  if g:floaterm_keymap_prev != v:null
    exe printf('nnoremap  <silent> %s :FloatermPrev<CR>', g:floaterm_keymap_prev)
    exe printf('tnoremap <silent> %s <C-\><C-n>:FloatermPrev<CR>', g:floaterm_keymap_prev)
  endif
  if g:floaterm_keymap_next != v:null
    exe printf('nnoremap  <silent> %s :FloatermNext<CR>', g:floaterm_keymap_next)
    exe printf('tnoremap <silent> %s <C-\><C-n>:FloatermNext<CR>', g:floaterm_keymap_next)
  endif
  if g:floaterm_keymap_toggle != v:null
    exe printf('nnoremap  <silent> %s :FloatermToggle<CR>', g:floaterm_keymap_toggle)
    exe printf('tnoremap <silent> %s <C-\><C-n>:FloatermToggle<CR>', g:floaterm_keymap_toggle)
  endif
endfunction
call s:install_keymap()
