# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-10-04

### Added

- Layouts for every screen size: forms and lists stop growing and stay
  centered on tablets and desktops, the creator page splits into two columns on
  wide windows, and the log in screens get a side panel.
- Every creator page has its own address (`/c/<id>`) that can be shared and
  opened directly in the web app. Signing in returns you to the page you came
  for.
- Landing page, published with GitHub Pages.
- Unit and widget tests, and a CI workflow that runs them.
- A retry button when a page fails to load.

### Changed

- Sharing a creator page now shares its web address. Firebase Dynamic Links,
  which the old links relied on, has been shut down by Google.
- Amounts are shown with thousands separators (`150,000 L.L.`).
- The profile form only requires a name. About and website are optional.
- The profile picture is saved to the creator page as soon as it is uploaded.
- Local emulators are opt in (`--dart-define=USE_EMULATORS=true`) instead of
  always on in debug builds.
- Code reorganised into models, a data layer of repositories, screens and
  widgets. Screens no longer talk to Firebase directly.
- Upgraded to Flutter 3.41, Dart 3.11, the current Firebase SDKs and the
  current Android build tooling.

### Fixed

- Becoming a fan no longer rewrites the whole profile of the creator, which
  could undo changes they made at the same time.
- Uploading a profile picture works on the web.
- Amount fields no longer accept letters.

### Removed

- Firebase Dynamic Links and the `flutter_keyboard_size` dependency.
- Firebase configuration files from the repository. Copy the `.example` files
  instead, see the README.

## [1.0.0] - 2024-09-19

### Added

- Accounts with email and password.
- Creator pages with a picture, about text, website and a page color.
- Buying kahwas in LBP or USD with an optional message, public or private.
- Fans, supporters and a home screen listing the creators you are a fan of.
- Goals with a progress bar.
- Balance, billing details and withdraw requests through Whish Money.
- Android and web apps.

[2.0.0]: https://github.com/georges-ph/kahwa/releases/tag/v2.0.0
[1.0.0]: https://github.com/georges-ph/kahwa/tree/49c7765
