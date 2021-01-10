#! /usr/bin/env bash

CRED='\033[0;31m'
CGREEN='\033[0;32m'
CCYAN='\033[0;36m'
CEND='\033[0m' # No Color

# USAGE: ./test/test.sh [vim]
VIM_EXEC=nvim
if [[ $1 = vim ]]
then
    VIM_EXEC=/usr/bin/vim
fi

passnum=0
failed=0
for f in `find test/*/*.vader`
do
    $VIM_EXEC -u test/vimrc -c "Vader! $f"
    if [[ $? != 0 ]]
    then
        printf "${CGREEN}Passed $passnum files${CEND}\n"
        printf "${CRED}Failed at $f${CEND}\n"
        failed=1
        break
    fi
    passnum=$(( $passnum + 1 ))
done

if [[ $failed = 0 ]]
then
    printf "${CCYAN}All tests passed!${CEND}\n"
fi
