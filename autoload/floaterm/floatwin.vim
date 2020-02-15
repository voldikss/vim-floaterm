" ============================================================================
" FileName: floatwin.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! s:nvim_create_buf(linelist, opts) abort
  let bufnr = nvim_create_buf(v:false, v:true)
  call nvim_buf_set_lines(bufnr, 0, -1, v:true, a:linelist)
  for [name, value] in items(a:opts)
    call nvim_buf_set_option(bufnr, name, value)
  endfor
  return bufnr
endfunction

" @param:
"   winid: floaterm window id
function! s:add_border(winid) abort
  let win_opts = nvim_win_get_config(a:winid)
  let top = g:floaterm_borderchars[4] .
          \ repeat(g:floaterm_borderchars[0], win_opts.width) .
          \ g:floaterm_borderchars[5]
  let mid = g:floaterm_borderchars[3] .
          \ repeat(' ', win_opts.width) .
          \ g:floaterm_borderchars[1]
  let bot = g:floaterm_borderchars[7] .
          \ repeat(g:floaterm_borderchars[2], win_opts.width) .
          \ g:floaterm_borderchars[6]
  let lines = [top] + repeat([mid], win_opts.height) + [bot]
  let buf_opts = {}
  let buf_opts.synmaxcol = 3000 " #17
  let buf_opts.filetype = 'floaterm_border'
  " Reuse s:add_border
  if !exists('s:border_bufnr')
    let s:border_bufnr = s:nvim_create_buf(lines, buf_opts)
  endif
  let win_opts.row -= (win_opts.anchor[0] ==# 'N' ? 1 : -1)
  " A bug fix
  if win_opts.row < 0
    let win_opts.row = 1
    call nvim_win_set_config(a:winid, win_opts)
    let win_opts.row = 0
  endif
  let win_opts.col -= (win_opts.anchor[1] ==# 'W' ? 1 : -1)
  let win_opts.width += 2
  let win_opts.height += 2
  let win_opts.style = 'minimal'
  let win_opts.focusable = v:false
  let s:border_winid = nvim_open_win(s:border_bufnr, v:false, win_opts)
  call nvim_win_set_option(s:border_winid, 'winhl', 'NormalFloat:FloatermBorderNF')
endfunction

function! s:floatwin_pos(width, height) abort
  if g:floaterm_position ==# 'topright'
    let row = 0
    let col = &columns
    let vert = 'N'
    let hor = 'E'
  elseif g:floaterm_position ==# 'topleft'
    let row = 0
    let col = 0
    let vert = 'N'
    let hor = 'W'
  elseif g:floaterm_position ==# 'bottomright'
    let row = &lines
    let col = &columns
    let vert = 'S'
    let hor = 'E'
  elseif g:floaterm_position ==# 'bottomleft'
    let row = &lines
    let col = 0
    let vert = 'S'
    let hor = 'W'
  elseif g:floaterm_position ==# 'center'
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
  else " at the cursor place
    let curr_pos = getpos('.')
    let row = curr_pos[1] - line('w0')
    let col = curr_pos[2]
    if row + a:height <= &lines
      let vert = 'N'
    else
      let vert = 'S'
    endif
    if col + a:width <= &columns
      let hor = 'W'
    else
      let hor = 'E'
    endif
  endif
  return [row, col, vert, hor]
endfunction

function! floaterm#floatwin#nvim_open_win(bufnr, width, height) abort
  let [row, col, vert, hor] = s:floatwin_pos(a:width, a:height)
  let opts = {
    \ 'relative': 'editor',
    \ 'anchor': vert . hor,
    \ 'row': row,
    \ 'col': col,
    \ 'width': a:width,
    \ 'height': a:height,
    \ 'style':'minimal'
    \ }
  let winid = nvim_open_win(a:bufnr, v:true, opts)
  call s:add_border(winid)
  call nvim_set_current_win(winid)
endfunction

function! floaterm#floatwin#hide_border(...) abort
  if exists('s:border_winid')
    execute win_id2win(s:border_winid) . 'hide'
  endif
endfunction
