{ pkgs, lib,  ... }:

{

 # The tools for a Roccat keyboard and mouse. Each host file imports this
 # module as a commented line, so no machine installs it today.
 environment.systemPackages = with pkgs; [
   roccat-tools
 ]; 

}
