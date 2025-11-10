#!/usr/bin/env python3
"""Minimal bootstrap script to download and install hpk from OCI registry."""
import os, sys, platform, urllib.request, json, struct, zlib
from pathlib import Path

REGISTRY, NAMESPACE = "ghcr.io", "psnszsn/hpkrepo"

def get_platform():
    os_name, machine = platform.system().lower(), platform.machine().lower()
    arch = {"x86_64": "x86_64", "amd64": "x86_64", "aarch64": "aarch64", "arm64": "aarch64"}.get(machine)
    if not arch: sys.exit(f"Unsupported architecture: {machine}")
    return f"{os_name}-{arch}"

def fetch_json(url, headers):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=headers)) as r:
            return json.loads(r.read())
    except urllib.error.HTTPError as e:
        sys.exit(f"Error fetching {url}: {e}")

def main():
    print("hpk bootstrap installer\n" + "=" * 40)
    plat = get_platform()
    print(f"Platform: {plat}")

    headers = {"Authorization": "Bearer QQ==", "Accept": "application/vnd.oci.image.manifest.v1+json"}
    tag = f"hpk-{plat}"
    manifest = fetch_json(f"https://{REGISTRY}/v2/{NAMESPACE}/manifests/{tag}", headers)

    layer = manifest["layers"][0]
    annotations = layer.get("annotations", {})
    offset, size = int(annotations.get("com.hpk.binary.offset", 0)), int(annotations.get("com.hpk.binary.size", 0))

    if not size: sys.exit("Error: Package missing binary annotations")

    print(f"Downloading {layer['digest'][:19]}... ({layer['size']} bytes)")
    with urllib.request.urlopen(urllib.request.Request(
        f"https://{REGISTRY}/v2/{NAMESPACE}/blobs/{layer['digest']}", headers=headers)) as r:
        apk_data = r.read()

    magic = struct.unpack('<I', apk_data[:4])[0]
    data = zlib.decompress(apk_data[4:], -zlib.MAX_WBITS) if magic in (0x63424441, 0x64424441) else apk_data[4:] if magic == 0x2e424441 else sys.exit(f"Unknown APK magic: 0x{magic:08x}")

    if offset + size > len(data): sys.exit("Error: Binary offset/size out of range")
    binary = data[offset:offset+size]

    install_dir = Path("/tmp/hpk-bootstrap")
    install_dir.mkdir(parents=True, exist_ok=True)
    hpk_path = install_dir / "hpk"

    hpk_path.write_bytes(binary)
    os.chmod(hpk_path, 0o755)

    print("=" * 40 + f"\nInstallation complete!\n\nRun: {hpk_path} --help")

if __name__ == "__main__":
    main()

