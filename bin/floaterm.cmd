@echo off
setlocal EnableDelayedExpansion

if "%1" == "" GOTO help

REM Get absolute name
for /f "delims=" %%i in ("%1") do set "NAME=%%~fi"
REM echo fullpath: %NAME%

if "%NVIM_LISTEN_ADDRESS%" == "" GOTO vim
goto neovim

:vim
if "%VIM_EXE%" == "" GOTO missing
call "%VIM_EXE%" --servername "%VIM_SERVERNAME%" --remote-expr "Tapi_edita_open(bufnr(), ['%NAME%'])"
goto end

:neovim
%FLOATERM% %NAME%
goto end

:help
echo usage: floaterm {filename}
goto end

:missing
echo Must be called inside vim/neovim
goto end


:end
