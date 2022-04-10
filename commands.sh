#!/bin/bash

# Er is ook een reflector timer. Misschien handiger om die te activeren?
reflector --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
