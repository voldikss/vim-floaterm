" ============================================================================
" FileName: floaterm.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! coc#source#floaterm#init() abort
  return g:floaterm_complete_options
endfunction

function! coc#source#floaterm#complete(opt, cb) abort
  let lines = floaterm#buffer#getlines(-1, 100)
  let completion = []
  let [minlength, maxlength] = g:floaterm_complete_options['filter_length']

  for line in lines
    let item = map(
                \ filter(
                        \ s:matchstrlist(line, '[a-zA-Z0-9]\+'),
                        \ { _,val -> len(val) >= minlength && len(val) <= maxlength}
                      \ ),
                \ { _,val -> {'word': val, 'dup': 0} }
                \ )
    let completion += item
  endfor
  call a:cb(completion)
endfunction

function! s:matchstrlist(expr, pat) abort
  let res = []
  let start = 0
  while 1
    let m = matchstrpos(a:expr, a:pat, start)
    if m[1] == -1
      break
    endif
    call add(res, m[0])
    let start = m[2]
  endwhile
  return res
endfunction
