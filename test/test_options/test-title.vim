" tests for g:floaterm_title

function! s:GetTitleTopline() abort
  if has('nvim')
    let bd_winid = getbufvar(bufnr('%'), 'floaterm_borderwinid')
    return getbufline(winbufnr(bd_winid), 1)[0]
  else
    return popup_getoptions(win_getid()).title
  endif
endfunction

function! Test_01_title() abort
  let g:floaterm_title = 'floaterm ($1/$2)'
  Log '# 1/1'
    FloatermNew
    let topline = s:GetTitleTopline()
    Assert topline =~ 'floaterm (1/1)'
  Log '# 2|2'
    FloatermNew --title=floaterm\ ($1|$2)
    let topline = s:GetTitleTopline()
    Assert topline =~ 'floaterm (2|2)'
  Log '# 1/2'
    FloatermPrev
    let topline = s:GetTitleTopline()
    Assert topline =~ 'floaterm (1/2)'
  Log '# no title'
    let g:floaterm_title = ''
    FloatermNew
    let topline = s:GetTitleTopline()
    if has('nvim')
      Assert topline =~ '┌─*┐'
    else
      Assert topline == ''
    endif

  FloatermKill!
  stopinsert
endfunction

function! Test_02_title_name_placeholder() abort
  let saved = g:floaterm_title
  try
    Log '# $3 expands to the name'
    let g:floaterm_title = '$3 ($1/$2)'
    FloatermNew --name=build
    let topline = s:GetTitleTopline()
    Assert topline =~ 'build (1/1)'

    Log '# $3 is empty when no name is set'
    FloatermNew
    let topline = s:GetTitleTopline()
    Assert topline =~ ' (2/2)'

    FloatermKill!
    stopinsert

    Log '# title defaults to --name when --title is not given'
    " keep the default g:floaterm_title so the name fallback kicks in
    let g:floaterm_title = 'floaterm($1/$2)'
    FloatermNew --name=deploy
    let topline = s:GetTitleTopline()
    Assert topline =~ 'deploy'
    Assert topline !~ 'floaterm'

    Log '# explicit --title takes precedence over the name default'
    FloatermNew --name=ci --title=custom
    let topline = s:GetTitleTopline()
    Assert topline =~ 'custom'
    Assert topline !~ 'ci'

    FloatermKill!
    stopinsert
  finally
    let g:floaterm_title = saved
  endtry
endfunction

call RunTests()
