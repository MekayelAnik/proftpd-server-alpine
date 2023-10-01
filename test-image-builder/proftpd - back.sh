#!/bin/bash
/usr/bin/banner.sh
# Show Conatiner Start Time
# Check if Username & Password is set for Each FTP share
# Create FTP User and assign Password, UID & GID from Environment variables for Multiple Users
	for ((i=1; i<="${NUMBER_OF_SHARES}"; i++))
	do
		FTP_SHARE=FTP_SHARE_${i}
		FTP_PASS=FTP_PASSWORD_${i}
			if [ -z "${!FTP_SHARE}" ] || [ -z "${!FTP_PASS}" ] ; then
    				echo "You have set NUMBER_OF_SHARES to ${NUMBER_OF_SHARES}"
				echo "So you have to set values in each of"
				for ((j=1; j<="${NUMBER_OF_SHARES}"; j++))
				do
					echo "FTP_SHARE_${j}, FTP_PASSWORD_${j}"
				done
				echo "Exitting..."
		        	exit 1
			fi
			if id "${!FTP_SHARE}" > /dev/null 2>&1; then
		        	:
			else
				FTP_UID=FTP_SHARE_${i}_PUID
	                	FTP_GID=FTP_SHARE_${i}_PGID
				FTP_CHMOD=FTP_SHARE_${i}_CHMOD
					if [ -z "${!FTP_UID}" ] || [ -z "${!FTP_GID}" ] ; then
						FTP_UID=$(( 1100 + i ))
						FTP_GID=$FTP_UID
                        			addgroup -g "${FTP_GID}" "${!FTP_SHARE}"
						adduser -D -u "${FTP_UID}" -G "${!FTP_SHARE}" -s /bin/sh -h /data/"${!FTP_SHARE}" "${!FTP_SHARE}"
					elif [ -z "${!FTP_UID}" ] ; then
						FTP_UID=${!FTP_GID}
                        			addgroup -g "${!FTP_GID}" "${!FTP_SHARE}"
						adduser -D -u "${FTP_UID}" -G "${!FTP_SHARE}" -s /bin/sh -h /data/"${!FTP_SHARE}" "${!FTP_SHARE}"
					elif [ -z "${!FTP_GID}" ] ; then
						FTP_GID=${!FTP_UID}
                        			addgroup -g "${FTP_GID}" "${!FTP_SHARE}"
						adduser -D -u "${!FTP_UID}" -G "${!FTP_SHARE}" -s /bin/sh -h /data/"${!FTP_SHARE}" "${!FTP_SHARE}"
					else 
						addgroup -g "${!FTP_GID}" "${!FTP_SHARE}"
						adduser -D -u "${!FTP_UID}" -G "${!FTP_SHARE}" -s /bin/sh -h /data/"${!FTP_SHARE}" "${!FTP_SHARE}"
					fi
					echo "${!FTP_SHARE}:${!FTP_PASS}" | chpasswd
					chown -R "${!FTP_SHARE}":"${!FTP_SHARE}" /data/"${!FTP_SHARE}"
					if [ -z "${!FTP_CHMOD}" ]; then
						:
					else
						chmod -cR "${!FTP_CHMOD}" /data/"${!FTP_SHARE}"
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
