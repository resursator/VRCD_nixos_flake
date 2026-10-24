
{
  description = "VR CyberDeck AppImage package for NixOS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      appimage = pkgs.fetchurl {
        url = "https://github.com/DeliciousMeatPop/VRCD/releases/download/v1.8.7/vr-cyberdeck-1.8.7-x86_64.AppImage";
        hash = "sha256-+WFvOdeub36v4H4O+/xKU/0b7tC0sRKGvJR4OPN2JsY=";
      };

      extracted = pkgs.appimageTools.extract {
        pname = "vr-cyberdeck";
        version = "1.8.7";
        src = appimage;
      };

      vr-cyberdeck = pkgs.appimageTools.wrapType2 {
        pname = "vr-cyberdeck";
        version = "1.8.7";
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
          license = pkgs.lib.licenses.agpl3Plus;
          platforms = [ system ];
          mainProgram = "vr-cyberdeck";
        };
      };
    in
    {
      packages.${system} = {
        default = vr-cyberdeck;
        vr-cyberdeck = vr-cyberdeck;
      };

      apps.${system}.default = {
        type = "app";
        program = "${vr-cyberdeck}/bin/vr-cyberdeck";
      };
    };
}
