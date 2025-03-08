#!/usr/bin/python3
from __future__ import annotations
import requests
import tarfile
from zipfile import ZipFile
import io
import sys
from dataclasses import dataclass
from pathlib import Path

bin_dir = Path(__file__).parent
manpage_dir = Path.home() / '.local/share/man/man.1'
manpage_dir.mkdir(exist_ok=True)

fishcomp_dir = Path.home() / '.local/share/fish/vendor_completions.d'
fishcomp_dir.mkdir(exist_ok=True)


@dataclass
class Pkg:
    name: str
    url: str
    member: str | None = None
    manpage: str | None = None
    fishcomp: str | None = None


pkgs = [
    Pkg('fzf', url='https://github.com/junegunn/fzf/releases/download/v0.58.0/fzf-0.58.0-linux_amd64.tar.gz'),
    Pkg(
        'ruff',
        url='https://github.com/astral-sh/ruff/releases/download/0.9.2/ruff-x86_64-unknown-linux-gnu.tar.gz',
        member='ruff-x86_64-unknown-linux-gnu/ruff',
    ),
    Pkg('lf', url='https://github.com/gokcehan/lf/releases/download/r32/lf-linux-amd64.tar.gz'),
    Pkg(
        'fd',
        url='https://github.com/sharkdp/fd/releases/download/v10.2.0/fd-v10.2.0-x86_64-unknown-linux-gnu.tar.gz',
        member='fd-v10.2.0-x86_64-unknown-linux-gnu/fd',
        manpage='fd-v10.2.0-x86_64-unknown-linux-gnu/fd.1',
        fishcomp='fd-v10.2.0-x86_64-unknown-linux-gnu/autocomplete/fd.fish',
    ),
    Pkg(
        'stylua',
        url='https://github.com/JohnnyMorganz/StyLua/releases/download/v2.0.2/stylua-linux-x86_64-musl.zip',
        member='stylua',
    ),
    Pkg('revive', url='https://github.com/mgechev/revive/releases/download/v1.6.0/revive_linux_amd64.tar.gz'),
    Pkg(
        'delta',
        url='https://github.com/dandavison/delta/releases/download/0.18.2/delta-0.18.2-x86_64-unknown-linux-gnu.tar.gz',
        member='delta-0.18.2-x86_64-unknown-linux-gnu/delta',
    ),
    Pkg('fish', url='https://github.com/fish-shell/fish-shell/releases/download/4.0b1/fish-static-linux-x86_64.tar.xz'),
    Pkg('zigup', url='https://github.com/marler8997/zigup/releases/download/v2025_01_02/zigup-x86_64-linux.tar.gz'),
]

# command: wget -qO- https://github.com/LuaLS/lua-language-server/releases/download/3.13.3/lua-language-server-3.13.3-linux-x64.tar.gz | tar xvz -C ~/.local/bin


for pkg in pkgs:
    if len(sys.argv) > 1:
        if not pkg.name == sys.argv[1]:
            continue
    if (bin_dir / pkg.name).exists():
        print(f'skipping {pkg}')
        continue

    response = requests.get(pkg.url, stream=True)

    if response.status_code == 200:
        file_like_object = io.BytesIO(response.content)
        print('Downloaded file into memory.')
    else:
        print(f'Failed to download file. Status code: {response.status_code}')
        exit()

    if pkg.url.endswith('tar.gz') or  pkg.url.endswith('tar.xz') :
        with tarfile.open(fileobj=file_like_object, mode='r') as tar:
            print(tar.getmembers())
            if pkg.manpage:
                member = tar.getmember(pkg.manpage)
                member.name = Path(pkg.manpage).name
                tar.extract(path=manpage_dir, member=member)
            if pkg.fishcomp:
                member = tar.getmember(pkg.fishcomp)
                member.name = Path(pkg.fishcomp).name
                tar.extract(path=fishcomp_dir, member=member)
            if pkg.member:
                member = tar.getmember(pkg.member)
                member.name = pkg.name
                tar.extract(path=bin_dir, member=member)
            else:
                tar.extractall
                tar.extractall(path=bin_dir)
    elif pkg.url.endswith('zip'):
        with ZipFile(file_like_object, 'r') as myzip:
            myzip.extractall(bin_dir)

    print(f'Extracted to: {bin_dir}')
