" vim:fdm=indent
" ========================================================================
" Description: autoload/floaterm.vim
" Author: voldikss
" GitHub: https://github.com/voldikss/vim-floaterm
" ========================================================================

if has('nvim') && exists('*nvim_win_set_config')
  let vtm_window_type = 'floating'
else
  let g:floaterm_type = 'normal'
endif

function! floaterm#toggleTerminal(height, width) abort
  let found_winnr = 0
  for winnr in range(1, winnr('$'))
    if getbufvar(winbufnr(winnr), '&buftype') == 'terminal'
      let found_winnr = winnr
    endif
  endfor

  if found_winnr > 0
    if &buftype == 'terminal'
      " if current window is the terminal window, close it
      execute found_winnr . ' wincmd q'
    else
      " if current window is not terminal, go to the terminal window
      execute found_winnr . ' wincmd w'
    endif
  else
    let found_bufnr = 0
    for bufnr in filter(range(1, bufnr('$')), 'bufexists(v:val)')
      let buftype = getbufvar(bufnr, '&buftype')
      if buftype == 'terminal'
        let found_bufnr = bufnr
      endif
    endfor

    if g:floaterm_type == 'floating'
      call s:openTermFloating(found_bufnr, a:height, a:width)
    else
      call s:openTermNormal(found_bufnr, a:height, a:width)
    endif
    call s:onOpenTerm()
  endif
endfunction

function! s:openTermFloating(found_bufnr, height, width) abort
  let [relative, row, col, vert, hor] = s:getWinPos(a:width, a:height)
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
  else
    let bufnr = nvim_create_buf(v:false, v:true)
    call nvim_open_win(bufnr, 1, opts)
    terminal
  endif
endfunction

function! s:openTermNormal(found_bufnr, height, width) abort
  if a:found_bufnr > 0
    if &lines > 30
      execute 'botright ' . a:height . 'split'
      execute 'buffer ' . a:found_bufnr
    else
      botright split
      execute 'buffer ' . a:found_bufnr
    endif
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
  endif
endfunction

function! s:getWinPos(width, height) abort
  let bottom_line = line('w0') + winheight(0) - 1
  let relative = 'win'
  if g:floaterm_position == 'topright'
    let row = 0
    let col = winwidth(0)
    let vert = 'N'
    let hor = 'E'
  elseif g:floaterm_position == 'topleft'
    let row = 0
    let col = 0
    let vert = 'N'
    let hor = 'W'
  elseif g:floaterm_position == 'bottomright'
    let row = winheight(0)
    let col = winwidth(0)
    let vert = 'S'
    let hor = 'E'
  elseif g:floaterm_position == 'bottomleft'
    let row = winheight(0)
    let col = 0
    let vert = 'S'
    let hor = 'W'
  elseif g:floaterm_position == 'center'
    let row = (winheight(0) - a:height)/2
    let col = (winwidth(0) - a:width)/2
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

function! s:onOpenTerm() abort
  augroup NvimCloseTermWin
    autocmd!
    autocmd TermClose <buffer> if &buftype=='terminal' | bdelete! | endif
  augroup END

  execute 'setlocal winblend=' . g:floaterm_winblend
  setlocal bufhidden=hide
  setlocal signcolumn=no
  setlocal nobuflisted
  setlocal nocursorline
  setlocal nonumber
  setlocal norelativenumber
endfunction
