
@echo off
setlocal EnableDelayedExpansion

if "%1" == "" GOTO help
if "%VIM_EXE%" == "" GOTO missing

REM Get absolute name
for /f "delims=" %%i in ("%1") do set "NAME=%%~fi"
REM echo fullpath: %NAME%

if "%NVIM_LISTEN_ADDRESS%" == "" GOTO vim
goto neovim

:vim
call "%VIM_EXE%" --servername "%VIM_SERVERNAME%" --remote-expr "floaterm#util#edit(0, '%NAME%')"
goto end

:neovim
call "nvr" --servername "%NVIM_LISTEN_ADDRESS%" --remote-expr "floaterm#util#edit(0, '%NAME%')"
goto end

:nonvr
echo missing nvr, you need install neovim-remote
goto end

:help
echo usage: floaterm {filename}
goto end

:missing
echo Must be called inside vim/neovim
goto end


:end
