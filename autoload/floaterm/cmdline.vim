" ============================================================================
" FileName: cmdline.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! floaterm#cmdline#complete(arg_lead, cmd_line, cursor_pos) abort
  let win_opts_key = ['height=', 'width=', 'wintype=']
  let candidates = win_opts_key + sort(getcompletion('', 'shellcmd'))

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
  else
    return filter(candidates, 'v:val[:len(prefix) - 1] ==# prefix')
  endif
endfunction

function! floaterm#cmdline#floaterm_names(arg_lead, cmd_line, cursor_pos)
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
