" ============================================================================
" FileName: floaterm.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! floaterm#new() abort
  call floaterm#hide()
  let bufnr = floaterm#terminal#open(-1)
  call floaterm#buflist#add(bufnr)
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

function! floaterm#start(action) abort
  if !exists(':terminal')
    let message = 'Terminal feature is required, please upgrade your vim/nvim'
    call floaterm#util#show_msg(message, 'warning')
    return
  endif
  if a:action ==# 'new'
    call floaterm#new()
  elseif a:action ==# 'next'
    call floaterm#next()
  elseif a:action ==# 'prev'
    call floaterm#prev()
  elseif a:action ==# 'toggle'
    call floaterm#toggle()
  endif
endfunction
