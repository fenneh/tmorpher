# tmorpher

PowerShell script that keeps tMorph updated. Set it as a scheduled task and forget about it.

## What it does

1. Checks the current tMorph version against the latest release
2. Downloads and extracts updates when available
3. Handles the boring parts so you don't have to

## Setup

1. Edit `tmorpher.ps1` and set `$tmorphDir` to your preferred location
2. Create a scheduled task to run the script periodically

## Requirements

- PowerShell
- Internet connection
- A reason to use tMorph
