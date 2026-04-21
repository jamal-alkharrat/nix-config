# SOPS + age + Home Manager Setup (nix-darwin)

This document describes a minimal setup to manage secrets using `sops-nix` with `age` on macOS with nix-darwin + Home Manager.

## Requirements

Add to your `flake.nix`:

```nix
{
  inputs = {
    # other inputs
    sops-nix.url = "github:Mic92/sops-nix";
  };

    outputs = {
        sops-nix,
        # other inputs
        }:
    let
        # other variables
    in {
        darwinConfigurations = {
            # other configurations
            modules = [
                {
                    # Expose sops options inside Home Manager modules.
                    home-manager.sharedModules = [ sops-nix.homeManagerModules.sops ];
                }
                # other modules
                sops-nix.darwinModules.sops
            ];
        };
    };
}
```

Add `sops` and `age` to your system:

```nix
home.packages = [
  pkgs.sops
  pkgs.age
];
```

Apply:

```bash
home-manager switch
```

Or by rebuilding the whole system:

```bash
sudo darwin-rebuild switch --flake .
```

## Generate age key (your identity)

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
```

Get public key:

```bash
age-keygen -y ~/.config/sops/age/keys.txt
```

Save the output (starts with `age1...`).

## Create `.sops.yaml` if missing and add public key

```yaml
keys:
  - &me age1YOUR_PUBLIC_KEY_HERE

creation_rules:
  - path_regex: secrets/.*\.yaml$
    key_groups:
      - age:
          - *me
```

## Create secrets folder

```bash
mkdir -p secrets
```

Add a plaintext file (NOT committed):

```bash
secrets/plain.yaml
```

Example:

```yaml
api_key: "my-secret"
```

Add to `.gitignore`:

```
secrets/plain.yaml
```

## Create encrypted secrets file

### Option A (recommended)

```bash
sops -e secrets/plain.yaml > secrets/secrets.yaml
```

### Option B (interactive)

```bash
sops secrets/secrets.yaml
```

## Edit secrets later

```bash
sops secrets/secrets.yaml
```

## Add new key / new machine

### Step 1: update `.sops.yaml`

Add new public key:

```yaml
keys:
  - &me age1...
  - &laptop age1NEWKEY...
```

### Step 2: update encrypted file

```bash
sops updatekeys secrets/secrets.yaml
```

## Use in Home Manager

```nix
{ config, ... }:

{
  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

  sops.secrets.api_key = {};

  home.sessionVariables = {
    # Set the path to your age key file so you can use sops in the terminal without issues.
    SOPS_AGE_KEY_FILE = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    # Load secrets into environment variables 
    # The secret.path is the path to the secret in the encrypted file, e.g. secrets.yaml
    # The value will be loaded into the environment variable API_KEY
    API_KEY = "$(cat ${config.sops.secrets.api_key.path})";
  };
}
```

## Key concepts

- `.sops.yaml` → defines who can decrypt
- `age key` → your identity (private key)
- `secrets.yaml` → encrypted file in Git
- `plain.yaml` → local unencrypted input (optional)

## Important notes

- Do NOT commit `keys.txt`
- Backup `~/.config/sops/age/keys.txt` or store it in a password manager
- If you lose it → you lose access to secrets
- Restart shell after changes
