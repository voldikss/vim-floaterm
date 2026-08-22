" tests for the LeaderF-floaterm integration

function! Test_01_lf_floaterm() abort
  if !g:run_in_ci | return | endif

  FloatermNew
  FloatermHide

  let candidates = lf_floaterm#source()
  Log candidates
  Assert !empty(candidates)

  FloatermKill!
  stopinsert
endfunction

call RunTests()
