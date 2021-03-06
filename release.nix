let
  pkgs = import ./nix/default.nix {};
in pkgs.lib.fix (self: {
  inherit (pkgs) crystal;
  inherit (pkgs.packages) cardano-faucet-cr;
  required = pkgs.releaseTools.aggregate {
    name = "required";
    constituents = with self; [
      crystal
      cardano-faucet-cr
    ];
  };
})
