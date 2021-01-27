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
    if s:has_float || s:has_popup
      return 'float'
    else
      return 'split'
    endif
  elseif g:floaterm_wintype =~ 'split'
    return g:floaterm_wintype
  else " backward compatiblity: float|floating|popup -> float
    if s:has_float || s:has_popup
      return 'float'
    else
      call floaterm#util#show_msg("floating or popup feature is not found, fall back to normal window", 'warning')
      return 'split'
    endif
  endif
endfunction

function! s:make_title(bufnr, tmpl) abort
  if empty(a:tmpl) | return '' | endif
  let buffers = floaterm#buflist#gather()
  let cnt = len(buffers)
  let idx = index(buffers, a:bufnr) + 1
  let title = substitute(a:tmpl, '$1', idx, 'gm')
  let title = substitute(title, '$2', cnt, 'gm')
  return title
endfunction

function! s:get_floatwin_pos(width, height, pos) abort
  if a:pos == 'topright'
    let row = 1
    let col = &columns
    let anchor = 'NE'
  elseif a:pos == 'topleft'
    let row = 1
    let col = 0
    let anchor = 'NW'
  elseif a:pos == 'bottomright'
    let row = &lines - &cmdheight - 1
    let col = &columns
    let anchor = 'SE'
  elseif a:pos == 'bottomleft'
    let row = &lines - &cmdheight - 1
    let col = 0
    let anchor = 'SW'
  elseif a:pos == 'top'
    let row = 1
    let col = (&columns - a:width)/2
    let anchor = 'NW'
  elseif a:pos == 'right'
    let row = (&lines - a:height)/2
    let col = &columns
    let anchor = 'NE'
  elseif a:pos == 'bottom'
    let row = &lines - &cmdheight - 1
    let col = (&columns - a:width)/2
    let anchor = 'SW'
  elseif a:pos == 'left'
    let row = (&lines - a:height)/2
    let col = 0
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
    let winpos = win_screenpos(0)
    let row = winpos[0] - 1 + winline()
    let col = winpos[1] - 1 + wincol()
    if row + a:height <= &lines - &cmdheight - 1
      let vert = 'N'
    else
      let vert = 'S'
      let row -= 1
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

" TODO: give this function a better name
" @argument: config, a floaterm local variable, will be stored as a `b:` variable
" @return: config, generated from `a:config`, has more additional info, used to
"   config the floaterm style
function! s:parse_config(bufnr, config) abort
  let a:config.title       = get(a:config, 'title', g:floaterm_title)
  let a:config.width       = get(a:config, 'width', g:floaterm_width)
  let a:config.height      = get(a:config, 'height', g:floaterm_height)
  let a:config.wintype     = get(a:config, 'wintype', s:get_wintype())
  let a:config.position    = get(a:config, 'position', g:floaterm_position)
  let a:config.autoclose   = get(a:config, 'autoclose', g:floaterm_autoclose)
  let a:config.borderchars = get(a:config, 'borderchars', g:floaterm_borderchars)

  " Edge cases
  if type(a:config.height) == v:t_number && a:config.height < 3
    call floaterm#util#show_msg('Floaterm height should be at least 3', 'warning')
    let a:config.height = 3
  endif
  if type(a:config.width) == v:t_number && a:config.width < 3
    call floaterm#util#show_msg('Floaterm width should be at least 3', 'warning')
    let a:config.width = 3
  endif
  " backward compatiblity
  if a:config.wintype == 'normal'
    let a:config.wintype = 'split'
  endif
  if a:config.wintype =~ 'split'
    if a:config.position == 'center'
      let a:config.position = 'botright'
    elseif a:config.position == 'top' || a:config.position == 'left'
      let a:config.position = 'aboveleft'
    elseif a:config.position == 'bottom' || a:config.position == 'right'
      let a:config.position = 'belowright'
    endif
  endif

  " Dump these configs into buffer, they can be reused for reopening
  call floaterm#buffer#set_config_dict(a:bufnr, a:config)

  " The following configs (width, height, borderchars, position) should be
  " parsed and become static. After opening windows, the configs are discard
  let config = deepcopy(a:config)

  let config.title = s:make_title(a:bufnr, a:config.title)

  let width = config.width
  if type(width) == v:t_float | let width = width * &columns | endif
  let config.width = float2nr(width)

  let height = config.height
  if type(height) == v:t_float | let height = height * (&lines - &cmdheight - 1) | endif
  let config.height = float2nr(height)

  let borderchars = config.borderchars
  " g:floaterm_borderchars is type v:t_list in old version vim-floaterm
  " strcharpart is useful for multiple-byte characters
  if type(borderchars) == v:t_string
    let borderchars = map(range(8), { idx -> strcharpart(borderchars, idx, 1) })
  endif
  let config.borderchars = borderchars

  if config.position == 'random'
    let randnum = str2nr(matchstr(reltimestr(reltime()), '\v\.@<=\d+')[1:])
    if config.wintype =~ 'split'
      let config.position = ['leftabove', 'aboveleft', 'rightbelow', 'belowright', 'topleft', 'botright'][randnum % 4]
    else
      let config.position = ['top', 'right', 'bottom', 'left', 'center', 'topleft', 'topright', 'bottomleft', 'bottomright', 'auto'][randnum % 10]
    endif
  endif

  let [row, col, anchor] = s:get_floatwin_pos(config.width, config.height, config.position)
  let config['anchor'] = anchor
  let config['row'] = row
  let config['col'] = col
  return config
endfunction

function! s:open_float(bufnr, config) abort
  let options = {
        \ 'relative': 'editor',
        \ 'anchor': a:config.anchor,
        \ 'row': a:config.row + (a:config.anchor[0] == 'N' ? 1 : -1),
        \ 'col': a:config.col + (a:config.anchor[1] == 'W' ? 1 : -1),
        \ 'width': a:config.width - 2,
        \ 'height': a:config.height - 2,
        \ 'style':'minimal',
        \ }
  let winid = nvim_open_win(a:bufnr, v:true, options)
  call s:init_win(winid, v:false)
  call floaterm#buffer#set_config(a:bufnr, 'winid', winid)

  let bd_options = {
        \ 'relative': 'editor',
        \ 'anchor': a:config.anchor,
        \ 'row': a:config.row,
        \ 'col': a:config.col,
        \ 'width': a:config.width,
        \ 'height': a:config.height,
        \ 'focusable': v:false,
        \ 'style':'minimal',
        \ }
  let bd_bufnr = floaterm#buffer#create_border_buf(a:config)
  let bd_winid = nvim_open_win(bd_bufnr, v:false, bd_options)
  call s:init_win(bd_winid, v:true)
  call floaterm#buffer#set_config(a:bufnr, 'borderwinid', bd_winid)
  return winid
endfunction

function! s:open_popup(bufnr, config) abort
  let options = {
        \ 'pos': a:config.anchor,
        \ 'line': a:config.row,
        \ 'col': a:config.col,
        \ 'maxwidth': a:config.width - 2,
        \ 'minwidth': a:config.width - 2,
        \ 'maxheight': a:config.height - 2,
        \ 'minheight': a:config.height - 2,
        \ 'title': a:config.title,
        \ 'border': [1, 1, 1, 1],
        \ 'borderchars': a:config.borderchars,
        \ 'borderhighlight': ['FloatermBorder'],
        \ 'padding': [0,1,0,1],
        \ 'highlight': 'Floaterm',
        \ 'zindex': len(floaterm#buflist#gather()) + 1
        \ }
  let winid = popup_create(a:bufnr, options)
  call s:init_win(winid, v:false)
  call floaterm#buffer#set_config(a:bufnr, 'winid', winid)
  return winid
endfunction

function! s:open_split(bufnr, config) abort
  if a:config.wintype == 'split'
    execute a:config.position . a:config.height . 'split'
  elseif a:config.wintype == 'vsplit'
    execute a:config.position . a:config.width . 'vsplit'
  endif
  execute 'buffer ' . a:bufnr
  let winid = win_getid()
  call s:init_win(winid, v:false)
  call floaterm#buffer#set_config(a:bufnr, 'winid', winid)
  return winid
endfunction

function! s:init_win(winid, is_border) abort
  if has('nvim')
    call setwinvar(a:winid, '&winhl', 'Normal:Floaterm,NormalNC:FloatermNC')
    if a:is_border
      call setwinvar(a:winid, '&winhl', 'Normal:FloatermBorder')
    endif
  else
    call setwinvar(a:winid, 'wincolor', 'Floaterm')
  endif
  call setwinvar(a:winid, '&sidescrolloff', 0)
  call setwinvar(a:winid, '&colorcolumn', '')
  call setwinvar(a:winid, '&winfixheight', 1)
  call setwinvar(a:winid, '&winfixwidth', 1)
endfunction

" :currpos: the position of the floaterm which will be opened soon
function! s:autohide(currpos) abort
  if g:floaterm_autohide == 2
    " hide all other floaterms
    call floaterm#hide(1, 0, '')
  elseif g:floaterm_autohide == 1
    " hide all other floaterms that will be overlaied by this one
    for bufnr in floaterm#buflist#gather()
      if getbufvar(bufnr, 'floaterm_position') == a:currpos
        call floaterm#hide(0, bufnr, '')
      endif
    endfor
  elseif g:floaterm_autohide == 0
    " nop
  endif
endfunction

function! floaterm#window#open(bufnr, config) abort
  let winnr = bufwinnr(a:bufnr)
  if winnr > -1
    execute winnr . 'wincmd w'
    return
  endif

  let config = s:parse_config(a:bufnr, a:config)

  call s:autohide(config.position)

  if config.wintype =~ 'split'
    call s:open_split(a:bufnr, config)
  else " backward compatiblity: float|floating|popup -> float
    if s:has_float
      call s:open_float(a:bufnr, config)
    else
      call s:open_popup(a:bufnr, config)
    endif
  endif
endfunction

function! floaterm#window#hide(bufnr) abort
  if getbufvar(a:bufnr, '&filetype') != 'floaterm'
    return
  endif
  let winid = floaterm#buffer#get_config(a:bufnr, 'winid', -1)
  let bd_winid = floaterm#buffer#get_config(a:bufnr, 'borderwinid', -1)
  if has('nvim')
    if s:winexists(winid)
      call nvim_win_close(winid, v:true)
    endif
    if s:winexists(bd_winid)
      call nvim_win_close(bd_winid, v:true)
    endif
  else
    if s:winexists(winid)
      try
        call popup_close(winid)
      catch
        if bufwinnr(a:bufnr) > 0
          silent! execute bufwinnr(a:bufnr) . 'hide'
        endif
      endtry
    endif
  endif
  silent checktime
endfunction

" find **one** visible floaterm window
function! floaterm#window#find() abort
  let found_winnr = 0
  for winnr in range(1, winnr('$'))
    if getbufvar(winbufnr(winnr), '&filetype') ==# 'floaterm'
      let found_winnr = winnr
      break
    endif
  endfor
  return found_winnr
endfunction
