# Renders a common/palettes.nix "foot" sub-palette into foot's colors.ini.
{ p }:
''
# -*- conf -*-
# Terminal colors, generated from common/palettes.nix - see
# common/lib/render-foot-colors.nix. Included from common/.config/foot/foot.ini.

[colors-dark]
cursor=${p.cursor}

background=${p.background}
foreground=${p.foreground}

regular0=${p.regular0}
regular1=${p.regular1}
regular2=${p.regular2}
regular3=${p.regular3}
regular4=${p.regular4}
regular5=${p.regular5}
regular6=${p.regular6}
regular7=${p.regular7}

bright0=${p.bright0}
bright1=${p.bright1}
bright2=${p.bright2}
bright3=${p.bright3}
bright4=${p.bright4}
bright5=${p.bright5}
bright6=${p.bright6}
bright7=${p.bright7}
''
