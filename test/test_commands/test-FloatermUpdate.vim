" tests for :FloatermUpdate

function! Test_01_update() abort
  Log '# Basic'
    FloatermNew
    FloatermUpdate --name=ft
    AssertEqual 'ft', b:floaterm_name

  FloatermKill!
  stopinsert
endfunction

call RunTests()
