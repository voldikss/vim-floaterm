# vim-floaterm

This plugin helps open the terminal in the floating window and toggle it quickly, detached from my [dotfiles](https://github.com/voldikss/dotfiles)

## Installation

```vim
Plug 'voldikss/vim-floaterm'
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

## Command

```
:ToggleTerminal
```

## Configuration

Recommended configuration

```vim
noremap  <silent> <expr><F12>     &buftype =='terminal' ?
                                  \ "\<C-\><C-n>:call util#toggleWindows('terminal')\<CR>" :
                                  \ "\<Esc>:call util#toggleWindows('terminal')\<CR>i<C-u>"
noremap! <silent> <F12>           <Esc>:call util#toggleWindows('terminal')<CR>i
tnoremap <silent> <F12>           <C-\><C-n>:call util#toggleWindows('terminal')<CR>
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
