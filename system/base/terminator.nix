{ pkgs, ... }:

{

# The terminator terminal. Each host file imports this module as a
# commented line, so no machine installs it today.
environment.systemPackages = with pkgs; [
  terminator
];

}

