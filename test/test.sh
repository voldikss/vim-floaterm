#! /usr/bin/env bash

# VIM_EXEC=/usr/bin/vim
VIM_EXEC=nvim

for f in `find test/*/*.vader`
do
    $VIM_EXEC -u test/vimrc -c "Vader! $f"
    if [ $? != 0 ]
    then
        break
    fi
done
