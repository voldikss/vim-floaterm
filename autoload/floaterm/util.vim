" vim:sw=2:
" ============================================================================
" FileName: autoload/floaterm/util.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! s:echohl(group, msg) abort
  execute 'echohl ' . a:group
  echom '[vim-floaterm] ' . a:msg
  echohl None
endfunction

function! floaterm#util#show_msg(message, ...) abort
  if a:0 == 0
    let msgtype = 'info'
  else
    let msgtype = a:1
  endif

  if type(a:message) != v:t_string
    let message = string(a:message)
  else
    let message = a:message
  endif

  if msgtype ==# 'info'
    call s:echohl('MoreMsg', message)
  elseif msgtype ==# 'warning'
    call s:echohl('WarningMsg', message)
  elseif msgtype ==# 'error'
    call s:echohl('ErrorMsg', message)
  endif
endfunction

" >>> floaterm test.txt
function! floaterm#util#edit_by_floaterm(_bufnr, filename) abort
  call floaterm#hide(1, 0, '')
  silent execute g:floaterm_open_command . ' ' . a:filename
endfunction

" >>> $EDITOR test.txt
function! floaterm#util#edit_by_editor(bufnr, filename) abort
  call floaterm#edita#vim#editor#open(a:filename, a:bufnr)
endfunction

function! floaterm#util#open(cmd, locations) abort
  execute a:cmd a:locations[0].filename
  for loc in a:locations
    execute 'edit ' loc.filename
    if has_key(loc, 'lnum')
      execute loc.lnum
    elseif has_key(loc, 'text')
      execute '/' . loc.text
    endif
    normal! zz
  endfor
endfunction

function! floaterm#util#startinsert() abort
  if &ft != 'floaterm'
    return
  endif
  if !g:floaterm_autoinsert 
    call feedkeys("\<C-\>\<C-n>", 'n')
  elseif mode() != 'i'
    if has('nvim')
      startinsert
    else
      silent! execute 'normal! i'
    endif
  endif
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

function! floaterm#util#use_sh_or_cmd() abort
  let [shell, shellslash, shellcmdflag, shellxquote] = [&shell, &shellslash, &shellcmdflag, &shellxquote]
  if has('win32')
    set shell=cmd.exe
    set noshellslash
    let &shellcmdflag = has('nvim') ? '/s /c' : '/c'
    let &shellxquote = has('nvim') ? '"' : '('
  else
    set shell=sh
  endif
  return [shell, shellslash, shellcmdflag, shellxquote]
endfunction
