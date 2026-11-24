# This makes the colors.ini file of foot from a "foot" sub-palette in
# common/palettes.nix.
{ p }:
''
# -*- conf -*-
# Terminal colors. common/lib/render-foot-colors.nix makes this file from
# common/palettes.nix. The file .config/foot/foot.ini of each host includes
# it. Those hosts are hosts/desktop, hosts/laptop and hosts/server.

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
