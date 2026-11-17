{ pkgs, ... }:

# The leisure account: common/home.nix plus these. Its own dotfiles (if any)
# are in ./.config, layered on top of hostDir/.config and common/.config.
{
  home.packages = with pkgs; [
    gh
    git
    ripgrep
    btop
    librespeed-cli
    unzip
    uv
    net-tools
    vim
    neovim

    discord
    spotify
    prismlauncher
    freecad
    qemu
    libreoffice-qt
    kdePackages.dolphin
    proton-vpn
    openconnect
    feh
    claude-code
  ];
}
