#!/bin/bash

# Check if Username & Password is set for Each FTP share
if [ "${NUMBER_OF_SHARES}" -gt 1 ]; then
	for ((i=1; i<="${NUMBER_OF_SHARES}"; i++))
	do
		FTP_USER=FTP_USERNAME_${i}
		FTP_PASS=FTP_PASSWORD_${i}
		if [ -z "${!FTP_USER}" ] || [ -z "${!FTP_PASS}" ]; then
    			echo "You have set NUMBER_OF_SHARES to ${NUMBER_OF_SHARES}"
			echo "So you have to set values in each of"
			for ((j=1; j<="${NUMBER_OF_SHARES}"; j++))
			do
				echo "FTP_USERNAME_${j} & FTP_PASSWORD_${j}"
			done
			echo "Exitting..."
		        exit 1
		fi
	done

# Create FTP User and assign Password from Environment variable for each share.
	for ((i=1; i<="${NUMBER_OF_SHARES}"; i++))
	do
		FTP_USER=FTP_USERNAME_${i}
		FTP_PASS=FTP_PASSWORD_${i}
		    if id "${!FTP_USER}" > /dev/null 2>&1; then
		        echo "${!FTP_USER}:${!FTP_PASS}" | chpasswd
		    else
			adduser --disabled-password -s /bin/sh -h /home/"${!FTP_USER}" ${!FTP_USER}
		        echo "${!FTP_USER}:${!FTP_PASS}" | chpasswd
			chown -R ${!FTP_USER}:${!FTP_USER} /home/"${!FTP_USER}"
		    fi
	done
else 

	    if id "$FTP_USERNAME_1" > /dev/null 2>&1; then
        	echo "$FTP_USERNAME_1:$FTP_PASSWORD_1" | chpasswd
    	    else
		adduser --disabled-password -s /bin/sh -h /home/"${FTP_USERNAME_1}" "${FTP_USERNAME_1}"
            	echo "$FTP_USERNAME_1:$FTP_PASSWORD_1" | chpasswd
	    	chown -R "${FTP_USERNAME_1}":"${FTP_USERNAME_1}" /home/"${FTP_USERNAME_1}"
    	    fi
        
fi
echo "Include /etc/proftpd/conf.d/*.conf" > /etc/proftpd/proftpd.conf
echo "DefaultServer           on" >> /etc/proftpd/proftpd.conf
echo "Group                   ftp"  >> /etc/proftpd/proftpd.conf
echo "User                    ftp"  >> /etc/proftpd/proftpd.conf
echo "Port                    $FTP_PORT"  >> /etc/proftpd/proftpd.conf
echo "ServerType              standalone"  >> /etc/proftpd/proftpd.conf
echo "UseIPv6                 off"  >> /etc/proftpd/proftpd.conf
echo "WtmpLog                 off"  >> /etc/proftpd/proftpd.conf
echo "RootLogin               off"  >> /etc/proftpd/proftpd.conf
echo "UseReverseDNS           off"  >> /etc/proftpd/proftpd.conf
echo "AllowOverwrite          on"  >> /etc/proftpd/proftpd.conf
echo "MaxInstances            $MAX_INSTANCES"  >> /etc/proftpd/proftpd.conf
echo "MaxClients              $MAX_CLIENTS"  >> /etc/proftpd/proftpd.conf
echo "PassivePorts            4559 4564"  >> /etc/proftpd/proftpd.conf
echo "ServerName              $SERVER_NAME"  >> /etc/proftpd/proftpd.conf
echo "TimesGMT                $TIMES_GMT"  >> /etc/proftpd/proftpd.conf
echo "Umask                   $LOCAL_UMASK"  >> /etc/proftpd/proftpd.conf
echo "DefaultRoot             $LOCAL_ROOT"  >> /etc/proftpd/proftpd.conf
echo "<Limit WRITE>"  >> /etc/proftpd/proftpd.conf
echo "  AllowAll"  >> /etc/proftpd/proftpd.conf
echo "</Limit>"  >> /etc/proftpd/proftpd.conf
exec "$@"