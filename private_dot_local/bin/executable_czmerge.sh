#!/bin/sh

for file in $(chezmoi managed)
do
	if test -f "$file" && ! chezmoi verify "$file"; then
		echo $file
	fi
done
