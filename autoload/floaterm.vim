" vim:fdm=indent
" ========================================================================
" Description: autoload/floaterm.vim
" Author: voldikss
" GitHub: https://github.com/voldikss/vim-floaterm
" ========================================================================

set hidden

let g:floaterm_buflist = []
let g:floaterm_bufindex = -1

function! floaterm#doAction(action)
  if !s:checkValid()
    return
  endif

  if a:action == 'new'
    call s:newTerminal()
  elseif a:action == 'next'
    call s:nextTerminal()
  elseif a:action == 'prev'
    call s:prevTerminal()
  elseif a:action == 'toggle'
    call s:toggleTerminal()
  endif
endfunction

function! s:toggleTerminal() abort
  let found_winnr = s:findTerminalWindow()
  if found_winnr > 0
    if &buftype == 'terminal'
      execute found_winnr . ' wincmd q'
    else
      execute found_winnr . ' wincmd w'
    endif
  else
    while 1
      if s:sum(g:floaterm_buflist) == 0
        call s:openTerminal(0)
        return
      endif
      let found_bufnr = g:floaterm_buflist[g:floaterm_bufindex]
      if found_bufnr != 0 && bufexists(found_bufnr)
        call s:openTerminal(found_bufnr)
        return
      else
        let g:floaterm_buflist[g:floaterm_bufindex] = 0
        let buf_cnt = len(g:floaterm_buflist)
        let g:floaterm_bufindex = (g:floaterm_bufindex-1+buf_cnt)%buf_cnt
      endif
    endwhile
  endif
endfunction

function! s:newTerminal() abort
  call s:hidePrevTerminals()
  call s:openTerminal(0)
endfunction

function! s:nextTerminal()
  call s:hidePrevTerminals()
  while 1
    if s:sum(g:floaterm_buflist) == 0
      call s:showMessage('No more terminal buffers', 'warning')
      return
    endif
    let buf_cnt = len(g:floaterm_buflist)
    let g:floaterm_bufindex = (g:floaterm_bufindex+1)%buf_cnt
    let next_bufnr = g:floaterm_buflist[g:floaterm_bufindex]
    if next_bufnr != 0 && bufexists(next_bufnr)
      call s:openTerminal(next_bufnr)
      return
    else
      let g:floaterm_buflist[g:floaterm_bufindex] = 0
    endif
  endwhile
endfunction

function! s:prevTerminal()
  call s:hidePrevTerminals()
  while 1
    if s:sum(g:floaterm_buflist) == 0
      call s:showMessage('No more terminal buffers', 'warning')
      return
    endif
    let buf_cnt = len(g:floaterm_buflist)
    let g:floaterm_bufindex = (g:floaterm_bufindex-1+buf_cnt)%buf_cnt
    let prev_bufnr = g:floaterm_buflist[g:floaterm_bufindex]
    if prev_bufnr != 0 && bufexists(prev_bufnr)
      call s:openTerminal(prev_bufnr)
      return
    else
      let g:floaterm_buflist[g:floaterm_bufindex] = 0
    endif
  endwhile
endfunction

function! s:hidePrevTerminals()
  while 1
    let found_winnr = s:findTerminalWindow()
    if found_winnr > 0
      execute found_winnr . ' wincmd q'
    else
      break
    endif
  endwhile
endfunction

function! s:openTerminal(found_bufnr)
  let height =
    \ g:floaterm_height == v:null
    \ ? float2nr(0.7*&lines)
    \ : float2nr(g:floaterm_height)
  let width =
    \ g:floaterm_width == v:null
    \ ? float2nr(0.7*&columns)
    \ : float2nr(g:floaterm_width)

  if g:floaterm_type == 'floating'
    let bufnr = s:openTerminalFloating(a:found_bufnr, height, width)
  else
    let bufnr = s:openTerminalNormal(a:found_bufnr, height, width)
  endif
  if bufnr
    call add(g:floaterm_buflist, bufnr)
    let g:floaterm_bufindex = len(g:floaterm_buflist) - 1
  endif
  call s:onOpenTerminal()
endfunction

function! s:openTerminalFloating(found_bufnr, height, width) abort
  let [relative, row, col, vert, hor] = s:getWindowPosition(a:width, a:height)
  let opts = {
    \ 'relative': relative,
    \ 'width': a:width,
    \ 'height': a:height,
    \ 'col': col,
    \ 'row': row,
    \ 'anchor': vert . hor
  \ }

  if a:found_bufnr > 0
    call nvim_open_win(a:found_bufnr, 1, opts)
    return
  else
    let bufnr = nvim_create_buf(v:false, v:true)
    call nvim_open_win(bufnr, 1, opts)
    terminal
    return bufnr
  endif
endfunction

function! s:openTerminalNormal(found_bufnr, height, width) abort
  if a:found_bufnr > 0
    if &lines > 30
      execute 'botright ' . a:height . 'split'
      execute 'buffer ' . a:found_bufnr
    else
      botright split
      execute 'buffer ' . a:found_bufnr
    endif
    return
  else
    if &lines > 30
      if has('nvim')
        execute 'botright ' . a:height . 'split term://' . &shell
      else
        botright terminal
        resize a:height
      endif
    else
      if has('nvim')
        execute 'botright split term://' . &shell
      else
        botright terminal
      endif
    endif
    return bufnr('%')
  endif
endfunction

function! s:onOpenTerminal() abort
  call setbufvar(bufnr('%'), 'floaterm_window', 1)
  setlocal signcolumn=no
  setlocal nobuflisted
  setlocal nocursorline
  setlocal nonumber
  setlocal norelativenumber
  setlocal foldcolumn=1
  setlocal filetype=terminal

  " iterate to find the background for floating
  if has('nvim')
    execute 'setlocal winblend=' . g:floaterm_winblend

    if g:floaterm_background == v:null
      let hiGroup = 'NormalFloat'
      while 1
        let hiInfo = execute('hi ' . hiGroup)
        let g:floaterm_background = matchstr(hiInfo, 'guibg=\zs\S*')
        let hiGroup = matchstr(hiInfo, 'links to \zs\S*')
        if g:floaterm_background != '' || hiGroup == ''
          break
        endif
      endwhile
    endif
    if g:floaterm_background != ''
      execute 'hi FloatTermNormal term=NONE guibg='. g:floaterm_background
      setlocal winhighlight=NormalFloat:FloatTermNormal,FoldColumn:FloatTermNormal
    endif

    augroup NvimCloseTermWin
      autocmd!
      autocmd TermClose <buffer> if &buftype=='terminal'
        \ && getbufvar(bufnr('%'), 'floaterm_window') == 1 |
        \ bdelete! |
        \ endif
    augroup END
  endif

  startinsert
endfunction

function! s:findTerminalWindow()
  let found_winnr = 0
  for winnr in range(1, winnr('$'))
    if getbufvar(winbufnr(winnr), '&buftype') == 'terminal'
      \ && getbufvar(winbufnr(winnr), 'floaterm_window') == 1
      let found_winnr = winnr
    endif
  endfor
  return found_winnr
endfunction

function! s:findTerminalBuffer() " NOTE: unused
  let found_bufnr = 0
  for bufnr in filter(range(1, bufnr('$')), 'bufexists(v:val)')
    let buftype = getbufvar(bufnr, '&buftype')
    if buftype == 'terminal' && getbufvar(bufnr, 'floaterm_window') == 1
      let found_bufnr = bufnr
    endif
  endfor
  return found_bufnr
endfunction

function! s:getWindowPosition(width, height) abort
  let bottom_line = line('w0') + &lines - 1
  let relative = 'editor'
  if g:floaterm_position == 'topright'
    let row = 0
    let col = &columns
    let vert = 'N'
    let hor = 'E'
  elseif g:floaterm_position == 'topleft'
    let row = 0
    let col = 0
    let vert = 'N'
    let hor = 'W'
  elseif g:floaterm_position == 'bottomright'
    let row = &lines
    let col = &columns
    let vert = 'S'
    let hor = 'E'
  elseif g:floaterm_position == 'bottomleft'
    let row = &lines
    let col = 0
    let vert = 'S'
    let hor = 'W'
  elseif g:floaterm_position == 'center'
    let row = (&lines - a:height)/2
    let col = (&columns - a:width)/2
    let vert = 'N'
    let hor = 'W'

    if row < 0
      let row = 0
    endif
    if col < 0
      let col = 0
    endif
  else
    let relative = 'cursor'
    let curr_pos = getpos('.')
    let rownr = curr_pos[1]
    let colnr = curr_pos[2]
    " a long wrap line
    if colnr > &columns
      let colnr = colnr % &columns
      let rownr += colnr / &columns
    endif

    if rownr + a:height <= bottom_line
      let vert = 'N'
      let row = 1
    else
      let vert = 'S'
      let row = 0
    endif

    if colnr + a:width <= &columns
      let hor = 'W'
      let col = 0
    else
      let hor = 'E'
      let col = 1
    endif
  endif

  return [relative, row, col, vert, hor]
endfunction

function! s:checkValid()
  if exists('*nvim_win_set_config')
    if g:floaterm_type == v:null
      let g:floaterm_type = 'floating'
    endif
  elseif has('terminal')
    let g:floaterm_type = 'normal'
  else
    let message = 'Terminal feature is required, please upgrade your vim/nvim'
    call s:showMessage(message, 'error')
    return v:false
  endif
  return v:true
endfunction

function! s:sum(lst)
  let res = 0
  for i in a:lst
    let res += i
  endfor
  return res
endfunction

function! s:showMessage(message, ...) abort
  if a:0 == 0
    let msgType = 'info'
  else
    let msgType = a:1
  endif

  if type(a:message) != 1
    let message = string(a:message)
  else
    let message = a:message
  endif

  if msgType == 'info'
    echohl String
  elseif msgType == 'warning'
    echohl WarningMsg
  elseif msgType == 'error'
    echohl ErrorMsg
  endif

  echomsg '[vim-floaterm] ' . message
  echohl None
endfunction
