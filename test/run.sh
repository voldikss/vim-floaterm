#! /usr/bin/bash
# only for local test, not used for github action
nvim +'Vader test/test_command.vader'
nvim +'Vader test/test_command_with_bang.vader'
nvim +'Vader test/test_cmdline.vader'
nvim +'Vader test/test_floaterm_size.vader'

nvim +'Vader test/test_g_autohide/v_true.vader'
nvim +'Vader test/test_g_autohide/v_false.vader'
