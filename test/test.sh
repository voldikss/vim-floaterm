#! /usr/bin/env bash

for f in `find test/*/*.vader`
do
    /usr/bin/vim -u test/vimrc -c "Vader! $f"
    # nvim -c "Vader $f"
done
