" tests for the clap-floaterm integration

function! Test_01_clap_floaterm() abort
  if !g:run_in_ci | return | endif

  FloatermNew
  FloatermHide

  let candidates = g:clap#provider#floaterm#.source()
  Log candidates
  Assert !empty(candidates)

  FloatermKill!
  stopinsert
endfunction

call RunTests()
