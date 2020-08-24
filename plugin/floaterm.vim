" vim:sw=2:
" ============================================================================
" FileName: plugin/floaterm.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

scriptencoding utf-8

let g:floaterm_shell         = get(g:, 'floaterm_shell', &shell)
let g:floaterm_width         = get(g:, 'floaterm_width', 0.6)
let g:floaterm_height        = get(g:, 'floaterm_height', 0.6)
let g:floaterm_wintype       = get(g:, 'floaterm_wintype', '')
let g:floaterm_wintitle      = get(g:, 'floaterm_wintitle', v:true)
let g:floaterm_winblend      = get(g:, 'floaterm_winblend', 0)
let g:floaterm_autoclose     = get(g:, 'floaterm_autoclose', 0)
let g:floaterm_autoinsert    = get(g:, 'floaterm_autoinsert', v:true)
let g:floaterm_autohide      = get(g:, 'floaterm_autohide', v:true)
let g:floaterm_position      = get(g:, 'floaterm_position', 'center')
let g:floaterm_borderchars   = get(g:, 'floaterm_borderchars', ['─', '│', '─', '│', '┌', '┐', '┘', '└'])
let g:floaterm_rootmarkers   = get(g:, 'floaterm_rootmarkers', [])
let g:floaterm_open_command  = get(g:, 'floaterm_open_command', 'edit')
let g:floaterm_gitcommit     = get(g:, 'floaterm_gitcommit', '')

let g:floaterm_keymap_new    = get(g:, 'floaterm_keymap_new', '')
let g:floaterm_keymap_prev   = get(g:, 'floaterm_keymap_prev', '')
let g:floaterm_keymap_next   = get(g:, 'floaterm_keymap_next', '')
let g:floaterm_keymap_hide   = get(g:, 'floaterm_keymap_hide', '')
let g:floaterm_keymap_show   = get(g:, 'floaterm_keymap_show', '')
let g:floaterm_keymap_kill   = get(g:, 'floaterm_keymap_kill', '')
let g:floaterm_keymap_toggle = get(g:, 'floaterm_keymap_toggle', '')

command! -nargs=* -complete=customlist,floaterm#cmdline#complete -bang
                          \ FloatermNew    call floaterm#run('new', <bang>0, <f-args>)
command! -nargs=* -complete=customlist,floaterm#cmdline#complete
                          \ FloatermUpdate call floaterm#run('update', 0, <f-args>)
command! -nargs=? -bang -complete=customlist,floaterm#cmdline#floaterm_names
                          \ FloatermShow   call floaterm#show(<bang>0, <q-args>)
command! -nargs=? -bang -complete=customlist,floaterm#cmdline#floaterm_names
                          \ FloatermHide   call floaterm#hide(<bang>0, <q-args>)
command! -nargs=? -bang -complete=customlist,floaterm#cmdline#floaterm_names
                          \ FloatermKill   call floaterm#kill(<bang>0, <q-args>)
command! -nargs=? -bang -complete=customlist,floaterm#cmdline#floaterm_names
                          \ FloatermToggle call floaterm#toggle(<bang>0, <q-args>)
command! -nargs=? -range -bang -complete=customlist,floaterm#cmdline#floaterm_names2
                          \ FloatermSend   call floaterm#send(<bang>0, visualmode(), <range>, <line1>, <line2>, <q-args>)
command! -nargs=0           FloatermPrev   call floaterm#prev()
command! -nargs=0           FloatermNext   call floaterm#next()

hi def link Floaterm       Normal
hi def link FloatermNC     Floaterm
hi def link FloatermBorder Floaterm

augroup floaterm_enter_insertmode
  autocmd!
  autocmd BufEnter * if &ft == 'floaterm' | call floaterm#util#startinsert() | endif
  autocmd FileType floaterm call floaterm#util#startinsert()
augroup END

function! s:install_keymap()
  if !empty(g:floaterm_keymap_new)
    exe printf('nnoremap  <silent> %s :FloatermNew<CR>', g:floaterm_keymap_new)
    exe printf('tnoremap <silent> %s <C-\><C-n>:FloatermNew<CR>', g:floaterm_keymap_new)
  endif
  if !empty(g:floaterm_keymap_prev)
    exe printf('nnoremap  <silent> %s :FloatermPrev<CR>', g:floaterm_keymap_prev)
    exe printf('tnoremap <silent> %s <C-\><C-n>:FloatermPrev<CR>', g:floaterm_keymap_prev)
  endif
  if !empty(g:floaterm_keymap_next)
    exe printf('nnoremap  <silent> %s :FloatermNext<CR>', g:floaterm_keymap_next)
    exe printf('tnoremap <silent> %s <C-\><C-n>:FloatermNext<CR>', g:floaterm_keymap_next)
  endif
  if !empty(g:floaterm_keymap_hide)
    exe printf('nnoremap  <silent> %s :FloatermHide<CR>', g:floaterm_keymap_hide)
    exe printf('tnoremap <silent> %s <C-\><C-n>:FloatermHide<CR>', g:floaterm_keymap_hide)
  endif
  if !empty(g:floaterm_keymap_show)
    exe printf('nnoremap  <silent> %s :FloatermShow<CR>', g:floaterm_keymap_show)
    exe printf('tnoremap <silent> %s <C-\><C-n>:FloatermShow<CR>', g:floaterm_keymap_show)
  endif
  if !empty(g:floaterm_keymap_kill)
    exe printf('nnoremap  <silent> %s :FloatermKill<CR>', g:floaterm_keymap_kill)
    exe printf('tnoremap <silent> %s <C-\><C-n>:FloatermKill<CR>', g:floaterm_keymap_kill)
  endif
  if !empty(g:floaterm_keymap_toggle)
    exe printf('nnoremap  <silent> %s :FloatermToggle<CR>', g:floaterm_keymap_toggle)
    exe printf('tnoremap <silent> %s <C-\><C-n>:FloatermToggle<CR>', g:floaterm_keymap_toggle)
  endif
endfunction
call s:install_keymap()
