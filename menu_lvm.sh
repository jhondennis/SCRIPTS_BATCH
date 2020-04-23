
#!/bin/bash

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

    write_header " SCRIPT PARA LVM "

	echo "|  1.  Informacion del S.O.                                       |"
	echo "|CREAR  LVM.......................................................|"
	echo "|  2.  Formatear disco                                            |"
	echo "|  3.  Crear pv phisical volume                                   |"
	echo "|  4.  Ampliar vg volumen group                                   |"
	echo "|  5.  Extender lv logical volume                                 |"
	echo "|-----------------------------------------------------------------|"
	echo "|[s|S] Salir                                                      |"
	echo "------------------------------------------------------------------"
}
function read_input(){
	local c
	read -p "Ingrese una opcion [ 1 - ... ] " c
	case $c in
		1) os_info ;;
		2) formato_disco;;
		3) crear_pv;;
		4) extender_vg;;
		5) ampliar_lv;;

		s|S)	clear
			exit 0 ;;
		*)
			echo "Seleccione entre 1 y ... unicamente."
			pause
	esac
}

function os_info(){
	clear
	write_header " Informacion del Sistema "
	echo "Sistema Operativo : $(uname)"
	echo
	pause
}

# LVM ES DESDE AQUI
function formato_disco(){
	clear
	if [ $LOGNAME != "root" ]
	then
	    read -p "Lo siento, este script debe ser ejecutado con privilegios de --root--."
	    exit 1
	fi

	echo "------------PASOS PARA FORMATEAR EL DISCO-----------|"
	echo "command (m for help): n                             |"
	echo "select (default p): p                               |"
	echo "Partition number(1-4, default 1): Enter             |"
	echo "First sector(2048-,default 2048): Enter             |"
	echo "Last sector, +sector(2048, deafault 2516): Enter    |"
	echo "Command (m for help): p                             |"
	echo "Command (m for help): w                             |"
	echo "----------------------------------------------------|"
	echo
	echo "$(lsblk)"
	echo
	echo "identifique el nombre de la undidad Ej. [sdb,sdb,...]"
	pause
	echo
	read -p "Ingrese nombre del dispositivo: " disp
	fdisk /dev/$disp
	pause
}
function crear_pv(){
	clear
	if [ $LOGNAME != "root" ]
	then
	    read -p "Lo siento, este script debe ser ejecutado con privilegios de --root--."
	    exit 1
	fi

	echo "$(lsblk)"
	echo "identifique el nombre de la undidad Ej. [sdb1,sdc1,sdb,...]"
	pause
	read -p "nombre del dispositivo para crear PV: " disp1
	pvcreate /dev/$disp1
	pvs

	pause
}
function extender_vg(){
	clear
	if [ $LOGNAME != "root" ]
	then
	    read -p "Lo siento, este script debe ser ejecutado con privilegios de --root--."
	    exit 1
	fi

	vgs
	echo "................................."
	pvs
	echo "................................."
	read -p "grupo volumen a extender [vgSERVIDOR]: " vg
	read -p "nombre del dispositivo [sdb1]: " disp
	vgextend $vg /dev/$disp
	echo "................................."
	pvs
	echo "................................."
	vgs
	pause
}
function ampliar_lv(){
	clear
	if [ $LOGNAME != "root" ]
	then
	    read -p "Lo siento, este script debe ser ejecutado con privilegios de --root--."
	    exit 1
	fi

	lvs
	echo "................................."
	vgs
	echo "................................."
	read -p "nombre del LV [lv-HOME]: " LV
	read -p "nombre del VG [vgSERVIDOR]: " VG
	read -p "cantidad Ej. [1G, 1M]: " CANT
	lvextend -L+$CANT /dev/$VG/$LV
	echo "................................."
	lvs
	pause
}

# MENU LOGICO
while true
do
	clear
 	show_menu	# display memu
 	read_input  # wait for user input
done