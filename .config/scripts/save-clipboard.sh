#!/bin/bash

clipboard_filetype=$(wl-paste --list-types)

if [[ -z ${clipboard_filetype} ]] || grep -q nothing <<< $clipboard_filetype; then
    notify-send -a "Clipboard saver" "Error: clipboard is empty."
    exit 1
fi

formats=$(echo ${clipboard_filetype} | grep -E '^image/' || true)

if [ -z "$formats" ]; then
    notify-send -a "Clipboard saver" "Error: clipboard content is not an image."
    exit 1
fi

# I ditched text dump support for now. Unsure I will need it at all
# if echo ${clipboard_filetype} | grep -q image; then
#     filename=$(rofi -dmenu -p "Save image as" -theme-str 'entry { placeholder: "filename.png"; }')
#     formats=$(echo ${clipboard_filetype} | grep -E '^image/' || true)
# elif echo "${clipboard_filetype}" | grep -q text; then
#     filename=$(rofi -dmenu -p "Save text as" -theme-str 'entry { placeholder: "plaintext.txt"; }')
#     wl-paste | echo
# else
#     notify-send -a "Clipboard saver" "Error: unsupported media type"
#     exit 1
# fi

filename=$(rofi -dmenu -l 0 -font "JetBrainsMonoNF 14" -p " Save image as" -theme-str 'entry { placeholder: "folder/filename.png"; }' -theme-str 'window { border-radius: 14px; width: 25%; }')

[ -z "$filename" ] && exit 0

priority_order=(
    image/png
    image/jpeg
    image/jpg
    image/webp
    image/tiff
    image/bmp
    image/gif
    image/svg+xml
    image/x-xpixmap
)

selected_mime=""
for mime in "${priority_order[@]}"; do
    if grep -q "$mime" <<< $formats; then
        selected_mime="$mime"
        break
    fi
done

[ -z "$selected_mime" ] && selected_mime=$(head -1 <<< "$formats")

# Map MIME types to extensions
declare -A mime_to_ext=(
    [image/png]="png"
    [image/jpeg]="jpg"
    [image/jpg]="jpg"
    [image/webp]="webp"
    [image/gif]="gif"
    [image/bmp]="bmp"
    [image/tiff]="tiff"
    [image/svg+xml]="svg"
    [image/x-xpixmap]="xpm"
)

# Get extension
extension=${mime_to_ext[$selected_mime]}
if [ -z "$extension" ]; then
    extension=$(awk -F/ '{print $2}' <<< "$selected_mime" | sed 's/[^a-zA-Z0-9]//g')
    [ -z "$extension" ] && extension="unknown_img"
fi

# Process filename
case $filename in
    /*) fullpath="$filename" ;;
    *)  fullpath="Pictures/$filename" ;;
esac

# Remove existing image extensions
if [[ "$(basename "$fullpath")" =~ \.(png|jpg|jpeg|webp|gif|bmp|tiff|svg|xpm)$ ]]; then
    fullpath="${fullpath%.*}"
fi

# Append extension
fullpath="${fullpath}.${extension}"

# Save and notify
mkdir -p "$(dirname "$fullpath")"
wl-paste -t "$selected_mime" > "$fullpath" && \
    notify-send -a "Clipboard saver" "Success: clipboard image saved" "Saved clipboard image to $fullpath." --icon="$fullpath" || \
    notify-send -a "Clipboard saver" "Error: failed to save clipboard image." "Could not save clipboard image to $fullpath due to unknown error."
