" tests for floaterm#config#get_all
" https://github.com/voldikss/vim-floaterm/issues/233

function! Test_01_get_all() abort
  function! MyFunc() abort
    " code
  endfunction

  FloatermNew
  let bufnr = bufnr('%')
  call setbufvar(bufnr, 'Fn', function("MyFunc"))
  call floaterm#config#get_all(bufnr)

  FloatermKill!
  stopinsert
endfunction

call RunTests()
