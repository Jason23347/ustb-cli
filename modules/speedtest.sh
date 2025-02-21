_ustb_time() {
	start_time=$(date +%s%3N)
	"$@"
	end_time=$(date +%s%3N)

	echo $((end_time - start_time))
}

ustb_speedtest() {
	local speed
	local r_value
	local -i elapsed_time

	local -i file_size=${1:-500} # defualt 500 M

	# Testing download speed

	echo "Test file size: ${file_size} MB"

	r_value=$(awk -v seed=$RANDOM 'BEGIN { srand(seed); printf "%.16f\n", rand() }')

	elapsed_time=$(
		_ustb_time \
			curl -s \
			"http://speed.ustb.edu.cn/backend/garbage.php?r=${r_value}&ckSize=${file_size}" \
			-o /dev/null
	)
	echo "Elapsed time: ${elapsed_time} ms"

	speed=$(echo "scale=2; $file_size * 1000 / $elapsed_time" | bc)

	echo "Average download speed: ${speed} MB/s"
	echo

	# Test upload speed

	echo "Test file size: ${file_size} MB"
	r_value=$(awk -v seed=$RANDOM 'BEGIN { srand(seed); printf "%.16f\n", rand() }')

	elapsed_time=$(
		_ustb_time \
			curl -s -X POST \
			-H "Content-Encoding: identity" \
			-d @- \
			"http://speed.ustb.edu.cn/backend/empty.php?r=${r_value}" \
			-o /dev/null < <(head -c "${file_size}M" </dev/urandom)
	)
	echo "Elapsed time: ${elapsed_time} ms"

	speed=$(echo "scale=2; $file_size * 1000 / $elapsed_time" | bc)

	echo "Average upload speed: ${speed} MB/s"
}
