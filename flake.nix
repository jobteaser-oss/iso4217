{
  description = "iso4217 – local development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-ruby = {
      # exact Ruby patch versions not always in nixpkgs
      url = "github:bobvanderlinden/nixpkgs-ruby";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-ruby,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };

        rubyVersion = pkgs.lib.trim (builtins.readFile ./.ruby-version);
        ruby = nixpkgs-ruby.packages.${system}."ruby-${rubyVersion}";

        # Node is only pulled in when the repo actually has a JS toolchain.
        nodeDeps = pkgs.lib.optionals (builtins.pathExists ./package.json) [ pkgs.nodejs ];
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs =
            with pkgs;
            [
              ruby # version read from .ruby-version

              # build toolchain for native gem extensions
              pkg-config
              gnumake
              cmake

              # core C libs the common JobTeaser gem set links against
              openssl # grpc, aws-sdk, net-http …
              libyaml # psych/psych_ext (mandatory on macOS M1+)
              readline # irb/pry
              libffi # ffi gem
              zlib
              gmp # bigdecimal

              postgresql # pg
              rdkafka # rdkafka-ruby
              snappy # rdkafka compression
              libxml2 # nokogiri
              libxslt # nokogiri
              protobuf # grpc / google-protobuf

              git
              jq
            ]
            ++ nodeDeps;

          # grpc: ARM64/macOS linker rejects undefined symbols by default;
          # dynamic_lookup defers them to runtime (Linux behaviour).
          BUNDLE_BUILD__GRPC = pkgs.lib.optionalString pkgs.stdenv.isDarwin "--with-ldflags=-Wl,-undefined,dynamic_lookup";

          # nokogiri: use Nix libxml2/libxslt instead of bundling its own.
          BUNDLE_BUILD__NOKOGIRI =
            "--use-system-libraries"
            + " --with-xml2-include=${pkgs.libxml2.dev}/include/libxml2"
            + " --with-xml2-lib=${pkgs.libxml2.out}/lib"
            + " --with-xslt-include=${pkgs.libxslt.dev}/include"
            + " --with-xslt-lib=${pkgs.libxslt.out}/lib";

          # snappy: point rdkafka-ruby's native ext at the Nix snappy.
          BUNDLE_BUILD__SNAPPY = "--with-ldflags=-L${pkgs.snappy}/lib --with-cppflags=-I${pkgs.snappy}/include";

          OPENSSL_DIR = "${pkgs.openssl.dev}";
          OPENSSL_LIB_DIR = "${pkgs.openssl.out}/lib";
          OPENSSL_INCLUDE_DIR = "${pkgs.openssl.dev}/include";
          LIBYAML_PREFIX = "${pkgs.libyaml}";

          shellHook = ''
            # Shared, Ruby-version-keyed gem home: projects on the same Ruby share one gem
            # store (deduped), nested under ~/.gems so it doesn't scatter $HOME. Native
            # extensions stay compatible because the flake pins exactly one Ruby per version.
            export GEM_HOME="$HOME/.gems/ruby-${rubyVersion}"
            export GEM_PATH="$GEM_HOME"
            export PATH="$GEM_HOME/bin:$PWD/bin:$PATH"
            mkdir -p "$GEM_HOME"

            # Editor tooling (replaces asdf's ~/.default-gems): install once into GEM_HOME.
            if ! gem list -i ruby-lsp >/dev/null 2>&1; then
              gem install --no-document ruby-lsp standard >/dev/null 2>&1 || true
            fi

            echo "iso4217 dev shell — ruby $(ruby --version | cut -d' ' -f2)"
          '';
        };
      }
    );
}
