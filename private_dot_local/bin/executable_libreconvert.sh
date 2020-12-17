#!/bin/bash
## zaread - a simple script created by paoloap.

# default variables
tmpdir=/tmp/conv

mkdir -p $tmpdir

# if no arguments exit.
if [[ -z $@ ]]; then exit 1; fi


filepath=$(readlink -f "$@")
filename=$(basename "${filepath}")


pdffile=${tmpdir}/${filename%.*}.pdf
check=$(md5sum "$filepath" | awk '{print $1}' )
# if pdf version hasn't ever been created, or it changed, then
# make conversion and store the checksum.
if [[ (! -f $pdffile) || ( $check != $(cat "${pdffile}.md5")) ]]; then 

    echo $check > "${pdffile}.md5"
    command -v soffice && soffice --convert-to pdf "${filepath}" --headless --outdir ${tmpdir} 
    # flatpak info org.libreoffice.LibreOffice && flatpak run --command=/app/libreoffice/program/soffice org.libreoffice.LibreOffice --convert-to pdf ${filepath} --headless --outdir ${tmpdir} 

fi

rifle "$pdffile"


