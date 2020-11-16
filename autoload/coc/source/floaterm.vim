" ============================================================================
" FileName: floaterm.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! coc#source#floaterm#init() abort
  return g:floaterm_complete_options
endfunction

function! coc#source#floaterm#complete(opt, cb) abort
  let lines = floaterm#util#getbufline(-1, 100)
  let completion = []
  let [minlength, maxlength] = g:floaterm_complete_options['filter_length']
  for line in lines
    let item = map(split(line, ' '), {_, val -> {
      \ 'word': val,
      \ 'dup': 0,
      \ }})
    call filter(item, {_, val -> len(val.word) >= minlength && len(val.word) <= maxlength})
    let completion += item
  endfor
  call a:cb(completion)
endfunction
