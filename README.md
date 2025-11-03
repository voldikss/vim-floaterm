<div align="center" markdown="1">
   <sup>Special thanks to:</sup>
   <br>
   <br>
   <a href="https://www.warp.dev/?utm_source=github&utm_medium=referral&utm_campaign=fzf">
      <img alt="Warp sponsorship" width="400" src="https://github.com/user-attachments/assets/ab8dd143-b0fd-4904-bdc5-dd7ecac94eae">
   </a>

### [Warp, the AI terminal built for developers](https://www.warp.dev/?utm_source=github&utm_medium=referral&utm_campaign=fzf)
[Available for MacOS, Linux, & Windows](https://www.warp.dev/?utm_source=github&utm_medium=referral&utm_campaign=fzf)<br>

</div>
<hr>

Use (neo)vim terminal in the floating/popup window.

[![CI](https://github.com/voldikss/vim-floaterm/workflows/CI/badge.svg)](https://github.com/voldikss/vim-floaterm/actions?query=workflow%3ACI) [![GitHub license](https://img.shields.io/github/license/voldikss/vim-floaterm.svg)](https://github.com/voldikss/vim-floaterm/blob/master/LICENSE) [![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/voldikss/vim-floaterm/graphs/commit-activity)

![](https://user-images.githubusercontent.com/20282795/91376670-2db3b080-e850-11ea-9991-efa4f4da6f44.png)

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Get started](#get-started)
  - [Commands](#commands)
  - [Options](#options)
  - [Keymaps](#keymaps)
  - [Highlights](#highlights)
  - [Autocmd](#autocmd)
- [Advanced Topics](#advanced-topics)
  - [Use with command line tools](#use-with-command-line-tools)
  - [Use with other plugins](#use-with-other-plugins)
  - [How to define more wrappers](#how-to-define-more-wrappers)
  - [How to write sources for fuzzy finder plugins](#how-to-write-sources-for-fuzzy-finder-plugins)
- [Contributing](#contributing)
- [FAQ](#faq)
- [Breaking changes](#breaking-changes)
- [Related projects](#related-projects)
- [Credits](#credits)
- [License](#license)

## Features

- Support neovim floatwin and vim8 popupwin
- Manage multiple terminal instances
- Customizable terminal window style
- Switch/preview floating terminal buffers using fuzzy-finder plugins such as
  [denite.nvim](https://github.com/Shougo/denite.nvim) or
  [fzf](https://github.com/junegunn/fzf), etc.
- Use with other external command-line tools(ranger, fzf, ripgrep etc.)
- Use as a custom task runner for [asynctasks.vim](https://github.com/skywind3000/asynctasks.vim)
  or [asyncrun.vim](https://github.com/skywind3000/asyncrun.vim)

## Requirements

- Vim or neovim with `terminal` feature

## Installation

- packer.nvim

```lua
use 'voldikss/vim-floaterm'

```

- vim-plug

```vim
Plug 'voldikss/vim-floaterm'
```

- dein.nvim

```vim
call dein#add('voldikss/vim-floaterm')
```

## Get Started

Use `:FloatermNew` to open a terminal window, use `:FloatermToggle` to
hide/reopen that. The filetype of the terminal buffer is `floaterm`.

If you've opened multiple floaterm instances, they will be attached to a
double-circular-linkedlist. Then you can use `:FloatermNext` or
`: FloatermPrev` to switch between them.

**❗️Note**: Long-running jobs (e.g. `yarn watch`) inside the builtin terminal
would probably slowdown your operation. It's recommended to put them into the
external terminals.

### Commands

#### `:FloatermNew[!] [options] [cmd]` Open a floaterm window.

- If `!` is given, execute `cmd` in `$SHELL`. Try `:FloatermNew python` and
  `: FloatermNew! python` to learn about the difference.
- If execute without `cmd`, open `$SHELL`.
- The `options` is formed as `--key[=value]`, it is used to specify local
  attributes of a specific floaterm instance. Note that in order to input
  space, you have to form it as `\` followed by space, and `\` must be typed
  as `\\`
  - `cwd` working directory that floaterm will be opened at. Accepts a
    path, the literal `<root>` which represents the project root directory,
    the literal `<buffer>` which specifies the directory of the active buffer,
    or the literal `<buffer-root>` which corresponds to the project root
    directory of the active buffer.
  - `name` name of the floaterm
  - `silent` If `--silent` is given, spawn a floaterm but not open the window,
    you may toggle it afterwards
  - `disposable` If `--disposable` is given, the floaterm will be destroyed
    once it is hidden.
  - `title` see `g:floaterm_title`
  - `width` see `g:floaterm_width`
  - `height` see `g:floaterm_height`
  - `opener` see `g:floaterm_opener`
  - `wintype` see `g:floaterm_wintype`
  - `position` see `g:floaterm_position`
  - `autoclose` see `g:floaterm_autoclose`
  - `borderchars` see `g:floaterm_borderchars`
  - `titleposition` see `g:floaterm_titleposition`
- This command basically shares the consistent behaviors with the builtin `:terminal`:
  - The special characters(`:help cmdline-special`) such as `%` and `<cfile>`
    will be auto-expanded, to get standalone characters, use `\` followed by
    the corresponding character(e.g., `\%`).
  - Note that `<bar>`(i.e., `|`) will be seen as an argument of the command,
    therefore it can not be followed by another Vim command.
- If execute this command with a range, i.e., `'<,'>:FloatermNew ...`, the
  selected lines will be sent to the created floaterm. For example, see
  [python repl use case](#python) below.
- Use `<TAB>` to get completion.

For example, the command

```vim
:FloatermNew --height=0.6 --width=0.4 --wintype=float --name=floaterm1 --position=topleft --autoclose=2 ranger --cmd="cd ~"
```

will open a new floating/popup floaterm instance named `floaterm1` running
`ranger --cmd="cd ~"` in the `topleft` corner of the main window.

The following command allows you to compile and run your C code in the floaterm window:

```vim
:FloatermNew --autoclose=0 gcc % -o %< && ./%<
```

#### `:FloatermPrev` Switch to the previous floaterm instance

#### `:FloatermNext` Switch to the next floaterm instance

#### `:FloatermFirst` Switch to the first floaterm instance

#### `:FloatermLast` Switch to the last floaterm instance

#### `:FloatermUpdate [options]` Update floaterm window attributes(`height`, `width`, etc.).

- The `options` is the same as in `:FloatermNew` (except `--silent`).
- Use `<TAB>` to get completion.

#### `:[N]FloatermToggle[!] [floaterm_name]` Open or hide the floaterm window.

- If `N` is given, toggle the floaterm whose buffer number is `N`
- If `floaterm_name` is given, toggle the floaterm instance whose `name`
  attribute is `floaterm_name`. Otherwise create a new floaterm named
  `floaterm_name`.
- Use `<TAB>` to get completion.
- If `!` is given, toggle all floaterms (`:FloatermHide!` or `: FloatermShow!`)

#### `:[N]FloatermShow[!] [floaterm_name]` Show the current floaterm window.

- If `N` is given, show the floaterm whose buffer number is `N`
- If `floaterm_name` is given, show the floaterm named `floaterm_name`.
- If `!` is given, show all floaterms (If multiple floaterms have the same
  position attribute, only one of them will be show)

#### `:[N]FloatermHide[!] [floaterm_name]` Hide the current floaterms window.

- If `N` is given, hide the floaterm whose buffer number is `N`
- If `floaterm_name` is given, show the floaterm named `floaterm_name`.
- If `!` is given, hide all floaterms

#### `:[N]FloatermKill[!] [floaterm_name]` Kill the current floaterm instance

- If `N` is given, kill the floaterm whose buffer number is `N`
- If `floaterm_name` is given, kill the floaterm instance named `floaterm_name`.
- If `!` is given, kill all floaterms

#### `:FloatermSend[!] [--name=floaterm_name] [cmd]` Send command to a job in floaterm.

- If `--name=floaterm_name` is given, send lines to the floaterm instance
  whose `name` is `floaterm_name`. Otherwise use the current floaterm.
- If `cmd` is given, it will be sent to floaterm and selected lines will be ignored.
- This command can also be used with a range, i.e., `'<,'>:FloatermSend [--name=floaterm_name]`
  to send selected lines to a floaterm.
  - If `cmd` is given, the selected lines will be ignored.
  - If use this command with a `!`, i.e., `'<,'>:FloatermSend! [--name=floaterm_name]`
    the common white spaces in the beginning of lines
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

Default: `'floaterm: $1/$2'`(`$1` and `$2` will be substituted by 'the index of
the current floaterm' and 'the count of all floaterms' respectively)

Example: `'floaterm($1|$2)'`

#### **`g:floaterm_wintype`**

Type `String`. `'float'`(nvim's floating or vim's popup) by default. Set it to
`'split'` or `'vsplit'` if you don't want to use floating or popup window.

#### **`g:floaterm_width`**

Type `Number` (number of columns) or `Float` (between 0 and 1). If `Float`,
the width is relative to `&columns`.

Default: `0.6`

#### **`g:floaterm_height`**

Type `Number` (number of lines) or `Float` (between 0 and 1). If `Float`, the
height is relative to `&lines`.

Default: `0.6`

#### **`g:floaterm_position`**

Type `String`. The position of the floating window. Available values:

- If `wintype` is `split`/`vsplit`: `'leftabove'`, `'aboveleft'`,
  `'rightbelow'`, `'belowright'`, `'topleft'`, `'botright'`. Default:
  `'botright'`.

  It's recommended to have a look at those options meanings, e.g. `:help :leftabove`.

- If `wintype` is `float`: `'top'`, `'bottom'`, `'left'`, `'right'`,
  `'topleft'`, `'topright'`, `'bottomleft'`, `'bottomright'`, `'center'`,
  `'auto'(at the cursor place)`. Default: `'center'`

In addition, there is another option `'random'` which allows to pick a random
position from above when (re)opening a floaterm window.

#### **`g:floaterm_borderchars`**

Type `String`. 8 characters of the floating window border (top, right, bottom,
left, topleft, topright, botright, botleft).

Default: `─│─│┌┐┘└`

#### **`g:floaterm_rootmarkers`**

Type `List` of `String`. Markers used to detect the project root directory for `--cwd=<root>`
or `--cwd=<buffer-root>`.

Default: `['.project', '.git', '.hg', '.svn', '.root']`

#### **`g:floaterm_giteditor`**

Type `Boolean`. Whether to override `$GIT_EDITOR` in floaterm terminals so git commands can
open open an editor in the same neovim instance. See [git](#git) for details.
This flag also overrides `$HGEDITOR` for Mercurial.

Default: `v:true`

#### **`g:floaterm_opener`**

Type `String`. Command used for opening a file in the outside nvim from within `:terminal`.

Available: `'edit'`, `'split'`, `'vsplit'`, `'tabe'`, `'drop'` or
[user-defined commands](https://github.com/voldikss/vim-floaterm/issues/259)

Default: `'split'`

#### **`g:floaterm_autoclose`**

Type `Number`. Whether to close floaterm window once the job gets finished.

- `0`: Always do NOT close floaterm window
- `1`: Close window if the job exits normally, otherwise stay it with messages
  like `[Process exited 101]`
- `2`: Always close floaterm window

Default: `1`.

#### **`g:floaterm_autohide`**

Type `Number`. Whether to hide previous floaterms before switching to or
opening a another one.

- `0`: Always do NOT hide previous floaterm windows
- `1`: Only hide those whose position (`b:floaterm_position`) is identical to
  that of the floaterm which will be opened
- `2`: Always hide them

Default: `1`.

#### **`g:floaterm_autoinsert`**

Type `Boolean`. Whether to enter Terminal-mode after opening a floaterm.

Default: `v:true`

#### **`g:floaterm_titleposition`**

Type `String`. The position of the floaterm title.

Available: `'left'`, `'center'`, `'right'`.

Default: `'left'`

### Keymaps

This plugin doesn't supply any default mappings. Here are the configuration examples.

```vim
" Configuration example
let g:floaterm_keymap_new    = '<F7>'
let g:floaterm_keymap_prev   = '<F8>'
let g:floaterm_keymap_next   = '<F9>'
let g:floaterm_keymap_toggle = '<F12>'
```

You can also use other keys as shown below:

```vim
let g:floaterm_keymap_new = '<Leader>ft'
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

Note that the key mappings are set from the [plugin/floaterm.vim](./plugin/floaterm.vim),
so if you are using on-demand loading feature provided by some plugin-managers,
the keymap above won't take effect(`:help load-plugins`). Then you have to
define the key bindings by yourself. For example,

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

To toggle a term in the current buffer directory :

```vim
function! s:get_dir(path) abort
    if isdirectory(a:path)
      let dir = fnamemodify(a:path, ':p')
    elseif filereadable(a:path)
      let dir = fnamemodify(a:path, ':p:h')
    else
      let dir = fnamemodify(getcwd(), ':p')
    endif
    let dir = fnamemodify(dir, ':~')
    let dir = escape(dir, ' %#|"')
    return dir
endfunction

nnoremap <silent><expr> <F6> g:floaterm#buflist#curr() == -1 ?
      \   ':<c-u>FloatermNew --cwd=<C-R>=<sid>get_dir(expand("%"))<CR><CR>'
      \ : ':<c-u>FloatermToggle<CR>'
tnoremap <silent> <F6>  <C-\><C-n>:<c-u>FloatermToggle<cr>
```

### Highlights

There are two `highlight-groups` to specify the color of floaterm (also the
border color if `g: floaterm_wintype` is `'float'`) window.

To customize, use `hi` command together with the colors you prefer.

```vim
" Configuration example

" Set floaterm window's background to black
hi Floaterm guibg=black
" Set floating window border line color to cyan, and background to orange
hi FloatermBorder guibg=orange guifg=cyan
```

<details>
<summary>Demo</summary>
<img src="https://user-images.githubusercontent.com/20282795/91368959-fee00f00-e83c-11ea-9002-cab992d30794.png"/>
</details>

Besides, there is a neovim only highlight group which can be used to configure
no-current-focused window(`:help NormalNC`).

```vim
" Configuration example

" Set floaterm window foreground to gray once the cursor moves out from it
hi FloatermNC guifg=gray
```

<details>
<summary>Demo</summary>
<img src="https://user-images.githubusercontent.com/20282795/91380259-28a62f80-e857-11ea-833f-11160d15647a.gif"/>
</details>

### Autocmd

```vim
autocmd User FloatermOpen        " triggered after opening a new/existed floaterm
```

## Advanced Topics

### Use with command line tools

The following cases should work both in Vim and NeoVim unless otherwise
specifically noted.

#### floaterm

Normally if you run `vim/nvim somefile.txt` within the builtin terminal, you
would get another nvim/vim instance running in the subprocess.

[Floaterm](https://github.com/voldikss/vim-floaterm/tree/master/bin), which is
a builtin script in this plugin, allows you to open files from within `: terminal`
without starting a nested nvim. To achieve that, just literally replace
`vim/nvim` with `floaterm`, e.g. `floaterm somefile.txt`

P.S.

- [#208](https://github.com/voldikss/vim-floaterm/issues/208#issuecomment-747829311)
  describes how to use `gf` in the floating terminal window.
- `floaterm` is too long to type? set alias in your `bashrc`, e.g. `alias f=floaterm`
- For configurable open action, refer to [g:floaterm_opener](#gfloaterm_opener)

<details>
<summary>Demo</summary>
<img src="https://user-images.githubusercontent.com/20282795/91380257-27750280-e857-11ea-8d49-d760c009fee0.gif"/>
</details>

#### [git](https://git-scm.com/)

Execute `git commit` in the terminal window without starting a nested vim/nvim.

Refer to [g:floaterm_giteditor](#gfloaterm_giteditor) to disable this behavior.

Refer to [g:floaterm_opener](#gfloaterm_opener) for configurable open action

<details>
<summary>Demo</summary>
<img src="https://user-images.githubusercontent.com/20282795/91380268-2cd24d00-e857-11ea-8dbd-d39a0bbb105e.gif"/>
</details>

#### [fzf](https://github.com/junegunn/fzf)

This plugin has implemented a [wrapper](./autoload/floaterm/wrapper/fzf.vim)
for `fzf` command. So it can be used as a tiny fzf plugin.

Try `:FloatermNew fzf` or even wrap this to a new command like this:

```vim
command! FZF FloatermNew fzf
```

<details>
<summary>Demo</summary>
<img src="https://user-images.githubusercontent.com/20282795/107140144-10d0ec80-695b-11eb-8c2f-8bd42ae26e6d.gif"/>
</details>

#### [ripgrep](https://github.com/BurntSushi/ripgrep)

_Requirements_:

- [fzf](https://github.com/junegunn/fzf)
- [vim-ripgrep](https://github.com/jremmen/vim-ripgrep)

This plugin has implemented a [wrapper](./autoload/floaterm/wrapper/rg.vim)
for `rg` command.

Try `:FloatermNew rg` or create yourself a new command like this:

```vim
command! Rg FloatermNew --width=0.8 --height=0.8 rg
```

or map via `.vimrc`

```vim
" Hotkey: \ + rg
nmap <leader>rg :Rg<CR>
```

<details>
<summary>Demo</summary>
You can use <button>Alt-A</button> to select all files and <button>Alt-D</button> to deselect them.
Use <button>Ctrl-/</button> to toggle preview.
<img src="https://user-images.githubusercontent.com/20282795/107148083-4c37df00-698c-11eb-80fb-ccfd94fc4419.gif"/>
</details>

#### [broot](https://github.com/Canop/broot)

This plugin has implemented a [wrapper](./autoload/floaterm/wrapper/broot.vim) for `broot`.

Try `:FloatermNew broot` or create yourself a new command like this:

```vim
command! Broot FloatermNew --width=0.8 --height=0.8 broot
```

<details>
<summary>Demo</summary>
<img src="https://user-images.githubusercontent.com/20282795/109648379-83696c80-7b95-11eb-8776-071b816cce2d.gif"/>
</details>

#### [fff](https://github.com/dylanaraps/fff)

There is also an [fff wrapper](./autoload/floaterm/wrapper/fff.vim)

Try `:FloatermNew fff` or define a new command:

```vim
command! FFF FloatermNew fff
```

<details>
<summary>Demo</summary>
<img src="https://user-images.githubusercontent.com/1472981/75105718-9f315d00-567b-11ea-82d1-6f9a6365391f.gif"/>
</details>

#### [nnn](https://github.com/jarun/nnn)

There is also an [nnn wrapper](./autoload/floaterm/wrapper/nnn.vim)

Try `:FloatermNew nnn` or define a new command:

```vim
command! NNN FloatermNew nnn
```

<details>
<summary>Demo</summary>
<img src="https://user-images.githubusercontent.com/20282795/91380278-322f9780-e857-11ea-8b1c-d40fc91bb07d.gif"/>
</details>

#### [xplr](https://github.com/sayanarijit/xplr)

There is also an [xplr wrapper](./autoload/floaterm/wrapper/xplr.vim)

Try `:FloatermNew xplr` or define a new command:

```vim
command! XPLR FloatermNew xplr
```

<details>
<summary>Demo</summary>
<img src="https://s4.gifyu.com/images/ft-xplr9173d6a849e3f6b9.gif"/>
</details>

#### [lf](https://github.com/gokcehan/lf)

There is also an [lf wrapper](./autoload/floaterm/wrapper/lf.vim).
It is recommened to use [lf.vim](https://github.com/ptzz/lf.vim) which is an lf wrapper with more features (Overriding netrw, Lfcd, etc.).

Try `:FloatermNew lf` or define a new command:

```vim
command! LF FloatermNew lf
```

<details>
<summary>Demo</summary>
<img src="https://user-images.githubusercontent.com/20282795/91380274-3065d400-e857-11ea-86df-981adddc04c6.gif"/>
</details>

#### [ranger](https://github.com/ranger/ranger)

This plugin can also be a handy ranger plugin since it also has a [ranger wrapper](./autoload/floaterm/wrapper/ranger.vim)

Try `:FloatermNew ranger` or define a new command:

```vim
command! Ranger FloatermNew ranger
```

<details>
<summary>Demo</summary>
<img src="https://user-images.githubusercontent.com/20282795/91380284-3360c480-e857-11ea-9966-34856592d487.gif"/>
</details>

#### [joshuto](https://github.com/kamiyaa/joshuto)

This plugin can also be a handy joshuto plugin since it also has a [joshuto wrapper](./autoload/floaterm/wrapper/joshuto.vim)

Try `:FloatermNew joshuto` or define a new command:

```vim
command! Joshuto FloatermNew joshuto
```

#### [vifm](https://github.com/vifm/vifm)

There is also a [vifm wrapper](./autoload/floaterm/wrapper/vifm.vim)

Try `:FloatermNew vifm` or define a new command:

```vim
command! Vifm FloatermNew vifm
```

<details>
<summary>Demo</summary>
<img src="https://user-images.githubusercontent.com/43941510/77137476-3c888100-6ac2-11ea-90f2-2345c881aa8f.gif"/>
</details>

#### [yazi](https://github.com/sxyazi/yazi)

There is also a [yazi wrapper](./autoload/floaterm/wrapper/yazi.vim)

Try `:FloatermNew yazi` or define a new command:

```vim
command! Yazi FloatermNew yazi
```

#### [lazygit](https://github.com/jesseduffield/lazygit)

Furthermore, you can also use other command-line programs, such as lazygit, htop, ncdu, etc.

Use `lazygit` for instance:

<details>
<summary>Demo</summary>
<img src="https://user-images.githubusercontent.com/20282795/74755376-0f239a00-52ae-11ea-9261-44d94abe5924.png"/>
</details>

#### [python](https://www.python.org/)

Use `:FloatermNew python` to open a python shell. After that you can use
`: FloatermSend` to send lines to the Python interactive shell.

Or you can just select lines and execute `:'<,'>FloatermNew --wintype=split python`, then the
selected lines will be sent and executed once a python repl floaterm window is
opened.

This can also work for other languages which have interactive shells, such as lua, node, etc.

<details>
<summary>Demo</summary>
<img src="https://user-images.githubusercontent.com/20282795/91380286-352a8800-e857-11ea-800c-ac54efa7dd72.gif"/>
</details>

### Use with other plugins

#### [vim-clap](https://github.com/liuchengxu/vim-clap)

Use vim-clap to switch/preview floating terminal buffers.

Install [clap-floaterm](https://github.com/voldikss/clap-floaterm) and try `:Clap floaterm`

<details>
<summary>Demo</summary>
<img src="https://user-images.githubusercontent.com/20282795/91380243-217f2180-e857-11ea-9f64-46e8676adc11.gif"/>
</details>

#### [denite.nvim](https://github.com/Shougo/denite.nvim)

Use denite to switch/preview/open floating terminal buffers.

Install [denite-floaterm](https://github.com/delphinus/denite-floaterm) and try `:Denial floaterm`

<details>
<summary>Demo</summary>
<img src="https://user-images.githubusercontent.com/1239245/73604753-17ef4d00-45d9-11ea-967f-ef75927e2beb.gif"/>
</details>

#### [coc.nvim](https://github.com/neoclide/coc.nvim)

Use CocList to switch/preview/open floating terminal buffers.

Install [coc-floaterm](https://github.com/voldikss/coc-floaterm) and try `:CocList floaterm`

<details>
<summary>Demo</summary>
<img src="https://user-images.githubusercontent.com/20282795/91380254-25ab3f00-e857-11ea-9733-d0ae5a954848.gif"/>
</details>

#### [fzf](https://github.com/junegunn/fzf)

Install [fzf-floaterm](https://github.com/voldikss/fzf-floaterm) and try `:Floaterms`

#### [LeaderF](https://github.com/Yggdroot/LeaderF)

Install [LeaderF-floaterm](https://github.com/voldikss/LeaderF-floaterm) and try `:Leaderf floaterm`

#### [asynctasks.vim](https://github.com/skywind3000/asynctasks.vim) | [asyncrun.vim](https://github.com/skywind3000/asyncrun.vim)

This plugin can be a runner for asynctasks.vim or asyncrun.vim. See
[asyncrun.extra](https://github.com/skywind3000/asyncrun.extra) for the
installation and usage.

<details>
<summary>Demo</summary>
<img src="https://user-images.githubusercontent.com/20282795/104123344-b3f70c00-5385-11eb-9f61-0a5703ba78f5.gif"/>
</details>

### How to define more wrappers

The wrapper script must be located in `autoload/floaterm/wrapper/` directory,
e.g., `autoload/floaterm/wrapper/fzf.vim`.

There are two ways for a command to be spawned:

- To be executed after spawning `$SHELL`. Here is the old implementation of
  [fzf wrapper](./autoload/floaterm/wrapper/fzf.vim)

  ```vim
  function! floaterm#wrapper#fzf#(cmd, jobopts, config) abort
    return [v:true, 'floaterm $(fzf)']
  endfunction
  ```

  The code above returns a list. `floaterm $(fzf)` is the command to be
  executed. `v:true` means the command will be executed after the `&shell`
  startup.

- To be executed through `termopen()`/`term_start()` function, in that case, a
  callback option can be provided. See [fzf wrapper](./autoload/floaterm/wrapper/fzf.vim)

  ```vim
  function! floaterm#wrapper#fzf#(cmd, jobopts, config) abort
    let s:fzf_tmpfile = tempname()
    let cmd = a:cmd . ' > ' . s:fzf_tmpfile
    let a:jobopts.on_exit = funcref('s:fzf_callback')
    return [v:false, cmd]
  endfunction

  function! s:fzf_callback(...) abort
    if filereadable(s:fzf_tmpfile)
      let filenames = readfile(s:fzf_tmpfile)
      if !empty(filenames)
        if has('nvim')
          call floaterm#window#hide(bufnr('%'))
        endif
        let locations = []
        for filename in filenames
          let dict = {'filename': fnamemodify(filename, ':p')}
          call add(locations, dict)
        endfor
        call floaterm#util#open(locations)
      endif
    endif
  endfunction
  ```

  In the example above, after executing `:FloatermNew fzf`, function
  `floaterm#wrapper#fzf#` will return

  ```vim
  [v:false, 'fzf > /tmp/atmpfilename'].
  ```

  Here `v:false` means `cmd`

  ```vim
  fzf > /tmp/atmpfilename
  ```

  will be passed through `termopen()`(neovim) or `term_start()`(vim). As the
  result, an fzf interactive will be opened in a floaterm window.

  When user picks a file using `ENTER`, fzf exits and the filepath will be
  written in `/tmp/atmpfilename` and `s:fzf_callback()` will be invoked to
  open the file. Note that the function `s: fzf_callback()` is registered by

  ```vim
  let a:jobopts.on_exit = funcref('s:fzf_callback')
  ```

  The variable `a:jobopts` in the above code will be eventually passed to
  `termopen()`(neovim) or `term_start()`(vim). For more info, see
  `:help jobstart-options`(neovim) or `:help job-options`(vim)

### How to write sources for fuzzy finder plugins

Function `floaterm#buflist#gather()` returns a list contains all the floaterm buffers.

Function `floaterm#terminal#open_existing({bufnr})` opens the floaterm whose buffer number is `{bufnr}`.

For reference, see [floaterm source for LeaderF](https://github.com/voldikss/LeaderF-floaterm/blob/master/autoload/lf_floaterm.vim).

## Contributing

- Improve the documentation
- Help resolve issues labeled as [help wanted](https://github.com/voldikss/vim-floaterm/issues?q=is%3Aissue+label%3A%22help+wanted%22)

## FAQ

https://github.com/voldikss/vim-floaterm/issues?q=label%3AFAQ

## Breaking Changes

https://github.com/voldikss/vim-floaterm/issues?q=label%3A%22breaking+change%22

## Related projects

- [vim-floaterm-repl](https://github.com/windwp/vim-floaterm-repl)
- [coc-floaterm](https://github.com/voldikss/coc-floaterm)
- [fzf-floaterm](https://github.com/voldikss/fzf-floaterm)
- [popc-floaterm](https://github.com/yehuohan/popc-floaterm)
- [LeaderF-floaterm](https://github.com/voldikss/LeaderF-floaterm)

## Credits

- [Vim](https://github.com/vim/vim/) and [Neovim](https://github.com/neovim/neovim/) the editor God

- [vim-terminal-help](https://github.com/skywind3000/vim-terminal-help/blob/master/tools/utils/drop)

- [edita.vim](https://github.com/lambdalisue/edita.vim)

## License

MIT
