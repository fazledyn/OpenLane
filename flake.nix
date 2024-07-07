# Copyright 2024 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
{
  nixConfig = {
    extra-substituters = [
      "https://openlane.cachix.org"
    ];
    extra-trusted-public-keys = [
      "openlane.cachix.org-1:qqdwh+QMNGmZAuyeQJTH9ErW57OWSvdtuwfBKdS254E="
    ];
  };

  inputs = {
    openlane2.url = github:efabless/openlane2/dev;
  };

  outputs = {
    self,
    openlane2,
    ...
  }: let
    nix-eda = openlane2.inputs.nix-eda;
    nixpkgs = openlane2.inputs.nixpkgs;
  in {
    # Outputs
    packages =
      nix-eda.forAllSystems {
        current = self;
        withInputs = [nix-eda openlane2.inputs.libparse openlane2.inputs.volare openlane2];
      } (util:
        with util; let
          self =
            {
              openroad-abc = pkgs.openroad-abc.override {
                # openroad-abc-rev-sha
              };
              opensta = pkgs.opensta.override {
                # opensta-rev-sha
              };
              openroad = pkgs.openroad.override {
                # openroad-rev-sha
                openroad-abc = self.openroad-abc;
                opensta = self.opensta;
              };
              openlane1 = callPythonPackage ./default.nix {};
              default = self.openlane1;
            }
            // (pkgs.lib.optionalAttrs (pkgs.stdenv.isLinux) {
              openlane1-docker = callPackage ./docker/docker.nix {
                createDockerImage = nix-eda.createDockerImage;
              };
            });
        in
          self);

    # devShells = self.forAllSystems (
    #   pkgs: let
    #     callPackage = pkgs.lib.callPackageWith (pkgs // self.packages.${pkgs.system});
    #     callPythonPackage = pkgs.lib.callPackageWith (pkgs // pkgs.python3.pkgs // self.packages.${pkgs.system});
    #   in rec {
    #   }
    # );
  };
}
