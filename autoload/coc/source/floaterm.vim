" ============================================================================
" FileName: floaterm.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! coc#source#floaterm#init() abort
  return g:floaterm_complete_options
endfunction

function! coc#source#floaterm#complete(opt, cb) abort
  if exists("*floaterm#buflist#gather")
    let completion = []
    for bufnr in floaterm#buflist#gather()
      let lnum = getbufinfo(bufnr)[0]['lnum']
      let lines = getbufline(bufnr, max([lnum - 100, 0]), '$')
      for line in lines
        let item = map(split(line, ' '), {_, val -> {
          \ 'word': val,
          \ 'dup': 0,
          \ }})
        let completion += item
      endfor
    endfor
    call a:cb(completion)
  endif
endfunction
