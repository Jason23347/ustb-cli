ustb_whoami() {
	printf "Current user: %s\n" \
		$(curl -s $LOGIN_HOST | grep ';uid' |
			iconv -f GBK -t UTF-8 | sed "s/.*uid='//;s/';.*//")
}

ustb_login() {
	local res=$(curl -s $LOGIN_HOST | grep ';uid')
	[ $? -eq 0 ] && username=$(echo "$res" |
		iconv -f GBK -t UTF-8 | sed "s/.*uid='//;s/';.*//")

	# Input username or use default
	if [ -n "$username" ] && [ $ALWAYS_USE_DEFAULT_USER -ne 0 ]; then
		read -n1 -ep "Login as $username? [Y/n]" yn
		[[ $yn =~ N|n ]] &&
			read -ep "Username: " username
	else
		read -ep "Username: " username
	fi

	# Input password
	read -sep "Password: " password

	# Fetch IPV6 address
	[[ "$ATTEMPT_IPV6" -gt 1 ]] && {
		printf "\nfetching IPV6 address..."
		if [ -n "$DEFAULT_IPV6_ADDRESS" ]; then
			ip_addr="$DEFAULT_IPV6_ADDRESS"
		else
			ip_addr=$(curl -s http://cippv6.ustb.edu.cn/get_ip.php |
				grep "gIpV6Addr" |
				sed "s/.*= '//;s/';.*//")
		fi
		printf "$ip_addr.\n"
	}

	# Do login
	params="callback=suibian&DDDDD=$username&upass=$password&0MKKey=123456&v6ip=$ip_addr"
	curl -s --retry 3 "$LOGIN_HOST/drcom/login?$params" |
		grep '"result":1' 2>&1 1>/dev/null
	[ $? -eq 0 ] &&
		echo "Login succeed." ||
		echo "Login failed."
}

ustb_logout() {
	curl -s "$LOGIN_HOST/F.htm" >/dev/null
	if [ $? -eq 0 ]; then
		echo "Logout succeed."
	else
		echo "Logout failed."
	fi
}
