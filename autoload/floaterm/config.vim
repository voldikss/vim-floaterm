" ============================================================================
" FileName: config.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! floaterm#config#get(bufnr, key, ...) abort
  let key = 'floaterm_' . a:key
  let val = getbufvar(a:bufnr, key)
  if val == '' && a:0 == 1
    return a:1
  endif
  return val
endfunction

function! floaterm#config#get_all(bufnr) abort
  let config = {}
  for var in items(getbufvar(a:bufnr, ''))
    if var[0] =~ '^floaterm_'
      let config[var[0][9:]] = var[1]
    endif
  endfor
  return config
endfunction

function! floaterm#config#set(bufnr, key, val) abort
  let key = 'floaterm_' . a:key
  call setbufvar(a:bufnr, key, a:val)
endfunction

function! floaterm#config#set_all(bufnr, config) abort
  for [key, val] in items(a:config)
    call floaterm#config#set(a:bufnr, key, val)
  endfor
endfunction

" TODO: give this function a better name
" @argument: config, a floaterm local variable, will be stored as a `b:` variable
" @return: config, generated from `a:config`, has more additional info, used to
"   config the floaterm style
function! floaterm#config#parse(bufnr, config) abort
  let a:config.title       = get(a:config, 'title', g:floaterm_title)
  let a:config.width       = get(a:config, 'width', g:floaterm_width)
  let a:config.height      = get(a:config, 'height', g:floaterm_height)
  let a:config.opener      = get(a:config, 'opener', g:floaterm_opener)
  let a:config.wintype     = get(a:config, 'wintype', floaterm#window#win_gettype())
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
  call floaterm#config#set_all(a:bufnr, a:config)

  " The following configs (width, height, borderchars, position) should be
  " parsed and become static. After opening windows, the configs are discard
  let config = deepcopy(a:config)

  let config.title = floaterm#window#make_title(a:bufnr, a:config.title)

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

  let [row, col, anchor] = floaterm#window#win_getpos(config.width, config.height, config.position)
  let config['anchor'] = anchor
  let config['row'] = row
  let config['col'] = col
  return config
endfunction

