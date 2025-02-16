{ config, lib, pkgs, ... }:
let
  gdk = pkgs.google-cloud-sdk.withExtraComponents [ pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin ];
in
{
  home.stateVersion = "23.11";
  # home.username = "rishi";
  # home.homeDirectory = builtins.toPath "/Users/rishi";

  home.packages = with pkgs; [
    jq
    discord
    watch
    element-desktop
    gh
    gdk
    zathura
    tree
    rectangle
    devenv
    neofetch
    python3Full
    alacritty
    terraform
    spotify
    nixpkgs-fmt
    nixfmt-rfc-style
    zoom-us
    slack
    telegram-desktop
    lua-language-server
    lazygit
    lazydocker
    htop
    direnv
    ripgrep
    discord
    fd
    nixd
    obsidian
    terraform-ls
    pyright
    clang
    clang-tools
    nodejs_22
    awscli2
    zip
    imagemagick
    ffmpeg
    aws-sam-cli
    vscode
    iterm2
  ];

  programs.tmux = {
    enable = true;
    mouse = true;
    plugins = with pkgs; [{ plugin = tmuxPlugins.yank; }];
    extraConfig = ''
      set -g history-limit 30000
      setw -g alternate-screen on
      set -s escape-time 50
      set-option -g default-terminal "tmux-256color"
    '';
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      vim = "nvim";
      tf = "terraform";
      k = "kubectl";
      ls = "ls -F --color=auto";
    };
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "af-magic";
      plugins = [ "git" "z" "direnv" ];
    };
    initExtra = ''
            export LC_ALL=en_US.UTF-8
            export LANG=en_US.UTF-8
      		# Homebrew environment
      		eval "$(/opt/homebrew/bin/brew shellenv)"

    '';
  };

  programs.git = {
    enable = true;
    userName = "Rishi Kumar";
    userEmail = "rsi.dev17@gmail.com";
    ignores = [ "*~" "*.swp" ".vscode" ];
  };

  imports = [
    ./modules/nvim.nix
  ];

  programs.home-manager.enable = true;

}
