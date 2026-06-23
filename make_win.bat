@echo off
echo ============================================================
echo  CQL3D MPI Windows Build (Intel oneAPI + vcpkg NetCDF)
echo ============================================================
call "%ONEAPI_ROOT%\setvars.bat" >nul 2>&1
set "VCPKG_ROOT=C:\vcpkg"
set "INCLUDE="
cd /d "%~dp0"
mingw32-make -f makefile_win %*
