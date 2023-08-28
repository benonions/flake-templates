{
  description = "Comprehensive Go development environment";

  # Flake inputs
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs"; # also valid: "nixpkgs"
  };

  # Flake outputs
  outputs = { self, nixpkgs }:
    let
      # Systems supported
      allSystems = [
        "x86_64-linux" # 64-bit Intel/AMD Linux
        "aarch64-linux" # 64-bit ARM Linux
        "x86_64-darwin" # 64-bit Intel macOS
        "aarch64-darwin" # 64-bit ARM macOS
      ];

      # Helper to provide system-specific attributes
      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      # Development environment output
      devShells = forAllSystems ({ pkgs }: {
        default = pkgs.mkShell {
          # The Nix packages provided in the environment
          packages = with pkgs; [
            go
            gotools # Go tools like godoc, etc.
            delve # Go debugger
            protobuf # Protocol Buffers compiler
            golangci-lint # Linter for Go
          ];

          # Shell hook to install Go tools and add bash aliases and scripts
          shellHook = ''
            go install github.com/vektra/mockery/v2@v2.32.4
            go install golang.org/x/tools/cmd/goimports@latest
            go install mvdan.cc/gofumpt@latest
            
            run_tests() {
              go test -coverprofile=coverage.out ./...
              go tool cover -html=coverage.out -o coverage.html
            }

            # Write the golangci-lint config file
            cat > .golangci-lint.yaml <<EOF
            run: 
              tests: true
            linters-settings:
              errcheck:
                check-type-assertions: true
                check-blank: true
              gocyclo:
                min-complexity: 20
              dupl:
                threshold: 100
              misspell:
                locale: US
              unused:
                check-exported: false
              unparam:
                check-exported: true

            linters:
              enable:
                - govet
                - golint
                - gocyclo
                - maligned
                - depguard
                - dupl
                - goconst

            run:
              timeout: 1m
            EOF

            # Write the mockery config file
            cat > config.yaml <<EOF
            output:
              filename: mocks.go
              dir: mocks
            case: snake
            all: true
            keep-tree: true
            EOF
          '';
        };
      });
    };
}

