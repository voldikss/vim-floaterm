" tests for the filetype observed by TermOpen autocmds (#438)

function! Test_01_termopen_filetype() abort
  if !has('nvim') | return | endif
  let g:termopen_filetype = ''
  augroup floaterm_test_termopen
    autocmd!
    autocmd TermOpen * let g:termopen_filetype =
          \ getbufvar(str2nr(expand('<abuf>')), '&filetype')
  augroup END

  Log '# filetype is floaterm inside TermOpen'
    FloatermNew
    AssertEqual 'floaterm', g:termopen_filetype

  autocmd! floaterm_test_termopen
  augroup! floaterm_test_termopen
  unlet g:termopen_filetype
  FloatermKill!
  stopinsert
endfunction

call RunTests()
