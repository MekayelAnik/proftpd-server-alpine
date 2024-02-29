#!/bin/bash
/usr/bin/banner.sh
# Show Conatiner Start Time
# Check if Username & Password is set for Each FTP share
# Create FTP User and assign Password, UID & GID from Environment variables for Multiple Users
if [[ -z "$ALL_FTP_SHARES_UNDER_SINGLE_COMMON_GROUP}" ]]; then
	ALL_FTP_SHARES_UNDER_SINGLE_COMMON_GROUP='false'
fi
if [[ -z "{$FTP_SHARE_COMMON_GID}" ]]; then
	FTP_SHARE_COMMON_GID='2121'
fi
if [[ -z "${FTP_SHARE_COMMON_GROUP_NAME}" ]]; then
	FTP_SHARE_COMMON_GROUP_NAME='ftp-common'
fi
no-uid-gid() {
	FTP_UID=$((1100 + i))
	if getent group ${FTP_UID} >/dev/null 2>&1; then
		FTP_UID=$((456 + FTP_UID))
	fi
	adduser -D -u "${FTP_UID}" -s /bin/sh -h /data/"${!FTP_SHARE}" "${!FTP_SHARE}"
	chown -cR "${FTP_UID}":"${FTP_UID}" /data/"${!FTP_SHARE}"
}
ALL_FTP_SHARES_UNDER_SINGLE_COMMON_GROUP=$(echo "${ALL_FTP_SHARES_UNDER_SINGLE_COMMON_GROUP}" | tr '[:upper:]' '[:lower:]')
if [[ "${ALL_FTP_SHARES_UNDER_SINGLE_COMMON_GROUP}" == 'true' ]] || [[ "${ALL_FTP_SHARES_UNDER_SINGLE_COMMON_GROUP}" == 'enabled' ]] || [[ "${ALL_FTP_SHARES_UNDER_SINGLE_COMMON_GROUP}" == 'enable' ]] || [[ "${ALL_FTP_SHARES_UNDER_SINGLE_COMMON_GROUP}" == 'yes' ]] || [[ "${ALL_FTP_SHARES_UNDER_SINGLE_COMMON_GROUP}" == 'ok' ]] || [[ "${ALL_FTP_SHARES_UNDER_SINGLE_COMMON_GROUP}" == 'y' ]] || [[ "${ALL_FTP_SHARES_UNDER_SINGLE_COMMON_GROUP}" == 'ya' ]] || [[ "${ALL_FTP_SHARES_UNDER_SINGLE_COMMON_GROUP}" == '1' ]]; then
	ALL_FTP_SHARES_UNDER_SINGLE_COMMON_GROUP='true'
fi
for ((i = 1; i <= "${NUMBER_OF_SHARES}"; i++)); do
	FTP_SHARE=FTP_SHARE_${i}
	FTP_PASS=FTP_PASSWORD_${i}
	if [[ -z "${!FTP_SHARE}" ]] || [[ -z "${!FTP_PASS}" ]]; then
		echo "You have set NUMBER_OF_SHARES to ${NUMBER_OF_SHARES}"
		echo "So you have to set values in each of"
		for ((j = 1; j <= "${NUMBER_OF_SHARES}"; j++)); do
			echo "FTP_SHARE_${j}, FTP_PASSWORD_${j}"
		done
		echo "Exitting..."
		exit 1
	fi
	if id "${!FTP_SHARE}" >/dev/null 2>&1; then
		:
	else
		FTP_UID=FTP_SHARE_${i}_PUID
		FTP_GID=FTP_SHARE_${i}_PGID
		FTP_CHMOD=FTP_SHARE_${i}_CHMOD
		if [[ "$ALL_FTP_SHARES_UNDER_SINGLE_COMMON_GROUP" == 'true' ]]; then
			if [[ -n "${FTP_SHARE_COMMON_GID}" ]]; then
				if [[ "${FTP_SHARE_COMMON_GID}" =~ ^[0-9]+$ ]]; then
					if getent group ${FTP_SHARE_COMMON_GID} >/dev/null 2>&1; then
						:
					else
						addgroup --gid "${FTP_SHARE_COMMON_GID}" "${FTP_SHARE_COMMON_GROUP_NAME}"
					fi
					if [[ -z "${!FTP_UID}" ]]; then
						FTP_UID=$((1100 + i))
						adduser -D -u "${FTP_UID}" -s /bin/sh -h /data/"${!FTP_SHARE}" "${!FTP_SHARE}"
						usermod -aG "${FTP_SHARE_COMMON_GID}" "${!FTP_SHARE}"
						chown -cR "${FTP_UID}":"${FTP_SHARE_COMMON_GID}" /data/"${!FTP_SHARE}"
					else
						adduser -D -u "${!FTP_UID}" -s /bin/sh -h /data/"${!FTP_SHARE}" "${!FTP_SHARE}"
						usermod -aG "${FTP_SHARE_COMMON_GID}" "${!FTP_SHARE}"
						chown -cR "${!FTP_UID}":"${FTP_SHARE_COMMON_GID}" /data/"${!FTP_SHARE}"
					fi
				else
					echo "You have to set numeric value in FTP_SHARE_COMMON_GID. Exitting..."
					exit 1
				fi
			else
				echo "You have set value TRUE in ALL_FTP_SHARES_UNDER_SINGLE_COMMON_GROUP but didn't set numeric value in FTP_SHARE_COMMON_GID. Exitting..."
				exit 1
			fi
		else
			if [[ -z "${!FTP_UID}" ]] && [[ -z "${!FTP_GID}" ]]; then
				FTP_UID=$((1100 + i))
				no-uid-gid
			elif [[ -z "${!FTP_UID}" ]] && [[ -n "${!FTP_GID}" ]]; then
				if [[ "${!FTP_GID}" =~ ^[0-9]+$ ]]; then
					FTP_UID=$((1100 + i))
					if getent group ${FTP_UID} >/dev/null 2>&1; then
						FTP_UID=$((456 + FTP_UID))
					fi
					adduser -D -u "${FTP_UID}" -s /bin/sh -h /data/"${!FTP_SHARE}" "${!FTP_SHARE}"
					if getent group ${!FTP_GID} >/dev/null 2>&1; then
						:
					else
						if [[ "${FTP_UID}" != "${!FTP_GID}" ]]; then
							addgroup --gid "${!FTP_GID}" "${FTP_GROUP_NAME}${!FTP_GID}"
						fi
					fi
					usermod -aG ${!FTP_GID} ${!FTP_SHARE}
					chown -cR "${FTP_UID}":"${!FTP_GID}" /data/"${!FTP_SHARE}"
				else
					echo "Set Numeric Value in ${FTP_GID}. Otherwise skipping creation of Group ${!FTP_GID}"
					no-uid-gid
				fi
			elif [[ -n "${!FTP_UID}" ]] && [[ -z "${!FTP_GID}" ]]; then
				if [[ "${!FTP_UID}" =~ ^[0-9]+$ ]]; then
					if getent passwd ${!FTP_UID} >/dev/null 2>&1; then
						echo "User with same UID already exists. Creating user with different UID"
						no-uid-gid
					else
						adduser -D -u "${!FTP_UID}" -s /bin/sh -h /data/"${!FTP_SHARE}" "${!FTP_SHARE}"
					fi
				else
					echo "UID of ${!FTP_SHARE} is not Numeric. Change the value of ${FTP_UID} to a numeric one. Otherwise skipping creation of ${!FTP_SHARE}..."
				fi
			elif [[ -n "${!FTP_UID}" ]] && [[ -n "${!FTP_GID}" ]]; then
				if [[ "${!FTP_UID}" =~ ^[0-9]+$ ]]; then
					if [[ "${!FTP_GID}" =~ ^[0-9]+$ ]]; then
						if getent group ${!FTP_GID} >/dev/null 2>&1; then
							:
						else
							if [[ "${!FTP_UID}" != "${!FTP_GID}" ]]; then
								addgroup --gid "${!FTP_GID}" "${FTP_GROUP_NAME}${!FTP_GID}"
							fi
						fi
					else
						echo "GUID of ${!FTP_SHARE} is not Numeric. Skipping Group Creation..."
					fi
					if getent passwd ${!FTP_UID} >/dev/null 2>&1; then
						echo "User with same UID already exists."
						FTP_UID=$((1100 + i))
						if getent group ${FTP_UID} >/dev/null 2>&1; then
							FTP_UID=$((456 + FTP_UID))
						fi
						echo "Creating FTP USER with UID=$FTP_UID"
						adduser -D -u "${FTP_UID}" -s /bin/sh -h /data/"${!FTP_SHARE}" "${!FTP_SHARE}"
						if [[ "${FTP_UID}" != "${!FTP_GID}" ]]; then
							usermod -aG ${!FTP_GID} ${!FTP_SHARE}
						fi
						chown -cR "${FTP_UID}":"${!FTP_GID}" /data/"${!FTP_SHARE}"
					else
						adduser -D -u "${!FTP_UID}" -s /bin/sh -h /data/"${!FTP_SHARE}" "${!FTP_SHARE}"
						if [[ "${!FTP_UID}" != "${!FTP_GID}" ]]; then
							usermod -aG ${!FTP_GID} ${!FTP_SHARE}
						fi
						chown -cR "${!FTP_UID}":"${!FTP_GID}" /data/"${!FTP_SHARE}"
					fi
				else
					echo "UID of ${!FTP_SHARE} is not Numeric. Change the value of ${FTP_UID} to a numeric one. Otherwise skipping creation of ${!FTP_SHARE}..."
				fi
			fi
		fi
		echo "${!FTP_SHARE}:${!FTP_PASS}" | chpasswd
		if [[ -n "${!FTP_CHMOD}" ]] && [[ "${!FTP_CHMOD}" =~ ^[0-9]+$ ]]; then
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
</Limit>" >/etc/proftpd/proftpd.conf
exec "$@"
