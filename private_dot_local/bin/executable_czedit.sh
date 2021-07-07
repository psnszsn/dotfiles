#!/bin/sh

FILE=$(chezmoi managed --exclude dirs| fzf) || exit

chezmoi edit $FILE
