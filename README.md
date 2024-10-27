# cppcfsMenu - AutoHotkey Script for cppcryptfs

## Overview

cppcfsMenu is an AutoHotkey v2 script that translates cppcryptfs encrypted paths to their decrypted equivalents, allowing easy copying and opening in File Explorer.

unenc to enced
![image](https://github.com/user-attachments/assets/2e6a0d8d-01dc-4009-8a9e-444d66f10aee)

enced to unenc
![image](https://github.com/user-attachments/assets/fcacc688-c13e-45bd-bd7b-591dac78b795)




## Features

- Translate encrypted paths to decrypted paths
- Copy translated paths
- Open translated paths in File Explorer

## Requirements

- AutoHotkey v2
- cppcryptfs with `cppcryptfsctl.exe` in system PATH

## Usage

1. Run `cppcfsMenu.ahk`
2. In File Explorer, select an item in a cppcryptfs encrypted folder
3. Press `Ctrl+Shift+Alt+C`
4. Choose from the menu options:
   - View translated path
   - Copy translated path
   - Open in File Explorer

## Installation

Download `cppcfsMenu.ahk` and run it with AutoHotkey v2.

## Troubleshooting

Ensure `cppcryptfsctl.exe` is in your system PATH and you're selecting items within a cppcryptfs encrypted folder.

## Contributing

Issues and pull requests are welcome.

## License

Dual licensing. free for personal use. paid for commercial.

