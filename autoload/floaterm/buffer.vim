" ============================================================================
" FileName: buffer.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! floaterm#buffer#create_scratch_buf(...) abort
  let bufnr = nvim_create_buf(v:false, v:true)
  call nvim_buf_set_option(bufnr, 'buftype', 'nofile')
  call nvim_buf_set_option(bufnr, 'buftype', 'nofile')
  call nvim_buf_set_option(bufnr, 'bufhidden', 'wipe')
  call nvim_buf_set_option(bufnr, 'swapfile', v:false)
  call nvim_buf_set_option(bufnr, 'undolevels', -1)
  let lines = get(a:, 1, v:null)
  if type(lines) != 7
    call nvim_buf_set_option(bufnr, 'modifiable', v:true)
    call nvim_buf_set_lines(bufnr, 0, -1, v:false, lines)
    call nvim_buf_set_option(bufnr, 'modifiable', v:false)
  endif
  return bufnr
endfunction

function! floaterm#buffer#create_border_buf(options) abort
  let repeat_width = a:options.width - 2
  let repeat_height = a:options.height - 2
  let title = a:options.title
  let title_width = strdisplaywidth(title)
  let borderchars = a:options.borderchars
  let [c_top, c_right, c_bottom, c_left, c_topleft, c_topright, c_botright, c_botleft] = borderchars
  let content = [c_topleft . title . repeat(c_top, repeat_width - title_width) . c_topright]
  let content += repeat([c_left . repeat(' ', repeat_width) . c_right], repeat_height)
  let content += [c_botleft . repeat(c_bottom, repeat_width) . c_botright]
  return floaterm#buffer#create_scratch_buf(content)
endfunction

function! floaterm#buffer#getlines(bufnr, length) abort
  let lines = []
  if a:bufnr == -1
    for bufnr in floaterm#buflist#gather()
      let lnum = getbufinfo(bufnr)[0]['lnum']
      let lines += getbufline(bufnr, max([lnum - a:length, 0]), '$')
    endfor
  else
    let lnum = getbufinfo(a:bufnr)[0]['lnum']
    let lines += getbufline(a:bufnr, max([lnum - a:length, 0]), '$')
  endif
  return lines
endfunction
