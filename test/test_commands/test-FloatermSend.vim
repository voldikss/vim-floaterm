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

call RunTests()
