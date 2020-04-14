" vim:sw=2:
" ============================================================================
" FileName: buffer.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! floaterm#buffer#create(linelist, opts) abort
  let bufnr = nvim_create_buf(v:false, v:true)
  call nvim_buf_set_lines(bufnr, 0, -1, v:true, a:linelist)
  for [name, value] in items(a:opts)
    call nvim_buf_set_option(bufnr, name, value)
  endfor
  return bufnr
endfunction

function! floaterm#buffer#update_winopts(bufnr, winopts) abort
  let winopts = getbufvar(a:bufnr, 'floaterm_winopts', {})
  for item in items(a:winopts)
    let winopts[item[0]] = item[1]
  endfor
  call setbufvar(a:bufnr, 'floaterm_winopts', winopts)
endfunction
