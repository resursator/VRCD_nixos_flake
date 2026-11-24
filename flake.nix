{
  description = "VR CyberDeck AppImage package for NixOS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs = { self, nixpkgs }:
    let
      lib = nixpkgs.lib;

      version = "2.0.1";

      mkPackage = system:
        let
          pkgs = import nixpkgs { inherit system; };

          isArm = system == "aarch64-linux";
          arch = if isArm then "arm64" else "x86_64";

          appimage = pkgs.fetchurl {
            url = "https://github.com/DeliciousMeatPop/VRCD/releases/download/v${version}/vr-cyberdeck-${version}-${arch}.AppImage";
            hash = if isArm then
              "sha256-25iU/Hz2zmEnf1xeZ4lPaU6o6pykztii9lCTxJtUCx4="
            else
              "sha256-LCllpjRTX5OV1PCn5OgvBskRR4QB74/aRulKviyW4+8=";
          };

          extracted = pkgs.appimageTools.extract {
            pname = "vr-cyberdeck";
            inherit version;
            src = appimage;
          };
        in
        pkgs.appimageTools.wrapType2 {
          pname = "vr-cyberdeck";
          inherit version;
          src = appimage;

          extraPkgs = pkgs: with pkgs; [
            android-tools
            p7zip
          ];

          extraInstallCommands = ''
            install -Dm644 \
              ${extracted}/resources/app.asar.unpacked/resources/icon.png \
              $out/share/icons/hicolor/512x512/apps/vr-cyberdeck.png

            mkdir -p $out/share/applications

            cat > $out/share/applications/vr-cyberdeck.desktop <<EOF
            [Desktop Entry]
            Name=VR CyberDeck
            Comment=Android and Meta Quest sideloading tool
            Exec=vr-cyberdeck
            Terminal=false
            Type=Application
            Categories=Utility;
            Icon=vr-cyberdeck
            EOF
          '';

          meta = {
            description = "Android and Meta Quest sideloading tool";
            homepage = "https://github.com/DeliciousMeatPop/VRCD";
            license = lib.licenses.agpl3Plus;
            platforms = [ system ];
            mainProgram = "vr-cyberdeck";
          };
        };

      systems = [ "x86_64-linux" "aarch64-linux" ];
      eachSystem = lib.genAttrs systems;
    in
    {
      packages = eachSystem (system: {
        default = mkPackage system;
        vr-cyberdeck = mkPackage system;
      });

      apps = eachSystem (system: {
        default = {
          type = "app";
          program = "${mkPackage system}/bin/vr-cyberdeck";
        };
      });
    };
}
