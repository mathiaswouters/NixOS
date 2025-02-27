# NixOS

---

Explanation ...

Search Nix packages using this [link](https://search.nixos.org/packages)

---

## ...

## Installation

### Prepare installation media

- Download NixOS ISO (GNOME): [nixos.org](https://nixos.org/download/)

### Install NixOS

1. **Welcome**:
   - Change **language** to `American English`
   - Press `Next`
2. **Location**:
   - Change **Region** to `Europe`
   - Change **Zone** to `Brussels`
   - Change **system language** to `American English (United States) - en_US.UTF-8`
   - Change **number and dates locale** to `Nederlands (Belgie) - nl_BE.UTF-8`
   - Press `Next`
3. **Keyboard**:
   - Change **Keyboard** to `English (US)`
   - Press `Next`
4. **Users**:
   - Enter **name**
   - Enter **log in name**
   - Enter **password**
   - Check the `Use the same password for the administrator account.` box
   - Press `Next`
5. **Desktop**:
   - Select `No desktop`
   - Press `Next`
6. **Unfree Software**:
   - Check the `Allow unfree software` box
   - Press `Next`
7. **Partitions**:
   - Partition the disk
   - Press `Next`
8. **Summary**:
   - Press `Install`
9. **Install**:
   - Press `Next`
10. **Finish**:
    - Press `Done`
    - Shutdown system

### Configure NixOS

- Configure NixOS Config file: `sudo nano /etc/nixos/configuration.nix`

### Rebuild NixOS

- `sudo nixos-rebuild switch`

### Nix flakes
...

### Nix Home Manager
...
