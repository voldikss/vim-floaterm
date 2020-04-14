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
let s:wrappers = fnamemodify(s:home . '/floaterm/wrapper', ':p')
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
      \ 'nvr -cc "call floaterm#hide() | %s" --remote-wait',
      \ g:floaterm_gitcommit
      \ )
  endif
endif

"-----------------------------------------------------------------------------
" script level functions
"-----------------------------------------------------------------------------
function! s:get_wrappers() abort
  let files = split(glob(s:wrappers . '/*.vim'), "\n")
  return map(files, "substitute(fnamemodify(v:val, ':t'), '\\..\\{-}$', '', '')")
endfunction

" ----------------------------------------------------------------------------
" main functions
" ----------------------------------------------------------------------------
function! floaterm#new(...) abort
  if !empty(g:floaterm_rootmarkers)
    let dest = floaterm#resolver#get_root()
    if dest !=# ''
      call floaterm#resolver#chdir(dest)
    endif
  endif

  let [cmd, winopts] = floaterm#cmdline#parse_new(a:000)
  if cmd != ''
    let wrappers = s:get_wrappers()
    let maybe_wrapper = split(cmd, '\s')[0]
    if index(wrappers, maybe_wrapper) >= 0
      let WrapFunc = function(printf('floaterm#wrapper#%s#', maybe_wrapper))
      let [name, jobopts, send2shell] = WrapFunc(cmd)
      if send2shell
        let bufnr = floaterm#terminal#open(-1, &shell, {}, winopts)
        call floaterm#terminal#send(bufnr, [name])
      else
        let bufnr = floaterm#terminal#open(-1, name, jobopts, winopts)
      endif
    else
      let bufnr = floaterm#terminal#open(-1, &shell, {}, winopts)
      call floaterm#terminal#send(bufnr, [cmd])
    endif
  else
    let bufnr = floaterm#terminal#open(-1, &shell, {}, winopts)
  endif
  return bufnr
endfunction

function! floaterm#toggle(...)  abort
  let termname = get(a:, 1, '')
  if termname != ''
    let bufnr = floaterm#terminal#get_bufnr(termname)
    if bufnr == -1
      call floaterm#util#show_msg('No floaterm found with name: ' . termname, 'error')
      return
    elseif bufnr == bufnr()
      call floaterm#window#hide_floaterm(bufnr)
    elseif bufwinnr(bufnr) > -1
      execute bufwinnr(bufnr) . 'wincmd w'
    else
      call floaterm#terminal#open_existing(bufnr)
    endif
  elseif &filetype == 'floaterm'
    call floaterm#window#hide_floaterm(bufnr())
  else
    let found_winnr = floaterm#window#find_floaterm_window()
    if found_winnr > 0
      execute found_winnr . 'wincmd w'
      call floaterm#util#startinsert()
    else
      call floaterm#curr()
    endif
  endif
endfunction

function! floaterm#update(...) abort
  if &filetype !=# 'floaterm'
    call floaterm#util#show_msg('You have to be in a floaterm window to change window opts.', 'error')
    return
  endif

  let bufnr = bufnr('%')
  let [_, winopts] = floaterm#cmdline#parse_new(a:000)
  call floaterm#window#hide_floaterm(bufnr)
  call floaterm#buffer#update_winopts(bufnr, winopts)
  call floaterm#terminal#open_existing(bufnr)
endfunction

function! floaterm#next()  abort
  call floaterm#window#hide_floaterm(bufnr())
  let next_bufnr = floaterm#buflist#find_next()
  if next_bufnr == -1
    let msg = 'No more floaterms'
    call floaterm#util#show_msg(msg, 'warning')
  else
    call floaterm#terminal#open_existing(next_bufnr)
  endif
endfunction

function! floaterm#prev()  abort
  call floaterm#window#hide_floaterm(bufnr())
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

"-----------------------------------------------------------------------------
" hide all floaterms
"-----------------------------------------------------------------------------
function! floaterm#hide() abort
  let buffers = floaterm#buflist#gather()
  for bufnr in buffers
    call floaterm#window#hide_floaterm(bufnr)
  endfor
endfunction

function! floaterm#send(bang, startlnum, endlnum, ...) abort
  if &filetype ==# 'floaterm'
    let msg = "FloatermSend can't be used in the floaterm window"
    call floaterm#util#show_msg(msg, 'warning')
    return
  endif

  let termname = get(a:, 1, '')
  if termname != ''
    let bufnr = floaterm#terminal#get_bufnr(termname)
    if bufnr == -1
      call floaterm#util#show_msg('No floaterm found with name: ' . termname, 'error')
    endif
  else
    let bufnr = floaterm#buflist#find_curr()
    if bufnr == -1
      let bufnr = floaterm#new()
    endif
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
