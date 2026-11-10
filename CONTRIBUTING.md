# Contributing to ZoneBar

Thanks for your interest in contributing to ZoneBar.

## Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/kkz6/ZoneBar.git
   cd ZoneBar
   ```

2. Open in Xcode:
   ```bash
   open ZoneBar.xcodeproj
   ```

3. Build and run with **Cmd+R**.

### Local Code Signing (recommended)

An ad-hoc signed Debug build gets a new identity on every rebuild, so macOS asks
for Calendar access again each time. To avoid that without an Apple Developer
account, create a self-signed certificate once:

```bash
scripts/setup-local-signing.sh
```

The script creates a "ZoneBar Local Signing" certificate in your login keychain
(macOS asks for your password once to trust it for code signing) and writes
`Configuration/LocalSigning.xcconfig` so Debug builds use it. If Xcode or
`codesign` asks to use the key, choose **Always Allow**. Run it again with
`--force` to regenerate the configuration.

If you have an Apple Developer account instead, copy
`Configuration/LocalSigning.xcconfig.example`, replace `YOUR_TEAM_ID` with your
team ID and keep `Apple Development` as the identity.

`LocalSigning.xcconfig` is ignored by Git, so personal signing preferences are
never committed. Release signing is controlled by the release workflow and is not
changed by this local configuration.

### Requirements
- macOS 14.0+ (Sonoma)
- Xcode 16.0+
- Swift 5+

## Project Conventions

### Code Style
- Follow standard Swift naming conventions (camelCase for properties/methods, PascalCase for types)
- Use the Observation framework (`@Observable`) and environment injection
- Keep views small and focused -- extract subviews when a view exceeds ~100 lines
- Use SF Symbols for icons

### File Organization
- **Models/** -- Data types and business logic
- **Views/** -- SwiftUI views
- **Services/** -- Stateful managers and system integrations
- **Resources/** -- Bundled data files

### Commits
- Write clear, concise commit messages
- Use imperative mood ("Add feature" not "Added feature")
- Reference issue numbers where applicable

## How to Contribute

### Reporting Bugs
- Open an issue with steps to reproduce
- Include macOS version and ZoneBar version
- Attach screenshots if relevant

### Suggesting Features
- Check existing issues first to see if the feature has already been requested
- Open an issue describing the feature and its use case

### Submitting Changes
1. Fork the repository
2. Create a feature branch from `main`
3. Make your changes
4. Run the tests:
   ```bash
   xcodebuild -project ZoneBar.xcodeproj -scheme ZoneBar \
     -destination "platform=macOS" CODE_SIGNING_ALLOWED=NO test
   ```
5. Open a pull request with a clear description of your changes
