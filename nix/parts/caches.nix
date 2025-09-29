# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
_: {
  flake.nixConfig = {
    # Enhanced substituters for better performance
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      # Add more specific caches for dependencies
      "https://devenv.cachix.org"
      "https://pre-commit-hooks.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16EGsB+7Ra0/Rdk8="
      "nix-community.cachix.org-1:mNRHBjxp3KqFYXrq6Q1LWuwYJECJRobOQ1d4Kd3v8M="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
    ];
    
    # Performance optimizations
    max-jobs = "auto";
    cores = 0;
    
    # Build optimization settings
    keep-outputs = true;
    keep-derivations = true;
    
    # Network and download optimizations
    connect-timeout = 5;
    stalled-download-timeout = 90;
    download-attempts = 3;
    
    # Evaluation optimizations  
    eval-cache = true;
    
    # Build log optimization
    log-lines = 25;
  };
}
