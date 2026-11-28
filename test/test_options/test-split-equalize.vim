" A split floaterm must be resizable by layout commands such as :wincmd =.
" 'winfixheight' is only meant for floating windows; setting it on a split
" prevents :wincmd = from equalizing the windows.

function! Test_01_equalize_split() abort
  FloatermNew --wintype=split --position=belowright
  let ft_win = win_getid()
  let h_ft_before = winheight(ft_win)
  wincmd p
  wincmd =
  let h_ft_after = winheight(ft_win)
  let h_other_after = winheight(0)
  Log printf('winfixheight=%d before ft=%d, after ft=%d other=%d',
        \ getwinvar(ft_win, '&winfixheight'), h_ft_before,
        \ h_ft_after, h_other_after)
  AssertEqual 0, getwinvar(ft_win, '&winfixheight')
  AssertNotEqual h_ft_before, h_ft_after
  Assert abs(h_ft_after - h_other_after) <= 1
  FloatermKill!
  stopinsert
endfunction

function! Test_02_equalize_vsplit() abort
  FloatermNew --wintype=vsplit --position=belowright
  let ft_win = win_getid()
  let w_ft_before = winwidth(ft_win)
  wincmd p
  wincmd =
  let w_ft_after = winwidth(ft_win)
  let w_other_after = winwidth(0)
  Log printf('winfixwidth=%d before ft=%d, after ft=%d other=%d',
        \ getwinvar(ft_win, '&winfixwidth'), w_ft_before,
        \ w_ft_after, w_other_after)
  AssertEqual 0, getwinvar(ft_win, '&winfixwidth')
  AssertNotEqual w_ft_before, w_ft_after
  Assert abs(w_ft_after - w_other_after) <= 1
  FloatermKill!
  stopinsert
endfunction

call RunTests()
