" tests for the fzf-floaterm integration

function! Test_01_fzf_floaterm() abort
  if !g:run_in_ci | return | endif

  FloatermNew
  FloatermHide

  let candidates = fzf_floaterm#feed()
  Log candidates
  Assert !empty(candidates)

  FloatermKill!
  stopinsert
endfunction

call RunTests()
