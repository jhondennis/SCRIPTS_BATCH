#!/bin/bash
clear
if [ "$LOGNAME" != "root" ]
then
   read -p "Lo siento, este sccript debe ser ejecutado con privilegios de --root--."
   exit 1
fi
NETMASK_DEFAULT='24'
IP_DEFAULT='10.0.0.2'
GATEWAY_DEFAULT="10.0.0.1"

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

    write_header "INFORMACION DEL SISTEMA"

	echo "|  1.  Informacion del S.O.                                      |"
	echo "|  2.  Informacion del Hostname y dns                            |"
	echo "|  3.  Informacion network                                       |"
	echo "|  4.  Usuarios conectados                                       |"
	echo "|  5.  Ultimos usuarios conectados                               |"
	echo "|  6.  Informacion de la memoria                                 |"
	echo "|................................................................|"
	echo "|  7.  Copia de seguridad /interfaces                            |"
	echo "|  8.  IP estatica                                               |"
	echo "|  9.  IP dinamica                                               |"
	echo "|PUERTOS.........................................................|"
	echo "|  10. Ver puerto                                                |"
	echo "|  11. Abrir puertos                                             |"
	echo "|  12. Cerrar puertos                                            |"
	echo "|................................................................|"
	echo "|[s|S] Salir                                                     |"
	echo "------------------------------------------------------------------"
}
function read_input(){
	local c
	read -p "Ingrese una opcion [ 1 - ... ] " c
	case $c in
		1) os_info ;;
		2) host_info ;;
		3) net_info ;;
		4) user_info "who" ;;
		5) user_info "last" ;;
		6) mem_info ;;

		7) copia_de_seguridad ;;
		8) ip_estatica ;;
		9) ip_dinamica ;;

		10) ver_puerto ;;
		11) abrir_puertos;;
		12) cerrar_puertos;;

		s|S)clear
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

function host_info(){
	clear
	local dnsips=$(sed -e '/^$/d' /etc/resolv.conf | awk '{if (tolower($1)=="nameserver") print $2}')
	write_header " Hostname and DNS information "
	echo "Hostname : $(hostname -s)"
	echo "DNS domain : $(hostname -d)"
	echo "Fully qualified domain name : $(hostname -f)"
	echo "Network address (IP) :  $(hostname -i)"
	echo "DNS name servers (DNS IP) : ${dnsips}"
	pause
}

function net_info(){
	clear
	devices=$(netstat -i | cut -d" " -f1 | egrep -v "^Kernel|Iface|lo")
	write_header " Network information "
	echo "Total network interfaces encontradas : $(wc -w <<< ${devices})"
	echo
	echo "******************************"
	echo "*** IP address Informacion ***"
	echo "******************************"
	ifconfig

	pause
}
function user_info(){
	clear
	local cmd="$1"
	case "$cmd" in
		who) write_header " Quien esta en linea :  "; who -H; pause ;;
		last) write_header " List of last logged in users "; last ; pause ;;
	esac
}
function mem_info(){
	clear
	write_header " Memoria libre y usada "
	free -m
    echo
    echo "*********************************"
	echo "*** Memoria Virtual Estatica ***"
    echo "*********************************"
	echo
	vmstat
	pause
}
function copia_de_seguridad(){
    clear
    echo "Realizando copias de seguridad..."
    echo
    if [ -e /etc/netplan/ ]
    then
        echo "hola"
        cp /etc/netplan/50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml.original
        if [ $? -eq 0 ]
        then
            echo "El archivo interfaces ha sido salvaguardado con exito."
        else
            echo "Error al salvaguardar el archivo interfaces."
        fi
    fi
    pause
}
function grabar_configuracion(){
	clear
    echo "----------------------------------------------------"
    echo "| La nueva configuracion de red introducida es: "
    echo "| Interfaz: $1"
    echo "| Direccion IP: $2"
    echo "| Mascara de red: $3"
    echo "| Puerta de enlace / Gateway: $4"
    echo "----------------------------------------------------"
    #Modificacion de /etc/netplan/

    ints="/etc/netplan/50-cloud-init.yaml"
    echo "# interfaces(5) file used by ifup(8) and ifdown(8)" > $ints
    echo "#ip estatica" >> $ints
    echo "network:" >> $ints
    echo "    ethernets:" >> $ints
    echo "        $1:" >> $ints
    echo "            addresses: [$2/$3]" >> $ints
    echo "            gateway4: $4" >> $ints
    echo "            dhcp4: false" >> $ints
    echo "            optional: true" >> $ints
    echo "    version: 2" >> $ints
    echo "Reiniciando tarjeta de red"
    netplan apply
}
function ip_estatica(){
	clear
	if [ $LOGNAME != "root" ]
	then
	    read -p "Lo siento, este script debe ser ejecutado con privilegios de --root--."
	    exit 1
	fi
	echo "Mostrando interfaces de red actuales..."
	var1='lshw -short -class network'
	$var1
	echo
	nic_elegida=""
	while [ "$nic_elegida" == "" ]
	do
	    read -p "Elige la interfaz/dispositivo desea configurar: " nic_elegida
	done
	echo
	echo "Presione [Enter] para configuracion por defecto"
	echo
	echo "La interfaz elegida es: $nic_elegida"
	read -p "Introduce la nueva direccion ip estatica [10.0.0.2]: " IP
	read -p "Introduce la nueva mascara de red [24]: " NETMASK
	read -p "Introduce la puerta de enlace [10.0.0.1]: " GATEWAY
	echo
	IP=${IP:-$IP_DEFAULT}
	NETMASK=${NETMASK:-$NETMASK_DEFAULT}
	GATEWAY=${GATEWAY:-$GATEWAY_DEFAULT}

	respuesta=""
	while [ "$respuesta" == "" ]
	do
	    read -p "Desea grabar estos datos de configuracion (S/N): " respuesta
	    case $respuesta in
	        s|S)
				grabar_configuracion $nic_elegida $IP $NETMASK $GATEWAY;
				break;;
	        n|N)
				echo "Ok, no se modificaron los archivos de configuracion";
				read;
				break;;
	        *)
				echo "No ha introducido una respuesta valida, vuelva a intentarlo.";;
	    esac
	done
	pause
}
function ip_dinamica(){
	clear
	if [ $LOGNAME != "root" ]
	then
	    read -p "Lo siento, este script debe ser ejecutado con privilegios de --root--."
	    exit 1
	fi

    write_header "Configuracion de red DINAMICA"

    echo "Mostrando interfaces de red actuales..."
	lshw -short -class network
	echo

	nic_elegida=""
	while [ "$nic_elegida" == "" ]
	do
	    read -p "Elige la interfaz/dispositivo desea configurar: " nic_elegida
	done

    echo "Configurando IP dinamica"
    echo
    #Modificacion de /etc/netplan
    ints="/etc/netplan/50-cloud-init.yaml"
    echo "# interfaces(5) file used by ifup(8) and ifdown(8)" > $ints
    echo "#IP dinamica" >> $ints
    echo "network:" >> $ints
    echo "    ethernets:" >> $ints
    echo "        $nic_elegida:" >> $ints
    echo "            dhcp4: true" >> $ints
    echo "    version: 2" >> $ints
    echo "Reiniciando tarjeta de red"
    netplan apply
    echo
    pause
}
#PUERTOS.....
function ver_puerto(){
	echo"$(netstat -topuna)"
      pause
}

# MENU LOGICO
while true
do
	clear
 	show_menu	# display memu
 	read_input  # wait for user input
done