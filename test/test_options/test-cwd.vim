" tests for the --cwd option

function! Test_01_cwd() abort
  Log '# --cwd=/'
    let cwd = getcwd()
    FloatermNew --cwd=/
    " cwd should be restored after opening floaterm
    AssertEqual cwd, getcwd()

  Log '# --cwd=~'
    FloatermNew --cwd=<root>

  Log '# --cwd=..'
    FloatermNew --cwd=<root>

  Log '# --cwd=<root>'
    FloatermNew --cwd=<root>

  FloatermKill!
  stopinsert
endfunction

call RunTests()
