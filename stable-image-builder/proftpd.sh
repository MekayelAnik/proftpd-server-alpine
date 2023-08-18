#!/bin/bash
# Show Image Build Time
BUILD_TIME=$(cat /build-timestamp)
echo "This Image was build on: ${BUILD_TIME}"
# Check if Username & Password is set for Each FTP share
if [ "${NUMBER_OF_SHARES}" -gt 1 ]; then
# Create FTP User and assign Password, UID & GID from Environment variables for Multiple Users
	for ((i=1; i<="${NUMBER_OF_SHARES}"; i++))
	do
		FTP_USER=FTP_USERNAME_${i}
		FTP_PASS=FTP_PASSWORD_${i}
		FTP_UID=FTP_USER_${i}_PUID
                FTP_GID=FTP_USER_${i}_PGID
		if [ -z "${!FTP_USER}" ] || [ -z "${!FTP_PASS}" ] || [ -z "${!FTP_UID}" ] || [ -z "${!FTP_GID}" ]; then
    			echo "You have set NUMBER_OF_SHARES to ${NUMBER_OF_SHARES}"
			echo "So you have to set values in each of"
			for ((j=1; j<="${NUMBER_OF_SHARES}"; j++))
			do
				echo "FTP_USERNAME_${j}, FTP_PASSWORD_${j}, FTP_USER_${j}_PUID & FTP_USER_${j}_GUID"
			done
			echo "Exitting..."
		        exit 1
		fi
		    if id "${!FTP_USER}" > /dev/null 2>&1; then
		        :
		    else
                        addgroup -g ${!FTP_GID} ${!FTP_USER}
			adduser --disabled-password --uid ${!FTP_UID} -G ${!FTP_USER} -s /bin/sh -h /home/"${!FTP_USER}" ${!FTP_USER}
		        echo "${!FTP_USER}:${!FTP_PASS}" | chpasswd
			chown -R "${!FTP_USER}":"${!FTP_USER}" /home/"${!FTP_USER}"
		    fi
	done
else 
# Create FTP User and assign Password, UID & GID from Environment variables for Single User
	    if id "$FTP_USERNAME_1" > /dev/null 2>&1; then
        	:
    	    else
    	        addgroup -g "${FTP_USER_1_PGID}" "${FTP_USERNAME_1}"
	        adduser --disabled-password --uid "${FTP_USER_1_PUID}" -G "${FTP_USERNAME_1}" -s /bin/sh -h /home/"${FTP_USERNAME_1}" "${FTP_USERNAME_1}"
		echo "${FTP_USERNAME_1}:${FTP_USERNAME_1}" | chpasswd
		chown -R "${FTP_USERNAME_1}":"${FTP_USERNAME_1}" /home/"${FTP_USERNAME_1}"
		fi
fi
echo -e "Include /etc/proftpd/conf.d/*.conf\n
DefaultServer           on\n
Group                   ftp\n
User                    ftp\n
Port                    $FTP_PORT\n
ServerType              standalone\n
UseIPv6                 off\n
WtmpLog                 off\n
RootLogin               off\n
UseReverseDNS           off\n
AllowOverwrite          on\n
MaxInstances            $MAX_INSTANCES\n
MaxClients              $MAX_CLIENTS\n
PassivePorts            4559 4564\n
ServerName              $SERVER_NAME\n
TimesGMT                $TIMES_GMT\n
Umask                   $LOCAL_UMASK\n
DefaultRoot             $LOCAL_ROOT\n
<Limit WRITE>\n
  AllowAll
</Limit>"  > /etc/proftpd/proftpd.conf
exec "$@"