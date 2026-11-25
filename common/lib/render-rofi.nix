# This makes the account.rasi theme file of rofi from a "rofi" sub-palette in
# common/palettes.nix.
#
# Every value is a bare hex string without the "#" prefix. This template adds
# the prefix. rasi reads a hex colour as #RRGGBB or #RRGGBBAA, so an alpha
# byte comes last. common/lib/render-kdeglobals.nix uses the other byte
# order.
{ p }:
''
/* Pastel rainbow palette. common/lib/render-rofi.nix makes this file from
 * common/palettes.nix. config.rasi holds @theme "account.rasi", which is the
 * only line that points here.
 * The account layer (users/<name> or a host layer) replaces this file with a
 * real file of the same name to switch the look of rofi. */
* {
    background:     #${p.background};
    background-alt: #${p.backgroundAlt};
    foreground:     #${p.foreground};
    selected:       #${p.selected};
    emerald:        #${p.emerald};
    selected-text:  #${p.selectedText};
    window-border:  #${p.windowBorder};
    prompt-color:   #${p.prompt};
    urgent:         #${p.urgent};
    active:         #${p.active};

    background-color: @background;
    text-color:        @foreground;
}

window {
    border:        2px;
    border-color:  @window-border;
    border-radius: 10px;
    width:         30%;
}

mainbox {
    children: [ inputbar, listview ];
}

inputbar {
    children: [ prompt, entry ];
    background-color: @background-alt;
    border-radius: 8px;
    padding: 8px;
}

entry {
    text-color: @foreground;
}

prompt {
    text-color: @prompt-color;
}

listview {
    lines: 8;
    spacing: 4px;
}

element {
    padding: 4px 6px;
    border-radius: 6px;
}

/* The "*" block above gives every widget the window background. The text
 * child of a row would therefore paint black over the fill of the current
 * row. These two children stay clear and take the colour of the row. */
element-text, element-icon {
    background-color: transparent;
    text-color:       inherit;
}

/* The current row carries the window background, so a 3px emerald outline
 * and the inverse text colour are the only marks of it. */
element selected {
    background-color: @selected;
    border:           3px;
    border-color:     @emerald;
    text-color:       @selected-text;
}

element urgent {
    text-color: @urgent;
}

element active {
    text-color: @active;
}
''
