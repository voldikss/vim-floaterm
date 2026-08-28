" vim:sw=2:
" ============================================================================
" FileName: floatwin.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

let s:has_popup = has('textprop') && has('patch-8.2.0286')
let s:has_float = has('nvim') && exists('*nvim_win_set_config')

function! floaterm#window#win_gettype() abort
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

function! floaterm#window#win_getpos(width, height, pos) abort
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

function! floaterm#window#make_title(bufnr, tmpl) abort
  if empty(a:tmpl) | return '' | endif
  let buffers = floaterm#buflist#gather()
  let cnt = len(buffers)
  let idx = index(buffers, a:bufnr) + 1
  let title = substitute(a:tmpl, '$1', idx, 'gm')
  let title = substitute(title, '$2', cnt, 'gm')
  return title
endfunction

function! s:winexists(winid) abort
  return !empty(getwininfo(a:winid))
endfunction

function! s:use_winborder() abort
  " neovim 0.11+ can draw the border itself via the 'winborder' option
  return exists('&winborder') && &winborder !=# '' && &winborder !=# 'none'
endfunction

function! s:open_float(bufnr, config) abort
  let native_border = s:use_winborder()
  let row = a:config.row + (a:config.anchor[0] == 'N' ? 1 : -1)
  let col = a:config.col + (a:config.anchor[1] == 'W' ? 1 : -1)
  if native_border
    " the border drawn by neovim extends outwards from the window
    let row = a:config.row
    let col = a:config.col
  end

  let options = {
        \ 'relative': 'editor',
        \ 'anchor': a:config.anchor,
        \ 'row': row,
        \ 'col': col,
        \ 'width': a:config.width - 2,
        \ 'height': a:config.height - 2,
        \ 'style':'minimal',
        \ }
  if native_border && !empty(a:config.title)
    let options.title = a:config.title
    let options.title_pos = index(['left', 'center', 'right'], a:config.titleposition) >= 0
          \ ? a:config.titleposition : 'left'
  endif
  let winid = nvim_open_win(a:bufnr, v:true, options)
  call s:init_win(winid, v:false)
  if native_border
    " the border and its title are drawn by neovim itself; route them to
    " FloatermBorder, the highlight group used by the hand-drawn border
    call setwinvar(winid, '&winhl',
          \ 'Normal:Floaterm,NormalNC:FloatermNC,FloatBorder:FloatermBorder,FloatTitle:FloatermBorder')
  endif
  call floaterm#config#set(a:bufnr, 'winid', winid)

  if !native_border
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
    call floaterm#config#set(a:bufnr, 'borderwinid', bd_winid)
  end
  return winid
endfunction

function! s:open_popup(bufnr, config) abort
  let title = a:config.title
  if a:config.titleposition != 'left'
    let title = floaterm#buffer#create_top_border(a:config, a:config.width)
  endif
  let options = {
        \ 'pos': a:config.anchor,
        \ 'line': a:config.row,
        \ 'col': a:config.col,
        \ 'maxwidth': a:config.width - 2,
        \ 'minwidth': a:config.width - 2,
        \ 'maxheight': a:config.height - 2,
        \ 'minheight': a:config.height - 2,
        \ 'title': title,
        \ 'border': [1, 1, 1, 1],
        \ 'borderchars': a:config.borderchars,
        \ 'borderhighlight': ['FloatermBorder'],
        \ 'padding': [0,1,0,1],
        \ 'highlight': 'Floaterm',
        \ 'zindex': len(floaterm#buflist#gather()) + 1
        \ }
  let winid = popup_create(a:bufnr, options)
  call s:init_win(winid, v:false)
  call floaterm#config#set(a:bufnr, 'winid', winid)
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
  call floaterm#config#set(a:bufnr, 'winid', winid)
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
  if g:floaterm_autohide ==# 'always'
    " hide all other floaterms
    call floaterm#hide(1, 0, '')
  elseif g:floaterm_autohide ==# 'smart'
    " hide all other floaterms that will be overlaied by this one
    for bufnr in floaterm#buflist#gather()
      if getbufvar(bufnr, 'floaterm_position') == a:currpos
        call floaterm#hide(0, bufnr, '')
      endif
    endfor
  endif " 'never': nop
endfunction

function! floaterm#window#open(bufnr, config) abort
  let winnr = bufwinnr(a:bufnr)
  if winnr > -1
    execute winnr . 'wincmd w'
    return
  endif

  call s:autohide(a:config.position)

  if a:config.wintype =~ 'split'
    call s:open_split(a:bufnr, a:config)
  else " backward compatiblity: float|floating|popup -> float
    if s:has_float
      call s:open_float(a:bufnr, a:config)
    else
      call s:open_popup(a:bufnr, a:config)
    endif
  endif
endfunction

" Record the cursor position of the floaterm `bufnr`, used by the smart mode
" of `g:floaterm_autoinsert` (see floaterm#util#startinsert())
function! floaterm#window#record_cursor(bufnr) abort
  if bufnr('%') == a:bufnr
    " the common case: leaving or hiding the focused floaterm
    call floaterm#config#set(a:bufnr, 'cursorline', line('.'))
  else
    " hiding the floaterm from another window, read the position via its
    " window id; `line()` with a winid is not supported on older Vim, in
    " which case keep the last recorded position
    let winnr = bufwinnr(a:bufnr)
    if winnr > 0
      try
        call floaterm#config#set(a:bufnr, 'cursorline', line('.', win_getid(winnr)))
      catch
      endtry
    endif
  endif
endfunction

function! floaterm#window#hide(bufnr) abort
  if getbufvar(a:bufnr, '&filetype') != 'floaterm'
    return
  endif
  call floaterm#window#record_cursor(a:bufnr)
  let winid = floaterm#config#get(a:bufnr, 'winid', -1)
  let bd_winid = floaterm#config#get(a:bufnr, 'borderwinid', -1)
  let was_visible = s:winexists(winid)
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
  if was_visible && bufexists(a:bufnr)
  \ && floaterm#config#get(a:bufnr, 'disposable')
  \ && floaterm#terminal#jobexists(a:bufnr)
    call floaterm#terminal#kill(a:bufnr, v:true)
  endif
  checktime
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

" ----------------------------------------------------------------------------
" recompute the geometry of every visible floaterm, called on |VimResized| so
" that floaterms sized proportionally (e.g. g:floaterm_width = 0.6) follow the
" new editor size (#296). Hidden floaterms are repositioned when they are
" opened again, so only visible ones need to be updated here.
" ----------------------------------------------------------------------------
function! floaterm#window#on_vimresized() abort
  for bufnr in floaterm#buflist#gather()
    let winid = floaterm#config#get(bufnr, 'winid', -1)
    if !s:winexists(winid)
      continue
    endif
    let config = floaterm#config#parse(bufnr, floaterm#config#get_all(bufnr))
    if config.wintype =~ 'split'
      let winnr = bufwinnr(bufnr)
      if winnr > 0
        if config.wintype == 'vsplit'
          execute 'vertical ' . winnr . 'resize ' . config.width
        else
          execute winnr . 'resize ' . config.height
        endif
      endif
    elseif s:has_float
      let native_border = s:use_winborder()
      let row = config.row + (config.anchor[0] == 'N' ? 1 : -1)
      let col = config.col + (config.anchor[1] == 'W' ? 1 : -1)
      if native_border
        let row = config.row
        let col = config.col
      endif
      call nvim_win_set_config(winid, {
            \ 'relative': 'editor',
            \ 'anchor': config.anchor,
            \ 'row': row,
            \ 'col': col,
            \ 'width': config.width - 2,
            \ 'height': config.height - 2,
            \ })
      let bd_winid = get(config, 'borderwinid', -1)
      if s:winexists(bd_winid)
        " the border buffer is a static frame, rebuild it for the new size
        call nvim_win_set_buf(bd_winid, floaterm#buffer#create_border_buf(config))
        call nvim_win_set_config(bd_winid, {
              \ 'relative': 'editor',
              \ 'anchor': config.anchor,
              \ 'row': config.row,
              \ 'col': config.col,
              \ 'width': config.width,
              \ 'height': config.height,
              \ })
      endif
    else
      let title = config.title
      if config.titleposition != 'left'
        let title = floaterm#buffer#create_top_border(config, config.width - 2)
      endif
      call popup_setoptions(winid, {'title': title})
      call popup_move(winid, {
            \ 'line': config.row,
            \ 'col': config.col,
            \ 'maxwidth': config.width - 2,
            \ 'minwidth': config.width - 2,
            \ 'maxheight': config.height - 2,
            \ 'minheight': config.height - 2,
            \ })
    endif
  endfor
endfunction
