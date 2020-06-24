import QtQuick 2.7

Item
{
    /* * * * * * * * * * * * * * * * * *
     *
     *  Layer 1 options
     *  Required
     *
     * * * * * * * * * * * * * * * * * */

    // Background
    property color background: config.color_bg

    // Base colors
    property color main: config.color_main
    property color dimmed: config.color_dimmed
    property color contrast: config.color_contrast


    /* * * * * * * * * * * * * * * * * *
     *
     *  Layer 2 options
     *  Common
     *
     * * * * * * * * * * * * * * * * * */

    // Text elements
    property color text:
    {
        if (config.color_text) return config.color_text
        else                   return main
    }
    property color textDimmed:
    {
        if (config.color_text_dimmed) return config.color_text_dimmed
        else                          return dimmed
    } 
    property color textBg: {
        if (config.color_text_bg) return config.color_text_bg
        else                      return Qt.rgba(main.r, main.g, main.b, 0.1)
    }
    property color textHover:
    {
        if (config.color_text_hover) return config.color_text_hover
        else                         return text
    }
    property color textDimmedHover:
    {
        if (config.color_text_dimmed_hover) return config.color_text_dimmed_hover
        else                                return textDimmed
    }
    property color textBgHover:
    {
        if (config.color_text_bg_hover) return config.color_text_bg_hover
        else if (config.color_text_bg)  return config.color_text_bg
        else                            return Qt.rgba(main.r, main.g, main.b, 0.15)
    }

    // Icon elements
    property color icon:
    {
        if (config.color_icon) return config.color_icon
        else                   return text
    }
    property color iconBg:
    { 
        if (config.color_icon_bg) return config.color_icon_bg
        else                      return Qt.rgba(main.r, main.g, main.b, 0.05)
    }
    property color iconHover:
    {
        if (config.color_icon_hover) return config.color_icon_hover
        else if (config.color_icon)  return config.color_icon
        else                         return textHover
    }
    property color iconBgHover:
    {
        if (config.color_icon_bg_hover) return config.color_icon_bg_hover
        else if (config.color_icon_bg)  return config.color_icon_bg
        else                            return Qt.rgba(main.r, main.g, main.b, 0.1)
    }

    // Button text
    property color buttonText:
    {
        if (config.color_button_text) return config.color_button_text
        else                          return contrast
    }
    property color buttonTextHover:
    {
        if (config.color_button_text_hover)     return config.color_button_text_hover
        else                                    return buttonText
    }
    property color buttonTextHighlighted:
    {
        if (config.color_button_text_selected)  return config.color_button_text_selected
        else                                    return contrast
    } 
    property color buttonTextHoverHighlighted:
    {
        if (config.color_button_text_selected_hover) return config.color_button_text_selected_hover
        else                                         return buttonTextHighlighted
    }

    // Button background
    property color buttonBg:
    {
        if (config.color_button_bg) return config.color_button_bg
        else                        return Qt.rgba(dimmed.r, dimmed.g, dimmed.b, 0.9)
    }
    property color buttonBgHover:
    {
        if (config.color_button_bg_hover) return config.color_button_bg_hover
        else if (config.color_button_bg)  return config.color_button_bg
        else                              return dimmed
    }
    property color buttonBgHighlighted:
    {
        if (config.color_button_bg_selected) return config.color_button_bg_selected
        else                                 return Qt.rgba(main.r, main.g, main.b, 0.9)
    } 
    property color buttonBgHoverHighlighted:
    {
        if (config.color_button_bg_selected_hover) return config.color_button_bg_selected_hover
        else if (config.color_button_bg_selected)  return config.color_button_bg_selected
        else                                       return main
    }

    // Progress bar
    property color progressBar:
    {
        if (config.color_progress_bar) return config.color_progress_bar
        else                           return main
    }
    property color progressBarBg: 
    {
        if (config.color_progress_bar_bg) return config.color_progress_bar_bg
        else                              return dimmed
    }


    /* * * * * * * * * * * * * * * * * *
     *
     *  Layer 3 options
     *  Control types
     *
     * * * * * * * * * * * * * * * * * */

    // Error message
    property color errorText:
    {
        if (config.color_error_text) return config.color_error_text
        else                         return text
    }
    property color errorBg:
    {
        if (config.color_error_bg) return config.color_error_bg
        else                       return textBg
    } 

    // Input field
    property color inputText:
    {
        if (config.color_input_text) return config.color_input_text
        else                         return text
    }
    property color inputBg:
    {
        if (config.color_input_bg) return config.color_input_bg
        else                       return textBg
    }
    property color inputPlaceholderText:
    {
        if (config.color_placeholder_text) return config.color_placeholder_text
        else                               return textDimmed
    } 
    property color inputSelectionText:
    {
        if (config.color_selection_text) return config.color_selection_text
        else                             return inputBg
    }
    property color inputSelectionBg:
    {
        if (config.color_selection_bg) return config.color_selection_bg
        else                           return inputText
    }

    // Progress bar
    property color progressBarSlider:
    {
        if (config.color_progress_bar_slider) return config.color_progress_bar_slider
        else                                  return progressBar
    }

} 
