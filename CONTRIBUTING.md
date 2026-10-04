# Contributing to kahwa

Thanks for taking the time to help. Bug reports, ideas and pull requests are
all welcome.

## Getting set up

1. Install [Flutter](https://docs.flutter.dev/get-started/install) 3.41.5, the
   version CI uses.
2. Fork and clone the repository.
3. Follow the [setup steps in the README](README.md#setup) to add your own
   Firebase configuration. The app does not build without it.
4. Run `flutter pub get`, then `flutter run -d chrome` or `flutter run` with an
   Android device connected.

You do not need a real Firebase project to work on most things. The
[local emulators](README.md#local-emulators) are enough.

## Making a change

1. Create a branch from `main`.
2. Keep the change focused. One fix or feature per pull request.
3. Follow the structure of the code: models hold data, repositories in
   `lib/data` are the only place that talks to Firebase, screens and widgets
   build the interface.
4. Check any screen you touch at phone, tablet and desktop widths.
5. Before pushing, run the same checks as CI:

   ```sh
   dart format lib test
   flutter analyze
   flutter test
   ```

6. Add a line to `CHANGELOG.md` if users will notice the change.
7. Open a pull request and fill in the template.

## Reporting bugs and suggesting features

Open an [issue](https://github.com/georges-ph/kahwa/issues/new/choose) and pick
the template that fits. For bugs, the steps to reproduce and the platform you
were on make all the difference.
