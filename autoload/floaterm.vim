" ============================================================================
" FileName: floaterm.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

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

function! floaterm#new(...) abort
  call floaterm#hide()
  let bufnr = floaterm#terminal#open(-1)
  call floaterm#buflist#add(bufnr)
  if a:0 > 0
    call floaterm#terminal#send(bufnr, a:1)
  endif
endfunction

function! floaterm#next()  abort
  call floaterm#hide()
  let next_bufnr = floaterm#buflist#find_next()
  if next_bufnr == -1
    let msg = 'No more floaterms'
    call floaterm#util#show_msg(msg, 'warning')
  else
    call floaterm#terminal#open(next_bufnr)
  endif
endfunction

function! floaterm#prev()  abort
  call floaterm#hide()
  let prev_bufnr = floaterm#buflist#find_prev()
  if prev_bufnr == -1
    let msg = 'No more floaterms'
    call floaterm#util#show_msg(msg, 'warning')
  else
    call floaterm#terminal#open(prev_bufnr)
  endif
endfunction

function! floaterm#curr() abort
  let curr_bufnr = floaterm#buflist#find_curr()
  let bufnr = floaterm#terminal#open(curr_bufnr)
  if curr_bufnr == -1 && bufnr != -1
    call floaterm#buflist#add(bufnr)
  endif
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

" @usage:
"   Find **one** floaterm window
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

" @usage:
"   Hide current before opening another terminal window
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
