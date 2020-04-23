#!/bin/bash
clear

if [ "$LOGNAME" != "root" ]
then
   read -p "Lo siento, este sccript debe ser ejecutado con privilegios de --root--."
   exit 1
fi


IP_RANGE_DEFAULT='10.0.0.50 10.0.0.100'
NETMASK_DEFAULT='255.255.255.0'
IP_DEFAULT='10.0.0.0'
DNS_DEFAULT='8.8.8.8'
GATEWAY_DEFAULT="10.0.0.1"
BROADCAST_DEFAULT="10.0.0.255"


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

    write_header " CONFIGURACION DHCP "

    echo "|  1.  Copia de seguridad dhcp.conf - isc-dhcp-server          |"
    echo "|--------------------------------------------------------------|"
	echo "|  2.  configuracion isc-dhcp-server                           |"
	echo "|  3.  Configuracion DHCP                                      |"
	echo "|--------------------------------------------------------------|"
	echo "|  4.  Configuracion DHCP manual                               |"
	echo "|  5.  Ingresar nuevo usuario                                  |"
	echo "|--------------------------------------------------------------|"
	echo "|  6.  Reiniciar DHCP                                          |"
	echo "|  7.  Detener   DHCP                                          |"
	echo "|  8.  Status    DHCP                                          |"
	echo "|--------------------------------------------------------------|"			
	echo "|[s|S] Salir                                                   |"
	echo "----------------------------------------------------------------"
}

function read_input(){
	local c
	read -p "Ingrese una opcion [ 1 - 9] " c
	case $c in
		1)	copia_seguridad ;;
		2)	isc_conf ;;
		3)	dhcp_automatico ;;
		4)	dhcp_manual ;;
		5)	new_user ;;
		6)	reiniciar_dhcp ;;
		7)	detener_dhcp ;;
		8)	status_dhcp ;;

		s|S)  clear
			exit 0 ;;
		*)
			echo "Seleccione entre 1 y 9 unicamente."
			pause
	esac
}

function copia_seguridad(){
	clear
    echo "Realizando copia de seguridad..."
    echo
    if [ -f /etc/dhcp/dhcpd.conf ]
    then
        cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.original
        if [ $? -eq 0 ]
        then
            echo "El archivo dhcpd.conf ha sido salvaguardado con éxito."
        else
            echo "Error al salvaguardar el archivo dhcpd.conf ."
        fi
    fi
    echo
    if [ -f /etc/default/isc-dhcp-server ]
    then
        cp /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.original
        if [ $? -eq 0 ]
        then
            echo "El archivo isc-dhcp-server ha sido salvaguardado con éxito."
        else
            echo "Error al salvaguardar el archivo isc-dhcp-server."
        fi
    fi
    echo
    pause
}
function dhcp_automatico(){
	clear
	echo ""
	echo "|==========================================================|"
	echo "|**********************************************************|"
	echo "|                       DHCP CONF                          |"
	echo "|                   configurando DHCP                      |"
	echo "|                                                          |"
	echo "|**********************************************************|"
	echo "|==========================================================|"
	echo ""
	echo "CTRL+C para detener
	Presionar directo [enter] para configuracion por Default"
	echo 
	pause
	echo 
	echo "Llenar la siguiente informacion"
	read -p "Network IP [10.0.0.0]: " IP
	read -p "Netmask [255.255.255.0]: " NETMASK
	read -p "IP Range [10.0.0.50 10.0.0.100]: " IP_RANGE
	read -p "DNS Servidor [8.8.8.8]: " DNS
	read -p "GATAWAY [10.0.0.1]: " GATEWAY
	read -p "BROADCAST [10.0.0.255]: " BROADCAST
	IP=${IP:-$IP_DEFAULT}
	NETMASK=${NETMASK:-$NETMASK_DEFAULT}
	IP_RANGE=${IP_RANGE:-$IP_RANGE_DEFAULT}
	DNS=${DNS:-$DNS_DEFAULT}
	GATEWAY=${GATEWAY:-$GATEWAY_DEFAULT}
	BROADCAST=${BROADCAST:-$BROADCAST_DEFAULT}

	echo 
	echo "--DHCP Configuration--"
	echo "
	#configuracion dhcp automatico
	default-lease-time 600;
	max-lease-time 7200;
	# ============================
	subnet $IP netmask $NETMASK {
		range $IP_RANGE;
		#deny unknown-clients;
		option domain-name-servers  $DNS;
		option subnet-mask $NETMASK;
		option routers $GATEWAY;
		option broadcast-address $BROADCAST;}
	"

	dhcp="/etc/dhcp/dhcpd.conf"
	echo "#configuracion dhcp automatico" > $dhcp
    echo "default-lease-time 600;" >> $dhcp
    echo "max-lease-time 7200;" >> $dhcp
    echo "# ============================" >> $dhcp
    echo "subnet $IP netmask $NETMASK {" >> $dhcp
    echo " range $IP_RANGE;" >> $dhcp
    echo " option domain-name-servers $DNS;" >> $dhcp
    echo " option subnet-mask $NETMASK;" >> $dhcp
    echo " option routers $GATEWAY;" >> $dhcp
    echo " option broadcast-address $BROADCAST;}" >> $dhcp
    echo
    
	systemctl stop isc-dhcp-server
 	systemctl start isc-dhcp-server
	systemctl status isc-dhcp-server
	pause
}
function isc_conf(){
	echo "--CONFIGURANDO isc-dhcp-server--"
    echo "Mostrando interfaces de red actuales..."
    echo
    echo 
	lshw -short -class network
	nic_elegida=""
	while [ "$nic_elegida" == "" ]
	do
		echo
	    read -p "Elige la interfaz/dispositivo desea configurar: " nic_elegida
	done
    server="/etc/default/isc-dhcp-server"
    echo "#configuracion isc-dhcp-server" > $server
    echo "INTERFACEv4=\"$nic_elegida\"" >> $server
    echo 'INTERFACEv6=""' >> $server
    pause
}
function dhcp_manual(){
	clear
	echo ""
	echo "|==========================================================|"
	echo "|**********************************************************|"
	echo "|                       DHCP CONF                          |"
	echo "|                   configurando DHCP                      |"
	echo "|                 ingresar IP-MAC ADDRESS                  |"
	echo "|**********************************************************|"
	echo "|==========================================================|"
	echo ""
	echo "CTRL+C para detener"
	echo ""
	pause
	echo ""
	echo "Llenar la siguiente informacion"
	read -p "Network IP [10.0.0.0]: " IP
	read -p "Netmask [255.255.255.0]: " NETMASK
	read -p "IP Range [10.0.0.50 10.0.0.100]: " IP_RANGE
	read -p "GATAWAY [10.0.0.1]: " GATEWAY
	read -p "BROADCAST [10.0.0.255]: " BROADCAST
	IP=${IP:-$IP_DEFAULT}
	NETMASK=${NETMASK:-$NETMASK_DEFAULT}
	IP_RANGE=${IP_RANGE:-$IP_RANGE_DEFAULT}
	GATEWAY=${GATEWAY:-$GATEWAY_DEFAULT}
	BROADCAST=${BROADCAST:-$BROADCAST_DEFAULT}

	echo ""
	echo "--DHCP Configuration--"
	echo "
	#configuracion dhcp manual
	default-lease-time 600;
	max-lease-time 7200;
	# ============================
	subnet $IP netmask $NETMASK {
		range $IP_RANGE;
		deny unknown-clients;
		option subnet-mask $NETMASK;
		option routers $GATEWAY;
		option broadcast-address $BROADCAST;}
	"

	dhcp="/etc/dhcp/dhcpd.conf"
	echo "#configuracion dhcp automatico" > $dhcp
    echo "default-lease-time 600;" >> $dhcp
    echo "max-lease-time 7200;" >> $dhcp
    echo "# ============================" >> $dhcp
    echo "subnet $IP netmask $NETMASK {" >> $dhcp
    echo " range $IP_RANGE;" >> $dhcp
    echo " deny unknown-clients;" >> $dhcp
    echo " option domain-name-servers $DNS;" >> $dhcp
    echo " option subnet-mask $NETMASK;" >> $dhcp
    echo " option routers $GATEWAY;" >> $dhcp
    echo " option broadcast-address $BROADCAST;}" >> $dhcp
    echo
    
	systemctl stop isc-dhcp-server
 	systemctl start isc-dhcp-server
	systemctl status isc-dhcp-server
	pause
}
function new_user(){
	write_header "Usuarios"
	cat /etc/dhcp/dhcpd.conf
	pause
	clear
	write_header "Nuevo Usuario"
	echo
	read -p "Ingrese nombre del usuario [admin]: " name
	read -p "Ingrese MacAddress [12:34:56:7a:8b:9c]: " mac
	read -p "Ingrese IP [192.168.0.5]: " ip
	echo
	echo "guardando configuracion . . . . . . ."
	echo
	new="/etc/dhcp/dhcpd.conf"
	echo "" >> $new
	echo "host $name {" >> $new
	echo " hardware ethernet $mac;" >> $new
	echo " fixed-address $ip;" >> $new
	echo "}" >> $new
	echo
	write_header "Nuevo Usuario Ingresado"
	cat /etc/dhcp/dhcpd.conf
	pause
	echo
	echo "guardando configuracion"
	echo
	systemctl stop isc-dhcp-server
	systemctl start isc-dhcp-server
	systemctl status isc-dhcp-server
	pause
}
function reiniciar_dhcp(){
	echo "Reiniciando SERVIDOR DHCP";
	systemctl restart isc-dhcp-server
	pause
}
function detener_dhcp(){
	echo "Deteniendo SERVIDOR DHCP";
	systemctl stop isc-dhcp-server
	pause
}
function status_dhcp(){
	echo "Estado del SERVICIO DHCP"
	systemctl status isc-dhcp-server
}
# aqui comienza la ejecucion del menu
while true
do
	clear
 	show_menu	# display memu
 	read_input  # wait for user input
done
