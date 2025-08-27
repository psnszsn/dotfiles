import pytest
from pathlib import Path

from main import main


def test_simple_tar_gz(tmp_path: Path):
    """Test simple tar.gz package with direct binary extraction (fzf)."""
    main(home_path=tmp_path, target_pkg='fzf')
    
    fzf_binary = tmp_path / '.local/bin/fzf'
    assert fzf_binary.exists()
    assert fzf_binary.is_file()
    assert fzf_binary.stat().st_mode & 0o111


def test_nested_tar_gz(tmp_path: Path):
    """Test tar.gz package with nested binary path (ruff)."""
    main(home_path=tmp_path, target_pkg='ruff')
    
    ruff_binary = tmp_path / '.local/bin/ruff'
    assert ruff_binary.exists()
    assert ruff_binary.is_file()
    assert ruff_binary.stat().st_mode & 0o111


def test_zip_package(tmp_path: Path):
    """Test zip package with direct binary (stylua)."""
    main(home_path=tmp_path, target_pkg='stylua')
    
    stylua_binary = tmp_path / '.local/bin/stylua'
    assert stylua_binary.exists()
    assert stylua_binary.is_file()
    assert stylua_binary.stat().st_mode & 0o111


def test_tar_xz_package(tmp_path: Path):
    """Test tar.xz package with direct binary (fish)."""
    main(home_path=tmp_path, target_pkg='fish')
    
    fish_binary = tmp_path / '.local/bin/fish'
    assert fish_binary.exists()
    assert fish_binary.is_file()
    assert fish_binary.stat().st_mode & 0o111


def test_package_with_manpage_and_fishcomp(tmp_path: Path):
    """Test package with manpage and fish completion (fd)."""
    main(home_path=tmp_path, target_pkg='fd')
    
    # Check binary
    fd_binary = tmp_path / '.local/bin/fd'
    assert fd_binary.exists()
    assert fd_binary.is_file()
    assert fd_binary.stat().st_mode & 0o111
    
    # Check manpage
    manpage = tmp_path / '.local/share/man/man.1/fd.1'
    assert manpage.exists()
    assert manpage.is_file()
    
    # Check fish completion
    fishcomp = tmp_path / '.local/share/fish/vendor_completions.d/fd.fish'
    assert fishcomp.exists()
    assert fishcomp.is_file()


def test_extract_to_opt_package(tmp_path: Path):
    """Test package with extract_to_opt=True (luals)."""
    main(home_path=tmp_path, target_pkg='luals')
    
    # Check symlink in bin
    luals_symlink = tmp_path / '.local/bin/luals'
    assert luals_symlink.exists()
    assert luals_symlink.is_symlink()
    
    # Check actual binary in opt
    opt_dir = tmp_path / '.local/bin/opt/luals'
    assert opt_dir.exists()
    assert opt_dir.is_dir()
    
    # Check the symlink points to the correct location
    target = luals_symlink.readlink()
    assert target.name == 'lua-language-server'
    assert 'bin/lua-language-server' in str(target)


if __name__ == '__main__':
    pytest.main([__file__])