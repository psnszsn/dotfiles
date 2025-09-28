#!/usr/bin/python3
from __future__ import annotations
import requests
import tarfile
from zipfile import ZipFile
import io
import sys
import os
from dataclasses import dataclass
from pathlib import Path

def setup_directories(home_path: Path = None):
    """Setup directory structure based on home path."""
    if home_path is None:
        home_path = Path.home()
    
    bin_dir = home_path / '.local/bin'
    opt_dir = bin_dir / 'opt'
    opt_dir.mkdir(exist_ok=True, parents=True)
    
    manpage_dir = home_path / '.local/share/man/man.1'
    manpage_dir.mkdir(exist_ok=True, parents=True)
    
    fishcomp_dir = home_path / '.local/share/fish/vendor_completions.d'
    fishcomp_dir.mkdir(exist_ok=True, parents=True)
    
    return bin_dir, opt_dir, manpage_dir, fishcomp_dir

# Default setup for when imported as module
bin_dir, opt_dir, manpage_dir, fishcomp_dir = setup_directories()


class Archive:
    """Unified interface for tar and zip archives."""
    
    def __init__(self, file_like_object: io.BytesIO, url: str):
        self.file_like_object = file_like_object
        self.url = url
        self._archive = None
        self._is_tar = url.endswith('tar.gz') or url.endswith('tar.xz')
    
    def __enter__(self):
        if self._is_tar:
            self._archive = tarfile.open(fileobj=self.file_like_object, mode='r')
        else:  # zip
            self._archive = ZipFile(self.file_like_object, 'r')
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        if self._archive:
            self._archive.close()
    
    def list_members(self):
        """List all members in the archive."""
        if self._is_tar:
            return [member.name for member in self._archive.getmembers()]
        else:
            return self._archive.namelist()
    
    def extract_all(self, target_dir: Path):
        """Extract all files to target directory."""
        if self._is_tar:
            print(self._archive.getmembers())
            self._archive.extractall(path=target_dir)
        else:
            print(self._archive.namelist())
            self._archive.extractall(target_dir)
    
    def extract_member(self, member_path: str, target_dir: Path, target_name: str):
        """Extract specific member to target directory with new name."""
        if self._is_tar:
            member = self._archive.getmember(member_path)
            member.name = target_name
            self._archive.extract(path=target_dir, member=member)
        else:
            member_content = self._archive.read(member_path)
            binary_file = target_dir / target_name
            with open(binary_file, 'wb') as f:
                f.write(member_content)
            binary_file.chmod(0o755)  # Make executable


@dataclass
class Pkg:
    name: str
    url: str
    bin: str | None = None
    manpage: str | None = None
    fishcomp: str | None = None
    extract_to_opt: bool = False
    
    def extract(self, file_like_object: io.BytesIO, bin_dir: Path, opt_dir: Path, manpage_dir: Path, fishcomp_dir: Path):
        """Extract the package using the Archive class."""
        with Archive(file_like_object, self.url) as archive:
            # Extract manpage if specified
            if self.manpage:
                archive.extract_member(self.manpage, manpage_dir, Path(self.manpage).name)
            
            # Extract fish completion if specified
            if self.fishcomp:
                archive.extract_member(self.fishcomp, fishcomp_dir, Path(self.fishcomp).name)
            
            if self.extract_to_opt:
                # Extract to opt directory and create symlink
                if not self.bin:
                    raise ValueError(f"bin is required when extract_to_opt=True for package '{self.name}'")
                
                pkg_opt_dir = opt_dir / self.name
                pkg_opt_dir.mkdir(exist_ok=True, parents=True)
                archive.extract_all(pkg_opt_dir)
                
                binary_path = pkg_opt_dir / self.bin
                
                if binary_path and binary_path.exists():
                    symlink_target = bin_dir / self.name
                    symlink_target.symlink_to(binary_path)
                    print(f'Created symlink: {symlink_target} -> {binary_path}')
                else:
                    print(f'Warning: Could not find binary at {binary_path} for {self.name}')
            elif self.bin:
                    archive.extract_member(self.bin, bin_dir, self.name)




pkgs = [
    Pkg('fzf', url='https://github.com/junegunn/fzf/releases/download/v0.58.0/fzf-0.58.0-linux_amd64.tar.gz', bin='fzf'),
    Pkg(
        'ruff',
        url='https://github.com/astral-sh/ruff/releases/download/0.9.2/ruff-x86_64-unknown-linux-gnu.tar.gz',
        bin='ruff-x86_64-unknown-linux-gnu/ruff',
    ),
    Pkg('lf', url='https://github.com/gokcehan/lf/releases/download/r32/lf-linux-amd64.tar.gz', bin='lf'),
    Pkg(
        'fd',
        url='https://github.com/sharkdp/fd/releases/download/v10.2.0/fd-v10.2.0-x86_64-unknown-linux-gnu.tar.gz',
        bin='fd-v10.2.0-x86_64-unknown-linux-gnu/fd',
        manpage='fd-v10.2.0-x86_64-unknown-linux-gnu/fd.1',
        fishcomp='fd-v10.2.0-x86_64-unknown-linux-gnu/autocomplete/fd.fish',
    ),
    Pkg(
        'stylua',
        url='https://github.com/JohnnyMorganz/StyLua/releases/download/v2.0.2/stylua-linux-x86_64-musl.zip',
        bin='stylua',
    ),
    Pkg('revive', url='https://github.com/mgechev/revive/releases/download/v1.6.0/revive_linux_amd64.tar.gz', bin='revive'),
    Pkg(
        'delta',
        url='https://github.com/dandavison/delta/releases/download/0.18.2/delta-0.18.2-x86_64-unknown-linux-gnu.tar.gz',
        bin='delta-0.18.2-x86_64-unknown-linux-gnu/delta',
    ),
    Pkg(
        'fish',
        url='https://github.com/fish-shell/fish-shell/releases/download/4.0b1/fish-static-linux-x86_64.tar.xz',
        bin='fish',
    ),
    Pkg(
        'zigup',
        url='https://github.com/marler8997/zigup/releases/download/v2025_05_24/zigup-x86_64-linux.tar.gz',
        bin='zigup',
    ),
    Pkg(
        'kdlfmt',
        url='https://github.com/hougesen/kdlfmt/releases/download/v0.0.14/kdlfmt-x86_64-unknown-linux-musl.tar.xz',
        bin='kdlfmt-x86_64-unknown-linux-musl/kdlfmt',
    ),
    Pkg('zellij', url='https://github.com/zellij-org/zellij/releases/download/v0.42.1/zellij-x86_64-unknown-linux-musl.tar.gz', bin='zellij'),
    Pkg('terraform-ls', url='https://releases.hashicorp.com/terraform-ls/0.36.5/terraform-ls_0.36.5_linux_amd64.zip', bin='terraform-ls'),
    Pkg('yazi', url='https://github.com/sxyazi/yazi/releases/download/v25.5.31/yazi-x86_64-unknown-linux-gnu.zip', bin='yazi'),
    Pkg(
        'zine',
        url='https://github.com/kristoff-it/zine/releases/download/v0.10.0/x86_64-linux-musl.tar.xz',
        bin='zine',
    ),
    Pkg(
        'luals',
        url='https://github.com/LuaLS/lua-language-server/releases/download/3.13.3/lua-language-server-3.13.3-linux-x64.tar.gz',
        bin='bin/lua-language-server',
        extract_to_opt=True,
    ),
]

# command: wget -qO- https://github.com/LuaLS/lua-language-server/releases/download/3.13.3/lua-language-server-3.13.3-linux-x64.tar.gz | tar xvz -C ~/.local/bin


def install_package(pkg: Pkg, bin_dir: Path, opt_dir: Path, manpage_dir: Path, fishcomp_dir: Path, force: bool = False) -> bool:
    """
    Install a single package.
    
    Args:
        pkg: Package to install
        bin_dir: Binary directory path
        opt_dir: Opt directory path  
        manpage_dir: Man page directory path
        fishcomp_dir: Fish completion directory path
        force: Force installation even if package already exists
        
    Returns:
        True if package was installed, False if skipped
    """
    # Check if binary already exists (either as file or symlink)
    if not force and (bin_dir / pkg.name).exists():
        print(f'skipping {pkg}')
        return False

    response = requests.get(pkg.url, stream=True)

    if response.status_code == 200:
        file_like_object = io.BytesIO(response.content)
        print('Downloaded file into memory.')
    else:
        print(f'Failed to download file. Status code: {response.status_code}')
        return False

    # Use polymorphic extract method with directory parameters
    pkg.extract(file_like_object, bin_dir, opt_dir, manpage_dir, fishcomp_dir)

    if pkg.extract_to_opt:
        print(f'Extracted to: {opt_dir / pkg.name}')
    else:
        print(f'Extracted to: {bin_dir}')
    
    return True


def main(home_path: Path = None, target_pkg: str = None):
    """
    Main function to download and install packages.
    
    Args:
        home_path: Root path for home directory (defaults to Path.home())
        target_pkg: Specific package name to install (installs all if None)
    """
    # Setup directories based on provided home path
    bin_dir, opt_dir, manpage_dir, fishcomp_dir = setup_directories(home_path)
    
    for pkg in pkgs:
        # Filter to specific package if requested
        if target_pkg and pkg.name != target_pkg:
            continue
            
        install_package(pkg, bin_dir, opt_dir, manpage_dir, fishcomp_dir)


if __name__ == '__main__':
    target_package = sys.argv[1] if len(sys.argv) > 1 else None
    main(target_pkg=target_package)
