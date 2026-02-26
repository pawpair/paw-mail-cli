{
  description = "Paw Mail — pre-built binaries for paw-mail-cli, paw-mail-tui, and paw-mail";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      version = (builtins.fromJSON (builtins.readFile ../version.json)).version;
      binariesMeta = (builtins.fromJSON (builtins.readFile ../version.json)).binaries;

      # Map Nix system strings to our arch convention
      archMap = {
        "x86_64-linux" = "x86_64-linux";
        "aarch64-linux" = "aarch64-linux";
        "x86_64-darwin" = "x86_64-darwin";
        "aarch64-darwin" = "aarch64-darwin";
      };

      supportedSystems = builtins.attrNames archMap;

      mkBinaryPackage = { pkgs, system, binaryName }:
        let
          arch = archMap.${system};
          meta = binariesMeta.${binaryName}.${arch};
          src = pkgs.fetchurl {
            url = "https://paw-mail-releases.pawpair.pet/v${version}/${binaryName}-${arch}.tar.gz";
            sha256 = meta.sha256;
          };
        in
        pkgs.stdenv.mkDerivation {
          pname = binaryName;
          inherit version src;

          sourceRoot = ".";

          nativeBuildInputs = pkgs.lib.optionals pkgs.stdenv.isLinux [
            pkgs.autoPatchelfHook
          ];

          # musl static builds should not need runtime deps, but keep this
          # in case we switch to glibc builds in the future
          buildInputs = [ ];

          unpackPhase = ''
            tar xzf $src
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp ${binaryName} $out/bin/${binaryName}
            chmod +x $out/bin/${binaryName}
          '';

          meta = with pkgs.lib; {
            description = "Paw Mail — ${binaryName}";
            homepage = "https://github.com/pawpair/paw-mail-cli";
            license = licenses.mit;
            platforms = [ system ];
            mainProgram = binaryName;
          };
        };
    in
    flake-utils.lib.eachSystem supportedSystems (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages = {
          paw-mail-cli = mkBinaryPackage { inherit pkgs system; binaryName = "paw-mail-cli"; };
          paw-mail-tui = mkBinaryPackage { inherit pkgs system; binaryName = "paw-mail-tui"; };
          paw-mail = mkBinaryPackage { inherit pkgs system; binaryName = "paw-mail"; };
          default = mkBinaryPackage { inherit pkgs system; binaryName = "paw-mail"; };
        };
      }
    );
}
