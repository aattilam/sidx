# SidX

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

SidX is a Debian Sid-based distribution that aims to provide a user-friendly and cutting-edge Linux experience. It is designed to automatically install drivers, utilizes the Liquorix kernel for enhanced performance, and offers the GNOME desktop environment by default. SidX keeps its packages up to date, while also allowing users to access additional software from stable and testing repositories.

## Features

- Automatic driver installation for a hassle-free setup
- Utilizes the Liquorix kernel for improved performance
- Default desktop environment: GNOME
- Up-to-date package selection
- Additional software availability through stable and testing repositories

## Getting Started

### Download the ISO

The ISO is still in the works currently.

### Build It Yourself

To build SidX yourself, follow the instructions below:

1. Download the firmware-debian-testing ISO.
2. Rename it to `og-debian.iso`.
3. Clone this repository.
4. Install udevil.
5. Place the ISO file into the same directory as the cloned repo.
6. Give execute permission: `chmod +x iso-creator.sh`.
7. Run the script: `./iso-creator.sh`.

## Contributing

Contributions are welcome! If you have any ideas, suggestions, or bug reports, please [open an issue](https://github.com/aattilam/sidx/issues) or submit a pull request.

## License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT). Feel free to use, modify, and distribute this software.

Please note that individual packages included in SidX may have their own licenses. Make sure to review the licenses of the packages you are using to ensure compliance with their respective terms.
