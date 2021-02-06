#!/bin/sh

set -C -f -u # -f disables path expantion
IFS=$'\n'

width=${2:-$(tput cols)}
height=${3:-$(tput lines)}
# hpos=$4
# vpos=$5


FILE_PATH="${1}"
FILE_EXTENSION="${FILE_PATH##*.}"
FILE_EXTENSION_LOWER=$(echo ${FILE_EXTENSION} | tr '[:upper:]' '[:lower:]')


case "$FILE_EXTENSION_LOWER" in
	a|ace|alz|arc|arj|bz|bz2|cab|cpio|deb|gz|jar|lha|lz|lzh|lzma|lzo|\
	rpm|rz|t7z|tar|tbz|tbz2|tgz|tlz|txz|tZ|tzo|war|xpi|xz|Z|zip)
		# atool --list -- "${FILE_PATH}"
		bsdtar --list --file "${FILE_PATH}"
		exit;;
	rar)
		unrar lt -p- -- "${FILE_PATH}"
		exit;;
	7z)
		7z l -p -- "${FILE_PATH}"
		exit;;
	pdf)
		pdftotext -l 10 -nopgbrk -q -- "${FILE_PATH}" - | fmt -w "${width}"
		exit;;
	json)
		jq --color-output . "${FILE_PATH}"
		exit;;
	htm|html|xhtml)
		w3m -dump "${FILE_PATH}"
		exit;;
esac

mimetype="$( file --dereference --brief --mime-type -- "${FILE_PATH}" )"

case "$mimetype" in
	text/* | */xml)
		bat -f --terminal-width=${width} --style="snip"  "$1"
		exit;;
	image/*)
		# exiftool "${FILE_PATH}"
		chafa --fill=block --symbols=block -s ${width}x"${height}" "${FILE_PATH}"
		exit;;

esac

echo '----- File Type Classification -----' && file --dereference --brief -- "${FILE_PATH}" && exit
