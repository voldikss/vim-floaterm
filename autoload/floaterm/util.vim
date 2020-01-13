" ============================================================================
" FileName: autoload/floaterm/util.vim
" Description:
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! floaterm#util#floating_win_pos(width, height) abort
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

function! floaterm#util#is_floaterm_available() abort
  if exists('*nvim_win_set_config')
    if g:floaterm_type == v:null
      let g:floaterm_type = 'floating'
    endif
  elseif has('terminal')
    let g:floaterm_type = 'normal'
  else
    let message = 'Terminal feature is required, please upgrade your vim/nvim'
    call floaterm#util#show_msg(message, 'error')
    return v:false
  endif
  return v:true
endfunction

function! s:echo(group, msg) abort
  if a:msg ==# '' | return | endif
  execute 'echohl' a:group
  echo a:msg
  echon ' '
  echohl NONE
endfunction

function! s:echon(group, msg) abort
  if a:msg ==# '' | return | endif
  execute 'echohl' a:group
  echon a:msg
  echon ' '
  echohl NONE
endfunction

function! floaterm#util#show_msg(message, ...) abort
  if a:0 == 0
    let msg_type = 'info'
  else
    let msg_type = a:1
  endif

  if type(a:message) != 1
    let message = string(a:message)
  else
    let message = a:message
  endif

  call s:echo('Constant', '[vim-floaterm]')

  if msg_type ==# 'info'
    call s:echon('Normal', message)
  elseif msg_type ==# 'warning'
    call s:echon('WarningMsg', message)
  elseif msg_type ==# 'error'
    call s:echon('Error', message)
  endif
endfunction

function! floaterm#util#get_normalfloat_fg() abort
  let hiGroup = 'NormalFloat'
  while v:true
    let hiInfo = execute('hi ' . hiGroup)
    let fgcolor = matchstr(hiInfo, 'guifg=\zs\S*')
    let hiGroup = matchstr(hiInfo, 'links to \zs\S*')
    if fgcolor !=# '' || hiGroup ==# ''
      break
    endif
  endwhile
  " If the foreground color isn't found eventually, use white
  if fgcolor ==# ''
    let fgcolor = '#FFFFFF'
  endif
  return fgcolor
endfunction

function! floaterm#util#get_normalfloat_bg() abort
  let hiGroup = 'NormalFloat'
  while v:true
    let hiInfo = execute('hi ' . hiGroup)
    let bgcolor = matchstr(hiInfo, 'guibg=\zs\S*')
    let hiGroup = matchstr(hiInfo, 'links to \zs\S*')
    if bgcolor !=# '' || hiGroup ==# ''
      break
    endif
  endwhile
  " If the background color isn't found eventually, use black
  if bgcolor ==# ''
    let bgcolor = '#000000'
  endif
  return bgcolor
endfunction
