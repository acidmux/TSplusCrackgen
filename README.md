# TSplus Crackgen

An automated tool that patches TSplus software to remove licensing restrictions and unlock all premium features. This project uses GitHub Actions to automatically download the latest TSplus installer, apply necessary binary patches, and create deployable releases.

## 🚀 Features

- Automatically detects and downloads the latest TSplus version
- Applies binary patches to bypass license verification
- Removes connection limits and feature restrictions
- Creates ready-to-deploy packages with patched files
- Includes original setup for easy installation
- Fully automated using GitHub Actions workflow

## 📦 Release Contents

Each release includes:
- **Setup-TSplus.exe**: Original unmodified TSplus setup
- **TSplus-Crack-v{version}.zip**: Archive containing all patched binary files

## 📋 Installation Instructions

### New Installation

1. Download both the installer (`Setup-TSplus.exe`) and the patched files archive from the [Releases](../../releases) page
2. Run the installer to complete the base TSplus installation
3. Extract the contents of the patched files archive
4. Copy and replace the extracted files to the following locations:
   - `C:\Program Files (x86)\TSplus\UserDesktop\files\`
   - `C:\Program Files (x86)\TSplus\Clients\www\cgi-bin\`
5. Restart the TSplus services

### Upgrading Existing Installation

1. Stop all TSplus services
2. Run the setup to update your installation
3. Apply the patched files as described above
4. Restart the TSplus services

## ⚙️ Patched Components

- `APSC.exe` - Administrative tool with licensing checks removed
- `AdminTool.exe` - Admin console with premium features unlocked
- `TwoFactor.Admin.exe` - Two-factor authentication administration
- `OneLicense.dll` - License validation component

## ⚠️ Legal Disclaimer

This project is provided for educational purposes only. The use of this software to bypass licensing in production environments may violate the TSplus End User License Agreement. Users should ensure they have proper licensing for any commercial use of TSplus software.

## 🛠️ Technical Information

This project leverages GitHub Actions to automate the entire process of downloading, patching, and releasing modified TSplus files. The workflow includes:

- Automatic detection of the latest TSplus version
- Binary patching using custom tools
- Integrity check bypasses
- Building structured release packages

## 🤝 Contributing

We welcome contributions to the TSplus Crackgen project! Please follow these guidelines to help us maintain a high-quality project:

1. **Reporting Issues**: If you encounter any bugs or have suggestions for improvements, please use the issue templates provided in the `.github/ISSUE_TEMPLATE` directory.
2. **Submitting Pull Requests**: When submitting a pull request, please ensure that your code adheres to the project's coding standards and includes appropriate tests.
3. **Code of Conduct**: Please be respectful and considerate in all interactions. We aim to create a welcoming environment for all contributors.

Thank you for your interest in contributing to TSplus Crackgen!

## 📚 References

- [Qatch](https://github.com/acidmux/qatch) - Related project by acidmux