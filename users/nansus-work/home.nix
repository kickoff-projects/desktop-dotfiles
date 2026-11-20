{ lib, pkgs, ... }:

# The work account: common/home.nix plus these. Visuals are the shared
# starlit-sky theme, apart from the neon kakoune override and the waybar
# microphone fix in ./.config (dark GTK/Qt theming lives in common/home.nix
# now, shared by every account). Dotfiles in ./.config (rofi, btop theme,
# fastfetch, zsh prompt, waybar, hypr) layer on top of common/ and
# hostDir/.config.
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
      # Account override, appended after the rendered template. Kakoune's
      # set-face is last-one-wins, so the first seven of these eleven lines
      # replace the ones render-kak-legacy.nix emitted without that
      # template having to change; the last four add faces it never had.
      #
      # Cursor is magenta and the selection is yellow, the reverse of the
      # template's baseAD01/baseAD02 pairing. Not done by swapping palette
      # slots because the template couples PrimaryCursorEol's background
      # and LineNumberCursor to base0A, which this theme spends on types
      # and docstrings - swapping the values there would have turned every
      # type magenta to recolor the end-of-line cursor.
      set-face global PrimaryCursor "%opt{base00},%opt{baseAD02}+b"
      set-face global PrimaryCursorEol "%opt{base00},%opt{baseAD02}"
      set-face global LineNumberCursor "%opt{baseAD02},%opt{base00}+b"
      # Secondary (multi-)cursors take the neighbouring violet, so they
      # read as cursors without being mistaken for the primary one.
      set-face global SecondaryCursor "%opt{base00},%opt{base0E}"
      set-face global SecondaryCursorEol "%opt{base00},%opt{base0E}"
      # Primary selection stays foreground-only, as the template had it -
      # only the hue changes. The secondary one needs a background to be
      # told apart, and base02 is the dark one that leaves the yellow legible.
      set-face global PrimarySelection "%opt{base0A}"
      set-face global SecondarySelection "%opt{base0A},%opt{base02}"
      # Faces the shared common/.config/kak/kakrc references in modelinefmt
      # and in its nix highlighter hook. They postdate
      # render-kak-legacy.nix's frozen body, so they live here rather than
      # in that file. Slots by role, not by slot number: the live template
      # spends base0A on violet, but this palette spends base0A on
      # types/docstrings and on the selections above, so the real violet
      # base0E is used; base09 and base08 are this palette's orange and
      # red, standing in for the live template's baseAD06 and baseAD10.
      set-face global kak_mode_info "%opt{base0E}+i"
      set-face global violet "%opt{base0E}"
      set-face global row_color "%opt{base09}"
      set-face global nix_interp "%opt{base08}"
    '');
}
