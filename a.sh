last_line='NULL'
while read line; do
	  if [[ -n "${line}" ]]; then
		      last_line="${line}"
		        fi
		done < <(ls -lah)

		# This will output the last non-empty line from your_command
		echo "${last_line}"
