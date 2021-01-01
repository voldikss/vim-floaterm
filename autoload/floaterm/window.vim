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

function! s:format_title(bufnr, text) abort
  if empty(a:text) | return '' | endif
  let buffers = floaterm#buflist#gather()
  let cnt = len(buffers)
  let idx = index(buffers, a:bufnr) + 1
  let title = substitute(a:text, '$1', idx, 'gm')
  let title = substitute(title, '$2', cnt, 'gm')
  return title
endfunction

function! s:hide_border(winid) abort
  if s:winexists(a:winid)
    let bd_winid = getwinvar(a:winid, 'floatermborder_winid', -1)
    if s:winexists(bd_winid)
      call nvim_win_close(bd_winid, v:true)
    endif
    call nvim_win_set_var(a:winid, 'floatermborder_winid', -1)
  endif
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

function! s:on_floaterm_open(bufnr, winid, opts) abort
  call setbufvar(a:bufnr, 'floaterm_winid', a:winid)
  call setbufvar(a:bufnr, 'floaterm_opts', a:opts)
  call setbufvar(a:bufnr, '&buflisted', 0)
  call setbufvar(a:bufnr, '&filetype', 'floaterm')
  if has('nvim')
    " TODO: need to be reworked
    execute printf(
          \ 'autocmd BufHidden <buffer=%s> ++once call floaterm#window#hide(%s)',
          \ a:bufnr,
          \ a:bufnr
          \ )
  endif
endfunction

" TODO: give this function a better name
" @argument: opts, a floaterm local variable, will be stored as a `b:` variable
" @return: options, generated from `opts`, has more additional info, used to
"   config the floaterm style
function! s:parse_options(opts) abort
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

  " generate and return window configs based on a:opts
  let configs = deepcopy(a:opts)

  let configs.borderchars = g:floaterm_borderchars

  let width = configs.width
  if type(width) == v:t_float | let width = width * &columns | endif
  let configs.width = float2nr(width)

  let height = configs.height
  if type(height) == v:t_float | let height = height * (&lines - &cmdheight - 1) | endif
  let configs.height = float2nr(height)

  if configs.position == 'random'
    let randnum = str2nr(matchstr(reltimestr(reltime()), '\v\.@<=\d+')[1:])
    if s:get_wintype() == 'normal'
      let configs.position = ['top', 'right', 'bottom', 'left'][randnum % 4]
    else
      let configs.position = ['top', 'right', 'bottom', 'left', 'center', 'topleft', 'topright', 'bottomleft', 'bottomright', 'auto'][randnum % 10]
    endif
  endif

  let [row, col, anchor] = s:get_floatwin_pos(configs.width, configs.height, configs.position)
  let configs['anchor'] = anchor
  let configs['row'] = row
  let configs['col'] = col
  return configs
endfunction

function! s:open_float(bufnr, configs) abort
  let options = {
        \ 'relative': 'editor',
        \ 'anchor': a:configs.anchor,
        \ 'row': a:configs.row + (a:configs.anchor[0] == 'N' ? 1 : -1),
        \ 'col': a:configs.col + (a:configs.anchor[1] == 'W' ? 1 : -1),
        \ 'width': a:configs.width - 2,
        \ 'height': a:configs.height - 2,
        \ 'style':'minimal',
        \ }
  let winid = nvim_open_win(a:bufnr, v:true, options)
  call s:init_win(winid, v:false)

  let bd_options = {
        \ 'relative': 'editor',
        \ 'anchor': a:configs.anchor,
        \ 'row': a:configs.row,
        \ 'col': a:configs.col,
        \ 'width': a:configs.width,
        \ 'height': a:configs.height,
        \ 'focusable': v:false,
        \ 'style':'minimal',
        \ }
  let a:configs.title = s:format_title(a:bufnr, a:configs.title)
  let bd_bufnr = floaterm#buffer#create_border_buf(a:configs)
  let bd_winid = nvim_open_win(bd_bufnr, v:false, bd_options)
  call nvim_win_set_var(winid, 'floatermborder_winid', bd_winid)
  call s:init_win(bd_winid, v:true)
  return winid
endfunction

function! s:open_popup(bufnr, configs) abort
  let opts = {
        \ 'pos': a:configs.anchor,
        \ 'line': a:configs.row,
        \ 'col': a:configs.col,
        \ 'maxwidth': a:configs.width,
        \ 'minwidth': a:configs.width,
        \ 'maxheight': a:configs.height,
        \ 'minheight': a:configs.height,
        \ 'border': [1, 1, 1, 1],
        \ 'borderchars': a:configs.borderchars,
        \ 'borderhighlight': ['FloatermBorder'],
        \ 'padding': [0,1,0,1],
        \ 'highlight': 'Floaterm',
        \ 'zindex': len(floaterm#buflist#gather()) + 1
        \ }

  " vim will pad the end of title but not begin part
  " so we build the title as ' floaterm (idx/cnt)'
  let opts.title = ' ' . s:format_title(a:bufnr, a:configs.title)
  let winid = popup_create(a:bufnr, opts)
  call s:init_win(winid, v:false)
  return winid
endfunction

function! s:open_split(bufnr, configs) abort
  if a:configs.position == 'top'
    execute 'topleft' . a:configs.height . 'split'
  elseif a:configs.position == 'left'
    execute 'topleft' . a:configs.width . 'vsplit'
  elseif a:configs.position == 'right'
    execute 'botright' . a:configs.width . 'vsplit'
  else " default position: bottom
    execute 'botright' . a:configs.height . 'split'
  endif
  execute 'buffer ' . a:bufnr
  let winid = win_getid()
  call s:init_win(winid, v:false)
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
endfunction

function! floaterm#window#open(bufnr, opts) abort
  let configs = s:parse_options(a:opts)
  if configs.wintype == 'floating'
    let winid = s:open_float(a:bufnr, configs)
  elseif configs.wintype == 'popup'
    let winid = s:open_popup(a:bufnr, configs)
  else
    let winid = s:open_split(a:bufnr, configs)
  endif
  call s:on_floaterm_open(a:bufnr, winid, a:opts)
endfunction

function! floaterm#window#hide(bufnr) abort
  let winid = getbufvar(a:bufnr, 'floaterm_winid', -1)
  if !s:winexists(winid) | return | endif
  if has('nvim')
    call nvim_win_close(winid, v:true)
    call s:hide_border(winid)
  else
    if exists('*win_gettype')
      if win_gettype() == 'popup'
        call popup_close(winid)
      elseif bufwinnr(a:bufnr) > 0
        silent! execute bufwinnr(a:bufnr) . 'hide'
      endif
    else
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
