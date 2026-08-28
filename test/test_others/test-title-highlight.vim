" tests for the FloatermTitle highlight group (#366)

function! s:title_marks(bd_bufnr) abort
  let ns = nvim_create_namespace('floaterm.title')
  return nvim_buf_get_extmarks(a:bd_bufnr, ns, 0, -1, {'details': v:true})
endfunction

function! Test_01_handdrawn_title_highlight() abort
  if !has('nvim') | return | endif
  let winborder_saved = &winborder
  set winborder=
  try
    Log '# title is highlighted with FloatermTitle'
    FloatermNew --title=mytitle
    let bufnr = bufnr('%')
    let bd_bufnr = winbufnr(getbufvar(bufnr, 'floaterm_borderwinid'))

    let marks = s:title_marks(bd_bufnr)
    AssertEqual 1, len(marks)
    AssertEqual 'FloatermTitle', marks[0][3].hl_group
    " the extmark covers exactly the title inside the top border line
    let top_line = getbufline(bd_bufnr, 1)[0]
    AssertEqual 'mytitle', top_line[marks[0][2] : marks[0][3].end_col - 1]

    Log '# centered title'
    FloatermNew --title=mytitle --titleposition=center
    let bufnr = bufnr('%')
    let bd_bufnr = winbufnr(getbufvar(bufnr, 'floaterm_borderwinid'))
    let marks = s:title_marks(bd_bufnr)
    AssertEqual 1, len(marks)
    let top_line = getbufline(bd_bufnr, 1)[0]
    AssertEqual 'mytitle', top_line[marks[0][2] : marks[0][3].end_col - 1]

    Log '# no title, no highlight'
    let title_saved = g:floaterm_title
    let g:floaterm_title = ''
    FloatermNew
    let g:floaterm_title = title_saved
    let bufnr = bufnr('%')
    let bd_bufnr = winbufnr(getbufvar(bufnr, 'floaterm_borderwinid'))
    let marks = s:title_marks(bd_bufnr)
    AssertEqual [], marks

    Log '# default link'
    redir => g:hi_out
    silent hi FloatermTitle
    redir END
    Assert g:hi_out =~# 'links to FloatermBorder'
  finally
    FloatermKill!
    let &winborder = winborder_saved
    stopinsert
  endtry
endfunction

call RunTests()
