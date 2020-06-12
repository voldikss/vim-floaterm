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
let s:wrappers = globpath(&runtimepath, 'autoload/floaterm/wrapper/*vim', 0, 1)
let s:windows = has('win32') || has('win64')

if stridx($PATH, s:script) < 0
  if s:windows == 0
    let $PATH .= ':' . s:script
  else
    let $PATH .= ';' . s:script
  endif
endif

if g:floaterm_gitcommit != v:null
  autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete
  if g:floaterm_gitcommit == 'floaterm'
    let $GIT_EDITOR = 'nvr --remote-wait'
  else
    let $GIT_EDITOR = printf(
      \ 'nvr -cc "call floaterm#hide(1, \"\") | %s" --remote-wait',
      \ g:floaterm_gitcommit
      \ )
  endif
endif

"-----------------------------------------------------------------------------
" script level functions
"-----------------------------------------------------------------------------
function! s:get_wrappers() abort
  return map(s:wrappers, "substitute(fnamemodify(v:val, ':t'), '\\..\\{-}$', '', '')")
endfunction

" ----------------------------------------------------------------------------
" wrapper function for `floaterm#new()` and `floaterm#update()` since they
" share the same argument: `winopts`
" ----------------------------------------------------------------------------
function! floaterm#run(action, bang, ...) abort
  let [cmd, winopts] = floaterm#cmdline#parse(a:000)
  if a:action == 'new'
    call floaterm#new(a:bang, cmd, winopts, {})
  elseif a:action == 'update'
    call floaterm#update(winopts)
  endif
endfunction

" ----------------------------------------------------------------------------
" create a floaterm. `jobopts` is not used inside this pugin actually, it's
" reserved for outer invoke
" ----------------------------------------------------------------------------
function! floaterm#new(bang, cmd, winopts, jobopts) abort
  call floaterm#util#autohide()
  if a:cmd != ''
    let wrappers = s:get_wrappers()
    let maybe_wrapper = split(a:cmd, '\s')[0]
    if index(wrappers, maybe_wrapper) >= 0
      let WrapFunc = function(printf('floaterm#wrapper#%s#', maybe_wrapper))
      let [name, jobopts, send2shell] = WrapFunc(a:cmd)
      if send2shell
        let bufnr = floaterm#terminal#open(-1, g:floaterm_shell, {}, a:winopts)
        call floaterm#terminal#send(bufnr, [name])
      else
        let bufnr = floaterm#terminal#open(-1, name, jobopts, a:winopts)
      endif
    elseif a:bang
      let bufnr = floaterm#terminal#open(-1, g:floaterm_shell, a:jobopts, a:winopts)
      call floaterm#terminal#send(bufnr, [a:cmd])
    else
      let bufnr = floaterm#terminal#open(-1, a:cmd, a:jobopts, a:winopts)
    endif
  else
    let bufnr = floaterm#terminal#open(-1, g:floaterm_shell, a:jobopts, a:winopts)
  endif
  return bufnr
endfunction

" ----------------------------------------------------------------------------
" toggle on/off the floaterm named `name`
" ----------------------------------------------------------------------------
function! floaterm#toggle(bang, name)  abort
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

  if !empty(a:name)
    let bufnr = floaterm#terminal#get_bufnr(a:name)
    if bufnr == -1
      call floaterm#util#show_msg('No floaterm found with name: ' . a:name, 'error')
      return
    elseif bufnr == bufnr('%')
      call floaterm#window#hide_floaterm(bufnr)
    elseif bufwinnr(bufnr) > -1
      execute bufwinnr(bufnr) . 'wincmd w'
    else
      call floaterm#terminal#open_existing(bufnr)
    endif
  elseif &filetype == 'floaterm'
    call floaterm#window#hide_floaterm(bufnr('%'))
  else
    let found_winnr = floaterm#window#find_floaterm_window()
    if found_winnr > 0
      execute found_winnr . 'wincmd w'
    else
      call floaterm#curr()
    endif
  endif
endfunction

" ----------------------------------------------------------------------------
" update the attributes of a floaterm
" ----------------------------------------------------------------------------
function! floaterm#update(winopts) abort
  if &filetype !=# 'floaterm'
    call floaterm#util#show_msg('You have to be in a floaterm window to change window opts.', 'error')
    return
  endif

  let bufnr = bufnr('%')
  call floaterm#window#hide_floaterm(bufnr)
  call floaterm#buffer#update_winopts(bufnr, a:winopts)
  call floaterm#terminal#open_existing(bufnr)
endfunction

function! floaterm#next()  abort
  let next_bufnr = floaterm#buflist#find_next()
  if next_bufnr == -1
    let msg = 'No more floaterms'
    call floaterm#util#show_msg(msg, 'warning')
  else
    call floaterm#util#autohide()
    call floaterm#terminal#open_existing(next_bufnr)
  endif
endfunction

function! floaterm#prev()  abort
  let prev_bufnr = floaterm#buflist#find_prev()
  if prev_bufnr == -1
    let msg = 'No more floaterms'
    call floaterm#util#show_msg(msg, 'warning')
  else
    call floaterm#util#autohide()
    call floaterm#terminal#open_existing(prev_bufnr)
  endif
endfunction

function! floaterm#curr() abort
  let curr_bufnr = floaterm#buflist#find_curr()
  if curr_bufnr == -1
    let curr_bufnr = floaterm#new(v:true, '', {}, {})
  else
    call floaterm#terminal#open_existing(curr_bufnr)
  endif
  return curr_bufnr
endfunction

function! floaterm#kill(bang, name) abort
  if a:bang
    for bufnr in floaterm#buflist#gather()
      call floaterm#terminal#kill(bufnr)
    endfor
    return
  endif

  if !empty(a:name)
    let bufnr = floaterm#terminal#get_bufnr(a:name)
  else
    let bufnr = floaterm#buflist#find_curr()
  endif
  if bufnr != -1
    call floaterm#terminal#kill(bufnr)
  else
    call floaterm#util#show_msg('The floaterm does not exist', 'warning')
  endif
endfunction

function! floaterm#show(bang, name) abort
  if a:bang
    for bufnr in floaterm#buflist#gather()
      call floaterm#terminal#open_existing(bufnr)
    endfor
    return
  endif

  if !empty(a:name)
    let bufnr = floaterm#terminal#get_bufnr(a:name)
  else
    let bufnr = floaterm#buflist#find_curr()
  endif
  if bufnr != -1
    call floaterm#util#autohide()
    call floaterm#terminal#open_existing(bufnr)
  else
    call floaterm#util#show_msg('The floaterm does not exist', 'warning')
  endif
endfunction

function! floaterm#hide(bang, name) abort
  if a:bang
    for bufnr in floaterm#buflist#gather()
      call floaterm#window#hide_floaterm(bufnr)
    endfor
    return
  endif

  if !empty(a:name)
    let bufnr = floaterm#terminal#get_bufnr(a:name)
  else
    let bufnr = bufnr('%')
  endif
  if bufnr != -1
    call floaterm#window#hide_floaterm(bufnr)
  else
    call floaterm#util#show_msg('The floaterm does not exist', 'warning')
  endif
endfunction

function! floaterm#send(bang, range, line1, line2, argstr) abort
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
    let bufnr = floaterm#buflist#find_curr()
    if bufnr == -1
      let bufnr = floaterm#new(v:true, '', {}, {})
      call floaterm#toggle('')
      call floaterm#send(a:bang, a:range, a:line1, a:line2, a:argstr)
      call floaterm#toggle('')
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
    let lines = [getline('.')]
  else
    if a:line1 == a:line2
      " https://vi.stackexchange.com/a/11028/17515
      let [lnum1, col1] = getpos("'<")[1:2]
      let [lnum2, col2] = getpos("'>")[1:2]
      let lines = getline(lnum1, lnum2)
      if empty(lines)
        call floaterm#util#show_msg('No lines were selected', 'error')
        return
      endif
      let lines[-1] = lines[-1][: col2 - 1]
      let lines[0] = lines[0][col1 - 1:]
    else
      let lines = getline(a:line1, a:line2)
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
