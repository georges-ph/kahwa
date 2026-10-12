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
- Public creator pages: anyone with the link can see a page without an
  account. Signing in is only asked for when buying a kahwa or becoming a fan.
- Top ups in LBP or USD: pick an amount, pay it with Whish Money (a button
  opens the WHISH app on a phone, a QR code is shown for other devices), then
  confirm in the app. The balance goes up once an admin has found the
  transfer. One request per user at a time. Before paying, the app says the
  money goes to the founder of kahwa and that top ups are checked by hand.
  The result of the last top up is shown for three days, and its WHISH number
  is filled in for the next one.
- Admin screen, for accounts listed as admins: the total held for users, and
  the top up and withdraw requests to approve, newest first.
- Usernames: creators can pick a handle and share a short address
  (`/rima`) instead of one made of their id.
- Goals can be in LBP or USD. Only kahwas bought in the currency of the goal
  count towards it.
- Landing page, published with GitHub Pages.
- Unit and widget tests, and a CI workflow that runs them.
- A retry button when a page fails to load.

### Changed

- One sign in screen replaces log in and sign up: a new email creates the
  account, a known one logs in. Accounts made in other apps of the same
  Firebase project work in kahwa right away.
- Sharing a creator page now shares its web address. Firebase Dynamic Links,
  which the old links relied on, has been shut down by Google.
- Amounts are shown with thousands separators (`150,000 L.L.`).
- The profile form only requires a name. About and website are optional.
- Local emulators are opt in (`--dart-define=USE_EMULATORS=true`) instead of
  always on in debug builds.
- Balances can only change through a donation: the security rules check that
  the supporter pays exactly what the creator receives. Supporters can no
  longer read the balance of a creator.
- Topping up happens in the app instead of through a WhatsApp link: see
  "Top ups" under Added. Realtime Database is no longer used.
- Withdraw requests are marked as paid by an admin in the app, which takes
  them out of the balance.
- Pages refresh by themselves after a donation or a goal change, and can be
  pulled down to refresh.
- Who made a private donation, and their message, are now stored apart from
  the donation itself, where only the creator and the supporter can read
  them. Everyone else still sees "Someone bought 3 kahwas".
- Emails are no longer stored on the creator page.
- Code reorganised into models, a data layer of repositories, screens and
  widgets. Screens no longer talk to Firebase directly.
- Upgraded to Flutter 3.41, Dart 3.11, the current Firebase SDKs and the
  current Android build tooling.

### Fixed

- Becoming a fan no longer rewrites the whole profile of the creator, which
  could undo changes they made at the same time.
- Amount fields no longer accept letters.
- The web app no longer shows a different font for a moment before the real
  one loads.
- Returning visitors get the latest version of the web app instead of one
  cached for up to an hour.

### Removed

- Profile pictures. Cloud Storage for Firebase is no longer available on the
  free plan, so pages show initials on the page color instead.
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
