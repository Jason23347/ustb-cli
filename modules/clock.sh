ustb_clock() {
	# refresh screen
	tput clear
	# make cursor invisible
	tput civis

	trap _ustb_reset_tty SIGWINCH

	# Digit variables
	EMPTY=
	for ((i = 0; i < $CLOCK_WIDTH; i++)); do
		EMPTY+=" "
	done
	POINT="${CLOCK_COLOR}$EMPTY\033[0m"

	CLOCK_BLOCK=$((2 + 3 * $CLOCK_WIDTH))

	# Padding variables
	[ -v CLOCK_GAP ] ||
		declare -i CLOCK_GAP=$CLOCK_BLOCK+$CLOCK_SPACE
	[ -v CLOCK_DOTS_OFFSET ] ||
		declare -i CLOCK_DOTS_OFFSET=$CLOCK_SPACE*2/3

	while :; do
		# get tty size
		# array, 0: height, 1: length
		tty_size=$(stty size)

		# minute hour
		date_string=$(date +"%M %l")

		# passing params divided by space if without quoting
		# 4 params: width height minute hour
		_ustb_draw_clock $tty_size $date_string
		[ $? -ne 0 ] && return 1

		# press 'q' to quit
		read -t 0.1 -n1 ch
		[ "$ch" == "q" ] && {
			clear
			tput cnorm
			break
		}
	done
}

_ustb_reset_tty() {
	sleep 0.2
	# refresh screen
	tput clear
	# reset tty size
	tty_size=$(stty size)
	# redraw ':' and flow info
	unset _dots _flow_info
}

_ustb_draw_clock() {
	local -i tty_height=$1
	local -i tty_width=$2

	# Avoid recognizing '08' as octal number
	local -i minute=$(echo $3 | sed 's/^0//')
	local -i hour=$(echo $4 | sed 's/^0//')

	# Calculate position
	# Space between dots and digits is thinner, so minus 2 * offset
	min_width=$((5 * CLOCK_BLOCK + 4 * CLOCK_SPACE - 2 * $CLOCK_DOTS_OFFSET))
	# height: 10 (clock) + 2 (date) + 4 (flow info)
	min_height=16
	padding_x=$((($tty_width - $min_width) / 2))
	padding_y=$((($tty_height - $min_height) / 2))

	# If terminal is not big enough, padding will be under 0
	[ $padding_x -lt 0 ] || [ $padding_y -lt 0 ] && {
		echo "Error: Minimum tty size ${min_height}x${min_width} required."
		return 1
	}

	# Initialize cursor position
	tput cup $tty_height 0

	# never redraw dots unless window size is changed
	[ -v _dots ] || {
		_ustb_draw_dots \
			$(($padding_x + 2 * $CLOCK_GAP - $CLOCK_DOTS_OFFSET)) \
			$padding_y
		_dots=1
	}

	# Skip further drawing unless force-updated
	# or the current digit mismatched with number
	[ $CLOCK_FORCE_UPDATE -eq 0 ] &&
		[ ${min_0:--1} -eq $(($minute % 10)) ] &&
		return

	# set number
	min_0=$(($minute % 10))
	# call the corresponding funciton, e.g. _ustb_draw_digit_7,
	# passing (col, row) position as parameters
	_ustb_draw_digit_${min_0} \
		$(($padding_x + 4 * $CLOCK_GAP - 2 * $CLOCK_DOTS_OFFSET)) \
		$padding_y

	[ $CLOCK_FORCE_UPDATE -eq 0 ] &&
		[ ${min_1:--1} -eq $(($minute - $min_0)) ] &&
		return

	min_1=$((($minute - $min_0) / 10))
	_ustb_draw_digit_${min_1} \
		$(($padding_x + 3 * $CLOCK_GAP - 2 * $CLOCK_DOTS_OFFSET)) \
		$padding_y

	[ $CLOCK_FORCE_UPDATE -eq 0 ] &&
		[ ${hour_0:--1} -eq $(($hour % 10)) ] &&
		return

	hour_0=$(($hour % 10))
	_ustb_draw_digit_${hour_0} \
		$(($padding_x + 1 * $CLOCK_GAP)) \
		$padding_y

	[ $CLOCK_FORCE_UPDATE -eq 0 ] &&
		[ ${hour_1:--1} -eq $(($hour - $hour_0)) ] &&
		return

	hour_1=$((($hour - $hour_0) / 10))
	_ustb_draw_digit_${hour_1} \
		$padding_x \
		$padding_y

	# draw date with date format
	# FIXME: called too many times if force-updated
	_ustb_draw_date $tty_width $(($padding_y + 10))

	# update every minute
	# set to 0 by default to ensure load info
	# when running for the first time
	[ ${_flow_info:-0} -eq 0 ] &&
		_ustb_draw_info $tty_width $(($padding_y + 12))
	_flow_info=$(date +%S | sed 's/^0//')
}

_ustb_draw_info_line() {
	padding_x=$1
	padding_y=$2
	prompt="$3"
	content="$4"

	tput cup $padding_y $padding_x
	printf "%s" "$prompt"
	for ((i = 0; i < $CLOCK_INFO_WIDTH - ${#prompt} - ${#content}; i++)); do
		printf " "
	done
	printf "${COLOR}%s\033[0m" "$content"
	# clear color variable
	COLOR=
}

_ustb_draw_info() {
	local -i padding_x
	local -i padding_y=$2
	local v4_only=0
	local res=$(curl -s $LOGIN_HOST)
	# save cursor position
	tput sc

	# Print error info and return when cannot connect to server
	[ "$res" == "" ] && {
		local str="Couldn't connect to server"
		padding_x=$((($1 - ${#str}) / 2))
		# Erase outdated info
		tput cup $padding_y 0
		tput ed
		# Show error message
		tput cup $padding_y $padding_x
		printf "\033[31m%s\033[0m" "$str"
		tput rc
		return 1
	}

	padding_x=$((($1 - 28) / 2))

	# Calculate download speed
	now=$(date +%s)
	# IPV4 flow
	flow=$(echo "$res" | grep ";flow=" |
		sed "s/.*flow='//;s/[[:space:]].*//")

	local -i divide=$now-${last:-0}
	if [ $divide -gt 3 ]; then
		speed=$(echo "scale=2;(${flow:-$old_flow}-${old_flow:-0})/($now-${last:-0})" | bc)
		# Human readable
		speed=$(_ustb_flow $speed)/s
	fi

	last=$now
	old_flow=$flow
	# Human readable
	flow=$(_ustb_flow $flow)

	# IPV6 flow
	local flow_v6=$(echo "$res" | grep "v6df=" |
		sed "s/.*v6df=//;s/;.*//")/4
	flow_v6=$(_ustb_flow $flow_v6)

	# fee
	local fee=$(echo "$res" | grep 'fee=' |
		sed "s/.*fee='//;s/[[:space:]].*//")
	fee=$(echo "scale=2;$fee/10000" | bc)

	# start output
	_ustb_draw_info_line $padding_x $padding_y \
		"Download:" "$speed"

	# move cursor to the next line
	padding_y+=1
	if [ $v4_only -eq 0 ]; then
		COLOR="\033[32m" # green
		_ustb_draw_info_line $padding_x $padding_y \
			"IPV6 Mode:" "ON"
	else
		COLOR="\033[31m" # red
		_ustb_draw_info_line $padding_x $padding_y \
			"IPV6 Mode:" "OFF"
	fi

	padding_y+=1
	_ustb_draw_info_line $padding_x $padding_y \
		"IPV4 Flow:" "$flow"

	# set color
	_ustb_fee_color $fee
	padding_y+=1
	_ustb_draw_info_line $padding_x $padding_y \
		"Fee Left:" "$fee"

	# move back cursor position
	tput rc
}

_ustb_draw_date() {
	local str=$(date +"$CLOCK_DATE_FORMAT")
	local len=${#str}
	local padding_x=$((($1 - $len) / 2))
	tput sc
	tput cup $2 $padding_x
	printf "%s" "$str"

	tput rc
}

_ustb_draw_dots() {
	local -i x=$1
	local -i y=$2
	tput sc

	x+=$(($CLOCK_BLOCK / 2 - 1))
	y+=2
	tput cup $y $x
	printf "$POINT"
	y+=4
	tput cup $y $x
	printf "$POINT"

	tput rc
}

_ustb_draw_digit_0() {
	local -i x=$1
	local -i y=$2
	tput sc

	# 1 1 1

	# 1 0 1
	# 1 0 1
	# 1 0 1

	# 1 1 1
	tput cup $y $x
	printf "$POINT $POINT $POINT"
	for ((i = 0; i < 3; i++)); do
		y+=2
		tput cup $y $x
		printf "$POINT $EMPTY $POINT"
	done

	y+=2
	tput cup $y $x
	printf "$POINT $POINT $POINT"

	tput rc
}

_ustb_draw_digit_1() {
	local -i x=$1
	local -i y=$2
	tput sc

	# 0 1 0
	for ((i = 0; i < 5; i++)); do
		tput cup $y $x
		# 0 1 0
		printf "$EMPTY $POINT $EMPTY"
		y+=2
	done

	tput rc
}

_ustb_draw_digit_2() {
	local -i x=$1
	local -i y=$2
	tput sc

	# 1 1 1
	# 0 0 1
	# 1 1 1
	# 1 0 0
	# 1 1 1
	tput cup $y $x
	printf "$POINT $POINT $POINT"
	y+=2
	tput cup $y $x
	printf "$EMPTY $EMPTY $POINT"
	y+=2
	tput cup $y $x
	printf "$POINT $POINT $POINT"
	y+=2
	tput cup $y $x
	printf "$POINT $EMPTY $EMPTY"
	y+=2
	tput cup $y $x
	printf "$POINT $POINT $POINT"

	tput rc
}

_ustb_draw_digit_3() {
	local -i x=$1
	local -i y=$2
	tput sc

	# 1 1 1

	# 0 0 1
	# 1 1 1
	# 0 0 1
	# 1 1 1
	tput cup $y $x
	printf "$POINT $POINT $POINT"
	for ((i = 0; i < 2; i++)); do
		y+=2
		tput cup $y $x
		printf "$EMPTY $EMPTY $POINT"
		y+=2
		tput cup $y $x
		printf "$POINT $POINT $POINT"
	done

	tput rc
}

_ustb_draw_digit_4() {
	local -i x=$1
	local -i y=$2
	tput sc

	# 1 0 1
	# 1 0 1
	# 1 1 1
	# 1 0 1
	# 0 0 1
	tput cup $y $x
	printf "$POINT $EMPTY $POINT"
	y+=2
	tput cup $y $x
	printf "$POINT $EMPTY $POINT"
	y+=2
	tput cup $y $x
	printf "$POINT $POINT $POINT"
	y+=2
	tput cup $y $x
	printf "$EMPTY $EMPTY $POINT"
	y+=2
	tput cup $y $x
	printf "$EMPTY $EMPTY $POINT"

	tput rc
}

_ustb_draw_digit_5() {
	local -i x=$1
	local -i y=$2
	tput sc

	# 1 1 1
	# 1 0 0
	# 1 1 1
	# 0 0 1
	# 1 1 1
	tput cup $y $x
	printf "$POINT $POINT $POINT"
	y+=2
	tput cup $y $x
	printf "$POINT $EMPTY $EMPTY"
	y+=2
	tput cup $y $x
	printf "$POINT $POINT $POINT"
	y+=2
	tput cup $y $x
	printf "$EMPTY $EMPTY $POINT"
	y+=2
	tput cup $y $x
	printf "$POINT $POINT $POINT"

	tput rc
}

_ustb_draw_digit_6() {
	local -i x=$1
	local -i y=$2
	tput sc

	# 1 1 1
	# 1 0 0
	# 1 1 1
	# 1 0 1
	# 1 1 1
	tput cup $y $x
	printf "$POINT $POINT $POINT"
	y+=2
	tput cup $y $x
	printf "$POINT $EMPTY $EMPTY"
	y+=2
	tput cup $y $x
	printf "$POINT $POINT $POINT"
	y+=2
	tput cup $y $x
	printf "$POINT $EMPTY $POINT"
	y+=2
	tput cup $y $x
	printf "$POINT $POINT $POINT"

	tput rc
}

_ustb_draw_digit_7() {
	local -i x=$1
	local -i y=$2
	tput sc

	# 1 1 1

	# 0 0 1
	# 0 0 1
	# 0 0 1
	# 0 0 1
	tput cup $y $x
	printf "$POINT $POINT $POINT"
	for ((i = 0; i < 4; i++)); do
		y+=2
		tput cup $y $x
		printf "$EMPTY $EMPTY $POINT"
	done

	tput rc
}

_ustb_draw_digit_8() {
	local -i x=$1
	local -i y=$2
	tput sc

	# 1 1 1

	# 1 0 1
	# 1 1 1
	# 1 0 1
	# 1 1 1
	tput cup $y $x
	printf "$POINT $POINT $POINT"
	for ((i = 0; i < 2; i++)); do
		y+=2
		tput cup $y $x
		printf "$POINT $EMPTY $POINT"
		y+=2
		tput cup $y $x
		printf "$POINT $POINT $POINT"
	done

	tput rc
}

_ustb_draw_digit_9() {
	local -i x=$1
	local -i y=$2
	tput sc

	local -i x=$1
	local -i y=$2
	tput sc

	# 1 1 1
	# 1 0 1
	# 1 1 1
	# 0 0 1
	# 0 0 1
	tput cup $y $x
	printf "$POINT $POINT $POINT"
	y+=2
	tput cup $y $x
	printf "$POINT $EMPTY $POINT"
	y+=2
	tput cup $y $x
	printf "$POINT $POINT $POINT"
	y+=2
	tput cup $y $x
	printf "$EMPTY $EMPTY $POINT"
	y+=2
	tput cup $y $x
	printf "$EMPTY $EMPTY $POINT"

	tput rc
}
