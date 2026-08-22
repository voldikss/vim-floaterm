" tests for g:floaterm_wintype

function! Test_01_wintype() abort
  Log '# Set wintype to split/vsplit'
    let g:floaterm_wintype = 'split'
    FloatermNew
    AssertEqual 0,IsFloatOrPopup(win_getid())
    FloatermNew --wintype=float
    AssertEqual 1,IsFloatOrPopup(win_getid())

  Log '# Set wintype to float'
    let g:floaterm_wintype = 'float'
    FloatermNew
    AssertEqual 1,IsFloatOrPopup(win_getid())
    FloatermNew --wintype=split
    AssertEqual 0,IsFloatOrPopup(win_getid())

  Log '# Independent wintype value for each floaterm'
    FloatermNew --wintype=split
    FloatermNew --wintype=float
    FloatermPrev
    AssertEqual 0,IsFloatOrPopup(win_getid())
    FloatermNext
    AssertEqual 1,IsFloatOrPopup(win_getid())

  FloatermKill!
  stopinsert
endfunction

call RunTests()
