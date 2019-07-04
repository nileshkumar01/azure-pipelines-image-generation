#!/bin/bash
################################################################################
##  File:  rust.sh
##  Team:  CI-Platform
##  Desc:  Installs Rust
################################################################################

# Source the helpers for use with the script
source $HELPER_SCRIPTS/document.sh

set -e

export RUSTUP_HOME=/usr/share/.rustup
export CARGO_HOME=/usr/share/.cargo

curl https://sh.rustup.rs -sSf | sh -s -- -y

# Add Cargo and Rust binaries to the machine path
echo "PATH=${CARGO_HOME}/bin:$PATH" | tee -a /etc/environment
source $CARGO_HOME/env

# Install common tools
rustup component add rustfmt
rustup component add clippy
cargo install bindgen
cargo install cbindgen

echo "Test installation of the Rust toochain"

# Permissions
chmod -R 777 $RUSTUP_HOME
chmod -R 777 $CARGO_HOME

for cmd in rustup rustc rustdoc cargo rustfmt cargo-clippy bindgen cbindgen; do
    if ! command -v $cmd --version; then
        echo "$cmd was not installed or is not found on the path"
        exit 1
    fi
done

# Symlinks
ln -sf $RUSTUP_HOME $HOME/.rustup
ln -sf $CARGO_HOME $HOME/.cargo

# /etc/profile contains Linux system wide environment and startup programs
RUSTSYM_SH=/etc/profile.d/rustsym.sh
cat > "${RUSTSYM_SH}" << _EOF_
if [ -d $CARGO_HOME ]; then
    if [ ! -h \$HOME/.cargo ]; then
        ln -sf $CARGO_HOME \$HOME/.cargo
    fi
fi

if [ -d $RUSTUP_HOME ]; then
    if [ ! -h \$HOME/.rustup ]; then
        ln -sf $RUSTUP_HOME \$HOME/.rustup
    fi
fi
_EOF_

chmod +x "${RUSTSYM_SH}"

# Add Rust symlinks for a new user (adduser)
ADDUSER_SH=/usr/local/sbin/adduser.local
echo "su - \$1 -c \"${RUSTSYM_SH}\"" > "${ADDUSER_SH}"
chmod +x "${ADDUSER_SH}"

# Document what was added to the image
echo "Lastly, document what was added to the metadata file"
DocumentInstalledItem "rustup ($(rustup --version 2>&1 | cut -d ' ' -f 2))"
DocumentInstalledItem "rust ($(rustc --version 2>&1 | cut -d ' ' -f 2))"
DocumentInstalledItem "cargo ($(cargo --version 2>&1 | cut -d ' ' -f 2))"
DocumentInstalledItem "rustfmt ($(rustfmt --version 2>&1 | cut -d ' ' -f 2))"
DocumentInstalledItem "clippy ($(cargo-clippy --version 2>&1 | cut -d ' ' -f 2))"
DocumentInstalledItem "rustdoc ($(rustdoc --version 2>&1 | cut -d ' ' -f 2))"
DocumentInstalledItem "bindgen ($(bindgen --version 2>&1 | cut -d ' ' -f 2))"
DocumentInstalledItem "cbindgen ($(cbindgen --version 2>&1 | cut -d ' ' -f 2))"
