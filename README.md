# nix-config guide (macOS + nix-darwin + Home Manager)

This repository defines two separate things:

1. System configuration for macOS through nix-darwin.
2. User configuration through Home Manager.

They are both in one flake, but they are activated by different commands in your current setup.

## Quick command cheat sheet

Run these from this repo directory.

### Darwin (system) target

```bash
sudo darwin-rebuild build --flake .#mac
sudo darwin-rebuild switch --flake .#mac
```

### Home Manager (user) target

```bash
nix build .#homeConfigurations.jamalalkharrat.activationPackage -L
./result/activate
```

or

```bash
nix run github:nix-community/home-manager/release-25.11 -- switch --flake .#jamalalkharrat
```

## 1) What this flake is doing

### Inputs

In flake.nix, these are your dependencies:

- nixpkgs: package collection
- nix-darwin: macOS system module framework
- home-manager: user-level module framework

You also use follows so nix-darwin and home-manager both use the same nixpkgs revision.

### Outputs

Your outputs define two independent targets:

- darwinConfigurations.mac
  - Built from the configuration function in flake.nix.
  - Activated with darwin-rebuild.
- homeConfigurations.jamalalkharrat
  - Built from home.nix.
  - Activated with Home Manager commands (or activation package).

Important: home.nix is NOT currently imported into darwinConfigurations.mac. That means darwin-rebuild alone does not apply your home.nix.

## Syntax walkthrough of your flake.nix

This is the key shape in your file:

```nix
outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, ... }:
let
  configuration = { pkgs, ... }: {
    # module options...
  };
in
{
  darwinConfigurations."mac" = ...;
  homeConfigurations."jamalalkharrat" = ...;
}
```

What each piece means:

- `outputs = ... : ...`
  - `outputs` is a function required by flakes.
  - Nix will call this function and expect an attribute set back (your flake outputs).

- `inputs@{ self, nix-darwin, nixpkgs, home-manager, ... }`
  - This is argument destructuring for a function.
  - `self`, `nix-darwin`, `nixpkgs`, `home-manager` are names pulled from the flake input set.
  - `...` means "and possibly more attributes" (ignore extra ones safely).
  - `inputs@` means "also keep the full original argument set as the name `inputs`".
  - So you get both: individual names and the full set.

- `configuration = { pkgs, ... }: { ... };`
  - Yes, `configuration` is a function.
  - It takes a module argument set (`pkgs` and others) and returns an attribute set of options.
  - That function is later passed to `modules = [ configuration ];` for nix-darwin.

- `let ... in ...`
  - `let` defines local variables/functions.
  - `in` starts the expression that uses those definitions.
  - So here: define `configuration` in `let`, then use it in the output set after `in`.

### Mini syntax notes

- `{ ... }` = attribute set (like a dictionary/object).
- `[ ... ]` = list.
- `name = value;` = bind attribute.
- `arg: body` = function.
- `"mac"` is quoted because the attribute name includes characters that often get quoted for clarity.
- `with pkgs; [ vim ]` means "make names from `pkgs` available in this expression".

## 2) Why Home Manager, Bun, and nh can look missing

You have these modules in home.nix:

- programs.bun.enable = true
- programs.nh.enable = true
- programs.home-manager.enable = true

So bun and nh are expected to come from Home Manager activation.

If Home Manager does not successfully activate, those binaries will not appear in your shell PATH.

One failure mode is Home Manager activation failing while building a dependency (for example direnv):

- direnv build runs tests
- fish test process gets killed (Killed: 9)
- Home Manager generation fails

When activation fails, bun and nh never get linked into your profile.

## 3) Your exact command flow (current architecture)

Run from this repo directory.

### A. Apply macOS system config

```bash
sudo darwin-rebuild switch --flake .#mac
```

This applies only nix-darwin modules from flake.nix.

### B. Apply Home Manager user config

Option 1 (works even if home-manager command is missing):

```bash
nix build .#homeConfigurations.jamalalkharrat.activationPackage -L
./result/activate
```

Option 2 (standalone Home Manager runner):

```bash
nix run github:nix-community/home-manager/release-25.11 -- switch --flake .#jamalalkharrat
```

Note: if B fails, bun and nh will still be missing.

## 4) Fast diagnostics

### See outputs available in the flake

```bash
nix flake show
```

### Try building Home Manager and print logs

```bash
nix build .#homeConfigurations.jamalalkharrat.activationPackage -L
```

### Inspect full failure log for a derivation

```bash
nix log /nix/store/<drv-name>.drv
```

### Check whether commands are in PATH

```bash
command -v home-manager
command -v nh
command -v bun
```

## 5) Why this happened after changes

Common causes:

- A package update in flake.lock changed a dependency behavior.
- A module in home.nix (currently direnv path) now fails to build in your environment.
- Home Manager activation stopped succeeding, so user binaries stopped updating.

## 6) Practical recovery path

1. Temporarily comment out programs.direnv in home.nix.
2. Re-run Home Manager activation.
3. Confirm bun and nh exist.
4. Re-enable direnv and troubleshoot it separately (pin package, override checks, or adjust channel/revision).

## 7) Useful learning links (official)

Core Nix and flakes:

- Nix flakes command reference:
  - https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-flake
- Nix language and docs hub:
  - https://nix.dev/

nix-darwin:

- nix-darwin repository and getting started:
  - https://github.com/nix-darwin/nix-darwin
- nix-darwin manual:
  - https://nix-darwin.github.io/nix-darwin/manual/index.html

Home Manager:

- Home Manager repository:
  - https://github.com/nix-community/home-manager
- Home Manager manual:
  - https://nix-community.github.io/home-manager/
- Home Manager options search:
  - https://home-manager-options.extranix.com/

Nixpkgs package search:

- https://search.nixos.org/packages

## 8) Optional simplification later (one command workflow)

If you want home.nix to be applied together with darwin-rebuild, you can integrate Home Manager as a nix-darwin module inside darwinConfigurations.mac.

Then one command can apply both system and user config:

```bash
sudo darwin-rebuild switch --flake .#mac
```

Your current flake does not do this yet, which is why things feel split.
