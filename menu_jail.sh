#!/bin/bash
clear

if [ "$LOGNAME" != "root" ]
then
   read -p "Lo siento, este sccript debe ser ejecutado con privilegios de --root--."
   exit 1
fi

function write_header(){
	local h="$@"
	echo "---------------------------------------------------------------"
	echo "                   ${h}"
	echo "---------------------------------------------------------------"
}
function pause(){
	echo
	local message="$@"
	[ -z $message ] && message="Presione [Enter] para continuar..."
	read -p "$message" readEnterKey
}

function show_menu(){
    echo "Fecha actual :"
    date

    write_header " ENJAULAMIENTO DE USUARIOS por pasos "

    echo "|  1.   Crear usuario                                           |"
    echo "|  2.   Crear grupo                                             |"
    echo "|  3.   Crear carpeta                                           |" 
    echo "|  4.   Asignar Usuario y Grupo a una carpeta                   |"           
    echo "|---------------------------------------------------------------|"
	echo "|  5.   Asignar herramienta a carpeta de Enjaule                |"
	echo "|  6.   Colocar usuario en la carpeta de Enjaule                |"
	echo "|---------------------------------------------------------------|"
	echo "|  7.   Configuracion para conexion                             |"
	echo "|---------------------------------------------------------------|"
    echo "|  8.   Eliminar usuario                                        |"
    echo "|  9.   Eliminar grupo                                          |"
    echo "|  10.  Eliminar carpeta                                        |"     
	echo "|---------------------------------------------------------------|"	
	echo "|[s|S] Salir                                                    |"
	echo "-----------------------------------------------------------------"
}

function read_input(){
	local c
	read -p "Ingrese una opcion [ 1 - ...] " c
	case $c in
		1)	crear_usuario ;;
		2)	crear_grupo ;;
		3)	crear_carpeta ;;
		4)  asignar_usuario_grupo ;;
		5)  herramientas ;;
		6)  enjaular_usuario ;;
		7)  conexion ;;
		8)	eliminar_usuario ;;
		9)	eliminar_grupo ;;
		10)	eliminar_carpeta ;;

		s|S)	clear ;
            exit 0 ;;
		*)
			echo "Seleccione una opcion unicamente."
			pause
	esac
}
function crear_usuario(){
	clear
	echo
	read -p "Ingrese nombre del Usuario: " USER
	adduser $USER
	VALOR=$?
	if [ "$VALOR" -eq "0" ]; then
		echo "Correctos..!!!"
	else
		echo "INCORRECTO..!!!"
	fi
	echo
	echo "------------------------------------------------------------"
	cat /etc/passwd |grep $USER:
	echo "------------------------------------------------------------"
	pause
}
function crear_grupo(){
	clear
	echo
	read -p "Ingrese nombre del Grupo: " GROUP
	addgroup $GROUP:
	VALOR=$?
	if [ "$VALOR" -eq "0" ]; then
		echo "Correctos..!!!"
	else
		echo "INCORRECTO..!!!"
	fi
	echo
	echo "------------------------------------------------------------"
	cat /etc/group |grep $GROUP:
	echo "------------------------------------------------------------"
	pause
}
function crear_carpeta(){
	clear
	echo
	read -p "Ingrese nombre de la carpeta [pagina.com]: " NOMBRE
	read -p "Ingrese ubicacion de la carpeta [/var/www/]: " UBICACION
	mkdir $UBICACION$NOMBRE
	VALOR=$?
	if [ "$VALOR" -eq "0" ]; then
		echo "Correctos..!!!"
	else
		echo "INCORRECTO..!!!"
	fi
	echo
	echo "------------------------------------------------------------"
	ls -l $UBICACION |grep $NOMBRE
	echo "------------------------------------------------------------"
	pause
}
function asignar_usuario_grupo(){
	clear
	echo
	read -p "Ingrese usuario [dennis]: " USUARIO
	read -p "Ingrese grupo [desarrolladores]: " GRUPO
	read -p "Ingrese ruta de la carpeta [/var/www/carpeta.com]: " RUTA

	chown $USUARIO.$GRUPO $RUTA
	VALOR=$?
	if [ "$VALOR" -eq "0" ]; then
		echo "Correctos..!!!"
	else
		echo "INCORRECTO..!!!"
	fi
	pause
}
function herramientas(){
	clear
	echo
	read -p "Ruta de la carpeta para Enjaule [/var/www/desarrolladores]: " RUTA
	jk_init -v $RUTA basicshell
	jk_init -v $RUTA chroot ssh
	jk_init -v $RUTA editors
	jk_init -v $RUTA extendedshell
	jk_init -v $RUTA netutils
	jk_init -v $RUTA ssh
	jk_init -v $RUTA sftp
	jk_init -v $RUTA jk_lsh
	echo
	echo "Completado...!!!"
	echo "Herramientas asignadas: [basicshell,chroot ssh,editors,extendedshell,netutils,ssh,sftp,jk_lsh]"
	pause
}
function enjaular_usuario(){
	clear
	echo
	read -p "Ingrese Unsuario [dennis]: " USUARIO
	read -p "Ingrese Ruta de la carpeta [/var/www/desarrolladores]: " RUTA
	echo
	jk_jailuser -m -j $RUTA $USUARIO
	VALOR=$?
	if [ "$VALOR" -eq "0" ]; then
		echo "Correcto..!!!"
	else
		echo "INCORRECTO..!!!"
	fi
	echo
	echo "-------------------------------------------------------"
	cat /etc/passwd |grep jk_chroot
	echo "-------------------------------------------------------"
	pause	
}
function conexion(){
	clear
	echo
	echo "Esto se lo debe realizar de forma manual: "
	echo
	echo "
		Se debe ingresar dentro de la carpeta enjaulada para 
		modificar el archivo [passwd] del usuario enajulado"
	echo "
		Ej.
		$ nano /var/www/desarrolladores/etc/passwd"
	echo "
		root:x:0:0:root:/root:/bin/bash
		#usuario:x:1001:1001:,,,:/home/usuario:/usr/bin/jk_lsh    <-- este debe ser comentado
		 usuario:x:1001:1001::/home/usuario:/bin/bash <-- esta línea se debe añadir "
	pause
}
function eliminar_usuario(){
	clear
	echo
	read -p "Ingrese nombre del Usuario: " USER
	deluser --remove-all-files $USER
	VALOR=$?
	if [ "$VALOR" -eq "0" ]; then
		echo "Correctos..!!!"
	else
		echo "INCORRECTO..!!!"
	fi
	echo
	echo "------------------------------------------------------------"
	cat /etc/passwd |grep $USER:
	echo "------------------------------------------------------------"
	pause
}
function eliminar_grupo(){
	clear
	echo
	read -p "Ingrese nombre del Grupo: " GROUP
	delgroup --remove-all-files $GROUP:
	VALOR=$?
	if [ "$VALOR" -eq "0" ]; then
		echo "Correctos..!!!"
	else
		echo "INCORRECTO..!!!"
	fi
	echo
	echo "------------------------------------------------------------"
	cat /etc/group |grep $GROUP:
	echo "------------------------------------------------------------"
	pause
}
function eliminar_carpeta(){
	clear
	echo
	read -p "Ingrese nombre de la carpeta [pagina.com]: " NOMBRE
	read -p "Ingrese ubicacion de la carpeta [/var/www/]: " UBICACION
	rm -r $UBICACION$NOMBRE
	VALOR=$?
	if [ "$VALOR" -eq "0" ]; then
		echo "Correctos..!!!"
	else
		echo "INCORRECTO..!!!"
	fi
	echo
	echo "------------------------------------------------------------"
	ls -l $UBICACION |grep $NOMBRE
	echo "------------------------------------------------------------"
	pause
}

# aqui comienza la ejecucion del menu
while true
do
	clear
 	show_menu	# display memu
 	read_input  # wait for user input
done
