# Run in cli mode if no arguments
if [ $# -lt 1 ]; then
	if [ $ENABLE_CLI_MODE -gt 0 ]; then
		# if no arguments and not enabling
		# CLI mode, print help message
		ustb_version
		ustb_help
	else
		# handle exit
		trap _ustb_bye 0

		while read -ep "ustb> " line; do
			_ustb_command $line
		done
	fi
else
	# or excute single command
	_ustb_command $*
	exit $?
fi
