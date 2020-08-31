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

"-----------------------------------------------------------------------------
" compose two string(thank skywind3000/vim-quickui)
"-----------------------------------------------------------------------------
function! floaterm#util#string_compose(target, pos, source)
  if a:source == ''
    return a:target
  endif
  let pos = a:pos
  let source = a:source
  if pos < 0
    let source = strcharpart(a:source, -pos)
    let pos = 0
  endif
  let target = strcharpart(a:target, 0, pos)
  if strchars(target) < pos
    let target .= repeat(' ', pos - strchars(target))
  endif
  let target .= source
  " vim popup will pad the end of title but not begin part
  " so we build the title as ' floaterm idx/cnt'
  " therefore, we need to add a space here
  let target .= ' ' . strcharpart(a:target, pos + strchars(source) + 1)
  return target
endfunction
