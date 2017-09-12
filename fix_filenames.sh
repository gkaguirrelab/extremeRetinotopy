#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Dropbox / Mac OS X has case insensitive directories, which causes problems in
# Linux and other case-sensitive filesystems.
# This script transforms the unzipped .zip download from Dropbox into the
# original directory structure with the path format R2590/pRFs/*
# r2590/prfs/*  --> R2590/pRFs/*
# Note that unzipping creates duplicates, one uppercase and one lowercase, but
# only one contains the data. Thus, we first remove empty pRFs directories, then
# remove the empty subject directories, then rename everything to uppercase.

rmdir */pRFs
rmdir *
rename 'y/a-z/A-Z/' *
