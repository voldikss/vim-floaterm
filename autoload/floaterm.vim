" ============================================================================
" FileName: floaterm.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

" ----------------------------------------------------------------------------
let $VIM_SERVERNAME = v:servername
let $VIM_EXE = v:progpath

let s:home = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let s:script = fnamemodify(s:home . '/../bin', ':p')
let s:wrappers = fnamemodify(s:home . '/floaterm/wrapper', ':p')
let s:windows = has('win32') || has('win64')

if stridx($PATH, s:script) < 0
  if s:windows == 0
    let $PATH .= ':' . s:script
  else
    let $PATH .= ';' . s:script
  endif
endif

function! s:get_wrappers() abort
  let files = split(glob(s:wrappers . '/*.vim'), "\n")
  return map(files, "substitute(fnamemodify(v:val, ':t'), '\\..\\{-}$', '', '')")
endfunction

if g:floaterm_gitcommit != v:null
  autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete
  if g:floaterm_gitcommit == 'floaterm'
    let $GIT_EDITOR = 'nvr --remote-wait'
  else
    let $GIT_EDITOR = printf(
      \ 'nvr -cc "call floaterm#hide() | %s" --remote-wait',
      \ g:floaterm_gitcommit
      \ )
  endif
endif


" ----------------------------------------------------------------------------
" Main functions
" ----------------------------------------------------------------------------
function! floaterm#new(...) abort
  call floaterm#hide()

  if !empty(g:floaterm_rootmarkers)
    let dest = floaterm#resolver#get_root()
    if dest !=# ''
      call floaterm#resolver#chdir(dest)
    endif
  endif

  let arg = get(a:, 1, '')
  let window_opts = get(a:, 2, {})
  if arg != ''
    let wrappers = s:get_wrappers()
    let maybe_wrapper = split(arg, '\s')[0]
    if index(wrappers, maybe_wrapper) >= 0
      let WrapFunc = function(printf('floaterm#wrapper#%s#', maybe_wrapper))
      let [cmd, opts, send2shell] = WrapFunc(arg)
      if send2shell
        let bufnr = floaterm#terminal#open(-1, &shell, {}, window_opts)
        call floaterm#terminal#send(bufnr, [cmd])
      else
        let bufnr = floaterm#terminal#open(-1, cmd, opts, window_opts)
      endif
    else
      let bufnr = floaterm#terminal#open(-1, &shell, {}, window_opts)
      call floaterm#terminal#send(bufnr, [arg])
    endif
  else
    let bufnr = floaterm#terminal#open(-1, &shell, {}, window_opts)
  endif
  call floaterm#buflist#add(bufnr)
  return bufnr
endfunction

function! floaterm#next()  abort
  call floaterm#hide()
  let next_bufnr = floaterm#buflist#find_next()
  if next_bufnr == -1
    let msg = 'No more floaterms'
    call floaterm#util#show_msg(msg, 'warning')
  else
    call floaterm#terminal#open_existing(next_bufnr)
  endif
endfunction

function! floaterm#prev()  abort
  call floaterm#hide()
  let prev_bufnr = floaterm#buflist#find_prev()
  if prev_bufnr == -1
    let msg = 'No more floaterms'
    call floaterm#util#show_msg(msg, 'warning')
  else
    call floaterm#terminal#open_existing(prev_bufnr)
  endif
endfunction

function! floaterm#curr() abort
  let curr_bufnr = floaterm#buflist#find_curr()
  if curr_bufnr == -1
    let curr_bufnr = floaterm#new()
  else
    call floaterm#terminal#open_existing(curr_bufnr)
  endif
  return curr_bufnr
endfunction

function! floaterm#toggle()  abort
  if &filetype ==# 'floaterm'
    hide
  else
    let found_winnr = s:find_term_win()
    if found_winnr > 0
      execute found_winnr . 'wincmd w'
      if has('nvim')
        startinsert
      elseif mode() ==# 'n'
        normal! i
      endif
    else
      call floaterm#curr()
    endif
  endif
endfunction

" Find **one** floaterm window
function! s:find_term_win() abort
  let found_winnr = 0
  for winnr in range(1, winnr('$'))
    if getbufvar(winbufnr(winnr), '&filetype') ==# 'floaterm'
      let found_winnr = winnr
      break
    endif
  endfor
  return found_winnr
endfunction

" Hide current before opening another terminal window
function! floaterm#hide() abort
  while v:true
    let found_winnr = s:find_term_win()
    if found_winnr > 0
      execute found_winnr . 'hide'
    else
      break
    endif
  endwhile
endfunction

function! floaterm#send(bang, startlnum, endlnum) abort
  if &filetype ==# 'floaterm'
    let msg = "FloatermSend can't be used in the floaterm window"
    call floaterm#util#show_msg(msg, 'warning')
    return
  endif

  let bufnr = floaterm#buflist#find_curr()
  if bufnr == -1
    let bufnr = floaterm#new()
  endif

  let linelist = []
  if a:bang ==# '!'
    let line1 = getline(a:startlnum)
    let trim_line = substitute(line1, '\v^\s+', '', '')
    let indent = len(line1) - len(trim_line)
    for lnum in range(a:startlnum, a:endlnum)
      let line = getline(lnum)
      if line[:indent] =~# '\s\+'
        let line = line[indent:]
        call add(linelist, line)
      endif
      call floaterm#terminal#send(bufnr, linelist)
    endfor
  else
    for lnum in range(a:startlnum, a:endlnum)
      let line = getline(lnum)
      call add(linelist, line)
    endfor
    call floaterm#terminal#send(bufnr, linelist)
  endif
endfunction
