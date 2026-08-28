" vim:sw=2:
" ============================================================================
" FileName: cmdline.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

" ----------------------------------------------------------------------------
" valid values for the enumerated options; used both for validation in
" floaterm#cmdline#parse and for completion in floaterm#cmdline#complete (#324)
" ----------------------------------------------------------------------------
let s:valid_wintype = ['float', 'split', 'vsplit']
let s:valid_opener = ['edit', 'split', 'vsplit', 'tabe', 'drop']
let s:valid_autoclose = ['always', 'never', 'smart']
let s:valid_autoinsert = ['always', 'never', 'smart']
let s:valid_titleposition = ['left', 'center', 'right']
let s:valid_position_float = [
      \ 'auto', 'center', 'random', 'top', 'topleft', 'topright',
      \ 'bottom', 'bottomleft', 'bottomright', 'left', 'right',
      \ ]
let s:valid_position_split = [
      \ 'random', 'leftabove', 'aboveleft', 'rightbelow', 'belowright',
      \ 'topleft', 'botright',
      \ ]

" ----------------------------------------------------------------------------
" used for `:FloatermNew` and `:FloatermUpdate`
" parse argument list to `cmd`(string, default '') and `config`(dict)
" ----------------------------------------------------------------------------
function! floaterm#cmdline#parse(argstr) abort
  let config = {}
  let cmd = ''
  let arglist = split(a:argstr, '\\\@<!\s')
  if arglist != []
    let c = 0
    for arg in arglist
      let arg = substitute(arg, '\\\\', '\', 'g')
      let arg = substitute(arg, '\\ ', ' ', 'g')
      if arg =~ '^--\S.*=\?.*$'
        " split on the first '=' only, keeping an empty value (e.g. --title=)
        let m = matchlist(arg, '^--\([^=]*\)=\(.*\)$')
        if !empty(m)
          let key = m[1]
          let value = m[2]
          if key ==# 'cwd'
            if value ==# '<root>'
              let value = floaterm#path#get_root(getcwd())
            elseif value ==# '<buffer>'
              let value = expand('%:p:h')
            elseif value ==# '<buffer-root>'
              let value = floaterm#path#get_root(expand('%:p:h'))
            else
              let value = fnamemodify(value, ':p')
            endif
          endif
        else
          " no '=' at all: flag options (silent, disposable) or error
          if index(['--silent', '--disposable'], arg) >= 0
            let [key, value] = [arg[2:], v:true]
          else
            call floaterm#util#show_msg('Argument Error: No value given to option: ' . arg, 'error')
            return [cmd, config]
          endif
        endif
        if index(['height', 'width'], key) > -1
          let value = eval(value)
        endif
        let err = s:validate(key, value, config)
        if !empty(err)
          call floaterm#util#show_msg(err, 'error')
          return [cmd, config]
        endif
        let config[key] = value
      else
        let cmd = s:expand(join(arglist[c:]))
        break
      endif
      let c += 1
    endfor
  endif
  return [cmd, config]
endfunction

" returns an error message string for an invalid option value, or '' if valid
function! s:validate(key, value, config) abort
  if a:key ==# 'wintype' && index(s:valid_wintype, a:value) < 0
    return printf('Argument Error: Invalid value "%s" for --wintype, valid: %s',
          \ a:value, join(s:valid_wintype, ', '))
  endif
  if a:key ==# 'opener' && index(s:valid_opener, a:value) < 0
    return printf('Argument Error: Invalid value "%s" for --opener, valid: %s',
          \ a:value, join(s:valid_opener, ', '))
  endif
  if a:key ==# 'autoclose' && index(s:valid_autoclose, a:value) < 0
    return printf('Argument Error: Invalid value "%s" for --autoclose, valid: %s',
          \ a:value, join(s:valid_autoclose, ', '))
  endif
  if a:key ==# 'autoinsert' && index(s:valid_autoinsert, a:value) < 0
    return printf('Argument Error: Invalid value "%s" for --autoinsert, valid: %s',
          \ a:value, join(s:valid_autoinsert, ', '))
  endif
  if a:key ==# 'titleposition' && index(s:valid_titleposition, a:value) < 0
    return printf('Argument Error: Invalid value "%s" for --titleposition, valid: %s',
          \ a:value, join(s:valid_titleposition, ', '))
  endif
  if a:key ==# 'position'
    " the valid set depends on wintype; the float set also includes the values
    " that config#parse maps to split equivalents (top, left, bottom, right,
    " center), so accept the union of both
    let valid = s:valid_position_float + s:valid_position_split
    if index(valid, a:value) < 0
      return printf('Argument Error: Invalid value "%s" for --position, valid: %s',
            \ a:value, join(uniq(sort(copy(valid))), ', '))
    endif
  endif
  return ''
endfunction

function! s:expand(cmd) abort
  " NOTE: '##' and '#N' must come before '#' in the alternation, otherwise
  " they would never be tried and expand('#') would match instead. Likewise,
  " '^' must come before '[^\\]' so that '##' at the beginning of the string
  " is not treated as the '#' wildcard preceded by a '#' character
  let wildchars = '\(%\|##\|#\d\|#\|<cfile>\|<afile>\|<abuf>\|<amatch>\|<cexpr>\|<sfile>\|<slnum>\|<sflnum>\|<SID>\|<stack>\|<cword>\|<cWORD>\|<client>\)'
  let cmd = substitute(a:cmd, '\(^\|[^\\]\)\zs' . wildchars . '\(<\|\(\(:g\=s?.*?.*?\)\|\(:[phtreS8\~\.]\)\)*\)\ze', '\=expand(submatch(0))', 'g')
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

  let cmd_line_before_cursor = a:cmd_line[:a:cursor_pos - 1]
  let args = split(cmd_line_before_cursor, '\v\\@<!(\\\\)*\zs\s+', 1)
  call remove(args, 0)

  for key in deepcopy(options)
    if match(cmd_line_before_cursor, key) != -1
      call remove(options, index(options, key))
    endif
  endfor

  if match(a:arg_lead, '--wintype=') > -1
    let vals = copy(s:valid_wintype)
    let candidates = map(vals, {idx -> '--wintype=' . vals[idx]})
  elseif match(a:arg_lead, '--opener=') > -1
    let vals = copy(s:valid_opener)
    if index(vals, g:floaterm_opener) == -1
      call add(vals, g:floaterm_opener)
    endif
    let candidates = map(vals, {idx -> '--opener=' . vals[idx]})
  elseif match(a:arg_lead, '--autoclose=') > -1
    let vals = copy(s:valid_autoclose)
    let candidates = map(vals, {idx -> '--autoclose=' . vals[idx]})
  elseif match(a:arg_lead, '--autoinsert=') > -1
    let vals = copy(s:valid_autoinsert)
    let candidates = map(vals, {idx -> '--autoinsert=' . vals[idx]})
  elseif match(a:arg_lead, '--silent') > -1
    return []
  elseif match(a:arg_lead, '--cwd=') > -1
    let prestr = matchstr(a:arg_lead, '--cwd=\zs.*\ze')
    let dirs = getcompletion(prestr, 'dir')
    if a:arg_lead == '--cwd='
      let dirs = ['<buffer>', '<root>', '<buffer-root>'] + dirs
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
  elseif match(a:arg_lead, '--titleposition=') > -1
    let vals = copy(s:valid_titleposition)
    let candidates = map(vals, {idx -> '--titleposition=' . vals[idx]})
  elseif match(a:arg_lead, '--position=') > -1
    let wintype = matchstr(a:cmd_line, '--wintype=\zs\w\+\ze')
    if empty(wintype)
      let wintype = g:floaterm_wintype
    endif
    if wintype ==# 'float'
      let vals = copy(s:valid_position_float)
    else
      let vals = copy(s:valid_position_split)
    endif
    let candidates = map(vals, {idx -> '--position=' . vals[idx]})
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
    let termname = floaterm#config#get(bufnr, 'name', '')
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
