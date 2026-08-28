" tests for floaterm#cmdline#parse and floaterm#cmdline#complete

function! s:check_complete(command, expected, handler) abort
  let commands = split(a:command)
  let arg_lead = a:command[-1:] == ' ' ? '' : commands[-1]
  let command = a:command
  let cursor_pos = len(a:command)
  let result = a:handler(arg_lead, command, cursor_pos)
  if a:expected != result
    Log printf('Command:  `:%s`', a:command)
    Log printf("Actual:   %s", result)
    Log printf('Expected: %s', string(a:expected))
  endif
  AssertEqual a:expected, result
endfunction

function! Test_01_parse() abort
  let argstr ='--height=0.6 --width=0.4 --wintype=float --name=floaterm1 --position=topleft --autoclose=always ranger --cmd="cd ~"'
  let [cmd, config] = floaterm#cmdline#parse(argstr)
  AssertEqual 'ranger --cmd="cd ~"', cmd
  AssertEqual {
        \ 'wintype': 'float',
        \ 'name': 'floaterm1',
        \ 'autoclose': 'always',
        \ 'width': 0.4,
        \ 'height': 0.6,
        \ 'position': 'topleft'
        \ }, config
endfunction

function! Test_02_parse_expand_feature() abort
  silent !touch test.txt && echo first.line > test.txt
  edit ./test.txt
  normal! gg0

  " %<
  AssertEqual expand('%<'), floaterm#cmdline#parse('%<')[0]
  " %\(:[phtreS8\~\.]\)
  AssertEqual expand('%'), floaterm#cmdline#parse('%')[0]
  AssertEqual expand('%:p'), floaterm#cmdline#parse('%:p')[0]
  AssertEqual expand('%:h'), floaterm#cmdline#parse('%:h')[0]
  AssertEqual expand('%:t'), floaterm#cmdline#parse('%:t')[0]
  AssertEqual expand('%:r'), floaterm#cmdline#parse('%:r')[0]
  AssertEqual expand('%:e'), floaterm#cmdline#parse('%:e')[0]
  AssertEqual expand('%:S'), floaterm#cmdline#parse('%:S')[0]
  AssertEqual expand('%:8'), floaterm#cmdline#parse('%:8')[0]
  AssertEqual expand('%:~'), floaterm#cmdline#parse('%:~')[0]
  AssertEqual expand('%:.'), floaterm#cmdline#parse('%:.')[0]
  " %\(:g\=s?.*?.*?\)
  AssertEqual expand('%:s?test?main?'), floaterm#cmdline#parse('%:s?test?main?')[0]
  AssertEqual expand('%:gs?test?main?'), floaterm#cmdline#parse('%:gs?test?main?')[0]
  AssertEqual '%', floaterm#cmdline#parse('\%')[0]
  AssertEqual '%:p', floaterm#cmdline#parse('\%:p')[0]
  " %\(\(:g\=s?.*?.*?\)\|\(:[phtreS8\~\.]\)\)*
  AssertEqual expand('%:p:h'), floaterm#cmdline#parse('%:p:h')[0]
  AssertEqual expand('%:p:s?test?main?'), floaterm#cmdline#parse('%:p:s?test?main?')[0]

  " <cfile><
  AssertEqual expand('<cfile><'), floaterm#cmdline#parse('<cfile><')[0]
  " <cfile>\(:[phtreS8\~\.]\)
  AssertEqual expand('<cfile>'), floaterm#cmdline#parse('<cfile>')[0]
  AssertEqual expand('<cfile>:p'), floaterm#cmdline#parse('<cfile>:p')[0]
  AssertEqual expand('<cfile>:h'), floaterm#cmdline#parse('<cfile>:h')[0]
  AssertEqual expand('<cfile>:t'), floaterm#cmdline#parse('<cfile>:t')[0]
  AssertEqual expand('<cfile>:r'), floaterm#cmdline#parse('<cfile>:r')[0]
  AssertEqual expand('<cfile>:e'), floaterm#cmdline#parse('<cfile>:e')[0]
  AssertEqual expand('<cfile>:S'), floaterm#cmdline#parse('<cfile>:S')[0]
  AssertEqual expand('<cfile>:8'), floaterm#cmdline#parse('<cfile>:8')[0]
  AssertEqual expand('<cfile>:~'), floaterm#cmdline#parse('<cfile>:~')[0]
  AssertEqual expand('<cfile>:.'), floaterm#cmdline#parse('<cfile>:.')[0]
  " <cfile>\(:g\=s?.*?.*?\)
  AssertEqual expand('<cfile>:s?test?main?'), floaterm#cmdline#parse('<cfile>:s?test?main?')[0]
  AssertEqual expand('<cfile>:gs?test?main?'), floaterm#cmdline#parse('<cfile>:gs?test?main?')[0]
  AssertEqual '<cfile>', floaterm#cmdline#parse('\<cfile>')[0]
  AssertEqual '<cfile>:p', floaterm#cmdline#parse('\<cfile>:p')[0]
  " <cfile>\(\(:g\=s?.*?.*?\)\|\(:[phtreS8\~\.]\)\)*
  AssertEqual expand('<cfile>:p:h'), floaterm#cmdline#parse('<cfile>:p:h')[0]
  AssertEqual expand('<cfile>:p:s?test?main?'), floaterm#cmdline#parse('<cfile>:p:s?test?main?')[0]

  " #, #N, ## and their modifiers (#443)
  silent !echo another.line > another.txt
  edit ./another.txt
  AssertEqual expand('#'), floaterm#cmdline#parse('#')[0]
  AssertEqual expand('#:t'), floaterm#cmdline#parse('#:t')[0]
  AssertEqual expand('#:p:h'), floaterm#cmdline#parse('#:p:h')[0]
  AssertEqual expand('#2'), floaterm#cmdline#parse('#2')[0]
  execute 'argadd ' . expand('%:p') . ' ' . expand('#:p')
  AssertEqual expand('##'), floaterm#cmdline#parse('##')[0]
  AssertEqual 'less ' . expand('##'), floaterm#cmdline#parse('less ##')[0]
  AssertEqual '#', floaterm#cmdline#parse('\#')[0]

  silent !rm test.txt
  silent !rm another.txt
endfunction

function! Test_02b_parse_validation() abort
  Log '# invalid wintype is rejected'
    let [cmd, config] = floaterm#cmdline#parse('--wintype=bogus')
    AssertEqual '', cmd
    AssertEqual {}, config

  Log '# invalid position is rejected'
    let [cmd, config] = floaterm#cmdline#parse('--position=nowhere')
    AssertEqual '', cmd
    AssertEqual {}, config

  Log '# invalid autoclose is rejected'
    let [cmd, config] = floaterm#cmdline#parse('--autoclose=maybe')
    AssertEqual '', cmd
    AssertEqual {}, config

  Log '# invalid autoinsert is rejected'
    let [cmd, config] = floaterm#cmdline#parse('--autoinsert=sometimes')
    AssertEqual '', cmd
    AssertEqual {}, config

  Log '# invalid titleposition is rejected'
    let [cmd, config] = floaterm#cmdline#parse('--titleposition=middle')
    AssertEqual '', cmd
    AssertEqual {}, config

  Log '# invalid opener is rejected'
    let [cmd, config] = floaterm#cmdline#parse('--opener=bogus')
    AssertEqual '', cmd
    AssertEqual {}, config

  Log '# empty title value is accepted (#324)'
    let [cmd, config] = floaterm#cmdline#parse('--title=')
    AssertEqual '', cmd
    Assert has_key(config, 'title')
    AssertEqual '', config.title

  Log '# valid values still parse'
    let [cmd, config] = floaterm#cmdline#parse('--wintype=split --position=aboveleft --autoclose=always')
    AssertEqual 'split', config.wintype
    AssertEqual 'aboveleft', config.position
    AssertEqual 'always', config.autoclose
endfunction

function! Test_03_complete() abort
  let F = function('floaterm#cmdline#complete')
  let all_candidates = [
        \ '--cwd=',
        \ '--name=',
        \ '--title=',
        \ '--width=',
        \ '--height=',
        \ '--opener=',
        \ '--wintype=',
        \ '--position=',
        \ '--autoclose=',
        \ '--autoinsert=',
        \ '--borderchars=',
        \ '--titleposition=',
        \ '--silent',
        \ '--disposable',
        \ ]
  call s:check_complete('FloatermNew ', all_candidates, F)
  call s:check_complete('FloatermNew -', all_candidates, F)
  call s:check_complete('FloatermNew --', all_candidates, F)
  call s:check_complete('FloatermNew nv', sort(getcompletion('nv', 'shellcmd')), F)
  call s:check_complete('FloatermNew --n', ['--name='], F)
  call s:check_complete('FloatermNew --w', ['--width=', '--wintype='], F)
  call s:check_complete('FloatermNew --name=', [], F)
  call s:check_complete('FloatermNew --title=', [], F)
  call s:check_complete('FloatermNew --width=', [], F)
  call s:check_complete('FloatermNew --height=', [], F)
  call s:check_complete('FloatermNew --silent', [], F)
  call s:check_complete('FloatermNew --wintype=', [
        \ '--wintype=float',
        \ '--wintype=split',
        \ '--wintype=vsplit',
        \ ], F)
  call s:check_complete('FloatermNew --wintype=f', [
        \ '--wintype=float'
        \ ], F)
  call s:check_complete('FloatermNew --position=', [
        \ '--position=auto',
        \ '--position=center',
        \ '--position=random',
        \ '--position=top',
        \ '--position=topleft',
        \ '--position=topright',
        \ '--position=bottom',
        \ '--position=bottomleft',
        \ '--position=bottomright',
        \ '--position=left',
        \ '--position=right',
        \ ], F)
  call s:check_complete('FloatermNew --wintype=split --position=', [
        \ '--position=random',
        \ '--position=leftabove',
        \ '--position=aboveleft',
        \ '--position=rightbelow',
        \ '--position=belowright',
        \ '--position=topleft',
        \ '--position=botright',
        \ ], F)
  call s:check_complete('FloatermNew --position=t', [
        \ '--position=top',
        \ '--position=topleft',
        \ '--position=topright'
        \ ], F)
  call s:check_complete('FloatermNew --autoclose=', [
        \ '--autoclose=always',
        \ '--autoclose=never',
        \ '--autoclose=smart'
        \ ], F)
  call s:check_complete('FloatermNew --autoclose=s', [
        \ '--autoclose=smart'
        \ ], F)
  call s:check_complete('FloatermNew --opener=', [
        \ '--opener=edit',
        \ '--opener=split',
        \ '--opener=vsplit',
        \ '--opener=tabe',
        \ '--opener=drop'
        \ ], F)
  call s:check_complete('FloatermNew '.
        \ '--cwd=1 '.
        \ '--name=1 '.
        \ '--title=1 '.
        \ '--width=1 '.
        \ '--height=1 '.
        \ '--opener=edit '.
        \ '--silent '.
        \ '--disposable '.
        \ '--wintype=1 '.
        \ '--position=1 '.
        \ '--autoclose=always '.
        \ '--autoinsert=1 '.
        \ '--borderchars=1 '.
        \ '--titleposition=1 ', sort(getcompletion('', 'shellcmd')), F)
  call s:check_complete('FloatermUpdate ', all_candidates, F)
  call s:check_complete('FloatermUpdate -', all_candidates, F)
  call s:check_complete('FloatermUpdate --', all_candidates, F)
  call s:check_complete('FloatermUpdate nv', ['  '], F)
  call s:check_complete('FloatermUpdate '.
        \ '--cwd=1 '.
        \ '--name=1 '.
        \ '--title=1 '.
        \ '--width=1 '.
        \ '--height=1 '.
        \ '--opener=edit '.
        \ '--silent '.
        \ '--disposable '.
        \ '--wintype=1 '.
        \ '--position=1 '.
        \ '--autoclose=never '.
        \ '--autoinsert=1 '.
        \ '--borderchars=1 '.
        \ '--titleposition=1 ', [], F)
endfunction

function! Test_04_complete_names1() abort
  FloatermNew --name=floaterm
  let F = function('floaterm#cmdline#complete_names1')
  call s:check_complete('abc', ['floaterm'], F)
  FloatermKill!
endfunction

function! Test_05_complete_names2() abort
  FloatermNew --name=floaterm1
  FloatermNew --name=floaterm2
  let F = function('floaterm#cmdline#complete_names2')
  call s:check_complete('FloatermUpdate -', ['--name='], F)
  call s:check_complete('FloatermSend ', ['--name='], F)
  call s:check_complete('FloatermSend --name=', ['--name=floaterm1', '--name=floaterm2'], F)

  FloatermKill!
  stopinsert
endfunction

call RunTests()
