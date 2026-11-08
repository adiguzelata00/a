# Web build as a claude.ai artifact

The playable browser version is the Flutter web build wrapped in a small
page (loader + error message) that inlines `flutter.js` and the build's
`_flutter.buildConfig`, plus `leaderboard_bridge.js` (daily leaderboard via
the artifact's shared database; see the comment at its top for the
`capabilities` to publish with).

Build: `flutter build web --release --no-web-resources-cdn`, then publish
`main.dart.js`, `canvaskit/` (canvaskit + chromium variants),
`assets/AssetManifest.bin.json`, `assets/FontManifest.json`, the fonts and
`assets/assets/audio/*.wav` next to the page. `.bin` and `.frag` files are
not served by artifacts and are not needed by the web build.
