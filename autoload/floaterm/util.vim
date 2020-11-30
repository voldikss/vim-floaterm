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

function! floaterm#util#getbufline(bufnr, length) abort
  let lines = []
  if a:bufnr == -1
    for bufnr in floaterm#buflist#gather()
      let lnum = getbufinfo(bufnr)[0]['lnum']
      let lines += getbufline(bufnr, max([lnum - a:length, 0]), '$')
    endfor
  else
    let lnum = getbufinfo(a:bufnr)[0]['lnum']
    let lines += getbufline(a:bufnr, max([lnum - a:length, 0]), '$')
  endif
  return lines
endfunction

function! floaterm#util#get_selected_text(visualmode, range, line1, line2) abort
  if a:range == 0
    let lines = [getline('.')]
  elseif a:range == 1
    let lines = [getline(a:line1)]
  else
    let [lnum1, col1] = getpos("'<")[1:2]
    let [lnum2, col2] = getpos("'>")[1:2]
    if lnum1 == 0 || col1 == 0 || lnum2 == 0 || col2 == 0
      let lines = getline(a:line1, a:line2)
    else
      let lines = getline(lnum1, lnum2)
      if !empty(lines)
        if a:visualmode ==# 'v'
          let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
          let lines[0] = lines[0][col1 - 1:]
        elseif a:visualmode ==# 'V'
        elseif a:visualmode == "\<c-v>"
          let i = 0
          for line in lines
            let lines[i] = line[col1 - 1: col2 - (&selection == 'inclusive' ? 1 : 2)]
            let i = i + 1
          endfor
        endif
      endif
    endif
  endif
  return lines
endfunction

function! floaterm#util#leftalign_lines(lines) abort
  let linelist = []
  let line1 = a:lines[0]
  let trim_line = substitute(line1, '\v^\s+', '', '')
  let indent = len(line1) - len(trim_line)
  for line in a:lines
    if line[:indent] =~# '\s\+'
      let line = line[indent:]
    endif
    call add(linelist, line)
  endfor
  return linelist
endfunction
