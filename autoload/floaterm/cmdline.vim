" vim:sw=2:
" ============================================================================
" FileName: cmdline.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

" ----------------------------------------------------------------------------
" used for `:FloatermNew` and `:FloatermUpdate`
" parse argument list to `cmd`(string, default '') and `config`(dict)
" ----------------------------------------------------------------------------
function! floaterm#cmdline#parse(arglist) abort
  let config = {}
  let cmd = ''
  if a:arglist != []
    let c = 0
    for arg in a:arglist
      if arg =~ '^--\S.*=\?.*$'
        let pair = split(arg, '=')
        if len(pair) != 2
          if index(['--silent', '--disposable'], pair[0]) >= 0
            let [key, value] = [pair[0][2:], v:true]
          else
            call floaterm#util#show_msg('Argument Error: No value given to option: ' . pair[0], 'error')
            return [cmd, config]
          endif
        else
          let [key, value] = [pair[0][2:], pair[1]]
        endif
        if index(['height', 'width', 'autoclose'], key) > -1
          let value = eval(value)
        endif
        let config[key] = value
      else
        let cmd = s:expand(join(a:arglist[c:]))
        break
      endif
      let c += 1
    endfor
  endif
  return [cmd, config]
endfunction

function! s:expand(cmd) abort
  let wildchars = '\(%\|#\|#\d\|<cfile>\|<afile>\|<abuf>\|<amatch>\|<cexpr>\|<sfile>\|<slnum>\|<sflnum>\|<SID>\|<stack>\|<cword>\|<cWORD>\|<client>\)'
  let cmd = substitute(a:cmd, '\([^\\]\|^\)\zs' . wildchars . '\(<\|\(\(:g\=s?.*?.*?\)\|\(:[phtreS8\~\.]\)\)*\)\ze', '\=expand(submatch(0))', 'g')
  let cmd = substitute(cmd, '\zs\\' . wildchars, '\=submatch(0)[1:]', 'g')
  return cmd
endfunction

" ----------------------------------------------------------------------------
" used for `:FloatermNew` and `:FloatermUpdate`
" ----------------------------------------------------------------------------
let s:shellcmds = []
function! floaterm#cmdline#complete(arg_lead, cmd_line, cursor_pos) abort
  let options = [
    \ '--cwd=',
    \ '--name=',
    \ '--width=',
    \ '--height=',
    \ '--title=',
    \ '--wintype=',
    \ '--position=',
    \ '--autoclose=',
    \ '--borderchars=',
    \ '--silent',
    \ '--disposable',
    \ ]

  let cmd_line_before_cursor = a:cmd_line[:a:cursor_pos - 1]
  let args = split(cmd_line_before_cursor, '\v\\@<!(\\\\)*\zs\s+', 1)
  call remove(args, 0)

  for key in deepcopy(options)
    if match(cmd_line_before_cursor, key) != -1
      call remove(options, index(options, key))
    endif
  endfor

  if match(a:arg_lead, '--wintype=') > -1
    let vals = ['float', 'split', 'vsplit']
    let candidates = map(vals, {idx -> '--wintype=' . vals[idx]})
  elseif match(a:arg_lead, '--position=') > -1
    let wintype = matchstr(a:cmd_line, '--wintype=\zs\w\+\ze')
    if empty(wintype)
      let wintype = g:floaterm_wintype
    endif
    if wintype == 'float'
      let vals = [
            \ 'auto',
            \ 'center',
            \ 'random',
            \ 'top',
            \ 'topleft',
            \ 'topright',
            \ 'bottom',
            \ 'bottomleft',
            \ 'bottomright',
            \ 'left',
            \ 'right',
            \ ]
    else
      let vals = [
            \ 'random',
            \ 'leftabove',
            \ 'aboveleft',
            \ 'rightbelow',
            \ 'belowright',
            \ 'topleft',
            \ 'botright',
            \ ]
    endif
    let candidates = map(vals, {idx -> '--position=' . vals[idx]})
  elseif match(a:arg_lead, '--autoclose=') > -1
    let vals = [0, 1, 2]
    let candidates = map(vals, {idx -> '--autoclose=' . vals[idx]})
  elseif match(a:arg_lead, '--silent') > -1
    return []
  elseif match(a:arg_lead, '--cwd=') > -1
    let prestr = matchstr(a:arg_lead, '--cwd=\zs.*\ze')
    let dirs = getcompletion(prestr, 'dir')
    if a:arg_lead == '--cwd='
      let dirs = ['<root>'] + dirs
    endif
    return map(dirs, { k,v -> '--cwd=' . v })
  elseif match(a:arg_lead, '--name=') > -1
    return []
  elseif match(a:arg_lead, '--width=') > -1
    return []
  elseif match(a:arg_lead, '--height=') > -1
    return []
  elseif match(a:arg_lead, '--title=') > -1
    return []
  elseif match(a:arg_lead, '--borderchars=') > -1
    return []
    " The dash absolutely belongs to the `options` instead of executable
    " commands(e.g. `nvim-qt.exe`). So if `a:arg_lead` matches 1 or 2 dash, the
    " user wants to complete options.
  elseif match(a:arg_lead, '^--\=\S*$') > -1
    let candidates = options
  elseif a:arg_lead == ''
    if a:cmd_line =~ '^FloatermUpdate'
      return options
    elseif empty(options)
      let s:shellcmds = sort(getcompletion('', 'shellcmd'))
      return s:shellcmds
    else
      return options
    endif
  else
    if a:cmd_line =~ '^FloatermUpdate'
      return [repeat(' ', len(a:arg_lead))]
    else
      let candidates = sort(getcompletion(a:arg_lead, 'shellcmd'))
    endif
  endif
  return filter(candidates, 'v:val[:len(a:arg_lead) - 1] == a:arg_lead')
endfunction

" ----------------------------------------------------------------------------
" used for `:FloatermToggle`, `:FloatermHide`, `:FloatermShow`, `:FloatermKill`
" ----------------------------------------------------------------------------
function! floaterm#cmdline#complete_names1(...) abort
  let buflist = floaterm#buflist#gather()
  let ret = []
  for bufnr in buflist
    let termname = floaterm#buffer#get_config(bufnr, 'name', '')
    if !empty(termname)
      call add(ret, termname)
    endif
  endfor
  return ret
endfunction

" ----------------------------------------------------------------------------
" used for `:FloatermSend`
" ----------------------------------------------------------------------------
function! floaterm#cmdline#complete_names2(arg_lead, cmd_line, cursor_pos) abort
  let candidates = ['--name=']
  let cmd_line_before_cursor = a:cmd_line[:a:cursor_pos - 1]
  let args = split(cmd_line_before_cursor, '\v\\@<!(\\\\)*\zs\s+', 1)
  call remove(args, 0)

  if match(cmd_line_before_cursor, '--name') != -1
    let candidates = []
  endif

  if a:arg_lead == ''
    return candidates
  endif

  if match(a:arg_lead, '--name=') > -1
    let names = floaterm#cmdline#complete_names1()
    let candidates = map(names, {idx -> '--name=' . names[idx]})
  endif
  return filter(candidates, 'v:val[:len(a:arg_lead) - 1] == a:arg_lead')
endfunction
