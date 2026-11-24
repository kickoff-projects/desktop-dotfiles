{ lib, pkgs, ... }:

# The work account. It takes common/home.nix and the options below.
# The visual theme is the shared starlit-sky theme. Two files in ./.config
# change it: the neon kakoune override and the waybar microphone fix. The
# dark GTK theme and Qt theme live in common/home.nix, and every account
# shares them.
# The dotfiles in ./.config cover rofi, the btop theme, fastfetch, the zsh
# prompt, waybar and hypr. They go on top of common/ and hostDir/.config.
let
  palettes = import ../../common/palettes.nix;
  renderKak = import ../../common/lib/render-kak-legacy.nix;
in
{
  home.packages = with pkgs; [
    ripgrep

    rustc
    cargo
    rust-analyzer
    clippy
    rustfmt

    uv
    python3

    openconnect
    proton-vpn

    claude-code
  ];

  xdg.configFile."kak/colors/account.kak".text =
    lib.mkForce (renderKak { p = palettes.neon_rainbow.kak; } + ''
      # Account override. Nix adds these lines after the rendered template.
      # The last set-face line wins in Kakoune. The first 7 of these 11 lines
      # therefore replace faces that render-kak-legacy.nix writes, and that
      # template needs no change. The last 4 lines add new faces.
      #
      # The cursor is magenta and the selection is yellow. The template pairs
      # baseAD01 and baseAD02 the other way.
      # These lines do not swap the palette slots. The template ties the
      # background of PrimaryCursorEol and the face LineNumberCursor to
      # base0A. This theme uses base0A for types and docstrings. A swap
      # there makes every type magenta.
      set-face global PrimaryCursor "%opt{base00},%opt{baseAD02}+b"
      set-face global PrimaryCursorEol "%opt{base00},%opt{baseAD02}"
      set-face global LineNumberCursor "%opt{baseAD02},%opt{base00}+b"
      # The secondary cursors take the violet beside the magenta. They then
      # look like cursors, and the user does not read them as the primary
      # cursor.
      set-face global SecondaryCursor "%opt{base00},%opt{base0E}"
      set-face global SecondaryCursorEol "%opt{base00},%opt{base0E}"
      # The primary selection sets the foreground only, like the template.
      # Only the colour changes. The secondary selection needs a background,
      # or the user cannot tell the two apart. base02 is dark enough to keep
      # the yellow readable.
      set-face global PrimarySelection "%opt{base0A}"
      set-face global SecondarySelection "%opt{base0A},%opt{base02}"
      # The shared file common/.config/kak/kakrc uses these 4 faces in
      # modelinefmt and in its nix highlighter hook. The frozen body of
      # render-kak-legacy.nix does not hold them, so they live here.
      # These lines pick slots by role, and not by slot number. The live
      # template uses base0A for violet. This palette uses base0A for types,
      # for docstrings and for the selections above. These lines therefore
      # use the real violet base0E. base09 and base08 are the orange and red of
      # this palette. They take the place of baseAD06 and baseAD10 in the
      # live template.
      set-face global kak_mode_info "%opt{base0E}+i"
      set-face global violet "%opt{base0E}"
      set-face global row_color "%opt{base09}"
      set-face global nix_interp "%opt{base08}"
    '');
}
