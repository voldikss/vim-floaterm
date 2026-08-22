" tests for :FloatermNew

call setline(1, '# text to be send')

function! Test_01_new() abort
  Log '# FloatermNew with range'
    normal! G
    AssertEqual getline('.'), '# text to be send'
    execute "normal! V\<Esc>"
    :'<,'>FloatermNew
    sleep 500m
    let bufnr = bufnr()
    let lines = getbufline(bufnr, 0, '$')
    for l in lines
      Log '  ' . l
    endfor
    Assert IsInFloatermBuffer()
    Assert join(lines) =~ '# text to be send'

  Log '# FloatermNew'
    FloatermNew
    Assert IsInFloatermBuffer()

  Log '# FloatermNew!'
    FloatermNew!
    Assert IsInFloatermBuffer()

  Log '# FloatermNew with arguments'
    FloatermNew --height=0.6 --width=0.4 --wintype=float --name=test --position=topleft --autoclose=never ls
    Assert IsInFloatermBuffer()

  FloatermKill!
  stopinsert
endfunction

call RunTests()
