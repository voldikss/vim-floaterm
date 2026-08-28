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
  let loc = a:locations[0]
  execute opener loc.filename
  if has_key(loc, 'lnum')
    execute loc.lnum
  elseif has_key(loc, 'text')
    execute '/' . loc.text
  endif
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

function! s:enter_insert() abort
  if mode() !~# '[it]'
    if has('nvim')
      startinsert
    else
      silent! execute 'normal! i'
    endif
  endif
endfunction

" The value of `g:floaterm_autoinsert` (or the per-floaterm `autoinsert`
" config) is guaranteed to be one of 'always', 'never' and 'smart' since it
" is normalized in plugin/floaterm.vim
function! floaterm#util#startinsert() abort
  if &ft != 'floaterm'
    return
  endif
  let bufnr = bufnr('%')
  let autoinsert = floaterm#config#get(bufnr, 'autoinsert', g:floaterm_autoinsert)
  if autoinsert ==# 'always'
    let enter_insert = 1
  elseif autoinsert ==# 'never'
    let enter_insert = 0
  else " smart: `cursorline` is unset on the first open; afterwards it is the
    " position recorded when the floaterm was left or hidden (see
    " floaterm#window#record_cursor()) — if the cursor was at or beyond the
    " last non-blank line, the user was probably at the shell prompt
    let curlnum = floaterm#config#get(bufnr, 'cursorline', -1)
    let enter_insert = curlnum < 0 || curlnum >= prevnonblank(line('$'))
  endif
  if enter_insert
    call s:enter_insert()
  else
    call feedkeys("\<C-\>\<C-n>", 'n')
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
    " The visual marks are only meaningful when they match the range given on
    " the command line; otherwise the range was typed explicitly (e.g.
    " `:2,3FloatermSend`) and the stale marks of an earlier selection must be
    " ignored
    if lnum1 == 0 || col1 == 0 || lnum2 == 0 || col2 == 0
          \ || a:line1 != lnum1 || a:line2 != lnum2
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

" Return the directory of the current buffer for use by the file-manager
" wrappers. Falls back to the current working directory when the buffer has no
" file name (e.g. an unnamed scratch buffer) or its parent is not accessible,
" so that `lcd %:p:h` never throws and aborts the wrapper (#293, #383).
function! floaterm#util#bufdir() abort
  let path = expand('%:p:h')
  if empty(path) || !isdirectory(path)
    return getcwd()
  endif
  return path
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

" Environment variables set to the floaterm editor when
" `g:floaterm_giteditor` is enabled.
let s:editor_env_names = ['GIT_EDITOR', 'HGEDITOR', 'JJ_EDITOR']
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
  if g:floaterm_giteditor
    for name in s:editor_env_names
      let env[name] = editor
    endfor
  endif
  return env
endfunction

function! floaterm#util#vim_version() abort
  if !has('nvim')
    return ['vim', string(v:version)]
  endif
  let c = execute('silent version')
  let lines = split(matchstr(c,  'NVIM v\zs[^\n-]*'))
  return ['nvim', lines[0]]
endfunction
