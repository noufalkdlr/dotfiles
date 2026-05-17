#!/usr/bin/env python3
import os
import subprocess
import shutil


# Function to run commands securely
def run_command(command, use_shell=False, input_file=None):
    try:
        if input_file:
            with open(input_file, "r") as f:
                subprocess.run(command, check=True, stdin=f)
        else:
            subprocess.run(command, check=True, shell=use_shell)
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {e}")
        exit(1)


print("Checking for base-devel and git... 📦")
# 1. Install prerequisites
run_command(["sudo", "pacman", "-S", "--needed", "--noconfirm", "base-devel", "git"])

print("Cloning yay... ⬇️")
# Switch to Home folder (Safe Place to clone)
home_dir = os.path.expanduser("~")
os.chdir(home_dir)

# 2. Clone yay
if os.path.exists("yay"):
    shutil.rmtree("yay")  # Remove if it already exists to avoid errors
run_command(["git", "clone", "https://aur.archlinux.org/yay.git"])

# 3. Build yay
os.chdir("yay")
print("Building yay... 🔨")
run_command(["makepkg", "-si", "--noconfirm"])

# 4. Cleanup
print("Cleaning up... 🧹")
os.chdir(home_dir)
shutil.rmtree("yay")  # Delete the yay source folder

# 5. Install AUR Packages
dotfiles_dir = os.path.expanduser("~/dotfiles")
pkglist_path = os.path.join(dotfiles_dir, "aur-pkglist.txt")

if os.path.exists(pkglist_path):
    print("Installing AUR packages from list... 📄")
    # Read aur-pkglist.txt and pass it to yay
    run_command(["yay", "-S", "--needed", "--noconfirm", "-"], input_file=pkglist_path)
else:
    print("Warning: aur-pkglist.txt not found! ❌")

print("Yay setup complete! 🎉")
