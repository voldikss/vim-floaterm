" vim:sw=2:
" ============================================================================
" FileName: cmdline.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! floaterm#cmdline#parse_new(arglist) abort
  let window_opts = {}
  let cmd = ''
  if a:arglist != []
    let c = 0
    for arg in a:arglist
      let opt = split(arg, '=')
      if len(opt) == 1
        let cmd = join(a:arglist[c:])
        break
      elseif len(opt) == 2
        let [key, value] = opt
        if key == 'height' || key == 'width'
          let value = eval(value)
        endif
        let window_opts[key] = value
      endif
      let c += 1
    endfor
  endif
  return [cmd, window_opts]
endfunction

function! floaterm#cmdline#complete(arg_lead, cmd_line, cursor_pos) abort
  let win_opts_key = ['height=', 'width=', 'wintype=', 'name=', 'position=']
  if a:cmd_line =~ '^FloatermNew'
    let candidates = win_opts_key + sort(getcompletion('', 'shellcmd'))
  elseif a:cmd_line =~ '^FloatermUpdate'
    let candidates = win_opts_key
  endif

  let cmd_line_before_cursor = a:cmd_line[:a:cursor_pos - 1]
  let args = split(cmd_line_before_cursor, '\v\\@<!(\\\\)*\zs\s+', 1)
  call remove(args, 0)

  for key in win_opts_key
    if match(cmd_line_before_cursor, key) != -1
      let idx = index(candidates, key)
      call remove(candidates, idx)
    endif
  endfor

  let prefix = args[-1]

  if prefix ==# ''
    return candidates
  endif

  if match(prefix, 'wintype=') > -1
    let wintype = ['normal', 'floating']
    let candidates = map(wintype, {idx -> 'wintype=' . wintype[idx]})
  elseif match(prefix, 'position=') > -1
    let position = ['top', 'right', 'bottom', 'left', 'center', 'topleft', 'topright', 'bottomleft', 'bottomright', 'auto']
    let candidates = map(position, {idx -> 'position=' . position[idx]})
  endif
  return filter(candidates, 'v:val[:len(prefix) - 1] ==# prefix')
endfunction

function! floaterm#cmdline#floaterm_names(arg_lead, cmd_line, cursor_pos) abort
  let buflist = floaterm#buflist#gather()
  let ret = []
  let pattern = '^floaterm://'
  for bufnr in buflist
    let name = getbufinfo(bufnr)[0].name
    let termname = substitute(name, pattern, '', '')
    if name =~ pattern && match(termname, a:arg_lead) != -1
      call add(ret, termname)
    endif
  endfor
  return ret
endfunction
