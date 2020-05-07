#! /usr/bin/bash
# only for local test, not used for github action
nvim +'Vader! test/test_command.vader'
nvim +'Vader! test/test_keymap.vader'
nvim +'Vader! test/test_function.vader'
nvim +'Vader! test/test_floaterm_size.vader'
