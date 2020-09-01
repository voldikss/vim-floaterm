" vim:sw=2:
" ============================================================================
" FileName: cmdline.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

" ----------------------------------------------------------------------------
" used for `:FloatermNew` and `:FloatermUpdate`
" parse argument list to `cmd`(string, default '') and `opts`(dict)
" ----------------------------------------------------------------------------
function! floaterm#cmdline#parse(arglist) abort
  let opts = {}
  let cmd = ''
  if a:arglist != []
    let c = 0
    for arg in a:arglist
      if arg =~ '^--.*$'
        let opt = split(arg, '=')
        if len(opt) == 2
          let [key, value] = [opt[0][2:], opt[1]]
          if index(['height', 'width', 'autoclose'], key) > -1
            let value = eval(value)
          endif
          let opts[key] = value
        else
          let key = opt[0][2:]
          let opts[key] = v:true
        endif
      else
        let cmd = s:expand(join(a:arglist[c:]))
        break
      endif
      let c += 1
    endfor
  endif
  return [cmd, opts]
endfunction

" say thanks to the neoterm project
function! s:expand(cmd) abort
  let cmd = substitute(a:cmd, '[^\\]\zs%\(:[phtre]\)\+', '\=expand(submatch(0))', 'g')
  let cmd = substitute(cmd, '\c\\<cr>', '', 'g')
  let cmd = substitute(cmd, '[^\\]\zs%', expand('%:p'), 'g')
  let cmd = substitute(cmd, '\\%', '%', 'g')
  return cmd
endfunction

" ----------------------------------------------------------------------------
" used for `:FloatermNew` and `:FloatermUpdate`
" ----------------------------------------------------------------------------
function! floaterm#cmdline#complete(arg_lead, cmd_line, cursor_pos) abort
  let opts_key = [
    \'--name=',
    \'--height=',
    \'--width=',
    \'--title=',
    \'--wintype=',
    \'--position=',
    \'--autoclose=',
    \]
  if a:cmd_line =~ '^FloatermNew'
    let candidates = opts_key + sort(getcompletion('', 'shellcmd'))
  elseif a:cmd_line =~ '^FloatermUpdate'
    let candidates = opts_key
  endif

  let cmd_line_before_cursor = a:cmd_line[:a:cursor_pos - 1]
  let args = split(cmd_line_before_cursor, '\v\\@<!(\\\\)*\zs\s+', 1)
  call remove(args, 0)

  for key in opts_key
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
      let vals = ['normal', 'floating']
    else
      let vals = ['normal', 'popup']
    endif
    let candidates = map(vals, {idx -> '--wintype=' . vals[idx]})
  elseif match(prefix, '--position=') > -1
    let vals = [
      \'top',
      \'right',
      \'bottom',
      \'left',
      \'center',
      \'topleft',
      \'topright',
      \'bottomleft',
      \'bottomright',
      \'auto',
      \]
    let candidates = map(vals, {idx -> '--position=' . vals[idx]})
  elseif match(prefix, '--autoclose') > -1
    let vals = [0, 1, 2]
    let candidates = map(vals, {idx -> '--autoclose=' . vals[idx]})
  endif
  return filter(candidates, 'v:val[:len(prefix) - 1] ==# prefix')
endfunction

" ----------------------------------------------------------------------------
" used for `:FloatermToggle`, `:FloatermHide`, `:FloatermShow`, `:FloatermKill`
" ----------------------------------------------------------------------------
function! floaterm#cmdline#floaterm_names(...) abort
  let buflist = floaterm#buflist#gather()
  let ret = []
  for bufnr in buflist
    let opts = getbufvar(bufnr, 'floaterm_opts', {})
    if !empty(opts)
      let termname = get(opts, 'name', '')
      if !empty(termname)
        call add(ret, termname)
      endif
    endif
  endfor
  return ret
endfunction

" ----------------------------------------------------------------------------
" used for `:FloatermSend`
" ----------------------------------------------------------------------------
function! floaterm#cmdline#floaterm_names2(arg_lead, cmd_line, cursor_pos) abort
  let candidates = ['--name=']
  let cmd_line_before_cursor = a:cmd_line[:a:cursor_pos - 1]
  let args = split(cmd_line_before_cursor, '\v\\@<!(\\\\)*\zs\s+', 1)
  call remove(args, 0)

  if match(cmd_line_before_cursor, '--name') != -1
    let candidates = []
  endif

  let prefix = args[-1]
  if prefix ==# ''
    return candidates
  endif

  if match(prefix, '--name=') > -1
    let names = floaterm#cmdline#floaterm_names()
    let candidates = map(names, {idx -> '--name=' . names[idx]})
  endif
  return filter(candidates, 'v:val[:len(prefix) - 1] ==# prefix')
endfunction
