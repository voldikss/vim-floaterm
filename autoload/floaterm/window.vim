" vim:sw=2:
" ============================================================================
" FileName: floatwin.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

let s:has_popup = has('textprop') && has('patch-8.2.0286')
let s:has_float = has('nvim') && exists('*nvim_win_set_config')

function! s:get_wintype() abort
  if empty(g:floaterm_wintype)
    if s:has_float
      return 'floating'
    elseif s:has_popup
      return 'popup'
    else
      return 'normal'
    endif
  elseif g:floaterm_wintype == 'floating' && !s:has_float
    call floaterm#util#show_msg("floating window is not supported in your nvim, fall back to normal window", 'warning')
    return 'normal'
  elseif g:floaterm_wintype == 'popup' && !s:has_popup
    call floaterm#util#show_msg("popup window is not supported in your vim, fall back to normal window", 'warning')
    return 'normal'
  else
    return g:floaterm_wintype
  endif
endfunction

function! s:build_title(bufnr, text) abort
  if empty(a:text) | return '' | endif
  let buffers = floaterm#buflist#gather()
  let cnt = len(buffers)
  let idx = index(buffers, a:bufnr) + 1
  let title = substitute(a:text, '$1', idx, 'gm')
  let title = substitute(title, '$2', cnt, 'gm')
  return ' ' . title
endfunction

function! s:draw_border(title, width, height) abort
  let top = g:floaterm_borderchars[4] .
          \ repeat(g:floaterm_borderchars[0], a:width) .
          \ g:floaterm_borderchars[5]
  let mid = g:floaterm_borderchars[3] .
          \ repeat(' ', a:width) .
          \ g:floaterm_borderchars[1]
  let bot = g:floaterm_borderchars[7] .
          \ repeat(g:floaterm_borderchars[2], a:width) .
          \ g:floaterm_borderchars[6]
  let top = floaterm#util#string_compose(top, 1, a:title)
  let lines = [top] + repeat([mid], a:height) + [bot]
  return lines
endfunction

" winid: floaterm window id
function! s:add_border(winid, title) abort
  let opts = nvim_win_get_config(a:winid)
  let border = s:draw_border(a:title, opts.width, opts.height)
  let bufopts = {}
  let bufopts.synmaxcol = 3000 " #17
  let bufopts.filetype = 'floatermborder'
  let bufopts.bufhidden = 'wipe'
  let border_bufnr = floaterm#buffer#create(border, bufopts)
  " update opts which will be used to config floatermborder window
  let opts.row -= (opts.anchor[0] == 'N' ? 1 : -1)
  " adjust offset
  if opts.row < 0
    let opts.row = 1
    call nvim_win_set_config(a:winid, opts)
    let opts.row = 0
  endif
  let opts.col -= (opts.anchor[1] == 'W' ? 1 : -1)
  let opts.width += 2
  let opts.height += 2
  let opts.style = 'minimal'
  let opts.focusable = v:false
  let border_winid = nvim_open_win(border_bufnr, v:false, opts)
  call nvim_win_set_option(border_winid, 'winhl', 'Normal:FloatermBorder')
  call nvim_win_set_option(border_winid, 'cursorcolumn', v:false)
  call nvim_win_set_option(border_winid, 'colorcolumn', '')
  return border_winid
endfunction

function! s:floatwin_pos(width, height, pos) abort
  if a:pos == 'topright'
    let row = 2
    let col = &columns - 1
    let anchor = 'NE'
  elseif a:pos == 'topleft'
    let row = 2
    let col = 1
    let anchor = 'NW'
  elseif a:pos == 'bottomright'
    let row = &lines - &cmdheight - 2
    let col = &columns - 1
    let anchor = 'SE'
  elseif a:pos == 'bottomleft'
    let row = &lines - &cmdheight - 2
    let col = 1
    let anchor = 'SW'
  elseif a:pos == 'top'
    let row = 2
    let col = (&columns - a:width)/2
    let anchor = 'NW'
  elseif a:pos == 'right'
    let row = (&lines - a:height)/2
    let col = &columns - 1
    let anchor = 'NE'
  elseif a:pos == 'bottom'
    let row = &lines - &cmdheight - 2
    let col = (&columns - a:width)/2
    let anchor = 'SW'
  elseif a:pos == 'left'
    let row = (&lines - a:height)/2
    let col = 1
    let anchor = 'NW'
  elseif a:pos == 'center'
    let row = (&lines - a:height)/2
    let col = (&columns - a:width)/2
    let anchor = 'NW'
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
    if row + a:height <= &lines - &cmdheight - 1
      let vert = 'N'
    else
      let vert = 'S'
    endif
    if col + a:width <= &columns
      let hor = 'W'
    else
      let hor = 'E'
    endif
    let anchor = vert . hor
  endif
  if !has('nvim')
    let anchor = substitute(anchor, '\CN', 'top', '')
    let anchor = substitute(anchor, '\CS', 'bot', '')
    let anchor = substitute(anchor, '\CW', 'left', '')
    let anchor = substitute(anchor, '\CE', 'right', '')
  endif
  return [row, col, anchor]
endfunction

function! s:winexists(winid) abort
  return !empty(getwininfo(a:winid))
endfunction

function! s:on_floaterm_open(bufnr, winid, opts) abort
  call setbufvar(a:bufnr, 'floaterm_winid', a:winid)
  call setbufvar(a:bufnr, 'floaterm_opts', a:opts)
  call setbufvar(a:bufnr, '&buflisted', 0)
  call setbufvar(a:bufnr, '&filetype', 'floaterm')
  if has('nvim')
    execute 'autocmd! BufHidden <buffer=' . a:bufnr . '> ++once call floaterm#window#hide_floaterm_border(' . a:bufnr . ')'
  endif
endfunction

function! s:parse_opts(opts) abort
  if !has_key(a:opts, 'width')
    let a:opts.width = g:floaterm_width
  endif

  if !has_key(a:opts, 'height')
    let a:opts.height = g:floaterm_height
  endif

  if !has_key(a:opts, 'wintype')
    let a:opts.wintype = s:get_wintype()
  endif

  if !has_key(a:opts, 'position')
    let a:opts.position = g:floaterm_position
  endif

  if !has_key(a:opts, 'autoclose')
    let a:opts.autoclose = g:floaterm_autoclose
  endif

  if !has_key(a:opts, 'title')
    let a:opts.title = g:floaterm_title
  endif
  return a:opts
endfunction

function! floaterm#window#open(bufnr, opts) abort
  let opts = s:parse_opts(a:opts)
  let wintype = a:opts.wintype
  let position = a:opts.position
  let title = a:opts.title

  " NOTE: these lines can not be moved into s:parse_opts() cause floaterm size
  " should be resized dynamically according to the terminal-app's size
  " See 'test/test_options/test_width_height.vader'
  let width = opts.width
  if type(width) == v:t_float | let width = width * &columns | endif
  let width = float2nr(width)

  let height = opts.height
  if type(height) == v:t_float | let height = height * (&lines - &cmdheight - 1) | endif
  let height = float2nr(height)

  if wintype == 'floating'
    let winid = floaterm#window#open_floating(a:bufnr, width, height, position, title)
  elseif wintype == 'popup'
    let winid = floaterm#window#open_popup(a:bufnr, width, height, position, title)
  else
    let winid = floaterm#window#open_split(a:bufnr, height, width, position)
  endif
  call s:on_floaterm_open(a:bufnr, winid, a:opts)
endfunction

function! floaterm#window#open_floating(bufnr, width, height, pos, title) abort
  let [row, col, anchor] = s:floatwin_pos(a:width, a:height, a:pos)
  let opts = {
    \ 'relative': 'editor',
    \ 'anchor': anchor,
    \ 'row': row,
    \ 'col': col,
    \ 'width': a:width,
    \ 'height': a:height,
    \ 'style':'minimal'
    \ }
  let winid = nvim_open_win(a:bufnr, v:true, opts)
  call nvim_win_set_option(winid, 'winblend', g:floaterm_winblend)
  call nvim_win_set_option(winid, 'winhl', 'Normal:Floaterm,NormalNC:FloatermNC')

  let border_winid = getbufvar(a:bufnr, 'floatermborder_winid', -1)
  " close border that already exists and make a new border
  " since `bufhidden` option of floatermborder is set to 'wipe',
  " the border_bufnr will be wiped out once the window was closed
  if s:winexists(border_winid)
    call nvim_win_close(border_winid, v:true)
  endif
  let title = s:build_title(a:bufnr, a:title)
  let border_winid = s:add_border(winid, title)
  call setbufvar(a:bufnr, 'floatermborder_winid', border_winid)
  return winid
endfunction

function! floaterm#window#open_popup(bufnr, width, height, pos, title) abort
  let [row, col, anchor] = s:floatwin_pos(a:width, a:height, a:pos)
  let opts = {
    \ 'pos': anchor,
    \ 'line': row,
    \ 'col': col,
    \ 'maxwidth': a:width,
    \ 'minwidth': a:width,
    \ 'maxheight': a:height,
    \ 'minheight': a:height,
    \ 'border': [1, 1, 1, 1],
    \ 'borderchars': g:floaterm_borderchars,
    \ 'borderhighlight': ['FloatermBorder'],
    \ 'padding': [0,1,0,1],
    \ 'highlight': 'Floaterm'
    \ }
  let opts.title = s:build_title(a:bufnr, a:title)
  let opts.zindex = len(floaterm#buflist#gather()) + 1
  let winid = popup_create(a:bufnr, opts)
  call setbufvar(a:bufnr, '&filetype', 'floaterm')
  return winid
endfunction

function! floaterm#window#open_split(bufnr, height, width, pos) abort
  if a:pos == 'top'
    execute 'topleft' . a:height . 'split'
  elseif a:pos == 'left'
    execute 'topleft' . a:width . 'vsplit'
  elseif a:pos == 'right'
    execute 'botright' . a:width . 'vsplit'
  else " default position: bottom
    execute 'botright' . a:height . 'split'
  endif
  execute 'buffer ' . a:bufnr
  return win_getid()
endfunction

function! floaterm#window#hide_floaterm_border(bufnr, ...) abort
  let winid = getbufvar(a:bufnr, 'floatermborder_winid', -1)
  if winid != v:null && s:winexists(winid)
    call nvim_win_close(winid, v:true)
  endif
  call setbufvar(a:bufnr, 'floatermborder_winid', -1)
endfunction

function! floaterm#window#hide_floaterm(bufnr) abort
  let winid = getbufvar(a:bufnr, 'floaterm_winid', -1)
  if winid == -1 | return | endif
  if has('nvim')
    if !s:winexists(winid) | return | endif
    call nvim_win_close(winid, v:true)
  else
    try      " there should be a function like `win_type()`
      call popup_close(winid)
    catch
      execute a:bufnr . 'hide'
    endtry
  endif
endfunction

"-----------------------------------------------------------------------------
" find **one** visible floaterm window
"-----------------------------------------------------------------------------
function! floaterm#window#find_floaterm_window() abort
  let found_winnr = 0
  for winnr in range(1, winnr('$'))
    if getbufvar(winbufnr(winnr), '&filetype') ==# 'floaterm'
      let found_winnr = winnr
      break
    endif
  endfor
  return found_winnr
endfunction
