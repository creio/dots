import QtQuick 2.7

Item
{
    /* * * * * * * * * * * * * * * * * *
     *
     *  Functions
     *
     * * * * * * * * * * * * * * * * * */

    function cap(str)
    {
        str = str.toLowerCase();

        switch (str)
        {
            case 'upper':
                return Font.AllUppercase;

            case 'lower':
                return Font.AllLowercase;

            case 'smallcaps':
                return Font.SmallCaps;

            case 'capitalize':
                return Font.Capitalize;

            default:
                return Font.MixedCase;
        }
    }


    /* * * * * * * * * * * * * * * * * *
     *
     *  Layer 1 options
     *  Required
     *
     * * * * * * * * * * * * * * * * * */

    property string main: config.font


    /* * * * * * * * * * * * * * * * * *
     *
     *  Layer 2 options
     *  Common
     *
     * * * * * * * * * * * * * * * * * */

    property font slices: Qt.font({
        family:                  config.font_slices             ?        config.font_slices             : config.font,
        pointSize:               config.font_slices_size        ? Number(config.font_slices_size)       : 13,
        bold:           not_null(config.font_slices_bold)       ?   bool(config.font_slices_bold)       : true,
        italic:         not_null(config.font_slices_italic)     ?   bool(config.font_slices_italic)     : false,
        underline:      not_null(config.font_slices_underline)  ?   bool(config.font_slices_underline)  : false,
        capitalization: not_null(config.font_slices_capitalize) ?    cap(config.font_slices_capitalize) : Font.AllUppercase
    });

    property font inputGroup: Qt.font({
        family:                  config.font_input_group             ?        config.font_input_group             : config.font,
        pointSize:               config.font_input_group_size        ? Number(config.font_input_group_size)       : 18,
        bold:           not_null(config.font_input_group_bold)       ?   bool(config.font_input_group_bold)       : false,
        italic:         not_null(config.font_input_group_italic)     ?   bool(config.font_input_group_italic)     : false,
        underline:      not_null(config.font_input_group_underline)  ?   bool(config.font_input_group_underline)  : false,
        capitalization: not_null(config.font_input_group_capitalize) ?    cap(config.font_input_group_capitalize) : Font.MixedCase
    });

    property font listItemBig: Qt.font({
        family:                  config.font_list_item_big             ?        config.font_list_item_big             : config.font,
        pointSize:               config.font_list_item_big_size        ? Number(config.font_list_item_big_size)       : 36,
        bold:           not_null(config.font_list_item_big_bold)       ?   bool(config.font_list_item_big_bold)       : true,
        italic:         not_null(config.font_list_item_big_italic)     ?   bool(config.font_list_item_big_italic)     : false,
        underline:      not_null(config.font_list_item_big_underline)  ?   bool(config.font_list_item_big_underline)  : false,
        capitalization: not_null(config.font_list_item_big_capitalize) ?    cap(config.font_list_item_big_capitalize) : Font.MixedCase
    });

    property font listItemMed: Qt.font({
        family:                  config.font_list_item_med             ?        config.font_list_item_med             : config.font,
        pointSize:               config.font_list_item_med_size        ? Number(config.font_list_item_med_size)       : 28,
        bold:           not_null(config.font_list_item_med_bold)       ?   bool(config.font_list_item_med_bold)       : true,
        italic:         not_null(config.font_list_item_med_italic)     ?   bool(config.font_list_item_med_italic)     : false,
        underline:      not_null(config.font_list_item_med_underline)  ?   bool(config.font_list_item_med_underline)  : false,
        capitalization: not_null(config.font_list_item_med_capitalize) ?    cap(config.font_list_item_med_capitalize) : Font.MixedCase
    });

    property font listItemSub: Qt.font({
        family:                  config.font_list_item_sub             ?        config.font_list_item_sub             : config.font,
        pointSize:               config.font_list_item_sub_size        ? Number(config.font_list_item_sub_size)       : 20,
        bold:           not_null(config.font_list_item_sub_bold)       ?   bool(config.font_list_item_sub_bold)       : false,
        italic:         not_null(config.font_list_item_sub_italic)     ?   bool(config.font_list_item_sub_italic)     : false,
        underline:      not_null(config.font_list_item_sub_underline)  ?   bool(config.font_list_item_sub_underline)  : false,
        capitalization: not_null(config.font_list_item_sub_capitalize) ?    cap(config.font_list_item_sub_capitalize) : Font.MixedCase
    });

    property font error: Qt.font({
        family:                  config.font_error             ?        config.font_error             : config.font,
        pointSize:               config.font_error_size        ? Number(config.font_error_size)       : 18,
        bold:           not_null(config.font_error_bold)       ?   bool(config.font_error_bold)       : true,
        italic:         not_null(config.font_error_italic)     ?   bool(config.font_error_italic)     : false,
        underline:      not_null(config.font_error_underline)  ?   bool(config.font_error_underline)  : false,
        capitalization: not_null(config.font_error_capitalize) ?    cap(config.font_error_capitalize) : Font.MixedCase
    });

    /* * * * * * * * * * * * * * * * * *
     *
     *  Layer 3 options
     *  Control types
     *
     * * * * * * * * * * * * * * * * * */

    // Slices
    property font slicesTop: Qt.font({
        family:                  config.font_slices_top             ?        config.font_slices_top             : slices.family,
        pointSize:               config.font_slices_top_size        ? Number(config.font_slices_top_size)       : slices.pointSize,
        bold:           not_null(config.font_slices_top_bold)       ?   bool(config.font_slices_top_bold)       : slices.bold,
        italic:         not_null(config.font_slices_top_italic)     ?   bool(config.font_slices_top_italic)     : slices.italic,
        underline:      not_null(config.font_slices_top_underline)  ?   bool(config.font_slices_top_underline)  : slices.underline,
        capitalization: not_null(config.font_slices_top_capitalize) ?    cap(config.font_slices_top_capitalize) : slices.capitalization
    });

    property font slicesBottomLeft: Qt.font({
        family:                  config.font_slices_bottom_left             ?        config.font_slices_bottom_left             : slices.family,
        pointSize:               config.font_slices_bottom_left_size        ? Number(config.font_slices_bottom_left_size)       : slices.pointSize,
        bold:           not_null(config.font_slices_bottom_left_bold)       ?   bool(config.font_slices_bottom_left_bold)       : slices.bold,
        italic:         not_null(config.font_slices_bottom_left_italic)     ?   bool(config.font_slices_bottom_left_italic)     : slices.italic,
        underline:      not_null(config.font_slices_bottom_left_underline)  ?   bool(config.font_slices_bottom_left_underline)  : slices.underline,
        capitalization: not_null(config.font_slices_bottom_left_capitalize) ?    cap(config.font_slices_bottom_left_capitalize) : slices.capitalization
    });

    property font slicesBottomRight: Qt.font({
        family:                  config.font_slices_bottom_right             ?        config.font_slices_bottom_right             : slices.family,
        pointSize:               config.font_slices_bottom_right_size        ? Number(config.font_slices_bottom_right_size)       : slices.pointSize,
        bold:           not_null(config.font_slices_bottom_right_bold)       ?   bool(config.font_slices_bottom_right_bold)       : slices.bold,
        italic:         not_null(config.font_slices_bottom_right_italic)     ?   bool(config.font_slices_bottom_right_italic)     : slices.italic,
        underline:      not_null(config.font_slices_bottom_right_underline)  ?   bool(config.font_slices_bottom_right_underline)  : slices.underline,
        capitalization: not_null(config.font_slices_bottom_right_capitalize) ?    cap(config.font_slices_bottom_right_capitalize) : slices.capitalization
    });

    property font slicesLoginButtons: Qt.font({
        family:                  config.font_slices_login_buttons             ?        config.font_slices_login_buttons             : slices.family,
        pointSize:               config.font_slices_login_buttons_size        ? Number(config.font_slices_login_buttons_size)       : slices.pointSize,
        bold:           not_null(config.font_slices_login_buttons_bold)       ?   bool(config.font_slices_login_buttons_bold)       : slices.bold,
        italic:         not_null(config.font_slices_login_buttons_italic)     ?   bool(config.font_slices_login_buttons_italic)     : slices.italic,
        underline:      not_null(config.font_slices_login_buttons_underline)  ?   bool(config.font_slices_login_buttons_underline)  : slices.underline,
        capitalization: not_null(config.font_slices_login_buttons_capitalize) ?    cap(config.font_slices_login_buttons_capitalize) : slices.capitalization
    });

    // Input group
    property font input: Qt.font({
        family:                  config.font_input             ?        config.font_input             : inputGroup.family,
        pointSize:               config.font_input_size        ? Number(config.font_input_size)       : inputGroup.pointSize,
        bold:           not_null(config.font_input_bold)       ?   bool(config.font_input_bold)       : inputGroup.bold,
        italic:         not_null(config.font_input_italic)     ?   bool(config.font_input_italic)     : inputGroup.italic,
        underline:      not_null(config.font_input_underline)  ?   bool(config.font_input_underline)  : inputGroup.underline,
        capitalization: not_null(config.font_input_capitalize) ?    cap(config.font_input_capitalize) : inputGroup.capitalization
    });

    property font loginInput: Qt.font({
        family:                  config.font_login_input             ?        config.font_login_input             : inputGroup.family,
        pointSize:               config.font_login_input_size        ? Number(config.font_login_input_size)       : inputGroup.pointSize,
        bold:           not_null(config.font_login_input_bold)       ?   bool(config.font_login_input_bold)       : true,
        italic:         not_null(config.font_login_input_italic)     ?   bool(config.font_login_input_italic)     : inputGroup.italic,
        underline:      not_null(config.font_login_input_underline)  ?   bool(config.font_login_input_underline)  : inputGroup.underline,
        capitalization: not_null(config.font_login_input_capitalize) ?    cap(config.font_login_input_capitalize) : inputGroup.capitalization
    });

    property font placeholder: Qt.font({
        family:                  config.font_placeholder             ?        config.font_placeholder             : inputGroup.family,
        pointSize:               config.font_placeholder_size        ? Number(config.font_placeholder_size)       : inputGroup.pointSize,
        bold:           not_null(config.font_placeholder_bold)       ?   bool(config.font_placeholder_bold)       : inputGroup.bold,
        italic:         not_null(config.font_placeholder_italic)     ?   bool(config.font_placeholder_italic)     : inputGroup.italic,
        underline:      not_null(config.font_placeholder_underline)  ?   bool(config.font_placeholder_underline)  : inputGroup.underline,
        capitalization: not_null(config.font_placeholder_capitalize) ?    cap(config.font_placeholder_capitalize) : inputGroup.capitalization
    });

}