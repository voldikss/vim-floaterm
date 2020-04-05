" ============================================================================
" FileName: plugin/floaterm.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

scriptencoding utf-8

let g:floaterm_type          = get(g:, 'floaterm_type', v:null)
let g:floaterm_width         = get(g:, 'floaterm_width', v:null)
let g:floaterm_height        = get(g:, 'floaterm_height', v:null)
let g:floaterm_winblend      = get(g:, 'floaterm_winblend', 0)
let g:floaterm_position      = get(g:, 'floaterm_position', 'auto')
let g:floaterm_borderchars   = get(g:, 'floaterm_borderchars', ['─', '│', '─', '│', '┌', '┐', '┘', '└'])
let g:floaterm_rootmarkers   = get(g:, 'floaterm_rootmarkers', [])
let g:floaterm_autoinsert    = get(g:, 'floaterm_autoinsert', v:true)
let g:floaterm_open_command  = get(g:, 'floaterm_open_command', 'edit')

let g:floaterm_keymap_new    = get(g:, 'floaterm_keymap_new', v:null)
let g:floaterm_keymap_prev   = get(g:, 'floaterm_keymap_prev', v:null)
let g:floaterm_keymap_next   = get(g:, 'floaterm_keymap_next', v:null)
let g:floaterm_keymap_toggle = get(g:, 'floaterm_keymap_toggle', v:null)
let g:floaterm_gitcommit     = get(g:, 'floaterm_gitcommit', v:null)

command! -nargs=0                    FloatermPrev   call floaterm#prev()
command! -nargs=0                    FloatermNext   call floaterm#next()
command! -nargs=?                    FloatermToggle call floaterm#toggle(<f-args>)
command! -nargs=0                    FloatermInfo   call floaterm#buflist#info()
command! -nargs=0 -range -bang       FloatermSend   call floaterm#send('<bang>', <line1>, <line2>)
command! -nargs=* -complete=customlist,floaterm#cmdline#complete
                                   \ FloatermNew    call s:new_floaterm(<f-args>)

function! s:new_floaterm(...) abort
  let window_opts = {}
  let cmd = ''
  if a:000 != []
    let c = 0
    for arg in a:000
      let opt = split(arg, '=')
      if len(opt) == 1
        let cmd = join(a:000[c:])
        break
      elseif len(opt) == 2
        let window_opts[opt[0]] = eval(opt[1])
      endif
      let c += 1
    endfor
  endif
  call floaterm#new(cmd, window_opts)
endfunction

hi def link FloatermNF NormalFloat
hi def link FloatermBorderNF NormalFloat

function! s:install_keymap()
  if g:floaterm_keymap_new != v:null
    exe printf('nnoremap  <silent> %s :FloatermNew<CR>', g:floaterm_keymap_new)
    exe printf('tnoremap <silent> %s <C-\><C-n>:FloatermNew<CR>', g:floaterm_keymap_new)
  endif
  if g:floaterm_keymap_prev != v:null
    exe printf('nnoremap  <silent> %s :FloatermPrev<CR>', g:floaterm_keymap_prev)
    exe printf('tnoremap <silent> %s <C-\><C-n>:FloatermPrev<CR>', g:floaterm_keymap_prev)
  endif
  if g:floaterm_keymap_next != v:null
    exe printf('nnoremap  <silent> %s :FloatermNext<CR>', g:floaterm_keymap_next)
    exe printf('tnoremap <silent> %s <C-\><C-n>:FloatermNext<CR>', g:floaterm_keymap_next)
  endif
  if g:floaterm_keymap_toggle != v:null
    exe printf('nnoremap  <silent> %s :FloatermToggle<CR>', g:floaterm_keymap_toggle)
    exe printf('tnoremap <silent> %s <C-\><C-n>:FloatermToggle<CR>', g:floaterm_keymap_toggle)
  endif
endfunction
call s:install_keymap()

function! s:runner_proc(opts)
  let curr_bufnr = floaterm#curr()
  if has_key(a:opts, 'silent') && a:opts.silent == 1
    call floaterm#hide()
  endif
  let cmd = 'cd ' . shellescape(getcwd())
  call floaterm#terminal#send(curr_bufnr, [cmd])
  call floaterm#terminal#send(curr_bufnr, [a:opts.cmd])
  stopinsert
  if &filetype == 'floaterm' && g:floaterm_autoinsert
    startinsert
  endif
endfunction
let g:asyncrun_runner = get(g:, 'asyncrun_runner', {})
let g:asyncrun_runner.floaterm = function('s:runner_proc')
