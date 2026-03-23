#!/bin/sh

folder="styles"

filename="-style.css"

validator="echo"

last=1

w3c="ignored"

methode=""

from="touch"

finally() {
	exit_status=$?

	if [ $((exit_status)) -ne 0 ]; then
		printf "w3c %s | %s\n" "$w3c" "$prev_file" >&2
	elif [ "$methode" = "touched" ]; then
		printf "w3c %s | %s %s\n"  "$w3c" "$current_file" "$methode"
	else
		printf "w3c %s | %s %s from %s\n"  "$w3c" "$current_file" "$methode" "$from"
	fi

	exit $((exit_status))
}

trap finally EXIT

while [ -f "$folder/$last$filename" ]; do
	last=$((last + 1))
done

prev_file="$folder/$((last - 1))$filename"
current_file="$folder/$last$filename"

if [ "$last" -eq 0 ]; then
	touch "$current_file"
	methode="touched"

else

	if [ "${1:-}" = "-bypass" ]; then
		w3c="bypassed"
	else
			if $validator "$prev_file" > /dev/null 2>&1; then
				w3c="passed"
			else
				if [ "$(head -n 1 "$prev_file")" = "placeholder" ]; then
					echo placeholder
				else
					w3c="failed"
					exit 1
				fi
			fi
		fi
		cp "$prev_file" "$current_file"
		methode="copied"
		from="$prev_file"
	fi

sed -i 's|href="styles/[0-9]*-style\.css"|href="'"$current_file"'"|' index.html