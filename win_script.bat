@echo off 
title Selecciona un opcion 

:inicio 
cls 
color 06
echo ******************** 
echo *****-=[MENU]=-***** 
echo ******************** 
echo 1) ip y mascara estatico 
echo 2) Puertos abiertos 
echo 3) ip dinamica
echo 4) ip com gateway
echo 5) probar internet
echo 6) hacer PING
echo 7) mostrar puertos
echo 8) cerrar puerto
echo 9) abrir puerto
echo 10) Maquinas en RED
echo ******************** 
echo 11) Salir 
echo ******************** 
echo. 

set /p var=Seleccione una opcion : 
if "%var%"=="1" goto op1 
if "%var%"=="2" goto op2 
if "%var%"=="3" goto op3 
if "%var%"=="4" goto op4 
if "%var%"=="5" goto op5
if "%var%"=="6" goto op6 
if "%var%"=="7" goto op7
if "%var%"=="8" goto op8
if "%var%"=="9" goto op9
if "%var%"=="10" goto op10
if "%var%"=="11" goto salir 

::Mensaje de error, validación cuando se selecciona una opción fuera de rango 
echo. El numero "%var%" no es una opcion valida, por favor intente de nuevo. 
echo. 
pause 
echo. 
goto inicio 

:op1 
echo. 
echo. Has elegido ip y mascara estatico   
echo. 
set /p ip=" Ingrese ip: " 
set /p mask="Ingrese mascara: "
set /p net="Ingrese nombre de la RED: "
netsh interface ipv4 set address name="%net%" static %ip% %mask%
echo. nombre = "%net%" static %ip% %mask%
REM ipconfig | find 
color 09
echo. 
pause 
goto inicio 

:op2 
echo. 
echo. Has elegido la opcion No. 2 
echo. 
mode con cols=70 
:start
cls
echo Puertos abiertos 
echo.
NETSTAT -AN|FINDSTR /C:LISTENING
ping -n 8 127.0.0.1>nul
color 09 
echo. 
pause 
goto inicio 

:op3 
echo. 
echo. Has elegido la opcion No. 3 
echo. 
set /p net=" Ingrese nombre de la RED: "
netsh interface ipv4 set address name="%net%" dhcp 
echo. se canbio la ip a ip dinamica
color 09 
echo. 
pause 
goto inicio 

:op4 
echo. 
echo. Has elegido la opcion No. 4 
echo. 
set /p ip=" Ingrese ip: " 
set /p mask="Ingrese mascara: "
set /p gate=" Ingrese gateway: "
set /p net=" Ingrese nombre de la RED: "
netsh interface ipv4 set address name="%net%" static %ip% %mask% %gate%
REM ipconfig | find 
color 09 
echo. 
pause 
goto inicio 

:op5 
echo. 
echo. Has elegido la opcion No. 5 
echo. 
::Aquí van las líneas de comando de tu opción 
ping 8.8.8.8 -t
color 09 
echo. 
pause 
goto inicio 

:op6
echo. 
echo. Has elegido la opcion No. 6
echo. 
::Aquí van las líneas de comando de tu opción 
set /p net=" Ingrese IP: "
ping "%net%"
color 09 
echo. 
pause 
goto inicio

:op7
echo. 
echo. Has elegido la opcion No. 7
echo. 
::Aquí van las líneas de comando de tu opción 
netstat -ano
color 09 
echo. 
pause 
goto inicio

:op8
echo. 
echo. Has elegido la opcion No. 8
echo. 
::Aquí van las líneas de comando de tu opción
set /p net=" Ingrese Puerto para cerrar: "
netstat -ano | findstr :"%net%"
echo
set /p net=" Ingrese PID: "
taskkill /PID "%net%" /F
color 09 
echo. 
pause 
goto inicio

:op9
echo. 
echo. Has elegido la opcion No. 9
echo. 
echo. faltaaaaa
::Aquí van las líneas de comando de tu opción
netsh wlan show interfaces
color 09 
echo. 
pause 
goto inicio



:op10
echo. 
echo. Has elegido la opcion No. 10
echo. 
::Aquí van las líneas de comando de tu opción
net view
color 09 
echo. 
pause 
goto inicio

:salir 
@cls&exit 
