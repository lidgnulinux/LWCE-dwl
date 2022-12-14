#!/usr/bin/env bash
# Variables
declare output title layout activetags selectedtags
declare -a tags name
readonly fname=/home/ahmad/.cache/dwltags


_cycle() {
  tags=( "1" "2" "3" "4" "5" "6" "7" "8" "9" )

  # Name of tag (optional)
  # If there is no name, number are used
  #
  # Example:
  #  name=( "" "" "" "Media" )
  #  -> return "" "" "" "Media" 5 6 7 8 9)
  name=()

  for tag in "${!tags[@]}"; do
    mask=$((1<<tag))

    tag_name="tag"
    declare "${tag_name}_${tag}"
    name[tag]="${name[tag]:-${tags[tag]}}"

    printf -- '%s\n' "${tag_name}_${tag}|string|${name[tag]}"

    if (( "${selectedtags}" & mask )) 2>/dev/null; then
      printf -- '%s\n' "${tag_name}_${tag}_focused|bool|true"
      printf -- '%s\n' "title|string|${title}"
    else
      printf '%s\n' "${tag_name}_${tag}_focused|bool|false"
    fi

    if (( "${activetags}" & mask )) 2>/dev/null; then
      printf -- '%s\n' "${tag_name}_${tag}_occupied|bool|true"
    else
      printf -- '%s\n' "${tag_name}_${tag}_occupied|bool|false"
    fi
  done

  printf -- '%s\n' "layout|string|${layout}"
  #printf -- '%s\n' "title|string|${title}"
  printf -- '%s\n' ""

}

# Call the function here so the tags are displayed at dwl launch
_cycle

while true; do

  [[ ! -f "${fname}" ]] && printf -- '%s\n' \
      "You need to redirect dwl stdout to ~/.cache/dwltags" >&2

  inotifywait -qq --event modify "${fname}"

  # Get info from the file
  # output="$(tail -n6 "${fname}")"
  output="$(tail -n6 "${fname}")"
  title="$(echo "${output}" | grep title | cut -d ' ' -f 3- )"
  #selmon="$(echo "${output}" | grep 'selmon')"
  layout="$(echo "${output}" | grep layout | cut -d ' ' -f 3- )"

  # Get the tag bit mask as a decimal
  activetags="$(echo "${output}" | grep tags | awk '{print $3}')"
  selectedtags="$(echo "${output}" | grep tags | awk '{print $4}')"

  _cycle

done

unset -v output title layout activetags selectedtags
unset -v tags name

