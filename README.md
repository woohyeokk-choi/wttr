# wttr

> Not the weather. Just what to do about it.

A decision-first iOS weather app. Instead of twelve data points, wttr tells
you whether to grab an umbrella, apply sunscreen, or layer up — in three
seconds.

- **Landing**: [wttr.fyi](https://wttr.fyi)
- **Platform**: iOS 17+ (iPhone, widgets)
- **Stack**: Swift 6, SwiftUI, WeatherKit, WidgetKit

## Repository layout

```
wttr/
├── wttr/              iOS app target
├── WttrWidgets/       Widget extension
├── SharedKit/         Shared Swift package (models, engine, services)
├── WttrTests/         Unit tests
├── WttrUITests/       UI tests
├── landing/           wttr.fyi landing page (GitHub Pages)
├── maestro/           Maestro UI test flows
└── project.yml        XcodeGen project spec
```

## Build

```bash
# Generate Xcode project
xcodegen

# Open in Xcode
open wttr.xcodeproj
```

Requires Xcode 15.3+ and an Apple Developer account with WeatherKit capability.

## Landing page

The marketing site at [wttr.fyi](https://wttr.fyi) lives in `landing/` and is
deployed to GitHub Pages on every push to `main` via
`.github/workflows/pages.yml`.

See [`landing/README.md`](landing/README.md) for local preview and deploy
details.

## License

TBD.
