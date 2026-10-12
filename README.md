# kahwa

[![CI](https://github.com/georges-ph/kahwa/actions/workflows/ci.yml/badge.svg)](https://github.com/georges-ph/kahwa/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/georges-ph/kahwa)](https://github.com/georges-ph/kahwa/releases)
[![License](https://img.shields.io/github/license/georges-ph/kahwa)](LICENSE)

Buy your favorite Lebanese creators a kahwa.

kahwa is a Lebanese take on Ko-fi and Buy Me a Coffee. Creators get a page of
their own, fans support them one kahwa at a time in LBP or USD, and creators
withdraw what they receive through Whish Money. It is built with Flutter and
Firebase, and runs on Android and the web.

**[Landing page](https://georges-ph.github.io/kahwa/)**

## Screenshots

| Creator page | Buy a kahwa | Balance |
| --- | --- | --- |
| ![Creator page on a phone](landing/screenshots/phone-creator.png) | ![Buying a kahwa on a phone](landing/screenshots/phone-donate.png) | ![Balance on a phone](landing/screenshots/phone-balance.png) |

![Creator page on a desktop](landing/screenshots/desktop-creator.png)

## Features

- **Creator pages** with an about text, a website and one of six page colors.
  Each page has its own address to share, with a username the creator picks.
- **Kahwas** priced by the creator in LBP and USD, with an optional message.
  Supporters can keep their support private.
- **Fans**: follow creators and find them again on your home screen.
- **Goals** in LBP or USD, with a progress bar that fills as kahwas come in.
- **Balance**: top ups and withdrawals through Whish Money. A user sends the
  money, confirms it in the app, and an admin approves the request.
- **Admin screen** for the people running it: the total held for users and
  the top up and withdraw requests waiting for a decision.
- **Every screen size**: phone, tablet and desktop layouts.

## Status

Version 2.0.0. The app is a working project rather than a live service. Money
moves between balances inside the app, and the security rules only let a
balance change in three ways: by the total of a donation made in the same
transaction, or by an admin approving a top up or a withdraw request of that
user. The transfers themselves happen outside the app, through Whish Money,
and an admin checks them by hand.

## Setup

You need [Flutter](https://docs.flutter.dev/get-started/install) 3.41.5 and a
[Firebase](https://console.firebase.google.com) project with Authentication
(email and password) and Cloud Firestore enabled.

1. Clone the repository and install the dependencies:

   ```sh
   git clone https://github.com/georges-ph/kahwa.git
   cd kahwa
   flutter pub get
   ```

2. Add your Firebase configuration. These files are different for every
   developer and are not in the repository. Either run
   [`flutterfire configure`](https://firebase.google.com/docs/flutter/setup),
   or copy the templates and fill in the values from your Firebase project:

   ```sh
   cp lib/firebase_options.dart.example lib/firebase_options.dart
   cp android/app/google-services.json.example android/app/google-services.json
   ```

3. Add the security rules. The Firestore rules the app expects are in
   [`docs/firestore.rules`](docs/firestore.rules).

4. In the Firebase console, under `kahwa/AppCollections` in Firestore:

   - create `Config/top_up` with the text inside your "Whish Me" QR codes
     (`https://whish.money/pay/...` links): `whish_qr_lbp` for the code of
     your LBP balance and `whish_qr_usd` for the one of your USD balance.
     WHISH gives a different code per currency, and top ups are only offered
     in the currencies you fill in. Users pay through it, on a phone with a
     button that opens the WHISH app and elsewhere by scanning the code.
     They see your name in WHISH, never a phone number. The app itself shows
     neither;
   - create `Admins/<user id>` (any content) for each account that should see
     the admin screen. The user id is in Authentication. Only the console can
     create these documents.

5. Run the app:

   ```sh
   flutter run -d chrome   # web
   flutter run             # Android device or emulator
   ```

### Local emulators

To work without touching a real Firebase project, start the
[Firebase emulators](https://firebase.google.com/docs/emulator-suite) and tell
the app to use them. The emulators need Java.

```sh
firebase emulators:start --config firebase.emulators.json --import local_data --export-on-exit
flutter run -d chrome --dart-define=USE_EMULATORS=true
```

On the web, reloading the page signs you out while using the emulators.

### Deploying the web app

The web app is hosted on its own Firebase Hosting site. Copy
`.firebaserc.example` to `.firebaserc`, fill in your project and site, then:

```sh
flutter build web --release --dart-define=APP_URL=https://your-site.web.app
firebase deploy --only hosting
```

`APP_URL` is the address used in the links creators share. The web app works
it out by itself, so it only matters for Android builds.

The landing page in [`landing/`](landing) is deployed to GitHub Pages by the
`Landing page` workflow whenever it changes.

## Project structure

```
lib/
  main.dart        Firebase setup and app start
  app.dart         MaterialApp and router
  core/            theme, routes, breakpoints, small helpers
  models/          plain data classes that map to Firestore documents
  data/            repositories, the only code that talks to Firebase
  screens/         one file per screen
  widgets/         pieces shared between screens
test/              unit and widget tests
landing/           landing page (GitHub Pages)
```

## Contributing

Contributions are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE)
