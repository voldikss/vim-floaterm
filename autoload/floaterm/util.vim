" vim:sw=2:
" ============================================================================
" FileName: autoload/floaterm/util.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! s:echo(group, msg) abort
  if a:msg ==# '' | return | endif
  execute 'echohl' a:group
  echo a:msg
  echon ' '
  echohl NONE
endfunction

function! s:echon(group, msg) abort
  if a:msg ==# '' | return | endif
  execute 'echohl' a:group
  echon a:msg
  echon ' '
  echohl NONE
endfunction

function! floaterm#util#show_msg(message, ...) abort
  if a:0 == 0
    let msg_type = 'info'
  else
    let msg_type = a:1
  endif

  if type(a:message) != 1
    let message = string(a:message)
  else
    let message = a:message
  endif

  call s:echo('Constant', '[vim-floaterm]')

  if msg_type ==# 'info'
    call s:echon('Normal', message)
  elseif msg_type ==# 'warning'
    call s:echon('WarningMsg', message)
  elseif msg_type ==# 'error'
    call s:echon('Error', message)
  endif
endfunction

function! floaterm#util#edit(_bufnr, filename) abort
  call floaterm#hide(1, 0, '')
  silent execute g:floaterm_open_command . ' ' . a:filename
endfunction

function! floaterm#util#startinsert() abort
  if !g:floaterm_autoinsert | return | endif
  if mode() == 'i' | return | endif
  if has('nvim')
    startinsert
  else
    silent! execute 'normal! i'
  endif
endfunction

function! floaterm#util#autohide() abort
  " hide all floaterms before opening a new floaterm
  if g:floaterm_autohide
    call floaterm#hide(1, 0, '')
  endif
endfunction

function! floaterm#util#update_opts(bufnr, opts) abort
  let opts = getbufvar(a:bufnr, 'floaterm_opts', {})
  for item in items(a:opts)
    let opts[item[0]] = item[1]
  endfor
  call setbufvar(a:bufnr, 'floaterm_opts', opts)
endfunction
