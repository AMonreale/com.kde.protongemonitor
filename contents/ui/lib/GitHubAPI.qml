import QtQuick

QtObject {
    id: root

    // Properties
    property string owner: "GloriousEggroll"
    property string repo: "proton-ge-custom"
    property bool loading: false
    property string errorMessage: ""

    // Signals
    signal releaseDataReceived(var releaseInfo)
    signal errorOccurred(string error)

    // API URLs
    readonly property string apiBaseUrl: "https://api.github.com"
    readonly property string latestReleaseUrl: apiBaseUrl + "/repos/" + owner + "/" + repo + "/releases/latest"
    readonly property string releasesUrl: apiBaseUrl + "/repos/" + owner + "/" + repo + "/releases"

    // XMLHttpRequest for API calls
    property var xhr: null

    // Get latest release
    function getLatestRelease() {
        if (loading) {
            console.log("GitHubAPI: Request already in progress")
            return
        }

        loading = true
        errorMessage = ""

        xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                loading = false

                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText)
                        var releaseInfo = parseReleaseData(response)
                        releaseDataReceived(releaseInfo)
                    } catch (e) {
                        errorMessage = "Failed to parse GitHub response: " + e
                        errorOccurred(errorMessage)
                    }
                } else if (xhr.status === 403) {
                    errorMessage = "GitHub API rate limit exceeded. Try again later."
                    errorOccurred(errorMessage)
                } else if (xhr.status === 404) {
                    errorMessage = "GitHub repository not found"
                    errorOccurred(errorMessage)
                } else {
                    errorMessage = "GitHub API error: " + xhr.status
                    errorOccurred(errorMessage)
                }
            }
        }

        xhr.open("GET", latestReleaseUrl)
        xhr.setRequestHeader("Accept", "application/vnd.github.v3+json")
        xhr.setRequestHeader("User-Agent", "ProtonGE-Monitor-Widget")
        xhr.send()
    }

    // Get all releases with limit
    function getReleases(perPage) {
        if (!perPage) perPage = 10

            if (loading) {
                console.log("GitHubAPI: Request already in progress")
                return
            }

            loading = true
            errorMessage = ""

            xhr = new XMLHttpRequest()
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    loading = false

                    if (xhr.status === 200) {
                        try {
                            var releases = JSON.parse(xhr.responseText)
                            var parsedReleases = []
                            for (var i = 0; i < releases.length; i++) {
                                parsedReleases.push(parseReleaseData(releases[i]))
                            }
                            releaseDataReceived(parsedReleases)
                        } catch (e) {
                            errorMessage = "Failed to parse GitHub response: " + e
                            errorOccurred(errorMessage)
                        }
                    } else {
                        errorMessage = "GitHub API error: " + xhr.status
                        errorOccurred(errorMessage)
                    }
                }
            }

            var url = releasesUrl + "?per_page=" + perPage
            xhr.open("GET", url)
            xhr.setRequestHeader("Accept", "application/vnd.github.v3+json")
            xhr.setRequestHeader("User-Agent", "ProtonGE-Monitor-Widget")
            xhr.send()
    }

    // Parse release data
    function parseReleaseData(release) {
        var info = {
            version: release.tag_name || "",
            name: release.name || release.tag_name || "",
            publishedAt: release.published_at || "",
            isPrerelease: release.prerelease || false,
            isDraft: release.draft || false,
            body: release.body || "",
            downloadUrl: "",
            fileName: "",
            fileSize: 0
        }

        // Find .tar.xz asset
        if (release.assets && release.assets.length > 0) {
            for (var i = 0; i < release.assets.length; i++) {
                var asset = release.assets[i]
                if (asset.name && asset.name.indexOf(".tar.xz") !== -1) {
                    info.downloadUrl = asset.browser_download_url || ""
                    info.fileName = asset.name
                    info.fileSize = asset.size || 0
                    break
                }
            }
        }

        // Fallback to .tar.gz if no .tar.xz found
        if (!info.downloadUrl && release.assets) {
            for (var j = 0; j < release.assets.length; j++) {
                var asset2 = release.assets[j]
                if (asset2.name && asset2.name.indexOf(".tar.gz") !== -1) {
                    info.downloadUrl = asset2.browser_download_url || ""
                    info.fileName = asset2.name
                    info.fileSize = asset2.size || 0
                    break
                }
            }
        }

        return info
    }

    // Cancel pending request
    function abort() {
        if (xhr && xhr.readyState !== XMLHttpRequest.DONE) {
            xhr.abort()
            loading = false
            errorMessage = "Request cancelled"
        }
    }

    // Format file size
    function formatFileSize(bytes) {
        if (bytes === 0) return "0 B"
            var k = 1024
            var sizes = ["B", "KB", "MB", "GB"]
            var i = Math.floor(Math.log(bytes) / Math.log(k))
            return (bytes / Math.pow(k, i)).toFixed(2) + " " + sizes[i]
    }

    // Format date
    function formatDate(dateString) {
        if (!dateString) return ""
            var date = new Date(dateString)
            return Qt.formatDateTime(date, "yyyy-MM-dd hh:mm")
    }
}
