" vim:sw=2:
" ============================================================================
" FileName: plugin/floaterm.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

if exists('g:loaded_floaterm')
  finish
endif
let g:loaded_floaterm = 1

let g:floaterm_shell            = get(g:, 'floaterm_shell', &shell)
let g:floaterm_title            = get(g:, 'floaterm_title', 'floaterm($1/$2)')
let g:floaterm_width            = get(g:, 'floaterm_width', 0.6)
let g:floaterm_height           = get(g:, 'floaterm_height', 0.6)
let g:floaterm_wintype          = get(g:, 'floaterm_wintype', '')
let g:floaterm_autoclose        = get(g:, 'floaterm_autoclose', 0)
let g:floaterm_autoinsert       = get(g:, 'floaterm_autoinsert', v:true)
let g:floaterm_autohide         = get(g:, 'floaterm_autohide', v:true)
let g:floaterm_position         = get(g:, 'floaterm_position', 'center')
let g:floaterm_borderchars      = get(g:, 'floaterm_borderchars', ['─', '│', '─', '│', '┌', '┐', '┘', '└'])
let g:floaterm_rootmarkers      = get(g:, 'floaterm_rootmarkers', [])
let g:floaterm_open_command     = get(g:, 'floaterm_open_command', 'edit')
let g:floaterm_gitcommit        = get(g:, 'floaterm_gitcommit', '')
let g:floaterm_complete_options = get(g:, 'floaterm_complete_options', {'shortcut': 'floaterm', 'priority': 5, 'filter_length': [5, 20]})

let g:floaterm_keymap_new    = get(g:, 'floaterm_keymap_new', '')
let g:floaterm_keymap_prev   = get(g:, 'floaterm_keymap_prev', '')
let g:floaterm_keymap_next   = get(g:, 'floaterm_keymap_next', '')
let g:floaterm_keymap_first  = get(g:, 'floaterm_keymap_first', '')
let g:floaterm_keymap_last   = get(g:, 'floaterm_keymap_last', '')
let g:floaterm_keymap_hide   = get(g:, 'floaterm_keymap_hide', '')
let g:floaterm_keymap_show   = get(g:, 'floaterm_keymap_show', '')
let g:floaterm_keymap_kill   = get(g:, 'floaterm_keymap_kill', '')
let g:floaterm_keymap_toggle = get(g:, 'floaterm_keymap_toggle', '')

command! -nargs=* -bang -complete=customlist,floaterm#cmdline#complete
                          \ FloatermNew    call floaterm#run('new', <bang>0, <f-args>)
command! -nargs=*       -complete=customlist,floaterm#cmdline#complete
                          \ FloatermUpdate call floaterm#run('update', 0, <f-args>)
command! -nargs=? -range=0 -bang -complete=customlist,floaterm#cmdline#complete_names1
                          \ FloatermShow   call floaterm#show(<bang>0, <count>, <q-args>)
command! -nargs=? -range=0 -bang -complete=customlist,floaterm#cmdline#complete_names1
                          \ FloatermHide   call floaterm#hide(<bang>0, <count>, <q-args>)
command! -nargs=? -range=0 -bang -complete=customlist,floaterm#cmdline#complete_names1
                          \ FloatermKill   call floaterm#kill(<bang>0, <count>, <q-args>)
command! -nargs=? -range=0 -bang -complete=customlist,floaterm#cmdline#complete_names1
                          \ FloatermToggle call floaterm#toggle(<bang>0, <count>, <q-args>)
command! -nargs=? -range   -bang -complete=customlist,floaterm#cmdline#complete_names2
                          \ FloatermSend   call floaterm#send(<bang>0, visualmode(), <range>, <line1>, <line2>, <q-args>)
command! -nargs=0           FloatermPrev   call floaterm#prev()
command! -nargs=0           FloatermNext   call floaterm#next()
command! -nargs=0           FloatermFirst  call floaterm#first()
command! -nargs=0           FloatermLast   call floaterm#last()

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
    exe printf('nnoremap <silent> %s :FloatermNew<CR>', g:floaterm_keymap_new)
    exe printf('tnoremap <silent> %s <C-\><C-n>:FloatermNew<CR>', g:floaterm_keymap_new)
  endif
  if !empty(g:floaterm_keymap_prev)
    exe printf('nnoremap <silent> %s :FloatermPrev<CR>', g:floaterm_keymap_prev)
    exe printf('tnoremap <silent> %s <C-\><C-n>:FloatermPrev<CR>', g:floaterm_keymap_prev)
  endif
  if !empty(g:floaterm_keymap_next)
    exe printf('nnoremap <silent> %s :FloatermNext<CR>', g:floaterm_keymap_next)
    exe printf('tnoremap <silent> %s <C-\><C-n>:FloatermNext<CR>', g:floaterm_keymap_next)
  endif
  if !empty(g:floaterm_keymap_first)
    exe printf('nnoremap <silent> %s :FloatermFirst<CR>', g:floaterm_keymap_first)
    exe printf('tnoremap <silent> %s <C-\><C-n>:FloatermFirst<CR>', g:floaterm_keymap_first)
  endif
  if !empty(g:floaterm_keymap_last)
    exe printf('nnoremap <silent> %s :FloatermLast<CR>', g:floaterm_keymap_last)
    exe printf('tnoremap <silent> %s <C-\><C-n>:FloatermLast<CR>', g:floaterm_keymap_last)
  endif
  if !empty(g:floaterm_keymap_hide)
    exe printf('nnoremap <silent> %s :FloatermHide<CR>', g:floaterm_keymap_hide)
    exe printf('tnoremap <silent> %s <C-\><C-n>:FloatermHide<CR>', g:floaterm_keymap_hide)
  endif
  if !empty(g:floaterm_keymap_show)
    exe printf('nnoremap <silent> %s :FloatermShow<CR>', g:floaterm_keymap_show)
    exe printf('tnoremap <silent> %s <C-\><C-n>:FloatermShow<CR>', g:floaterm_keymap_show)
  endif
  if !empty(g:floaterm_keymap_kill)
    exe printf('nnoremap <silent> %s :FloatermKill<CR>', g:floaterm_keymap_kill)
    exe printf('tnoremap <silent> %s <C-\><C-n>:FloatermKill<CR>', g:floaterm_keymap_kill)
  endif
  if !empty(g:floaterm_keymap_toggle)
    exe printf('nnoremap <silent> %s :FloatermToggle<CR>', g:floaterm_keymap_toggle)
    exe printf('tnoremap <silent> %s <C-\><C-n>:FloatermToggle<CR>', g:floaterm_keymap_toggle)
  endif
endfunction
call s:install_keymap()
