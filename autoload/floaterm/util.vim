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

" - locations: List of location, which is a Dictionary:
"   - filename: String
"   - lnum[optional]: Number, used to locate
"   - text[optional]: String, search `/` content, used to locate
" - a:0: String, opening action, default `g:floaterm_opener`
function! floaterm#util#open(locations, ...) abort
  let opener = get(a:000, 0, g:floaterm_opener)
  execute opener a:locations[0].filename
  for loc in a:locations[1:]
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

function! floaterm#util#deep_extend(dict1, dict2) abort
  for key in keys(a:dict2)
    if has_key(a:dict1, key)
      if type(a:dict1[key]) == v:t_dict
        call floaterm#util#deep_extend(a:dict1[key], a:dict2[key])
      else
        let a:dict1[key] = a:dict2[key]
      endif
    else
      let a:dict1[key] = a:dict2[key]
    endif
  endfor
endfunction

let s:home = fnamemodify(resolve(expand('<sfile>:p')), ':h:h')
let s:binpath = fnamemodify(s:home . '/../bin', ':p')
function! floaterm#util#setenv() abort
  let env = {}
  " bin/floaterm.cmd
  if has('win32') && !has('nvim')
    let env.VIM_SERVERNAME = v:servername
    let env.VIM_EXE = v:progpath
  endif
  if has('win32') == 0
    let env.PATH = $PATH . ':' . s:binpath
  else
    let env.PATH = $PATH . ';' . s:binpath
  endif
  let editor = floaterm#edita#setup#EDITOR()
  let env.FLOATERM = editor
  let env.GIT_EDITOR = editor
  return env
endfunction

function! floaterm#util#vim_version() abort
  if !has('nvim')
    return ['vim', string(v:versionlong)]
  endif
  let c = execute('silent version')
  let lines = split(matchstr(c,  'NVIM v\zs[^\n-]*'))
  return ['nvim', lines[0]]
endfunction
