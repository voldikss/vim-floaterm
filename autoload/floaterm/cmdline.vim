" vim:sw=2:
" ============================================================================
" FileName: cmdline.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

" ----------------------------------------------------------------------------
" used for `:FloatermNew` and `:FloatermUpdate`
" parse argument list to `cmd`(string, default '') and `winopts`(dict)
" ----------------------------------------------------------------------------
function! floaterm#cmdline#parse(arglist) abort
  let winopts = {}
  let cmd = ''
  if a:arglist != []
    let c = 0
    for arg in a:arglist
      if arg =~ '^--.*$'
        let opt = split(arg, '=')
        if len(opt) == 2
          let [key, value] = [opt[0][2:], opt[1]]
          if key == 'height' || key == 'width'
            let value = eval(value)
          endif
          let winopts[key] = value
        else
          let key = opt[0][2:]
          let winopts[key] = v:true
        endif
      else
        let cmd = join(a:arglist[c:])
        break
      endif
      let c += 1
    endfor
  endif
  return [cmd, winopts]
endfunction

" ----------------------------------------------------------------------------
" used for `:FloatermNew` and `:FloatermUpdate`
" ----------------------------------------------------------------------------
function! floaterm#cmdline#complete(arg_lead, cmd_line, cursor_pos) abort
  let winopts_key = ['--height=', '--width=', '--wintype=', '--name=', '--position=', '--autoclose']
  if a:cmd_line =~ '^FloatermNew'
    let candidates = winopts_key + sort(getcompletion('', 'shellcmd'))
  elseif a:cmd_line =~ '^FloatermUpdate'
    let candidates = winopts_key
  endif

  let cmd_line_before_cursor = a:cmd_line[:a:cursor_pos - 1]
  let args = split(cmd_line_before_cursor, '\v\\@<!(\\\\)*\zs\s+', 1)
  call remove(args, 0)

  for key in winopts_key
    if match(cmd_line_before_cursor, key) != -1
      let idx = index(candidates, key)
      call remove(candidates, idx)
    endif
  endfor

  let prefix = args[-1]

  if prefix ==# ''
    return candidates
  endif

  if match(prefix, '--wintype=') > -1
    if has('nvim')
      let wintypes = ['normal', 'floating']
    else
      let wintypes = ['normal', 'popup']
    endif
    let candidates = map(wintypes, {idx -> '--wintype=' . wintypes[idx]})
  elseif match(prefix, '--position=') > -1
    let position = ['top', 'right', 'bottom', 'left', 'center', 'topleft', 'topright', 'bottomleft', 'bottomright', 'auto']
    let candidates = map(position, {idx -> '--position=' . position[idx]})
  endif
  return filter(candidates, 'v:val[:len(prefix) - 1] ==# prefix')
endfunction

" ----------------------------------------------------------------------------
" used for `:FloatermToggle`
" ----------------------------------------------------------------------------
function! floaterm#cmdline#floaterm_names(arg_lead, cmd_line, cursor_pos) abort
  let buflist = floaterm#buflist#gather()
  let ret = []
  let pattern = '^floaterm://'
  for bufnr in buflist
    let winopts = getbufvar(bufnr, 'floaterm_winopts', {})
    if !empty(winopts)
      let termname = get(winopts, 'name', '')
      if !empty(termname)
        call add(ret, termname)
      endif
    endif
  endfor
  return ret
endfunction
