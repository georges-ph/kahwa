# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [3.0.0] - 2026-11-06

kahwa 3.0.0, a rewrite of the whole app with a new look and new features.
Its data lives apart from kahwa 2's, so accounts start over with an empty
page and balance.

### Added

- Monthly memberships: a creator offers up to three tiers, each a number of
  kahwas a month with its perks. Members pay from their balance every 30
  days, charged when they open the app, and can switch tier, cancel and
  come back.
- Posts on a creator page, for everyone or for members only, with likes,
  and a feed of the creators you are a fan of on the home screen.
- Activity, an inbox in the app: kahwas, new members and fans, replies, top
  ups and withdrawals, with an unread count. No push notifications.
- Explore: every creator, by category, with search and sorting.
- A first setup after signing up: a name, a username, a look, and whether
  you make things or are here to support.
- Pages get a banner in one of twelve colors and six patterns, an emoji
  avatar, a tagline, a category and up to eight links with their icons.
- Creators can answer a message, and set a thank-you note shown after a
  purchase.
- Stats for creators: kahwas over time, what came in per currency, top
  supporters and members.
- A list of supporters and members, and a list of your own memberships.
- French and Arabic next to English, Arabic right to left with its own font,
  and a choice of language in the settings and on the welcome page.
- The email of an account can be changed in the settings, through a link sent
  to the new address.
- A dark mode, which follows the device or can be picked in the settings.
- Account security without a server: money only moves once the email is
  verified (link sent at sign up, sent again on request; Google accounts
  count as verified), a password change in the app, and a list of signed in
  devices that can each be signed out, even while closed.
- Creators can be paid straight to their own WHISH account, set up from a
  screenshot of their Whish Me QR code. The supporter says what they sent,
  the creator confirms it from the balance page, and only then do the kahwas
  count. Paying from the kahwa balance still works.
- Admins can look up any user's money (balance, history, memberships, last
  top up) and correct a balance with a written reason. Each correction is
  kept for good, in the user's history and an admin log that also shows who
  answered each top up and withdrawal.
- An intro on the first start of the app, in place of the website-like
  welcome page.
- A demo on the local Firebase emulators, `tool/try_local.ps1`, with two
  ready accounts.

### Changed

- License: PolyForm Noncommercial 1.0.0 instead of MIT. kahwa stays free to
  use, change and share for non-commercial purposes, but may not be sold or
  used commercially.
- A new design: a colored banner on every page, tabs for the wall, posts,
  memberships and about, and Home, Explore, Activity and Me tabs.
- The buy screen offers one time kahwas or a monthly membership, says what
  each one gives, and will not charge a month already paid.
- Amount fields mark thousands as you type and always show their currency.
- A goal's currency can change until the first kahwa counts towards it.
- A post can be switched between members only and everyone when editing it.
- Sign out and feedback are in the settings only.
- Pages read their data when they open, when the app comes back to the
  front and on pull to refresh, instead of listening for every change, which
  keeps Firestore reads low.
- On wide screens, forms show a live preview beside them (page, goal, post),
  and the admin screens use the full width.
- Money history and requests show the time as well as the date.
- Back on another tab goes to Home first, then leaves the app.
- Messages and posts written in English read left to right in the Arabic
  app, and the other way round.
- New Firestore layout under `kahwa/AppData`, with its own security rules.
- Firebase packages updated (Firebase JS SDK 13, Android BoM 35) with
  Kotlin 2.3.20.
- A build made for the local emulators never holds the production Firebase
  configuration.

### Removed

- kahwa 2 data (`kahwa/AppCollections`) is not read anymore.

## [2.1.0] - not released

Committed on 2026-10-27 and not released: production runs 2.0.0. These
changes are also part of the 3.0 rewrite above.

### Added

- Search for creators by name or username on the home screen.
- Google sign in, on the web and on Android.
- A "Set up your page" checklist on the home screen for new creators.
- A QR code and a copy button to share a creator page.
- A history of everything that moved the balance: kahwas bought and
  received, top ups and withdrawals.
- Withdraw requests show their status and can be cancelled while they wait.
  An admin can refuse one.
- Creators can remove a message from their page.
- When the balance is too low to buy a kahwa, the app offers to top up
  exactly what is missing and keeps the kahwa until the top up is approved.
- A picture and a short text when a kahwa link is shared.
- The buy screen shows the balance in the chosen currency and asks for
  confirmation before buying.

### Changed

- One withdraw request can wait at a time, and billing details are needed
  before sending one.
- The creator page loads its supporters ten at a time.

### Removed

- Firebase Analytics, In-App Messaging and Performance Monitoring, which the
  app did not use.

### Fixed

- The Android app is signed with the release key, not the debug key.
- Status bar icons on Android are dark, so they show on the white pages.
- The password field lets the password manager suggest a strong password.
- The password manager treats the Android app and the website as the same
  app and shares saved sign ins between them.
- After a first sign in, the home screen shows the new account's checklist
  without a refresh.
- Logging out happens at once.
- The profile shows the email of accounts made with Google.
- Saving a form scrolls to the first field with an error.
- Switching currency while buying could show the price in the wrong
  currency.

## [2.0.0] - 2026-10-13

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
- Release builds use a production Firebase project and all other builds a
  development one, each from its own local config file.
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

[Unreleased]: https://github.com/georges-ph/kahwa/compare/v3.0.0...HEAD
[3.0.0]: https://github.com/georges-ph/kahwa/releases/tag/v3.0.0
[2.1.0]: https://github.com/georges-ph/kahwa/commit/4e36144
[2.0.0]: https://github.com/georges-ph/kahwa/releases/tag/v2.0.0
[1.0.0]: https://github.com/georges-ph/kahwa/tree/49c7765
