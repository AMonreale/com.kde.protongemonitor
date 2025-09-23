# Proton GE Monitor for KDE Plasma

A simple and convenient widget for your KDE Plasma desktop that keeps you up-to-date with the latest GloriousEggroll's Proton (Proton GE) releases.

This widget automatically checks for new versions, downloads them, and can also clean up old installations to free up space, all integrated into your Plasma panel.

![Widget Screenshot (placeholder)](https://raw.githubusercontent.com/your-username/com.kde.protongemonitor/main/screenshot.png) <!-- TODO: Replace with a real screenshot! -->

## Features

*   **Automatic Checks**: Periodically checks GloriousEggroll's GitHub page for new Proton GE releases.
*   **Automatic Downloads**: Automatically downloads and installs new versions as soon as they are available.
*   **Manual Check**: Trigger a manual check and download directly from the widget's interface.
*   **Old Version Cleanup**: Automatically removes old Proton GE installations, keeping only a configurable number of recent versions.
*   **Desktop Notifications**: Get notified about new versions, completed downloads, and any errors.
*   **Highly Configurable**: Customize the check interval, download behavior, paths, and much more.
*   **GitHub Token Support**: Option to add a GitHub Personal Access Token to increase API request limits and avoid rate-limiting.
*   **Proxy Support**: Can use system proxy settings for downloads.

## Installation

### Method 1: From the KDE Store (Recommended) [NOT YET AVAILABLE]

The easiest way to install the widget is to search for it directly from your Plasma desktop:
1.  Right-click on your desktop or panel and select "Add Widgets...".
2.  Click "Get New Widgets...".
3.  Search for "Proton GE Monitor" and install it.

### Method 2: Manual Installation

If you prefer to install the widget from the source code:
1.  Clone this repository:
    ```bash
    git clone https://github.com/your-username/com.kde.protongemonitor.git $HOME/.local/share/plasma/plasmoids/
    ```
2.  Navigate into the project directory and run the Plasma installation command:
    ```bash
    cd com.kde.protongemonitor
    plasmapkg2 -i .
    ```
3.  To apply the changes, restart `plasmashell`:
    ```bash
    killall plasmashell && kstart5 plasmashell &
    ```

## Configuration

Right-click the widget and select "Configure Proton GE Monitor..." to access the settings.

### General
*   **Check interval**: How often (in minutes) the widget checks for new versions.
*   **Automatically download updates**: If enabled, new versions are downloaded without user interaction.
*   **Custom Steam installation path**: Specify this path if your Steam installation is not in the default directory.
*   **Show desktop notifications**: Enable or disable notifications.
*   **Enable debug logging**: Writes detailed information to log files, useful for troubleshooting.

### Advanced
*   **Clean old versions**: Enables automatic removal of old Proton GE installations.
*   **Maximum versions to keep**: How many versions to keep when cleanup is active.
*   **GitHub Personal Access Token**: **(See Security Note)** Add a token to avoid GitHub API limits.
*   **Download timeout**: Maximum time (in seconds) allowed for download operations.
*   **Use system proxy settings**: Use the system-wide proxy for network requests.

### Appearance
*   **Widget icon**: Customize the icon displayed in the panel.

## ⚠️ Important Note on GitHub Token Security

The current version of the widget stores the GitHub Personal Access Token in a plain text configuration file. **This is not a secure method.**

It is strongly recommended to **NOT use a token with write permissions**. If you need to use a token to increase the request limit, generate it from your GitHub account settings **without assigning it any scopes** (public-only access).

A future update will integrate **KWallet** for secure token storage.

## Contributing

Contributions are welcome! Feel free to open an issue to report a bug, suggest a feature, or submit a pull request.

## License

This project is licensed under the MIT License.
