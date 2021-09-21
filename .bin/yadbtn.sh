#!/bin/bash
# https://github.com/cjungmann/yaddemo/blob/master/yadbuttons

simple_dialog()
{
		yad
		exval=$?
		case $exval in
				1) echo "You pressed Cancel.";;
				0) echo "You pressed OK.";;
		esac
}

announce()
{
		# yad commands should be on a single line, so escape line breaks with a trailing backslash
		yad --title="YAD Announce" --center --borders=20 --button="Done" \
				--text="You pressed the Announce Key and called function announce."
}

custom_dialog_buttons()
{
		cmd=(
				yad --center --borders=20
				--title="YAD Custom Dialog Buttons"
				--button="Browse":"firefox"
				--button="Annonuce":"bash -c announce"
				--button="Exit"
		)

		"${cmd[@]}"
}

too_many_dialog_buttons()
{
		cmd=(
				yad --center --borders=20
				--title="YAD Custom Dialog Buttons"
				--button="Browse":"firefox"
				--button="Annonuce":"bash -c announce"
				--button="Exit"
				--button="Extra Button"
				--button="Super-extra Button"
				--button="Supercalifragilisticexpialidocious Button"
		)

		"${cmd[@]}"
}

form_buttons()
{
		cmd=(
				yad --center --borders=20
				--title="YAD Form Using Buttons"
				--form
				--field="Browse":btn "firefox"
				--field="Announce":btn "bash -c announce"
		)

		"${cmd[@]}"

}

using_common_args()
{
		mapfile -t lcomargs < <( printf "%s" "${COMARGS}" | xargs -n 1 printf "%s\n" )
		yad "${lcomargs[@]}" --text="Demonstration of using exported common arguments."
}



cmdmain=(
	 yad
	 --center --width=400
	 --image="gtk-dialog-info"
	 --title="YAD Button Examples"
	 --text="Click a link to see a demo."
	 --button="Exit":1
	 --form
			--field="Simple Dialog":btn "bash -c simple_dialog"
			--field="Custom Dialog Buttons":btn "bash -c custom_dialog_buttons"
			--field="Too Many Dialog Buttons":btn "bash -c too_many_dialog_buttons"
			--field="Using Form Buttons":btn "bash -c form_buttons"
			--field="Using Common Arguments":btn "bash -c using_common_args"

)

export -f simple_dialog
export -f announce
export -f custom_dialog_buttons
export -f too_many_dialog_buttons
export -f form_buttons
export -f using_common_args


while true; do
		"${cmdmain[@]}"
		exval=$?
		case $exval in
				1|252) break;;
		esac
done

unset simple_dialog
unset announce
unset custom_dialog_buttons
unset too_man_dialog_buttons
unset form_buttons
unset using_common_args
