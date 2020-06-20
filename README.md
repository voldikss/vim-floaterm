![CI](https://github.com/voldikss/vim-floaterm/workflows/CI/badge.svg)

【[Introduction in Chinese|中文介绍](https://zhuanlan.zhihu.com/p/107749687)】

Use (neo)vim terminal in the floating/popup window.

![](https://user-images.githubusercontent.com/20282795/74799912-de268200-530c-11ea-9831-d412a7700505.png)

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Basic Usage](#basic-usage)
  - [Commands](#commands)
  - [Options](#options)
  - [Keymaps](#keymaps)
  - [Highlights](#highlights)
- [Integrate with command line tools](#integrate-with-command-line-tools)
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
- [Integrate with other plugins](#integrate-with-other-plugins)
  - [vim-clap](#vim-clap)
  - [denite.nvim](#denitenvim)
  - [coc.nvim](#cocnvim)
  - [other fuzzy finder plugins](#other-fuzzy-finders)
  - [asynctasks.vim](#asynctasksvim)
- [How to define more wrappers](#how-to-define-more-wrappers)
- [How to write sources for fuzzy finder plugins](#how-to-write-sources-for-fuzzy-finder-plugins)
- [Wiki](#wiki)
- [F.A.Q](#f.a.q)
- [Break changes](#break-changes)
- [Credits](#credits)
- [License](#license)

## Features

- NeoVim floatwin and Vim8 popupwin support
- Open and toggle terminal window quickly
- Multiple terminal instances
- Customizable floating terminal style
- Switch/Preview floating terminal buffers using [vim-clap](https://github.com/liuchengxu/vim-clap), [denite.nvim](https://github.com/Shougo/denite.nvim) or [coc.nvim](https://github.com/neoclide/coc.nvim)
- Integrate with other external command-line tools(ranger, lf, fzf, etc.)
- Use as a custom task runner for [asynctasks.vim](https://github.com/skywind3000/asynctasks.vim)

## Requirements

- Vim or NeoVim with `terminal` feature

Run `:checkhealth` to check the environment.

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

Use `:FloatermNew` command to open a terminal window, use `:FloatermToggle` to hide/reopen that. The filetype of the terminal buffer is set to `floaterm`.

If you've opened multiple floaterm instances, they will be attached to a double-circular-linkedlist. Then you can use `:FloatermNext` or `:FloatermPrev` to switch between them.

### Commands

#### `:FloatermNew[!] [options] [cmd]` Open a floaterm window.

- If `!` exists, run program in `$SHELL`. Try `:FloatermNew python` and `:FloatermNew! python` to learn about the difference.
- If `cmd` doesn't exist, open `$SHELL`.
- The `options` is formed as `--key[=value]`, it is used to specify some attributes of the floaterm instance, including `height`, `width`, `wintype`, `position`, `name` and `autoclose`.
  - `height` see `g:floaterm_height`
  - `width` see `g:floaterm_width`
  - `wintype` see `g:floaterm_wintype`
  - `position` see `g:floaterm_position`
  - `name` name of the floaterm
  - `autoclose` close the window after finishing job, see `g:floaterm_autoclose`
- Use `<TAB>` to get completion.

For example, command

```vim
:FloatermNew --height=0.6 --width=0.4 --wintype=floating --name=floaterm1 --position=topleft --autoclose=2 ranger --cmd="cd ~"
```

will open a new `floating` floaterm instance named `floaterm1` running `ranger --cmd="cd ~"` in the `topleft` corner of the main window.

#### `:FloatermPrev` Switch to the previous floaterm instance

#### `:FloatermNext` Switch to the next floaterm instance

#### `:FloatermUpdate [options]` Update floaterm window attributes(`height`, `width`, etc.).

- The `options` is the same as in `:FloatermNew`.
- Use `<TAB>` to get completion.

#### `:FloatermToggle[!] [floaterm_name]` Open or hide the floaterm window.

- If `floaterm_name` exists, toggle the floaterm instance whose `name` attribute is `floaterm_name`.
- Use `<TAB>` to get completion.
- If `!` exists, toggle all floaterms

#### `:FloatermShow[!] [floaterm_name]` Show the current floaterm window.

- If `floaterm_name` exists, show the floaterm named `floaterm_name`.
- If `!` exists, show all floaterms

#### `:FloatermHide[!] [floaterm_name]` Hide the current floaterms window.

- If `floaterm_name` exists, show the floaterm named `floaterm_name`.
- If `!` exists, hide all floaterms

#### `:FloatermKill[!] [floaterm_name]` Kill the current floaterm instance

- If `floaterm_name` exists, kill the floaterm instance named `floaterm_name`.
- If `!` exists, kill all floaterms

#### `:FloatermSend [--name=floaterm_name] [cmd]` Send command to a job in floaterm.

- If `--name=floaterm_name` exists, send lines to the floaterm instance whose `name` is `floaterm_name`. Otherwise use the current floaterm.
- If `cmd` exists, it will be sent to floaterm and selected lines will be ignored.
- This command can also be used with a range, i.e., `'<,'>:FloatermSend [--name=floaterm_name]` to send selected lines to a floaterm.
  - If `cmd` exists, the selected lines will be ignored.
  - If use this command with a `!`, i.e., `'<,'>:FloatermSend! [--name=floaterm_name]` the common white spaces in the beginning of lines will be trimmed while the relative indent between lines will still be kept.
- Use `<TAB>` to get completion.
- Examples
  ```vim
  :FloatermSend                        " Send current line to the current floaterm
  :FloatermSend --name=ft1             " Send current line to the floaterm named ft1
  :FloatermSend ls -la                 " Send `ls -la` to the current floaterm
  :FloatermSend --name=ft1 ls -la      " Send `ls -la` to the floaterm named ft1
  :23FloatermSend ...                  " Send the line 23 to floaterm
  :1,23FloatermSend ...                " Send lines between line 1 and line 23 to floaterm
  :'<,'>FloatermSend ...               " Send lines selected to floaterm
  :%FloatermSend ...                   " Send the whole buffer to floaterm
  ```

### Options

#### **`g:floaterm_shell`**

Type `string`. Default: `&shell`

#### **`g:floaterm_wintype`**

Type `string`. `'floating'`(neovim) or `'popup'`(vim) by default. Set it to `'normal'` if your vim/nvim doesn't support `floatwin` or `popup`.

#### **`g:floaterm_wintitle`**

Type `bool`. Whether to show floaterm info(e.g., `'floaterm: 1/3'`) at the top left corner of floaterm window. Default: `v:true`

#### **`g:floaterm_width`**

Type `int` (number of columns) or `float` (between 0 and 1). If `float`, the width is relative to `&columns`. Default: `0.6`

#### **`g:floaterm_height`**

Type `int` (number of lines) or `float` (between 0 and 1). If `float`, the height is relative to `&lines`. Default: `0.6`

#### **`g:floaterm_winblend`**

Type `int`. The transparency of the floating terminal. Only works in neovim. Default: `0`

#### **`g:floaterm_position`**

Type `string`. The position of the floating window. Available values:

- If `wintype` is `normal`: `'top'`, `'right'`, `'bottom'`, `'left'`. Default: `'bottom'`
- If `wintype` is `floating` or `popup`: `'top'`, `'right'`, `'bottom'`, `'left'`, `'center'`, `'topleft'`, `'topright'`, `'bottomleft'`, `'bottomright'`, `'auto'(at the cursor place)`. Default: `'center'`

#### **`g:floaterm_borderchars`**

Type `array of string`. Characters of the floating window border.

Default: `['─', '│', '─', '│', '┌', '┐', '┘', '└']`

#### **`g:floaterm_rootmarkers`**

Type `array of string`. If not empty, floaterm will be opened in the project root directory.

Example: `['.project', '.git', '.hg', '.svn', '.root', '.gitignore']`, Default: `[]`

#### **`g:floaterm_autoinsert`**

Type `bool`. Enter terminal mode after opening a floaterm. Default: `v:true`

#### **`g:floaterm_open_command`**

Type `string`. Command used for opening a file from within `:terminal`.

Available: `'edit'`, `'split'`, `'vsplit'`, `'tabe'`, `'drop'`. Default: `'edit'`

#### **`g:floaterm_gitcommit`**

Type `string`. Opening strategy for running `git commit` in floaterm window. Only works in neovim.

Available: `'floaterm'`(open `gitcommit` file in the floaterm window), `'split'`, `'vsplit'`, `'tabe'`.

Recommended: `'split'` or `'vsplit'`.

Default: `v:null` which means this is disabled by default(use your own `$GIT_EDITOR`).

#### **`g:floaterm_autoclose`**

Type `number`. Decide whether to close floaterm window once job gets finished.

- `0`: Always do NOT close floaterm window
- `1`: Close window if the job exits normally, otherwise stay it with messages like `[Process exited 101]`
- `2`: Always close floaterm window

Default: `1`.

#### **`g:floaterm_autohide`**

Type `boolean`. Decide whether to hide previous floaterms before switching to or opening a new one.

Default: `v:true`.

### Keymaps

This plugin doesn't supply any default mappings. To use a recommended mappings, put the following code in your `vimrc`.

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
- `g:floaterm_keymap_hide`
- `g:floaterm_keymap_show`
- `g:floaterm_keymap_kill`
- `g:floaterm_keymap_toggle`

Note that this key mapping is installed from the [plugin](./plugin) directory, so if you use on-demand loading provided by some plugin-managers, the keymap above won't take effect(`:help load-plugins`). Then you have to define the key bindings yourself by putting the code used to define the key bindings in your `vimrc`. For example,

For example,

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

This plugin provides two `highlight-groups` to specify the background/foreground color of floaterm (also the border color if `g:floaterm_wintype` is `'floating'` or `'popup'`) window.

By default, they are both linked to `Normal`(see [detail](./plugin/floaterm.vim)). To customize, use `hi` command together with the colors you prefer.

```vim
" Configuration example

" Set floaterm window's background to black
hi Floaterm guibg=black
" Set floating window border line color to cyan, and background to orange
hi FloatermBorder guibg=orange guifg=cyan
```

![](https://user-images.githubusercontent.com/20282795/74794098-42d9e080-52fd-11ea-9ccf-661dd748aa03.png)

Besides, there is a neovim only `hi-group` which can be used to configure no-current window(`:help NormalNC`). It's also linked to `Normal` by default.

```vim
" Configuration example

" Set floaterm window background to skyblue once the cursor moves out from it
hi FloatermNC guibg=skyblue
```

## Integrate with command line tools

Before you start, if you are using neovim, please make sure that `nvr` is required, please install it via pip using `pip3 install neovim-remote`.

The following cases should work both in Vim and NeoVim unless otherwise specifically noted.

### floaterm

Normally if you run `vim/nvim somefile.txt` within a builtin terminal, you will get another nvim/vim instance running in the subprocess. This plugin allows you to open files from within `:terminal` without starting a nested nvim process. To archive that, just replace `vim/nvim` with `floaterm`, i.e., `floaterm somefile.txt`

**❗️Note**: This is neovim only

![](https://user-images.githubusercontent.com/20282795/74755351-06cb5f00-52ae-11ea-84ba-d0b3e88e9377.gif)

### git

See `g:floaterm_gitcommit` option.

Execute `git commit` in the terminal window without starting a nested nvim.

**❗️Note**: This is neovim only

![](https://user-images.githubusercontent.com/20282795/76213003-b0b26180-6244-11ea-85ad-1632adfd07d9.gif)

### fzf

This plugin has implemented a [wrapper](./autoload/floaterm/wrapper/fzf.vim) for fzf command. So it can be used as a tiny fzf plugin.

Try `:FloatermNew fzf` or even wrap this to a new command like this:

```vim
command! FZF FloatermNew fzf
```

![](https://user-images.githubusercontent.com/20282795/78089550-60b95b80-73fa-11ea-8ac8-8fab2025b4d8.gif)

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

![](https://user-images.githubusercontent.com/20282795/75599726-7a594180-5ae2-11ea-80e2-7a33df1433f6.gif)

### lf

There is also an [lf wrapper](./autoload/floaterm/wrapper/lf.vim)

Try `:FloatermNew lf` or define a new command:

```vim
command! LF FloatermNew lf
```

![](https://user-images.githubusercontent.com/20282795/77142551-6e4a1980-6abb-11ea-9525-73e1a1844e83.gif)

### ranger

This plugin can also be a handy ranger plugin since it also has a [ranger wrapper](./autoload/floaterm/wrapper/ranger.vim)

Try `:FloatermNew ranger` or define a new command:

```vim
command! Ranger FloatermNew ranger
```

![](https://user-images.githubusercontent.com/20282795/74800026-2e054900-530d-11ea-8e2a-67168a9532a9.gif)

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

Use `:FloatermNew python` to open a python shell. After that you can use `:FloatermSend` to send lines to the Python interactive shell.

This can also work for other languages which have interactive shells, such as lua, node, etc.

![](https://user-images.githubusercontent.com/20282795/78530892-0c0d4a80-7817-11ea-8934-835a6e6d0628.gif)

## Integrate with other plugins

### [vim-clap](https://github.com/liuchengxu/vim-clap)

Use vim-clap to switch/preview floating terminal buffers.

Try `:Clap floaterm`

![](https://user-images.githubusercontent.com/20282795/74755336-00d57e00-52ae-11ea-8afc-030ff55c2145.gif)

### [denite.nvim](https://github.com/Shougo/denite.nvim)

Use denite to switch/preview/open floating terminal buffers.

Try `:Denite floaterm`

![](https://user-images.githubusercontent.com/1239245/73604753-17ef4d00-45d9-11ea-967f-ef75927e2beb.gif)

### [coc.nvim](https://github.com/neoclide/coc.nvim)

Use CocList to switch/preview/open floating terminal buffers.

Install [coc-floaterm](https://github.com/voldikss/coc-floaterm) and try `:CocList floaterm`

![](https://user-images.githubusercontent.com/20282795/75005925-fcc27f80-54aa-11ea-832e-59ea5b02fc04.gif)

### other fuzzy finders

Please refer to the [Wiki](https://github.com/voldikss/vim-floaterm/wiki/Integration-with-other-fuzzy-finders)

### [asynctasks.vim](https://github.com/skywind3000/asynctasks.vim)

This plugin can be a runner for [asynctasks.vim](https://github.com/skywind3000/asynctasks.vim/). To use it, copy the following code to your `vimrc` set `g:asynctasks_term_pos` to `"floaterm"` or add a `"pos=floaterm"` filed in your asynctasks configuration files.

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

Then your task will be ran in the floaterm instance. See asynctasks.vim [Wiki](https://github.com/skywind3000/asynctasks.vim/wiki/Customize-Runner) for more information.

## How to define more wrappers

Once you've find a nice command line program which can be used as a wrapper of this plugin, you can either send me a PR or define a personal wrapper for yourself.

The wrapper script must be located in `autoload/floaterm/wrapper/` directory, e.g., `autoload/floaterm/wrapper/fzf.vim`.

There are two ways for a command to be spawned:

- To be executed after spawning `$SHELL`. Here is the old implementation of [fzf wrapper](./autoload/floaterm/wrapper/fzf.vim)

  ```vim
  function! floaterm#wrapper#fzf#() abort
    return ['floaterm $(fzf)', {}, v:true]
  endfunction
  ```

  The code above returns a list. `floaterm $(fzf)` is the command to be executed. `v:true` means the command will be executed after the `&shell` startup. In this way, the second element of the list must be `{}`.

- To be executed through `termopen()`/`term_start()` function, in that case, a callback option can be provided. See [fzf wrapper](./autoload/floaterm/wrapper/fzf.vim)

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

  In the example above, after executing `:FloatermNew fzf`, function `floaterm#wrapper#fzf#` will return `['fzf > /tmp/atmpfilename', {'on_exit': funcref('s:fzf_callback')}, v:false]`.

  Here `v:false` means `cmd`(`fzf > /tmp/atmpfilename`) will be passed through `termopen()`(neovim) or `term_start()`(vim). As a result, an fzf interactive will be opened in a floaterm window. After choosing a file using `<CR>`, fzf exits and the filepath will be written in `/tmp/atmpfilename`. Then the function `s:fzf_callback()` will be invoked to open the file.

## How to write sources for fuzzy finder plugins

Function `floaterm#buflist#gather()` returns a list contains all the floaterm buffers.

Function `floaterm#terminal#open_existing({bufnr})` opens the floaterm whose buffer number is `{bufnr}`.

For reference, see [floaterm source for vim-clap](./autoload/clap/provider/floaterm.vim).

## Wiki

[Here you go](https://github.com/voldikss/vim-floaterm/wiki)

## F.A.Q

- #### This plugin leaves an empty buffer/window on startify window

  Put this code in your `vimrc`

  ```vim
  autocmd User Startified setlocal buflisted
  ```

- #### How to customize the style of the floaterm window?

  Use `autocmd`. For example

  ```vim
  function s:floatermSettings()
      setlocal number
      " more settings
  endfunction

  autocmd FileType floaterm call s:floatermSettings()
  ```

- #### I want to open normal(non-floating) floaterm in a vsplit window.

  Use `:FloatermUpdate`

  ```vim
  :FloatermUpdate --wintype=normal --position=right
  ```

- #### Can not enter insert mode after creating a new floaterm...

  See option [g:floaterm_autoinsert](#gfloaterm_autoinsert), also [#52](https://github.com/voldikss/vim-floaterm/issues/52) might be helpful.

- #### Why the plugin is named "vim-floaterm" instead of "vim-popterm" or others?

  Because this was firstly developed based on nvim's floating window. But now it supports both floaterm and popup, you can get similar experience in both.

## Break Changes

- Change in asynctasks.runner_proc: `call floaterm#hide()` => `call floaterm#hide(1, '')`
- Current floaterm will be hidden by default before opening a new one or switching to prev/next one using `:FloatermPrev` or `:FloatermNext`. See `g:floaterm_autohide` to get more info.
- Current floaterm won't be hidden before switching to prev/next one using `:FloatermPrev` or `:FloatermNext`
- Command `:FloatermSend [floaterm_name]` => `:FloatermSend [--name=floaterm_name] [cmd]`
- Use GNU style for cmdline arguments. e.g., `wintype=normal` => `--wintype=normal`
- Floaterm window won't be closed automatically after finishing job by default, see `g:floaterm_autoclose`
- Rename: `g:floaterm_type` => `g:floaterm_wintype`
- Rename: `FloatermNF` => `Floaterm`
- Rename: `FloatermBorderNF` => `FloatermBorder`

## Credits

- [floaterm executable](https://github.com/voldikss/vim-floaterm/blob/master/bin/floaterm) is modified from [vim-terminal-help](https://github.com/skywind3000/vim-terminal-help/blob/master/tools/utils/drop)

- Some features require [neovim-remote](https://github.com/mhinz/neovim-remote)

## License

MIT
