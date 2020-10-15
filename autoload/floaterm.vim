" vim:sw=2:
" ============================================================================
" FileName: floaterm.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

"-----------------------------------------------------------------------------
" script level variables and environment variables
"-----------------------------------------------------------------------------
let $VIM_SERVERNAME = v:servername
let $VIM_EXE = v:progpath

let s:home = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let s:script = fnamemodify(s:home . '/../bin', ':p')
let s:windows = has('win32') || has('win64')

if stridx($PATH, s:script) < 0
  if s:windows == 0
    let $PATH .= ':' . s:script
  else
    let $PATH .= ';' . s:script
  endif
endif

if !empty(g:floaterm_gitcommit)
  autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete
  if g:floaterm_gitcommit == 'floaterm'
    let $GIT_EDITOR = 'nvr --remote-wait'
  else
    let $GIT_EDITOR = printf(
      \ 'nvr -cc "call floaterm#hide(1, 0, \"\") | %s" --remote-wait',
      \ g:floaterm_gitcommit
      \ )
  endif
endif

" ----------------------------------------------------------------------------
" wrapper function for `floaterm#new()` and `floaterm#update()` since they
" share the same argument: `opts`
" ----------------------------------------------------------------------------
function! floaterm#run(action, bang, ...) abort
  let [cmd, opts] = floaterm#cmdline#parse(a:000)
  if a:action == 'new'
    call floaterm#new(a:bang, cmd, {}, opts)
  elseif a:action == 'update'
    call floaterm#update(opts)
  endif
endfunction

" ----------------------------------------------------------------------------
" create a floaterm. `jobopts` is not used inside this pugin actually, it's
" reserved for outer invoke
" ----------------------------------------------------------------------------
function! floaterm#new(bang, cmd, jobopts, opts) abort
  call floaterm#util#autohide()
  if a:cmd != ''
    let wrappers_path = globpath(&runtimepath, 'autoload/floaterm/wrapper/*vim', 0, 1)
    let wrappers = map(wrappers_path, "substitute(fnamemodify(v:val, ':t'), '\\..\\{-}$', '', '')")
    let maybe_wrapper = split(a:cmd, '\s')[0]
    if index(wrappers, maybe_wrapper) >= 0
      let WrapFunc = function(printf('floaterm#wrapper#%s#', maybe_wrapper))
      let [name, jobopts, send2shell] = WrapFunc(a:cmd)
      if send2shell
        let bufnr = floaterm#terminal#open(-1, g:floaterm_shell, {}, a:opts)
        call floaterm#terminal#send(bufnr, [name])
      else
        let bufnr = floaterm#terminal#open(-1, name, jobopts, a:opts)
      endif
    elseif a:bang
      let bufnr = floaterm#terminal#open(-1, g:floaterm_shell, a:jobopts, a:opts)
      call floaterm#terminal#send(bufnr, [a:cmd])
    else
      let bufnr = floaterm#terminal#open(-1, a:cmd, a:jobopts, a:opts)
    endif
  else
    let bufnr = floaterm#terminal#open(-1, g:floaterm_shell, a:jobopts, a:opts)
  endif
  return bufnr
endfunction

" ----------------------------------------------------------------------------
" toggle on/off the floaterm named `name`
" ----------------------------------------------------------------------------
function! floaterm#toggle(bang, bufnr, name)  abort
  if a:bang
    let found_winnr = floaterm#window#find_floaterm_window()
    if found_winnr > 0
      for bufnr in floaterm#buflist#gather()
        call floaterm#window#hide_floaterm(bufnr)
      endfor
    else
      for bufnr in floaterm#buflist#gather()
        call floaterm#terminal#open_existing(bufnr)
      endfor
    endif
    return
  endif

  let bufnr = a:bufnr
  if bufnr == 0 && !empty(a:name)
    let bufnr = floaterm#terminal#get_bufnr(a:name)
  endif

  if bufnr == -1
    call floaterm#new(a:bang, '', {}, {'name': a:name})
  elseif bufnr == 0
    if &filetype == 'floaterm'
      call floaterm#window#hide_floaterm(bufnr('%'))
    else
      let found_winnr = floaterm#window#find_floaterm_window()
      if found_winnr > 0
        noautocmd execute found_winnr . 'wincmd w'
      else
        call floaterm#curr()
      endif
    endif
  elseif getbufvar(bufnr, 'floaterm_winid', -1) != -1
    if bufnr == bufnr('%')
      call floaterm#window#hide_floaterm(bufnr)
    elseif bufwinnr(bufnr) > -1
      noautocmd execute bufwinnr(bufnr) . 'wincmd w'
    else
      call floaterm#terminal#open_existing(bufnr)
    endif
  else
    call floaterm#util#show_msg('No floaterms with the bufnr or name', 'error')
  endif
endfunction

" ----------------------------------------------------------------------------
" update the attributes of a floaterm
" ----------------------------------------------------------------------------
function! floaterm#update(opts) abort
  if &filetype !=# 'floaterm'
    call floaterm#util#show_msg('You have to be in a floaterm window to change window opts.', 'error')
    return
  endif

  let bufnr = bufnr('%')
  call floaterm#window#hide_floaterm(bufnr)
  call floaterm#util#update_opts(bufnr, a:opts)
  call floaterm#terminal#open_existing(bufnr)
endfunction

function! floaterm#next()  abort
  let next_bufnr = floaterm#buflist#next()
  if next_bufnr == -1
    let msg = 'No more floaterms'
    call floaterm#util#show_msg(msg, 'warning')
  else
    call floaterm#util#autohide()
    call floaterm#terminal#open_existing(next_bufnr)
  endif
endfunction

function! floaterm#prev()  abort
  let prev_bufnr = floaterm#buflist#prev()
  if prev_bufnr == -1
    let msg = 'No more floaterms'
    call floaterm#util#show_msg(msg, 'warning')
  else
    call floaterm#util#autohide()
    call floaterm#terminal#open_existing(prev_bufnr)
  endif
endfunction

function! floaterm#curr() abort
  let curr_bufnr = floaterm#buflist#curr()
  if curr_bufnr == -1
    let curr_bufnr = floaterm#new(v:true, '', {}, {})
  else
    call floaterm#terminal#open_existing(curr_bufnr)
  endif
  return curr_bufnr
endfunction

function! floaterm#first() abort
  let first_bufnr = floaterm#buflist#first()
  if first_bufnr == -1
    call floaterm#util#show_msg('No more floaterms', 'warning')
  else
    call floaterm#util#autohide()
    call floaterm#terminal#open_existing(first_bufnr)
  endif
endfunction

function! floaterm#last() abort
  let last_bufnr = floaterm#buflist#last()
  if last_bufnr == -1
    call floaterm#util#show_msg('No more floaterms', 'warning')
  else
    call floaterm#util#autohide()
    call floaterm#terminal#open_existing(last_bufnr)
  endif
endfunction

function! floaterm#kill(bang, bufnr, name) abort
  if a:bang
    for bufnr in floaterm#buflist#gather()
      call floaterm#terminal#kill(bufnr)
    endfor
    return
  endif

  let bufnr = a:bufnr
  if bufnr == 0 && !empty(a:name)
    let bufnr = floaterm#terminal#get_bufnr(a:name)
  endif
  if bufnr == 0 || bufnr == -1
    let bufnr = floaterm#buflist#curr()
  endif

  if bufnr > 0
    call floaterm#terminal#kill(bufnr)
  else
    call floaterm#util#show_msg('No floaterms with the bufnr or name', 'error')
  endif
endfunction

function! floaterm#show(bang, bufnr, name) abort
  if a:bang
    for bufnr in floaterm#buflist#gather()
      call floaterm#terminal#open_existing(bufnr)
    endfor
    return
  endif

  let bufnr = a:bufnr
  if bufnr == 0 && !empty(a:name)
    let bufnr = floaterm#terminal#get_bufnr(a:name)
  endif
  if bufnr == 0 || bufnr == -1
    let bufnr = floaterm#buflist#curr()
  endif

  if bufnr > 0
    call floaterm#util#autohide()
    call floaterm#terminal#open_existing(bufnr)
  else
    call floaterm#util#show_msg('No floaterms with the bufnr or name', 'error')
  endif
endfunction

function! floaterm#hide(bang, bufnr, name) abort
  if a:bang
    for bufnr in floaterm#buflist#gather()
      call floaterm#window#hide_floaterm(bufnr)
    endfor
    return
  endif

  let bufnr = a:bufnr
  if bufnr == 0 && !empty(a:name)
    let bufnr = floaterm#terminal#get_bufnr(a:name)
  endif
  if bufnr == 0 || bufnr == -1
    let bufnr = bufnr('%')
  endif

  if bufnr > 0
    call floaterm#window#hide_floaterm(bufnr)
  else
    call floaterm#util#show_msg('No floaterms with the bufnr or name', 'error')
  endif
endfunction

function! floaterm#send(bang, mode, range, line1, line2, argstr) abort
  if &filetype ==# 'floaterm'
    let msg = "FloatermSend can't be used in the floaterm window"
    call floaterm#util#show_msg(msg, 'warning')
    return
  endif

  let [cmd, opts] = floaterm#cmdline#parse(split(a:argstr))
  let termname = get(opts, 'termname', '')
  if !empty(termname)
    let bufnr = floaterm#terminal#get_bufnr(termname)
    if bufnr == -1
      call floaterm#util#show_msg('No floaterm found with name: ' . termname, 'error')
      return
    endif
  else
    let bufnr = floaterm#buflist#curr()
    if bufnr == -1
      call floaterm#util#show_msg('No more floaterms', 'warning')
      return
    endif
  endif
  if !empty(cmd)
    call floaterm#terminal#send(bufnr, [cmd])
    return
  endif

  if a:range == 0
    let lines = [getline('.')]
  elseif a:range == 1
    let lines = [getline(a:line1)]
  else
    " https://stackoverflow.com/a/61486601/8554147
    let [lnum1, col1] = getpos("'<")[1:2]
    let [lnum2, col2] = getpos("'>")[1:2]
    let lines = getline(lnum1, lnum2)
    if empty(lines)
      call floaterm#util#show_msg('No lines were selected', 'error')
      return
    endif
    if a:mode ==# 'v'
      let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
      let lines[0] = lines[0][col1 - 1:]
    elseif a:mode ==# 'V'
    elseif a:mode == "\<c-v>"
      let i = 0
      for line in lines
        let lines[i] = line[col1 - 1: col2 - (&selection == 'inclusive' ? 1 : 2)]
        let i = i + 1
      endfor
    endif
  endif

  let linelist = []
  if a:bang
    let line1 = lines[0]
    let trim_line = substitute(line1, '\v^\s+', '', '')
    let indent = len(line1) - len(trim_line)
    for line in lines
      if line[:indent] =~# '\s\+'
        let line = line[indent:]
      endif
      call add(linelist, line)
    endfor
  else
    let linelist = lines
  endif
  call floaterm#terminal#send(bufnr, linelist)
endfunction
