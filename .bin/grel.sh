#!/bin/bash

tag_name="$1"
target_name="$2"
asset_dir="./"
cr_date=$(date +%Y%m%d)

assets=()
for f in "$asset_dir"/*; do [ -f "$f" ] && assets+=(-a "$f"); done

hub release create "${assets[@]}" -m "Release $tag_name $cr_date" -t "$target_name" "$tag_name"

hub release edit -m "Release $tag_name $cr_date

https://ctlos.github.io/wiki/changelog/" "$tag_name"
