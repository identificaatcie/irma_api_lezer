#!/bin/sh

now="$(date)"
target="$(date -d "$now" +"%a Aug 31 %T %Z %Y")"
target_year=$(date -d "$target" +%Y)

if [ "$(date -d "$now" +%m)" -ge "9" ]; then
    target_year=$((target_year+1))
    target="$(date -d "$now" +"%a Aug 31 %T %Z $target_year")"
fi

echo $(( ($(date -d "$target" +%s) - $(date -d "$now" +%s)) /86400 ))
