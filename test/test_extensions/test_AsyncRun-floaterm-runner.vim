" tests for the AsyncRun floaterm runner integration

function! Test_01_asyncrun_floaterm_runner() abort
  if !g:run_in_ci | return | endif

  AsyncRun -mode=term -pos=floaterm -position=bottomright -width=0.4  ls -la
  AssertEqual &ft, 'floaterm'
  FloatermHide

  FloatermKill!
  stopinsert
endfunction

call RunTests()
