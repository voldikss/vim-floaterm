" tests for :FloatermSend

call setline(1, '# text to be send')

function! Test_01_send() abort
  FloatermNew
  let bufnr1 = bufnr('%')
  FloatermHide

  Log '# FloatermSend'
    FloatermSend
    sleep 500m
    Log getline('.')
    let lines = getbufline(bufnr1, 0, '$')
    for l in lines
      Log '  ' . l
    endfor
    Assert join(lines) =~ '# text to be send'

  Log '# FloatermSend with argument'
    FloatermNew
    let bufnr2 = bufnr('%')
    FloatermHide
    FloatermSend \# text to be send
    sleep 500m
    let lines = join(getbufline(bufnr2, 0, '$'))
    Assert lines =~ '# text to be send'

  FloatermKill!
  stopinsert
endfunction

function! Test_02_send_with_explicit_range() abort
  call setline(1, ['sendAAA', 'sendBBB', 'sendCCC'])
  FloatermNew
  let bufnr1 = bufnr('%')
  FloatermHide

  " leave stale visual marks on line 1, then send an explicit range: the
  " lines of the range, not the old selection, must be sent (#435)
  execute "normal! 1GV\<Esc>"
  2,3FloatermSend
  sleep 500m
  let lines = join(getbufline(bufnr1, 0, '$'))
  Assert lines =~ 'sendBBB'
  Assert lines =~ 'sendCCC'
  Assert lines !~ 'sendAAA'

  " sending the visual selection itself still works
  execute "normal! 1GV\<Esc>"
  '<,'>FloatermSend
  sleep 500m
  let lines = join(getbufline(bufnr1, 0, '$'))
  Assert lines =~ 'sendAAA'

  FloatermKill!
  stopinsert
endfunction

function! Test_03_send_visual_mode() abort
  call setline(1, 'LEFTxyzzyRIGHT')
  FloatermNew
  let bufnr1 = bufnr('%')
  FloatermHide

  " charwise selection: only the selected part is sent
  execute "normal! 1G04lv5l\<Esc>"
  '<,'>FloatermSend
  sleep 500m
  let lines = join(getbufline(bufnr1, 0, '$'))
  Assert lines =~ 'xyzzy'
  Assert lines !~ 'LEFT'
  Assert lines !~ 'RIGHT'

  FloatermKill!
  stopinsert
endfunction

call RunTests()
