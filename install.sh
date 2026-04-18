#!/bin/bash

# Install all packages in order

./scripts/01-install/install-git.sh
./scripts/01-install/install-curl.sh
./scripts/01-install/install-wget.sh

# Configure packages

./scripts/02-configure/configure-plymouth.sh