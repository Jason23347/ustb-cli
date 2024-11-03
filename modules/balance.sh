ustb_info() {
	local v4_only=0

	# fetch login page info
	local res=$(curl -s $LOGIN_HOST | iconv -f GBK -t UTF-8)

	# LOGIN check
	echo "$res" | grep "flow=" 2>&1 >/dev/null
	[ $? -ne 0 ] && {
		echo "Login required."
		return 1
	}

	# IPV6 check
	v46m=$(echo "$res" | grep ";v46m=" | sed "s/.*v46m=//;s/;.*//")
	[ $v46m -eq 4 ] || [ $v46m -eq 12 ] || v4_only=1

	# IPV4 flow
	local flow=$(echo "$res" | grep ";flow=" |
		sed "s/.*flow='//;s/[[:space:]].*//")

	# IPV4 fee
	local fee=$(echo "$res" | grep "fee=" |
		sed "s/.*fee='//;s/[[:space:]].*//")

	# IPV6 upload flow
	local flow_v6=$(echo "$res" | grep "v6df=" |
		sed "s/.*v6df=//;s/;.*//")/4

	printf "\033[34mIPV4\033[0m\n"
	cat <<INFO
IP address:	$(echo "$res" | grep "v4ip=" | sed "s/.*v4ip='//;s/'.*//")
Flow:		$(_ustb_flow $flow)

INFO

	[ $v4_only -eq 1 ] && {
		cat <<INFO
IPV6 not found.

INFO
		return 0
	}

	printf "\033[32mIPV6\033[0m\n"
	cat <<INFO
IP address:	$(echo "$res" | grep ";v6ip=" | sed "s/.*;v6ip='//;s/'.*//")
Flow:		$(_ustb_flow $flow_v6)

Flow Saving rate (%):	$(echo "scale=2; $flow_v6 / ($flow_v6 + $flow)" | bc)

INFO
}

ustb_fee() {
	local res=$(curl -s $LOGIN_HOST)

	# Default color
	local COLOR_FEE="\033[0m"
	local COLOR_="\033[0m"

	# cost
	local flow=$(echo "$res" | grep ";flow=" |
		sed "s/.*flow='//;s/[[:space:]].*//")
	local cost
	# First 120G free
	if [ $(echo "$flow <= 120000000" | bc) -eq 1 ]; then
		cost=0
	else
		cost=$(echo "scale=2; ($flow / 1000000 - 120) * 0.6" | bc)
	fi

	# fee
	local fee=$(echo "$res" | grep 'fee=' |
		sed "s/.*fee='//;s/[[:space:]].*//")
	fee=$(echo "scale=2;$fee/10000" | bc)

	# set color
	if [ $(bc <<<"$cost < 10") -eq 1 ]; then
		COLOR="\033[32m"
	elif [ $(bc <<<"$cost < 30") -eq 1 ]; then
		COLOR="\033[34m"
	elif [ $(bc <<<"$cost < 50") -eq 1 ]; then
		COLOR="\033[33m"
	else
		COLOR="\033[31m"
	fi

	printf "Money Cost: ${COLOR}￥%s\033[0m\n" $cost

	# set color
	_ustb_fee_color $fee
	printf "Money left: ${COLOR}￥%s\033[0m\n\n" $fee
}

_ustb_fee_color() {
	local fee=${1:-0}
	if [ $(bc <<<"$fee > 30") -eq 1 ]; then
		COLOR="\033[32m" # green
	elif [ $(bc <<<"$fee > 10") -eq 1 ]; then
		COLOR="\033[34m" # blue
	elif [ $(bc <<<"$fee > 3") -eq 1 ]; then
		COLOR="\033[33m" # yellow
	elif [ $(bc <<<"$fee > 1") -eq 1 ]; then
		COLOR="\033[31m" # red
	fi
}
