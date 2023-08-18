#!/bin/bash
# Show Image Build Time
echo "This image was build on: $(cat /usr/bin/build-timestamp)"   
# /usr/bin/banner.sh
# Show Conatiner Start Time
(date +%Z)
echo "This Container was started on: $(date)"
# Check if Username & Password is set for Each FTP share
# Create FTP User and assign Password, UID & GID from Environment variables for Multiple Users
	for ((i=1; i<="${NUMBER_OF_SHARES}"; i++))
	do
		FTP_USER=FTP_USERNAME_${i}
		FTP_PASS=FTP_PASSWORD_${i}
			if [ -z "${!FTP_USER}" ] || [ -z "${!FTP_PASS}" ] ; then
    				echo "You have set NUMBER_OF_SHARES to ${NUMBER_OF_SHARES}"
				echo "So you have to set values in each of"
				for ((j=1; j<="${NUMBER_OF_SHARES}"; j++))
				do
					echo "FTP_USERNAME_${j}, FTP_PASSWORD_${j}"
				done
				echo "Exitting..."
		        	exit 1
			fi
			if id "${!FTP_USER}" > /dev/null 2>&1; then
		        	:
			else
				FTP_UID=FTP_USER_${i}_PUID
	                	FTP_GID=FTP_USER_${i}_PGID
					if [ -z "${!FTP_UID}" ] || [ -z "${!FTP_GID}" ] ; then
						FTP_UID=$(( 1100 + i ))
						FTP_GID=$FTP_UID
                        			addgroup -g ${FTP_GID} ${!FTP_USER}
						adduser -D -u ${FTP_UID} -G ${!FTP_USER} -s /bin/sh -h /home/"${!FTP_USER}" ${!FTP_USER}
		        			echo "${!FTP_USER}:${!FTP_PASS}" | chpasswd
						chown -R "${!FTP_USER}":"${!FTP_USER}" /home/"${!FTP_USER}"
					elif [ -z "${!FTP_UID}" ] ; then
						FTP_UID=${!FTP_GID}
                        			addgroup -g ${!FTP_GID} ${!FTP_USER}
						adduser -D -u ${FTP_UID} -G ${!FTP_USER} -s /bin/sh -h /home/"${!FTP_USER}" ${!FTP_USER}
		        			echo "${!FTP_USER}:${!FTP_PASS}" | chpasswd
						chown -R "${!FTP_USER}":"${!FTP_USER}" /home/"${!FTP_USER}"
					elif [ -z "${!FTP_GID}" ] ; then
						FTP_GID=${!FTP_UID}
                        			addgroup -g ${FTP_GID} ${!FTP_USER}
						adduser -D -u ${!FTP_UID} -G ${!FTP_USER} -s /bin/sh -h /home/"${!FTP_USER}" ${!FTP_USER}
		        			echo "${!FTP_USER}:${!FTP_PASS}" | chpasswd
						chown -R "${!FTP_USER}":"${!FTP_USER}" /home/"${!FTP_USER}"
					else 
						addgroup -g ${!FTP_GID} ${!FTP_USER}
						adduser -D -u ${!FTP_UID} -G ${!FTP_USER} -s /bin/sh -h /home/"${!FTP_USER}" ${!FTP_USER}
		        			echo "${!FTP_USER}:${!FTP_PASS}" | chpasswd
						chown -R "${!FTP_USER}":"${!FTP_USER}" /home/"${!FTP_USER}"
					fi

			fi
	done
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
AllowOverwrite          $ALLOW_OVERWRITE\n
MaxInstances            $MAX_INSTANCES\n
MaxClients              $MAX_CLIENTS\n
PassivePorts            4559 4564\n
ServerName              $SERVER_NAME\n
TimesGMT                $TIMES_GMT\n
Umask                   $LOCAL_UMASK\n
DefaultRoot             $LOCAL_ROOT\n
TimeoutIdle             $TIMEOUT_IDLE\n
TimeoutNoTransfer       $TIMEOUT_NO_TRANSFER\n
TimeoutStalled          $TIMEOUT_STALLED\n
<Limit WRITE>\n
  AllowAll\n
</Limit>"  > /etc/proftpd/proftpd.conf
exec "$@"