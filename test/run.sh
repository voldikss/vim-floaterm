#! /usr/bin/bash
# only for local test, not used for github action
nvim +'Vader test/test_command/test_FloatermFirst_Last.vader'
nvim +'Vader test/test_command/test_FloatermKill.vader'
nvim +'Vader test/test_command/test_FloatermNew.vader'
nvim +'Vader test/test_command/test_FloatermPrev_Next.vader'
nvim +'Vader test/test_command/test_FloatermSend.vader'
nvim +'Vader test/test_command/test_FloatermShow_Hide.vader'
nvim +'Vader test/test_command/test_FloatermToggle.vader'
nvim +'Vader test/test_command/test_FloatermUpdate.vader'

nvim +'Vader test/test_g_autohide/v_true.vader'
nvim +'Vader test/test_g_autohide/v_false.vader'

nvim +'Vader test/test_floaterm_cli.vader'
