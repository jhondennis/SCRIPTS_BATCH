@echo off 
title Selecciona un opcion 

:inicio 
cls 
color 07
echo ------------------------------
echo      - = [ MENU ] = -
echo ------------------------------
echo 1) Vaciar Cola de Impresion 
echo 2) Reiniciar Printers
echo 3) Pedir Nuevamente IP
echo 4) Probar Conexion
echo 5) Borrar Archivos Temp
echo ------------------------------ 
echo S) Salir 
echo ------------------------------ 
echo. 

set /p var=Seleccione una opcion : 
if "%var%"=="1" goto op1 
if "%var%"=="2" goto op2 
if "%var%"=="3" goto op3
if "%var%"=="4" goto op4
if "%var%"=="5" goto op5
if "%var%"=="s" goto salir
if "%var%"=="S" goto salir 

::Mensaje de error, validación cuando se selecciona una opción fuera de rango 
echo. El numero "%var%" no es una opcion valida, por favor intente de nuevo. 
echo. 
pause 
echo. 
goto inicio

:op1
cls
echo. ---------------------------------------------
echo. Has elegido la opcion BOORAR COLA DE IMPRESION
echo. ---------------------------------------------
::Aquí van las líneas de comando de tu opción
net stop spooler
DEL /F/S/Q c:\Windows\System32\spool\PRINTERS\*.* >NUL
echo.
echo.       Eliminando Cola de IMPRESION
echo.
net start spooler
echo.
color 09
echo.       La impresora esta lista para Usarse
echo.
pause 
goto inicio

:op2
cls
echo. ---------------------------------------------
echo. Has elegido la opcion REINICIAR IMPRESORA
echo. ---------------------------------------------
::Aquí van las líneas de comando de tu opción
net stop spooler
echo.
echo.       Reiniciando IMPRESORA
echo.
net start spooler
color 09
echo.
echo.       LISTO
echo.
pause 
goto inicio

:op3
cls
echo. ---------------------------------------------
echo. Has elegido la opcion PEDIR IP
echo. ---------------------------------------------
::Aquí van las líneas de comando de tu opción
ipconfig /release
echo.
pause
ipconfig /renew
color 09
echo.
echo.
echo.-------....::: NUEVAS IP ADQUIRIDAS ::::....------
echo.
ipconfig | findstr IPv
echo.
echo.--------------         LISTO         -------------
echo.
pause 
goto inicio

:op4
cls
echo. ---------------------------------------------
echo. Has elegido la opcion PROBAR CONEXION
echo. ---------------------------------------------
::Aquí van las líneas de comando de tu opción
ping 8.8.8.8
echo.
color 09
echo.
echo.--------------       LISTO     ---------------
echo.
pause 
goto inicio

:op5
cls
echo. ---------------------------------------------
echo. Has elegido la opcion BORRAR ARCHIVOS TEMP 
echo. ---------------------------------------------
::Aquí van las líneas de comando de tu opción
DEL /F/S/Q C:\Users\Dennis\AppData\Local\Temp\*.* >NUL
echo.
echo.       Eliminando ARCHIVOS
echo.
color 09
echo.-------------       LISTO       --------------
echo.
pause 
goto inicio

:salir 
@cls&exit 