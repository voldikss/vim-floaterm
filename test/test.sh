#! /usr/bin/env bash

CRED='\033[0;31m'
CGREEN='\033[0;32m'
CCYAN='\033[0;36m'
CEND='\033[0;0m' # No Color

# USAGE: ./test/test.sh [vim-bin]
if [[ $1 = '' ]]
then
    VIM_EXEC=nvim
else
    VIM_EXEC=$1
fi

if [[ $VIM_EXEC == *nvim* ]]
then
    HEADLESS=--headless
else
    HEADLESS=
fi

passnum=0
failed=0
for f in `find test/*/*.vim | sort`
do
    FLOATERM_TEST_FILE="$f" "$VIM_EXEC" $HEADLESS -u test/vimrc \
        -c 'source test/run.vim' -c 'qa!' > /dev/null 2>&1
    if [[ $? != 0 ]]
    then
        printf "${CRED}Failed at $f${CEND}\n"
        FLOATERM_TEST_FILE="$f" "$VIM_EXEC" $HEADLESS -u test/vimrc \
            -c 'source test/run.vim' -c 'qa!' 2>&1
        failed=1
        break
    fi
    passnum=$(( $passnum + 1 ))
done

if [[ $failed = 0 ]]
then
    printf "${CCYAN}All ${passnum} test files passed!${CEND}\n"
else
    printf "${CGREEN}Passed ${passnum} files${CEND}\n"
fi
