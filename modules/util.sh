SCRIPTNAME=${0##*/}

# Bouncing commands to functions
_ustb_command() {
	# ignore empty lines
	[ $# -lt 1 ] && return

	command=$1
	shift

	# check if command exists
	type -t "ustb_$command" >/dev/null
	[ $? -ne 0 ] && {
		[ "$command" == "exit" ] && exit 0
		echo "$SCRIPTNAME: '$command' is not a command. See '$SCRIPTNAME help'."
		return 1
	}
	# excute
	ustb_$command
}

# Handle exit
_ustb_bye() {
	printf "Bye-bye.\n"
	tput cnorm
}

_ustb_flow() {
	local -i flow=$(echo ${1:-0} | tr -cd "[0-9\/]" | sed 's/^0\+//')

	if [ $(echo "$flow / 1024 < 1" | bc) -eq 1 ]; then
		printf "%s KB" $flow
	elif [ $(echo "$flow / 1024^2 < 1" | bc) -eq 1 ]; then
		printf "%s MB" $(echo "scale=2; $flow / 1024" | bc)
	elif [ $(echo "$flow / 1024^2 < 900" | bc) -eq 1 ]; then
		printf "%s GB" $(echo "scale=2; $flow / 1024^2" | bc)
	else
		printf "%s TB" $(echo "scale=2; $flow / 1024^3" | bc)
	fi
}

ustb_help() {
	cat <<END
Usage: $SCRIPTNAME [options] <command>
Commands:
login		login to USTB web
logout		logout of USTB web
clock		display a clock with flow info
whoami		show current user
fee		show network fees left
info		show further flow infomation
version		show version and authors
help		show this information

END
}

ustb_version() {
	cat <<INFO
$SCRIPTNAME $VERSION - A utility script for USTB web.

Copyright  2020-2024	Shuaicheng Zhu <jason23347@gmail.com>

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

INFO
}
