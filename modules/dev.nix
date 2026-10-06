{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vscode
    rustup
    gcc
  ];

  users.users.diskutabel.packages = with pkgs; [
    jetbrains.idea
    nodejs_22
    claude-code
    pince
  ];
}
