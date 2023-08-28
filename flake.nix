{

  description = "A collection of nix flake templates for development environmets";

  outputs = { self, nixpkgs }:
    {
      templates = {
        go-dev = {
          path = ./nix/templates/dev/go;
          description = "Go dev environment";
        };
      };
    };
}
