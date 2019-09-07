# vim-floaterm

This plugin helps open the terminal in the floating window and toggle it quickly, detached from my [dotfiles](https://github.com/voldikss/dotfiles)

**Note:** Only available in NeoVim.

## Installation

- vim-plug

```vim
Plug 'voldikss/vim-floaterm'
```

- dein.nvim

```vim
call dein#add('voldikss/vim-floaterm', {'on_cmd': 'FloatermToggle'})
```

## Variables

#### **`g:floaterm_type`**

- Available: `'floating'`, `'normal'`

- Default: `'floating'`

#### **`g:floaterm_width`**

- Type: number

- Default: value of `&columns`

#### **`g:floaterm_height`**

- Type: number

- Default: value of `winheight(0)/2`

#### **`g:floaterm_winblend`**

- Type: number(0-100)

- Default: 0

## Command

```
:FloatermToggle
```

## Configuration

Recommended configuration

```vim
noremap  <silent> <F12>           :FloatermToggle<CR>i
noremap! <silent> <F12>           <Esc>:FloatermToggle<CR>i
tnoremap <silent> <F12>           <C-\><C-n>:FloatermToggle<CR>
```

## Q & A

- **This plguin leaves an empty window on startify window**

  Put this code in `vimrc`

  ```vim
  autocmd User Startified setlocal buflisted
  ```

## Todo

- [ ] add doc

## Screenshot

![](https://user-images.githubusercontent.com/20282795/62412186-8c006680-b631-11e9-842b-1fffda64d926.gif)
