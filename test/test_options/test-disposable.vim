" tests for the --disposable option

function! Test_01_disposable() abort
  Log '# FloatermNew --disposable'
    FloatermNew --disposable
    FloatermNew --disposable
    FloatermNew --disposable
    FloatermHide!
    sleep 100m
    Log floaterm#buflist#gather()
    Assert empty(floaterm#buflist#gather())

  FloatermKill!
  stopinsert
endfunction

call RunTests()
