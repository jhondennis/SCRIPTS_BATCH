#!/bin/bash
clear

if [ "$LOGNAME" == "root" ]
then
   read -p "Lo siento, este sccript debe ser ejecutado con SIN privilegios de --root--."
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

    write_header " CONFIGURACION SSH "

    echo "|  1.  Generar archivo ssh-keygen                              |"
    echo "|--------------------------------------------------------------|"
	echo "|  2.  Copiar llave al Servidor                                |"
	echo "|  3.  Manual                                                  |"
	echo "|--------------------------------------------------------------|"
	echo "|  4.  Reiniciar ssh                                           |"			
	echo "|  5.  Detener   ssh                                           |"
	echo "|  6.  Estatus   ssh                                           |"
	echo "|--------------------------------------------------------------|"
	echo "|[s|S] Salir                                                   |"
	echo "----------------------------------------------------------------"
}

function read_input(){
	local c
	read -p "Ingrese una opcion [ 1 - ...] " c
	case $c in
		1)	generar_certificado ;;
		2)	copiar_al_servidor ;;
		3)	manual ;;
		4)  reiniciar_ssh ;;
		5)  detener_ssh ;;
		6)  status_ssh ;;

		s|S)	clear ;
            exit 0 ;;
		*)
			echo "Seleccione entre una opcion unicamente."
			pause
	esac
}
function generar_certificado(){
	echo "Generando certificados"
	ssh-keygen
	pause	
}
function copiar_al_servidor(){
	clear
	echo
	echo "Copiando llave al servidor"
	echo "previamente ejecute el comando [ssh-keygen] en el servidor"
	read -p "Ingrese nombre del Usuario Servidor: " USUARIO
	read -p "Ingrese la IP del Servidor: " IP
	ssh-copy-id $USUARIO@$IP
	pause
}
function manual(){
	clear
	echo
	echo "Al colocar ssh-key genera los archivos -id_rsa- y -id_rsa.pub- 
	-id_rsa- es la llave que va en el cliente
	-id_rsa.pub- es la llave que va en el servidor
	se puede agregar directamente la llave con el comando:
	-ssh-copy-id dennis@10.0.0.1-"
	echo
	pause
}
function reiniciar_ssh(){
	clear
	echo "Reiniciando SSH"
	sudo systemctl restart ssh 
	pause
}
function detener_ssh(){
	clear
	echo "Deteniendo SSH"
	sudo systemctl stop ssh 
	pause
}
function status_ssh(){
	clear
	echo "Estatus SSH"
	sudo systemctl status ssh 
	pause
}

# aqui comienza la ejecucion del menu
while true
do
	clear
 	show_menu	# display memu
 	read_input  # wait for user input
done
