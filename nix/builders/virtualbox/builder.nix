{ pkgs, arch, dbxRelease, ... }:

let
  vboxFile = pkgs.writeTextFile {
    name = "vbox.nix";
    text = builtins.readFile ./base.nix;
  };

  baseFile = pkgs.writeTextFile {
    name = "base.nix";
    text = builtins.readFile ../../dbx/base.nix;
  };

  dogeboxFile = pkgs.writeTextFile {
    name = "dogebox.nix";
    text = builtins.readFile ../../dbx/dogebox.nix;
  };

  dogeboxdFile = pkgs.writeTextFile {
    name = "dogeboxd.nix";
    text = builtins.readFile ../../dbx/dogeboxd.nix;
  };

  dkmFile = pkgs.writeTextFile {
    name = "dkm.nix";
    text = builtins.readFile ../../dbx/dkm.nix;
  };
in
{
  imports = [ ./base.nix ];

  virtualbox.memorySize = 4096;
  virtualbox.vmDerivationName = "dogebox";
  virtualbox.vmName = "Dogebox";
  virtualbox.vmFileName = "dogebox-${dbxRelease}-${arch}.ova";

  system.activationScripts.copyFiles = ''
    mkdir /opt
    echo "vbox" > /opt/build-type
    cp ${vboxFile} /etc/nixos/configuration.nix
    cp ${baseFile} /etc/nixos/base.nix
    cp ${dogeboxFile} /etc/nixos/dogebox.nix
    cp ${dogeboxdFile} /etc/nixos/dogeboxd.nix
    cp ${dkmFile} /etc/nixos/dkm.nix
  '';
}
