Use (neo)vim terminal in the floating/popup window.

[![CI](https://github.com/voldikss/vim-floaterm/workflows/CI/badge.svg)](https://github.com/voldikss/vim-floaterm/actions?query=workflow%3ACI) [![GitHub license](https://img.shields.io/github/license/voldikss/vim-floaterm.svg)](https://github.com/voldikss/vim-floaterm/blob/master/LICENSE) [![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/voldikss/vim-floaterm/graphs/commit-activity)

![](https://user-images.githubusercontent.com/20282795/91376670-2db3b080-e850-11ea-9991-efa4f4da6f44.png)

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Get started](#basic-usage)
  - [Commands](#commands)
  - [Options](#options)
  - [Keymaps](#keymaps)
  - [Highlights](#highlights)
- [Use with command line tools](#use-with-command-line-tools)
  - [floaterm](#floaterm)
  - [git](#git)
  - [fzf](#fzf)
  - [fff](#fff)
  - [nnn](#nnn)
  - [lf](#lf)
  - [ranger](#ranger)
  - [vifm](#vifm)
  - [lazygit](#lazygit)
  - [python](#python)
- [Use with other plugins](#use-with-other-plugins)
  - [vim-clap](#vim-clap)
  - [denite.nvim](#denitenvim)
  - [coc.nvim](#cocnvim)
  - [fzf](#fzf)
  - [LeaderF](#leaderf)
  - [asynctasks.vim](#asynctasksvim)
- [How to define more wrappers](#how-to-define-more-wrappers)
- [How to write sources for fuzzy finder plugins](#how-to-write-sources-for-fuzzy-finder-plugins)
- [Wiki](#wiki)
- [F.A.Q](#faq)
- [Breaking changes](#breaking-changes)
- [Feedback](#feedback)
- [Credits](#credits)
- [License](#license)

## Features

- Support neovim floatwin and vim8 popupwin feature
- Manage multiple terminal instances
- Customizable floating terminal style
- Switch/preview floating terminal buffers using fuzzy-finder plugins such as
  [denite.nvim](https://github.com/Shougo/denite.nvim) or
  [coc.nvim](https://github.com/neoclide/coc.nvim), etc.
- Use with other external command-line tools(ranger, lf, fzf, etc.)
- Autocompletion from within floaterms(require [coc.nvim](https://github.com/neoclide/coc.nvim))
- Use as a custom task runner for [asynctasks.vim](https://github.com/skywind3000/asynctasks.vim)

## Requirements

- Vim or neovim with `terminal` feature

Run `:checkhealth` for more info.

## Installation

- vim-plug

```vim
Plug 'voldikss/vim-floaterm'
```

- dein.nvim

```vim
call dein#add('voldikss/vim-floaterm')
```

## Basic Usage

Use `:FloatermNew` to open a terminal window, use `:FloatermToggle` to
hide/reopen that. The filetype of the terminal buffer is `floaterm`.

If you've opened multiple floaterm instances, they will be attached to a
double-circular-linkedlist. Then you can use `:FloatermNext` or `: FloatermPrev` to switch between them.

### Commands

#### `:FloatermNew[!] [options] [cmd]` Open a floaterm window.

- If `!` is given, execute `cmd` in `$SHELL`. Try `:FloatermNew python` and `:FloatermNew! python` to learn about the difference.
- If without `cmd`, open `$SHELL`.
- The `options` is formed as `--key=value`, it is used to specify attributes of a specific floaterm instance.
  - `name` name of the floaterm
  - `height` see `g:floaterm_height`
  - `width` see `g:floaterm_width`
  - `title` see `g:floaterm_title`
  - `wintype` see `g:floaterm_wintype`
  - `position` see `g:floaterm_position`
  - `autoclose` close the window after finishing job, see `g:floaterm_autoclose`
- Use `<TAB>` to get completion.
- The special characters(`:help cmdline-special`) such as `%` and `<cfile>`
  will be auto-expanded, to get standalone characters, use `\` followed by
  the corresponding character(e.g., `\%`).

For example, the command

```vim
:FloatermNew --height=0.6 --width=0.4 --wintype=floating --name=floaterm1 --position=topleft --autoclose=2 ranger --cmd="cd ~"
```

will open a new `floating` floaterm instance named `floaterm1` running `ranger --cmd="cd ~"` in the `topleft` corner of the main window.

The following command allows you to compile and run your C code in the floaterm window:

```vim
:FloatermNew --autoclose=0 gcc % -o %< && ./%<
```

#### `:FloatermPrev` Switch to the previous floaterm instance

#### `:FloatermNext` Switch to the next floaterm instance

#### `:FloatermFirst` Switch to the first floaterm instance

#### `:FloatermLast` Switch to the last floaterm instance

#### `:FloatermUpdate [options]` Update floaterm window attributes(`height`, `width`, etc.).

- The `options` is the same as in `:FloatermNew`.
- Use `<TAB>` to get completion.

#### `:[N]FloatermToggle[!] [floaterm_name]` Open or hide the floaterm window.

- If `N` is given, toggle the floaterm whose buffer number is `N`
- If `floaterm_name` is given, toggle the floaterm instance whose `name`
  attribute is `floaterm_name`. Otherwise create a new floaterm named
  `floaterm_name`.
- Use `<TAB>` to get completion.
- If `!` is given, toggle all floaterms

#### `:[N]FloatermShow[!] [floaterm_name]` Show the current floaterm window.

- If `N` is given, show the floaterm whose buffer number is `N`
- If `floaterm_name` is given, show the floaterm named `floaterm_name`.
- If `!` is given, show all floaterms

#### `:[N]FloatermHide[!] [floaterm_name]` Hide the current floaterms window.

- If `N` is given, hide the floaterm whose buffer number is `N`
- If `floaterm_name` is given, show the floaterm named `floaterm_name`.
- If `!` is given, hide all floaterms

#### `:[N]FloatermKill[!] [floaterm_name]` Kill the current floaterm instance

- If `N` is given, kill the floaterm whose buffer number is `N`
- If `floaterm_name` is given, kill the floaterm instance named `floaterm_name`.
- If `!` is given, kill all floaterms

#### `:FloatermSend [--name=floaterm_name] [cmd]` Send command to a job in floaterm.

- If `--name=floaterm_name` is given, send lines to the floaterm instance
  whose `name` is `floaterm_name`. Otherwise use the current floaterm.
- If `cmd` is given, it will be sent to floaterm and selected lines will be ignored.
- This command can also be used with a range, i.e., `'<,'>:FloatermSend [--name=floaterm_name]` to send selected lines to a floaterm.
  - If `cmd` is given, the selected lines will be ignored.
  - If use this command with a `!`, i.e., `'<,'>:FloatermSend! [--name=floaterm_name]` the common white spaces in the beginning of lines
    will be trimmed while the relative indent between lines will still be
    kept.
- Use `<TAB>` to get completion.
- Examples
  ```vim
  :FloatermSend                        " Send current line to the current floaterm (execute the line in the terminal)
  :FloatermSend --name=ft1             " Send current line to the floaterm named ft1
  :FloatermSend ls -la                 " Send `ls -la` to the current floaterm
  :FloatermSend --name=ft1 ls -la      " Send `ls -la` to the floaterm named ft1
  :23FloatermSend ...                  " Send the line 23 to floaterm
  :1,23FloatermSend ...                " Send lines between line 1 and line 23 to floaterm
  :'<,'>FloatermSend ...               " Send lines selected to floaterm(visual block selection are supported)
  :%FloatermSend ...                   " Send the whole buffer to floaterm
  ```

### Options

#### **`g:floaterm_shell`**

Type `String`. Default: `&shell`

#### **`g:floaterm_title`**

Type `String`. Show floaterm info(e.g., `'floaterm: 1/3'` implies there are 3
floaterms in total and the current is the first one) at the top left corner of
floaterm window.

Default: `'floaterm: $1/$2'`(`$1` and `$2` will be replaced by 'the index of
the current floaterm' and 'total floaterms count' respectively)

Example: `'floaterm($1|$2)'`

#### **`g:floaterm_wintype`**

Type `String`. `'floating'`(neovim) or `'popup'`(vim) by default. Set it to
`'normal'` if your vim/nvim doesn't support `floatwin` or `popup`.

#### **`g:floaterm_width`**

Type `Number` (number of columns) or `Float` (between 0 and 1). If `Float`,
the width is relative to `&columns`.

Default: `0.6`

#### **`g:floaterm_height`**

Type `Number` (number of lines) or `Float` (between 0 and 1). If `Float`, the
height is relative to `&lines`.

Default: `0.6`

#### **`g:floaterm_winblend`**

Type `Number`. The transparency of the floating terminal. Only works in neovim.

Default: `0`

#### **`g:floaterm_position`**

Type `String`. The position of the floating window. Available values:

- If `wintype` is `normal`: `'top'`, `'right'`, `'bottom'`, `'left'`. Default: `'bottom'`
- If `wintype` is `floating` or `popup`: `'top'`, `'right'`, `'bottom'`,
  `'left'`, `'center'`, `'topleft'`, `'topright'`, `'bottomleft'`,
  `'bottomright'`, `'auto'(at the cursor place)`. Default: `'center'`

#### **`g:floaterm_borderchars`**

Type `List` of `String`. Characters of the floating window border.

Default: `['─', '│', '─', '│', '┌', '┐', '┘', '└']`

#### **`g:floaterm_rootmarkers`**

Type `List` of `String`. If not empty, floaterm will be opened in the project root directory.

Example: `['.project', '.git', '.hg', '.svn', '.root', '.gitignore']`

Default: `[]`, which means floaterm will be opened just at the current directory

#### **`g:floaterm_open_command`**

Type `String`. Command used for opening a file in the outside nvim from within `:terminal`.

Available: `'edit'`, `'split'`, `'vsplit'`, `'tabe'`, `'drop'`. Default: `'edit'`

#### **`g:floaterm_gitcommit`**

Type `String`. Opening strategy for `COMMIT_EDITMSG` window by running `git commit` in the floaterm window. Only works in neovim.

Available: `'floaterm'`(open `gitcommit` in the floaterm window), `'split'`(recommended), `'vsplit'`, `'tabe'`.

Default: `''`, which means this is disabled by default(use your own `$GIT_EDITOR`).

#### **`g:floaterm_autoclose`**

Type `Number`. Whether to close floaterm window once the job gets finished.

- `0`: Always do NOT close floaterm window
- `1`: Close window if the job exits normally, otherwise stay it with messages like `[Process exited 101]`
- `2`: Always close floaterm window

Default: `0`.

#### **`g:floaterm_autoinsert`**

Type `Boolean`. Whether to enter Terminal-mode after opening a floaterm.

Default: `v:true`

#### **`g:floaterm_autohide`**

Type `Boolean`. Decide whether to hide previous floaterms before switching to or opening a new one.

Default: `v:true`.

#### **`g:floaterm_complete_options`**

Type `Dict`. Autocompletion options used for coc.nvim.

Available options:

- `shortcut`: a string
- `priority`: number between 0-99
- `filetypes`: array of filetype names this source should be triggered by. Available for all filetypes when ommited and for no filetypes when empty
- `firstMatch`: if not falsy, only the completion item that has the first letter matching the user input will be shown
- `triggerCharacters`: trigger characters for this source.

Default value: `{'shortcut': 'floaterm', 'priority': 5}`

### Keymaps

This plugin doesn't supply any default mappings. The following is a configuration example.

```vim
" Configuration example
let g:floaterm_keymap_new    = '<F7>'
let g:floaterm_keymap_prev   = '<F8>'
let g:floaterm_keymap_next   = '<F9>'
let g:floaterm_keymap_toggle = '<F12>'
```

You can also use other keys as shown below:

```vim
let g:floaterm_keymap_new = '<Leader>fn'
```

All options for the mappings are listed below:

- `g:floaterm_keymap_new`
- `g:floaterm_keymap_prev`
- `g:floaterm_keymap_next`
- `g:floaterm_keymap_first`
- `g:floaterm_keymap_last`
- `g:floaterm_keymap_hide`
- `g:floaterm_keymap_show`
- `g:floaterm_keymap_kill`
- `g:floaterm_keymap_toggle`

Note that this key mapping is installed from the [plugin](./plugin) directory,
so if you are using on-demand loading feature provided by some plugin-managers, the keymap
above won't take effect(`:help load-plugins`). Then you have to define the key
bindings yourself by putting the code used to define the key bindings in your
`vimrc`. For example,

```vim
nnoremap   <silent>   <F7>    :FloatermNew<CR>
tnoremap   <silent>   <F7>    <C-\><C-n>:FloatermNew<CR>
nnoremap   <silent>   <F8>    :FloatermPrev<CR>
tnoremap   <silent>   <F8>    <C-\><C-n>:FloatermPrev<CR>
nnoremap   <silent>   <F9>    :FloatermNext<CR>
tnoremap   <silent>   <F9>    <C-\><C-n>:FloatermNext<CR>
nnoremap   <silent>   <F12>   :FloatermToggle<CR>
tnoremap   <silent>   <F12>   <C-\><C-n>:FloatermToggle<CR>
```

### Highlights

This plugin provides two `highlight-groups` to specify the
background/foreground color of floaterm (also the border color if `g: floaterm_wintype` is `'floating'` or `'popup'`) window.

By default, they are both linked to `Normal`(see [detail]
(./plugin/floaterm.vim)). To customize, use `hi` command together with the
colors you prefer.

```vim
" Configuration example

" Set floaterm window's background to black
hi Floaterm guibg=black
" Set floating window border line color to cyan, and background to orange
hi FloatermBorder guibg=orange guifg=cyan
```

![](https://user-images.githubusercontent.com/20282795/91368959-fee00f00-e83c-11ea-9002-cab992d30794.png)

Besides, there is a neovim only highlight group which can be used to configure
no-current-focused window(`:help NormalNC`). It's also linked to `Normal` by
default.

```vim
" Configuration example

" Set floaterm window background to gray once the cursor moves out from it
hi FloatermNC guibg=gray
```

![](https://user-images.githubusercontent.com/20282795/91380259-28a62f80-e857-11ea-833f-11160d15647a.gif)

## Use with command line tools

The following cases should work both in Vim and NeoVim unless otherwise
specifically noted.

### floaterm

Normally if you run `vim/nvim somefile.txt` within the builtin terminal, you
would get another nvim/vim instance running in the subprocess.

[Floaterm](https://github.com/voldikss/vim-floaterm/tree/master/bin), which is
a builtin script in this plugin, allows you to open files from within `: terminal` without starting a nested nvim. To archive that, just literally
replace `vim/nvim` with `floaterm`, i.e., `floaterm somefile.txt`

**❗️Note**: This should works both in neovim and vim, but if you are using
neovim, please make sure [neovim-remote](https:
//github.com/mhinz/neovim-remote) has been installed. You can install it via
pip:

```sh
pip install neovim-remote
```

![](https://user-images.githubusercontent.com/20282795/91380257-27750280-e857-11ea-8d49-d760c009fee0.gif)

### git

See `g:floaterm_gitcommit` option.

Execute `git commit` in the terminal window without starting a nested nvim.

**❗️Note**: neovim only feature. Moreover, it also requires [neovim-remote](https://github.com/mhinz/neovim-remote), please install it using `pip3 install neovim-remote`.

![](https://user-images.githubusercontent.com/20282795/91380268-2cd24d00-e857-11ea-8dbd-d39a0bbb105e.gif)

### fzf

This plugin has implemented a [wrapper](./autoload/floaterm/wrapper/fzf.vim)
for `fzf` command. So it can be used as a tiny fzf plugin.

Try `:FloatermNew fzf` or even wrap this to a new command like this:

```vim
command! FZF FloatermNew fzf
```

![](https://user-images.githubusercontent.com/20282795/91380264-2b088980-e857-11ea-80ff-062b3d3bbf12.gif)

### fff

There is also an [fff wrapper](./autoload/floaterm/wrapper/fff.vim)

Try `:FloatermNew fff` or define a new command:

```vim
command! FFF FloatermNew fff
```

![](https://user-images.githubusercontent.com/1472981/75105718-9f315d00-567b-11ea-82d1-6f9a6365391f.gif)

### nnn

There is also an [nnn wrapper](./autoload/floaterm/wrapper/nnn.vim)

Try `:FloatermNew nnn` or define a new command:

```vim
command! NNN FloatermNew nnn
```

![](https://user-images.githubusercontent.com/20282795/91380278-322f9780-e857-11ea-8b1c-d40fc91bb07d.gif)

### lf

There is also an [lf wrapper](./autoload/floaterm/wrapper/lf.vim)

Try `:FloatermNew lf` or define a new command:

```vim
command! LF FloatermNew lf
```

![](https://user-images.githubusercontent.com/20282795/91380274-3065d400-e857-11ea-86df-981adddc04c6.gif)

### ranger

This plugin can also be a handy ranger plugin since it also has a [ranger wrapper](./autoload/floaterm/wrapper/ranger.vim)

Try `:FloatermNew ranger` or define a new command:

```vim
command! Ranger FloatermNew ranger
```

![](https://user-images.githubusercontent.com/20282795/91380284-3360c480-e857-11ea-9966-34856592d487.gif)

### vifm

There is also a [vifm wrapper](./autoload/floaterm/wrapper/vifm.vim)

Try `:FloatermNew vifm` or define a new command:

```vim
command! Vifm FloatermNew vifm
```

![](https://user-images.githubusercontent.com/43941510/77137476-3c888100-6ac2-11ea-90f2-2345c881aa8f.gif)

### lazygit

Furthermore, you can also use other command-line programs, such as lazygit, htop, ncdu, etc.

Use `lazygit` for instance:

![](https://user-images.githubusercontent.com/20282795/74755376-0f239a00-52ae-11ea-9261-44d94abe5924.png)

### python

Use `:FloatermNew python` to open a python shell. After that you can use `: FloatermSend` to send lines to the Python interactive shell.

This can also work for other languages which have interactive shells, such as lua, node, etc.

![](https://user-images.githubusercontent.com/20282795/91380286-352a8800-e857-11ea-800c-ac54efa7dd72.gif)

## Use with other plugins

### [vim-clap](https://github.com/liuchengxu/vim-clap)

Use vim-clap to switch/preview floating terminal buffers.

Try `:Clap floaterm`

![](https://user-images.githubusercontent.com/20282795/91380243-217f2180-e857-11ea-9f64-46e8676adc11.gif)

### [denite.nvim](https://github.com/Shougo/denite.nvim)

Use denite to switch/preview/open floating terminal buffers.

Try `:Denite floaterm`

![](https://user-images.githubusercontent.com/1239245/73604753-17ef4d00-45d9-11ea-967f-ef75927e2beb.gif)

### [coc.nvim](https://github.com/neoclide/coc.nvim)

Use CocList to switch/preview/open floating terminal buffers.

Install [coc-floaterm](https://github.com/voldikss/coc-floaterm) and try `:CocList floaterm`

![](https://user-images.githubusercontent.com/20282795/91380254-25ab3f00-e857-11ea-9733-d0ae5a954848.gif)

### [fzf](https://github.com/junegunn/fzf)

Install [fzf-floaterm](https://github.com/voldikss/fzf-floaterm) and try `:Floaterms`

### [LeaderF](https://github.com/Yggdroot/LeaderF)

Install [LeaderF-floaterm](https://github.com/voldikss/LeaderF-floaterm) and try `:Leaderf floaterm`

### [asynctasks.vim](https://github.com/skywind3000/asynctasks.vim)

This plugin can be a runner for [asynctasks.vim](https://github.com/skywind3000/asynctasks.vim/).
To use it, copy the following code to your `vimrc` set `g:asynctasks_term_pos`
to `"floaterm"` or add a `"pos=floaterm"` filed in your asynctasks
configuration files.

```vim
function! s:runner_proc(opts)
  let curr_bufnr = floaterm#curr()
  if has_key(a:opts, 'silent') && a:opts.silent == 1
    FloatermHide!
  endif
  let cmd = 'cd ' . shellescape(getcwd())
  call floaterm#terminal#send(curr_bufnr, [cmd])
  call floaterm#terminal#send(curr_bufnr, [a:opts.cmd])
  stopinsert
  if &filetype == 'floaterm' && g:floaterm_autoinsert
    call floaterm#util#startinsert()
  endif
endfunction

let g:asyncrun_runner = get(g:, 'asyncrun_runner', {})
let g:asyncrun_runner.floaterm = function('s:runner_proc')
```

Then your task will be ran in the floaterm instance. See asynctasks.vim
[Wiki](https://github.com/skywind3000/asynctasks.vim/wiki/Customize-Runner) for more information.

## How to define more wrappers

Once you've find a nice command line program which can be used as a wrapper of
this plugin, you can either send me a PR or define a personal wrapper for
yourself.

The wrapper script must be located in `autoload/floaterm/wrapper/` directory, e.g., `autoload/floaterm/wrapper/fzf.vim`.

There are two ways for a command to be spawned:

- To be executed after spawning `$SHELL`. Here is the old implementation of [fzf wrapper](./autoload/floaterm/wrapper/fzf.vim)

  ```vim
  function! floaterm#wrapper#fzf#() abort
    return ['floaterm $(fzf)', {}, v:true]
  endfunction
  ```

  The code above returns a list. `floaterm $(fzf)` is the command to be
  executed. `v:true` means the command will be executed after the `&shell`
  startup. In this way, the second element of the list must be `{}`.

- To be executed through `termopen()`/`term_start()` function, in that case, a
  callback option can be provided. See [fzf wrapper](./autoload/floaterm/wrapper/fzf.vim)

  ```vim
  function! floaterm#wrapper#fzf#(cmd) abort
    let s:fzf_tmpfile = tempname()
    let cmd = a:cmd . ' > ' . s:fzf_tmpfile
    return [cmd, {'on_exit': funcref('s:fzf_callback')}, v:false]
  endfunction

  function! s:fzf_callback(...) abort
    if filereadable(s:fzf_tmpfile)
      let filenames = readfile(s:fzf_tmpfile)
      if !empty(filenames)
        if has('nvim')
          call floaterm#window#hide_floaterm(bufnr('%'))
        endif
        for filename in filenames
          execute g:floaterm_open_command . ' ' . fnameescape(filename)
        endfor
      endif
    endif
  endfunction
  ```

  In the example above, after executing `:FloatermNew fzf`, function
  `floaterm#wrapper#fzf#` will return `['fzf > /tmp/atmpfilename', {'on_exit': funcref('s:fzf_callback')}, v:false]`.

  Here `v:false` means `cmd`(`fzf > /tmp/atmpfilename`) will be passed through
  `termopen()`(neovim) or `term_start()`(vim). As a result, an fzf interactive
  will be opened in a floaterm window. After choosing a file using `<CR>`, fzf
  exits and the filepath will be written in `/tmp/atmpfilename`. Then the
  function `s:fzf_callback()` will be invoked to open the file.

## How to write sources for fuzzy finder plugins

Function `floaterm#buflist#gather()` returns a list contains all the floaterm buffers.

Function `floaterm#terminal#open_existing({bufnr})` opens the floaterm whose buffer number is `{bufnr}`.

For reference, see [floaterm source for vim-clap](./autoload/clap/provider/floaterm.vim).

## Wiki

https://github.com/voldikss/vim-floaterm/wiki

## F.A.Q

https://github.com/voldikss/vim-floaterm/issues?q=label%3AFAQ

## Breaking Changes

https://github.com/voldikss/vim-floaterm/issues?q=label%3A%22breaking+change%22

## Feedback

If you like this plugin, please star it or sponsor the project.

It's a great way of getting feedback.

The same goes for reporting issues or feature requests.

## Credits

- [floaterm executable](https://github.com/voldikss/vim-floaterm/blob/master/bin/floaterm) is modified
  from [vim-terminal-help](https://github.com/skywind3000/vim-terminal-help/blob/master/tools/utils/drop)

- Some features require [neovim-remote](https://github.com/mhinz/neovim-remote)

- Become a [contributor](https://github.com/voldikss/vim-floaterm/graphs/contributors) of this project, or
  even help improve this documentation(correct some grammar mistakes).

## License

MIT
