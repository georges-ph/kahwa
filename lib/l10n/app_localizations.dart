import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Buy your favorite Lebanese creators a kahwa'**
  String get tagline;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Support the people who make what you love, one cup at a time. Monthly memberships, posts and goals, all in one page.'**
  String get welcomeSubtitle;

  /// No description provided for @madeInLebanon.
  ///
  /// In en, this message translates to:
  /// **'Made in Lebanon'**
  String get madeInLebanon;

  /// No description provided for @exploreCreators.
  ///
  /// In en, this message translates to:
  /// **'Explore creators'**
  String get exploreCreators;

  /// No description provided for @startYourPage.
  ///
  /// In en, this message translates to:
  /// **'Start your page'**
  String get startYourPage;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get howItWorks;

  /// No description provided for @step1.
  ///
  /// In en, this message translates to:
  /// **'Top up your balance with WHISH MONEY.'**
  String get step1;

  /// No description provided for @step2.
  ///
  /// In en, this message translates to:
  /// **'Buy a creator kahwas, or join their monthly membership.'**
  String get step2;

  /// No description provided for @step3.
  ///
  /// In en, this message translates to:
  /// **'Creators withdraw what they receive to their WHISH account.'**
  String get step3;

  /// No description provided for @meetCreators.
  ///
  /// In en, this message translates to:
  /// **'Meet the creators'**
  String get meetCreators;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @openSource.
  ///
  /// In en, this message translates to:
  /// **'kahwa is open source'**
  String get openSource;

  /// No description provided for @featureKahwaTitle.
  ///
  /// In en, this message translates to:
  /// **'Kahwas that add up'**
  String get featureKahwaTitle;

  /// No description provided for @featureKahwaBody.
  ///
  /// In en, this message translates to:
  /// **'Buy a kahwa or a few, leave a message, and watch your support grow their goal.'**
  String get featureKahwaBody;

  /// No description provided for @featureMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly memberships'**
  String get featureMembersTitle;

  /// No description provided for @featureMembersBody.
  ///
  /// In en, this message translates to:
  /// **'Support every month and unlock members-only posts and perks.'**
  String get featureMembersBody;

  /// No description provided for @featurePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Your page in two minutes'**
  String get featurePageTitle;

  /// No description provided for @featurePageBody.
  ///
  /// In en, this message translates to:
  /// **'Pick a color, an avatar and a price. Share your link and start receiving kahwas.'**
  String get featurePageBody;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @somethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get somethingWrong;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this'**
  String get loadFailed;

  /// No description provided for @loadFailedHint.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get loadFailedHint;

  /// No description provided for @linkFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the link'**
  String get linkFailed;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get justNow;

  /// No description provided for @someone.
  ///
  /// In en, this message translates to:
  /// **'Someone'**
  String get someone;

  /// No description provided for @private.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get private;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @earlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get earlier;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get showMore;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @fewer.
  ///
  /// In en, this message translates to:
  /// **'Fewer'**
  String get fewer;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get tabExplore;

  /// No description provided for @tabActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get tabActivity;

  /// No description provided for @tabMe.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get tabMe;

  /// No description provided for @tabWall.
  ///
  /// In en, this message translates to:
  /// **'Wall'**
  String get tabWall;

  /// No description provided for @tabPosts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get tabPosts;

  /// No description provided for @tabMemberships.
  ///
  /// In en, this message translates to:
  /// **'Memberships'**
  String get tabMemberships;

  /// No description provided for @tabAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get tabAbout;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to kahwa'**
  String get signInTitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in, or create your account with the same form.'**
  String get signInSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @newAccountHint.
  ///
  /// In en, this message translates to:
  /// **'New here? Enter your email and a password and your account is created.'**
  String get newAccountHint;

  /// No description provided for @emailMissing.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailMissing;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'That email doesn\'t look right'**
  String get emailInvalid;

  /// No description provided for @passwordMissing.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordMissing;

  /// No description provided for @passwordShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 6 characters'**
  String get passwordShort;

  /// No description provided for @passwordWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password'**
  String get passwordWrong;

  /// No description provided for @tooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again later.'**
  String get tooManyAttempts;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection'**
  String get noInternet;

  /// No description provided for @signInFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sign in. Try again.'**
  String get signInFailed;

  /// No description provided for @googleFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign in didn\'t work. Try again.'**
  String get googleFailed;

  /// No description provided for @googleUsesPassword.
  ///
  /// In en, this message translates to:
  /// **'This email signs in with a password'**
  String get googleUsesPassword;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get resetTitle;

  /// No description provided for @resetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll email you a link to choose a new one.'**
  String get resetSubtitle;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get sendResetLink;

  /// No description provided for @resetSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox'**
  String get resetSentTitle;

  /// No description provided for @resetSent.
  ///
  /// In en, this message translates to:
  /// **'A link to reset your password was sent to {email}.'**
  String resetSent(String email);

  /// No description provided for @setupNameTitle.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get setupNameTitle;

  /// No description provided for @setupNameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your name shows on your page and next to the kahwas you buy.'**
  String get setupNameSubtitle;

  /// No description provided for @setupLookTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick your look'**
  String get setupLookTitle;

  /// No description provided for @setupLookSubtitle.
  ///
  /// In en, this message translates to:
  /// **'An avatar and a color for your page. You can change them any time.'**
  String get setupLookSubtitle;

  /// No description provided for @setupRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'How will you use kahwa?'**
  String get setupRoleTitle;

  /// No description provided for @setupRoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can always do both later.'**
  String get setupRoleSubtitle;

  /// No description provided for @setupCreatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Open your page'**
  String get setupCreatorTitle;

  /// No description provided for @setupCreatorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell people what you make and set the price of a kahwa.'**
  String get setupCreatorSubtitle;

  /// No description provided for @roleCreatorTitle.
  ///
  /// In en, this message translates to:
  /// **'I make things'**
  String get roleCreatorTitle;

  /// No description provided for @roleCreatorBody.
  ///
  /// In en, this message translates to:
  /// **'Open a page and receive kahwas and memberships.'**
  String get roleCreatorBody;

  /// No description provided for @roleSupporterTitle.
  ///
  /// In en, this message translates to:
  /// **'I\'m here to support'**
  String get roleSupporterTitle;

  /// No description provided for @roleSupporterBody.
  ///
  /// In en, this message translates to:
  /// **'Find creators and buy them kahwas.'**
  String get roleSupporterBody;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @usernameHint.
  ///
  /// In en, this message translates to:
  /// **'The address of your page. Optional.'**
  String get usernameHint;

  /// No description provided for @usernameLength.
  ///
  /// In en, this message translates to:
  /// **'Use {min} to {max} characters'**
  String usernameLength(int min, int max);

  /// No description provided for @usernameCharacters.
  ///
  /// In en, this message translates to:
  /// **'Use only letters, numbers and underscores'**
  String get usernameCharacters;

  /// No description provided for @usernameReserved.
  ///
  /// In en, this message translates to:
  /// **'This username isn\'t available'**
  String get usernameReserved;

  /// No description provided for @usernameTaken.
  ///
  /// In en, this message translates to:
  /// **'Someone already has this username'**
  String get usernameTaken;

  /// No description provided for @nameMissing.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get nameMissing;

  /// No description provided for @avatar.
  ///
  /// In en, this message translates to:
  /// **'Avatar'**
  String get avatar;

  /// No description provided for @pageColor.
  ///
  /// In en, this message translates to:
  /// **'Page color'**
  String get pageColor;

  /// No description provided for @pageColorHint.
  ///
  /// In en, this message translates to:
  /// **'Your color is used for your banner and every button on your page.'**
  String get pageColorHint;

  /// No description provided for @bannerPattern.
  ///
  /// In en, this message translates to:
  /// **'Banner pattern'**
  String get bannerPattern;

  /// No description provided for @taglineLabel.
  ///
  /// In en, this message translates to:
  /// **'Tagline'**
  String get taglineLabel;

  /// No description provided for @taglineHint.
  ///
  /// In en, this message translates to:
  /// **'One line under your name.'**
  String get taglineHint;

  /// No description provided for @taglineExample.
  ///
  /// In en, this message translates to:
  /// **'Illustrator in Beirut'**
  String get taglineExample;

  /// No description provided for @whatYouMake.
  ///
  /// In en, this message translates to:
  /// **'What you make'**
  String get whatYouMake;

  /// No description provided for @kahwaPrice.
  ///
  /// In en, this message translates to:
  /// **'Price of a kahwa'**
  String get kahwaPrice;

  /// No description provided for @kahwaPriceHint.
  ///
  /// In en, this message translates to:
  /// **'Supporters pay in L.L. or \$, so set both.'**
  String get kahwaPriceHint;

  /// No description provided for @priceInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a price above 0 in both currencies'**
  String get priceInvalid;

  /// No description provided for @openMyPage.
  ///
  /// In en, this message translates to:
  /// **'Open my page'**
  String get openMyPage;

  /// No description provided for @categoryArt.
  ///
  /// In en, this message translates to:
  /// **'Art'**
  String get categoryArt;

  /// No description provided for @categoryMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get categoryMusic;

  /// No description provided for @categoryWriting.
  ///
  /// In en, this message translates to:
  /// **'Writing'**
  String get categoryWriting;

  /// No description provided for @categoryVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get categoryVideo;

  /// No description provided for @categoryPhotography.
  ///
  /// In en, this message translates to:
  /// **'Photography'**
  String get categoryPhotography;

  /// No description provided for @categoryGaming.
  ///
  /// In en, this message translates to:
  /// **'Gaming'**
  String get categoryGaming;

  /// No description provided for @categoryPodcast.
  ///
  /// In en, this message translates to:
  /// **'Podcasts'**
  String get categoryPodcast;

  /// No description provided for @categoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get categoryFood;

  /// No description provided for @categoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get categoryEducation;

  /// No description provided for @categoryTech.
  ///
  /// In en, this message translates to:
  /// **'Tech'**
  String get categoryTech;

  /// No description provided for @categoryComedy.
  ///
  /// In en, this message translates to:
  /// **'Comedy'**
  String get categoryComedy;

  /// No description provided for @categoryCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get categoryCommunity;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @exploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploreTitle;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search creators'**
  String get searchHint;

  /// No description provided for @sortPopular.
  ///
  /// In en, this message translates to:
  /// **'Most fans'**
  String get sortPopular;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// No description provided for @creatorsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 creator} other{{count} creators}}'**
  String creatorsCount(int count);

  /// No description provided for @noResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No creators found'**
  String get noResultsTitle;

  /// No description provided for @noResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Try another name or category.'**
  String get noResultsBody;

  /// No description provided for @noTagline.
  ///
  /// In en, this message translates to:
  /// **'A creator on kahwa'**
  String get noTagline;

  /// No description provided for @kahwasLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{kahwa} other{kahwas}}'**
  String kahwasLabel(int count);

  /// No description provided for @supportersLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{supporter} other{supporters}}'**
  String supportersLabel(int count);

  /// No description provided for @fansTitle.
  ///
  /// In en, this message translates to:
  /// **'Fans'**
  String get fansTitle;

  /// No description provided for @fansLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{fan} other{fans}}'**
  String fansLabel(int count);

  /// No description provided for @kahwasCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 kahwa} other{{count} kahwas}}'**
  String kahwasCount(int count);

  /// No description provided for @boughtKahwas.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{bought a kahwa} other{bought {count} kahwas}}'**
  String boughtKahwas(int count);

  /// No description provided for @paidMembership.
  ///
  /// In en, this message translates to:
  /// **'supports monthly · {tier}'**
  String paidMembership(String tier);

  /// No description provided for @buyKahwaFor.
  ///
  /// In en, this message translates to:
  /// **'Buy {name} a kahwa'**
  String buyKahwaFor(String name);

  /// No description provided for @notAcceptingYet.
  ///
  /// In en, this message translates to:
  /// **'Not accepting kahwas yet'**
  String get notAcceptingYet;

  /// No description provided for @becomeFan.
  ///
  /// In en, this message translates to:
  /// **'Become a fan'**
  String get becomeFan;

  /// No description provided for @unfan.
  ///
  /// In en, this message translates to:
  /// **'Stop being a fan'**
  String get unfan;

  /// No description provided for @shareMyPage.
  ///
  /// In en, this message translates to:
  /// **'Share my page'**
  String get shareMyPage;

  /// No description provided for @editPage.
  ///
  /// In en, this message translates to:
  /// **'Edit page'**
  String get editPage;

  /// No description provided for @wallEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No kahwas yet'**
  String get wallEmptyTitle;

  /// No description provided for @wallEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Be the first to buy {name} a kahwa.'**
  String wallEmptyBody(String name);

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @editReply.
  ///
  /// In en, this message translates to:
  /// **'Edit reply'**
  String get editReply;

  /// No description provided for @sayThanks.
  ///
  /// In en, this message translates to:
  /// **'Say thanks'**
  String get sayThanks;

  /// No description provided for @replyHint.
  ///
  /// In en, this message translates to:
  /// **'Thank you so much!'**
  String get replyHint;

  /// No description provided for @removeMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove message'**
  String get removeMessage;

  /// No description provided for @removeMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this message?'**
  String get removeMessageTitle;

  /// No description provided for @removeMessageBody.
  ///
  /// In en, this message translates to:
  /// **'It will no longer show on your page. The kahwas stay.'**
  String get removeMessageBody;

  /// No description provided for @newPost.
  ///
  /// In en, this message translates to:
  /// **'New post'**
  String get newPost;

  /// No description provided for @postsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get postsEmptyTitle;

  /// No description provided for @postsEmptyOwner.
  ///
  /// In en, this message translates to:
  /// **'Share news, work in progress, or a thank you.'**
  String get postsEmptyOwner;

  /// No description provided for @postsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'{name} has not posted anything yet.'**
  String postsEmptyBody(String name);

  /// No description provided for @membershipsIntro.
  ///
  /// In en, this message translates to:
  /// **'Support {name} every month and get more in return.'**
  String membershipsIntro(String name);

  /// No description provided for @membershipsHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'Paid from your kahwa balance every 30 days, when you open kahwa. Cancel any time.'**
  String get membershipsHowItWorks;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'a month'**
  String get perMonth;

  /// No description provided for @kahwasEachMonth.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 kahwa each month} other{{count} kahwas each month}}'**
  String kahwasEachMonth(int count);

  /// No description provided for @yourTier.
  ///
  /// In en, this message translates to:
  /// **'Your tier'**
  String get yourTier;

  /// No description provided for @youAreMember.
  ///
  /// In en, this message translates to:
  /// **'You\'re a member'**
  String get youAreMember;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @rejoin.
  ///
  /// In en, this message translates to:
  /// **'Join again'**
  String get rejoin;

  /// No description provided for @becomeMember.
  ///
  /// In en, this message translates to:
  /// **'Become a member'**
  String get becomeMember;

  /// No description provided for @cancelledUntil.
  ///
  /// In en, this message translates to:
  /// **'Cancelled, perks until {date}'**
  String cancelledUntil(String date);

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About {name}'**
  String aboutTitle(String name);

  /// No description provided for @noAbout.
  ///
  /// In en, this message translates to:
  /// **'Nothing written here yet.'**
  String get noAbout;

  /// No description provided for @joinedOn.
  ///
  /// In en, this message translates to:
  /// **'On kahwa since {date}'**
  String joinedOn(String date);

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'This page doesn\'t exist'**
  String get pageNotFound;

  /// No description provided for @pageNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'The link may be wrong, or the username changed.'**
  String get pageNotFoundBody;

  /// No description provided for @goalLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goalLabel;

  /// No description provided for @goalReached.
  ///
  /// In en, this message translates to:
  /// **'Reached'**
  String get goalReached;

  /// No description provided for @goalOf.
  ///
  /// In en, this message translates to:
  /// **'of {target}'**
  String goalOf(String target);

  /// No description provided for @membersOnly.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get membersOnly;

  /// No description provided for @lockedPost.
  ///
  /// In en, this message translates to:
  /// **'This post is for members.'**
  String get lockedPost;

  /// No description provided for @edited.
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get edited;

  /// No description provided for @like.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get like;

  /// No description provided for @unlike.
  ///
  /// In en, this message translates to:
  /// **'Unlike'**
  String get unlike;

  /// No description provided for @deletePostTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this post?'**
  String get deletePostTitle;

  /// No description provided for @deletePostBody.
  ///
  /// In en, this message translates to:
  /// **'It\'s removed for everyone.'**
  String get deletePostBody;

  /// No description provided for @editPost.
  ///
  /// In en, this message translates to:
  /// **'Edit post'**
  String get editPost;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @postHint.
  ///
  /// In en, this message translates to:
  /// **'What\'s new?'**
  String get postHint;

  /// No description provided for @postEmpty.
  ///
  /// In en, this message translates to:
  /// **'Write something first'**
  String get postEmpty;

  /// No description provided for @posted.
  ///
  /// In en, this message translates to:
  /// **'Posted'**
  String get posted;

  /// No description provided for @membersOnlyPost.
  ///
  /// In en, this message translates to:
  /// **'For members only'**
  String get membersOnlyPost;

  /// No description provided for @membersOnlyHint.
  ///
  /// In en, this message translates to:
  /// **'Only you and paying members can read it.'**
  String get membersOnlyHint;

  /// No description provided for @membersOnlyNeedsTiers.
  ///
  /// In en, this message translates to:
  /// **'Add a membership first, in Prices and memberships.'**
  String get membersOnlyNeedsTiers;

  /// No description provided for @shareTitle.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s page'**
  String shareTitle(String name);

  /// No description provided for @shareText.
  ///
  /// In en, this message translates to:
  /// **'Buy {name} a kahwa: {link}'**
  String shareText(String name, String link);

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopied;

  /// No description provided for @buyTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy {name} a kahwa'**
  String buyTitle(String name);

  /// No description provided for @joinTitle.
  ///
  /// In en, this message translates to:
  /// **'Join {name}\'s membership'**
  String joinTitle(String name);

  /// No description provided for @oneTime.
  ///
  /// In en, this message translates to:
  /// **'One time'**
  String get oneTime;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @payIn.
  ///
  /// In en, this message translates to:
  /// **'Pay in'**
  String get payIn;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @messageHint.
  ///
  /// In en, this message translates to:
  /// **'Say something nice (optional)'**
  String get messageHint;

  /// No description provided for @keepPrivate.
  ///
  /// In en, this message translates to:
  /// **'Keep it private'**
  String get keepPrivate;

  /// No description provided for @keepPrivateHint.
  ///
  /// In en, this message translates to:
  /// **'Only {name} sees your name and message.'**
  String keepPrivateHint(String name);

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @eachMonth.
  ///
  /// In en, this message translates to:
  /// **'Each month'**
  String get eachMonth;

  /// No description provided for @yourBalance.
  ///
  /// In en, this message translates to:
  /// **'Your balance'**
  String get yourBalance;

  /// No description provided for @afterThis.
  ///
  /// In en, this message translates to:
  /// **'After this'**
  String get afterThis;

  /// No description provided for @notEnoughShort.
  ///
  /// In en, this message translates to:
  /// **'Not enough'**
  String get notEnoughShort;

  /// No description provided for @membershipRenewHint.
  ///
  /// In en, this message translates to:
  /// **'Renews from your balance every 30 days, the next time you open kahwa. Cancel any time from Me, My memberships.'**
  String get membershipRenewHint;

  /// No description provided for @topUpToContinue.
  ///
  /// In en, this message translates to:
  /// **'Top up to continue'**
  String get topUpToContinue;

  /// No description provided for @supportFor.
  ///
  /// In en, this message translates to:
  /// **'Support {amount}'**
  String supportFor(String amount);

  /// No description provided for @joinFor.
  ///
  /// In en, this message translates to:
  /// **'Join for {amount} a month'**
  String joinFor(String amount);

  /// No description provided for @confirmBuyTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Buy a kahwa?} other{Buy {count} kahwas?}}'**
  String confirmBuyTitle(int count);

  /// No description provided for @confirmBuyBody.
  ///
  /// In en, this message translates to:
  /// **'{amount} goes from your balance to {name}.'**
  String confirmBuyBody(String amount, String name);

  /// No description provided for @confirmJoinTitle.
  ///
  /// In en, this message translates to:
  /// **'Join {tier}?'**
  String confirmJoinTitle(String tier);

  /// No description provided for @confirmJoinBody.
  ///
  /// In en, this message translates to:
  /// **'{amount} now, then every 30 days.'**
  String confirmJoinBody(String amount);

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// No description provided for @pageChanged.
  ///
  /// In en, this message translates to:
  /// **'This page just changed. Check the price and try again.'**
  String get pageChanged;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'The payment didn\'t go through. Nothing was taken.'**
  String get paymentFailed;

  /// No description provided for @notEnoughTitle.
  ///
  /// In en, this message translates to:
  /// **'Not enough balance'**
  String get notEnoughTitle;

  /// No description provided for @notEnoughBody.
  ///
  /// In en, this message translates to:
  /// **'You need {amount} more. Top up now and come back to finish: your kahwa is kept for you.'**
  String notEnoughBody(String amount);

  /// No description provided for @topUpAmount.
  ///
  /// In en, this message translates to:
  /// **'Top up {amount}'**
  String topUpAmount(String amount);

  /// No description provided for @resumedKahwa.
  ///
  /// In en, this message translates to:
  /// **'Your kahwa was kept while you topped up.'**
  String get resumedKahwa;

  /// No description provided for @cannotSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'You can\'t support this page'**
  String get cannotSupportTitle;

  /// No description provided for @cannotSupportBody.
  ///
  /// In en, this message translates to:
  /// **'It\'s your own page, or it doesn\'t accept kahwas yet.'**
  String get cannotSupportBody;

  /// No description provided for @thankYouKahwas.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Your kahwa is on its way!} other{Your {count} kahwas are on their way!}}'**
  String thankYouKahwas(int count);

  /// No description provided for @thankYouMember.
  ///
  /// In en, this message translates to:
  /// **'Welcome to {tier}!'**
  String thankYouMember(String tier);

  /// No description provided for @defaultThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you so much for the kahwa!'**
  String get defaultThanks;

  /// No description provided for @backToPage.
  ///
  /// In en, this message translates to:
  /// **'Back to {name}\'s page'**
  String backToPage(String name);

  /// No description provided for @tellFriends.
  ///
  /// In en, this message translates to:
  /// **'Tell your friends'**
  String get tellFriends;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}'**
  String goodMorning(String name);

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {name}'**
  String goodAfternoon(String name);

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name}'**
  String goodEvening(String name);

  /// No description provided for @yourCreators.
  ///
  /// In en, this message translates to:
  /// **'Your creators'**
  String get yourCreators;

  /// No description provided for @noCreatorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Find creators you love'**
  String get noCreatorsTitle;

  /// No description provided for @noCreatorsBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on a page to see it here.'**
  String get noCreatorsBody;

  /// No description provided for @latestPosts.
  ///
  /// In en, this message translates to:
  /// **'Latest posts'**
  String get latestPosts;

  /// No description provided for @feedEmpty.
  ///
  /// In en, this message translates to:
  /// **'Posts from creators you are a fan of show up here.'**
  String get feedEmpty;

  /// No description provided for @startPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Start your creator page'**
  String get startPageTitle;

  /// No description provided for @startPageBody.
  ///
  /// In en, this message translates to:
  /// **'Set a price and start receiving kahwas.'**
  String get startPageBody;

  /// No description provided for @setUpPage.
  ///
  /// In en, this message translates to:
  /// **'Set up your page'**
  String get setUpPage;

  /// No description provided for @checkUsername.
  ///
  /// In en, this message translates to:
  /// **'Pick a username'**
  String get checkUsername;

  /// No description provided for @checkAbout.
  ///
  /// In en, this message translates to:
  /// **'Write about yourself'**
  String get checkAbout;

  /// No description provided for @checkLinks.
  ///
  /// In en, this message translates to:
  /// **'Add your links'**
  String get checkLinks;

  /// No description provided for @checkGoal.
  ///
  /// In en, this message translates to:
  /// **'Set a goal'**
  String get checkGoal;

  /// No description provided for @checkTiers.
  ///
  /// In en, this message translates to:
  /// **'Offer a membership'**
  String get checkTiers;

  /// No description provided for @checkPost.
  ///
  /// In en, this message translates to:
  /// **'Write your first post'**
  String get checkPost;

  /// No description provided for @membershipUnpaidTitle.
  ///
  /// In en, this message translates to:
  /// **'A membership couldn\'t renew'**
  String get membershipUnpaidTitle;

  /// No description provided for @membershipUnpaidBody.
  ///
  /// In en, this message translates to:
  /// **'Your membership to {name} needs {amount}. Top up and it renews the next time you open kahwa.'**
  String membershipUnpaidBody(String name, String amount);

  /// No description provided for @finishKahwaTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish your kahwa'**
  String get finishKahwaTitle;

  /// No description provided for @finishKahwaBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 kahwa for {name}} other{{count} kahwas for {name}}}'**
  String finishKahwaBody(int count, String name);

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @forget.
  ///
  /// In en, this message translates to:
  /// **'Forget it'**
  String get forget;

  /// No description provided for @topUpCheckingTitle.
  ///
  /// In en, this message translates to:
  /// **'Top up being checked'**
  String get topUpCheckingTitle;

  /// No description provided for @topUpChecking.
  ///
  /// In en, this message translates to:
  /// **'Your transfer of {amount} is being checked. Your balance goes up as soon as it is found.'**
  String topUpChecking(String amount);

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @clearRead.
  ///
  /// In en, this message translates to:
  /// **'Clear read'**
  String get clearRead;

  /// No description provided for @activityEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get activityEmptyTitle;

  /// No description provided for @activityEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Kahwas, new fans and replies show up here.'**
  String get activityEmptyBody;

  /// No description provided for @activityKahwa.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{name} bought you a kahwa} other{{name} bought you {count} kahwas}}'**
  String activityKahwa(String name, int count);

  /// No description provided for @activityMembership.
  ///
  /// In en, this message translates to:
  /// **'{name} supports you monthly · {amount}'**
  String activityMembership(String name, String amount);

  /// No description provided for @activityFan.
  ///
  /// In en, this message translates to:
  /// **'{name} is now your fan'**
  String activityFan(String name);

  /// No description provided for @activityReply.
  ///
  /// In en, this message translates to:
  /// **'{name} replied to your message'**
  String activityReply(String name);

  /// No description provided for @activityTopUpOk.
  ///
  /// In en, this message translates to:
  /// **'{amount} was added to your balance'**
  String activityTopUpOk(String amount);

  /// No description provided for @activityTopUpFailed.
  ///
  /// In en, this message translates to:
  /// **'Your top up of {amount} couldn\'t be found'**
  String activityTopUpFailed(String amount);

  /// No description provided for @activityWithdrawOk.
  ///
  /// In en, this message translates to:
  /// **'{amount} was sent to your WHISH'**
  String activityWithdrawOk(String amount);

  /// No description provided for @activityWithdrawRefused.
  ///
  /// In en, this message translates to:
  /// **'Your withdrawal of {amount} was refused'**
  String activityWithdrawRefused(String amount);

  /// No description provided for @yourPage.
  ///
  /// In en, this message translates to:
  /// **'Your page'**
  String get yourPage;

  /// No description provided for @viewMyPage.
  ///
  /// In en, this message translates to:
  /// **'View my page'**
  String get viewMyPage;

  /// No description provided for @noUsername.
  ///
  /// In en, this message translates to:
  /// **'No username yet'**
  String get noUsername;

  /// No description provided for @editPageHint.
  ///
  /// In en, this message translates to:
  /// **'Name, avatar, colors, links'**
  String get editPageHint;

  /// No description provided for @pricesAndMemberships.
  ///
  /// In en, this message translates to:
  /// **'Prices and memberships'**
  String get pricesAndMemberships;

  /// No description provided for @pricesHint.
  ///
  /// In en, this message translates to:
  /// **'{price} a kahwa · {count, plural, =0{no memberships} =1{1 membership} other{{count} memberships}}'**
  String pricesHint(String price, int count);

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @goalHint.
  ///
  /// In en, this message translates to:
  /// **'What you are saving for'**
  String get goalHint;

  /// No description provided for @newPostHint.
  ///
  /// In en, this message translates to:
  /// **'Share an update'**
  String get newPostHint;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @statsHint.
  ///
  /// In en, this message translates to:
  /// **'Kahwas over time, top supporters'**
  String get statsHint;

  /// No description provided for @supportersAndMembers.
  ///
  /// In en, this message translates to:
  /// **'Supporters and members'**
  String get supportersAndMembers;

  /// No description provided for @youSupport.
  ///
  /// In en, this message translates to:
  /// **'You support'**
  String get youSupport;

  /// No description provided for @myMemberships.
  ///
  /// In en, this message translates to:
  /// **'My memberships'**
  String get myMemberships;

  /// No description provided for @activeMemberships.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{None active} =1{1 active} other{{count} active}}'**
  String activeMemberships(int count);

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @historyHint.
  ///
  /// In en, this message translates to:
  /// **'Everything that moved your balance'**
  String get historyHint;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsHint.
  ///
  /// In en, this message translates to:
  /// **'Account, security, theme, language'**
  String get settingsHint;

  /// No description provided for @billingDetails.
  ///
  /// In en, this message translates to:
  /// **'Billing details'**
  String get billingDetails;

  /// No description provided for @billingHint.
  ///
  /// In en, this message translates to:
  /// **'Where withdrawals are paid'**
  String get billingHint;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get feedback;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @topUp.
  ///
  /// In en, this message translates to:
  /// **'Top up'**
  String get topUp;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @myMembershipsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Creators you support every month.'**
  String get myMembershipsSubtitle;

  /// No description provided for @noMembershipsTitle.
  ///
  /// In en, this message translates to:
  /// **'No memberships yet'**
  String get noMembershipsTitle;

  /// No description provided for @noMembershipsBody.
  ///
  /// In en, this message translates to:
  /// **'Join a creator to support them every month.'**
  String get noMembershipsBody;

  /// No description provided for @cancelMembership.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelMembership;

  /// No description provided for @keepMembership.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get keepMembership;

  /// No description provided for @cancelMembershipTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this membership?'**
  String get cancelMembershipTitle;

  /// No description provided for @cancelMembershipBody.
  ///
  /// In en, this message translates to:
  /// **'It stops renewing. Your perks last until {date}.'**
  String cancelMembershipBody(String date);

  /// No description provided for @membershipDue.
  ///
  /// In en, this message translates to:
  /// **'Renews now: open kahwa with enough balance'**
  String get membershipDue;

  /// No description provided for @renewsOn.
  ///
  /// In en, this message translates to:
  /// **'Renews {date}'**
  String renewsOn(String date);

  /// No description provided for @membershipEnded.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get membershipEnded;

  /// No description provided for @changeTier.
  ///
  /// In en, this message translates to:
  /// **'Change tier'**
  String get changeTier;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Same as device'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageDevice.
  ///
  /// In en, this message translates to:
  /// **'Device\'s language'**
  String get languageDevice;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get changeEmail;

  /// No description provided for @changeEmailHint.
  ///
  /// In en, this message translates to:
  /// **'We send a link to the new address'**
  String get changeEmailHint;

  /// No description provided for @newEmail.
  ///
  /// In en, this message translates to:
  /// **'New email'**
  String get newEmail;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @emailChangeSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a link to {email}. Open it to finish the change, then sign in with your new email.'**
  String emailChangeSent(String email);

  /// No description provided for @emailInUse.
  ///
  /// In en, this message translates to:
  /// **'Another account already uses this email'**
  String get emailInUse;

  /// No description provided for @emailSame.
  ///
  /// In en, this message translates to:
  /// **'That\'s already your email'**
  String get emailSame;

  /// No description provided for @passwordFieldHint.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordFieldHint;

  /// No description provided for @oneTimeHint.
  ///
  /// In en, this message translates to:
  /// **'A one-off thank you. It doesn\'t unlock members-only posts.'**
  String get oneTimeHint;

  /// No description provided for @monthlyHint.
  ///
  /// In en, this message translates to:
  /// **'Charged from your balance every 30 days. Unlocks members-only posts and the perks of your tier.'**
  String get monthlyHint;

  /// No description provided for @alreadyInTier.
  ///
  /// In en, this message translates to:
  /// **'You\'re already in this tier. It renews {date}.'**
  String alreadyInTier(String date);

  /// No description provided for @goalCurrencyLocked.
  ///
  /// In en, this message translates to:
  /// **'Kahwas have already counted towards this goal, so its currency stays.'**
  String get goalCurrencyLocked;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @changePasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Your current password, then a new one'**
  String get changePasswordHint;

  /// No description provided for @aboutKahwa.
  ///
  /// In en, this message translates to:
  /// **'About kahwa'**
  String get aboutKahwa;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutHint.
  ///
  /// In en, this message translates to:
  /// **'Who you are and what kahwas help you do.'**
  String get aboutHint;

  /// No description provided for @links.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get links;

  /// No description provided for @linksHint.
  ///
  /// In en, this message translates to:
  /// **'Instagram, YouTube, your website... up to 8.'**
  String get linksHint;

  /// No description provided for @addLink.
  ///
  /// In en, this message translates to:
  /// **'Add a link'**
  String get addLink;

  /// No description provided for @linkInvalid.
  ///
  /// In en, this message translates to:
  /// **'That link doesn\'t look right'**
  String get linkInvalid;

  /// No description provided for @openPageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Setting a price opens your page to kahwas and lists it on Explore.'**
  String get openPageSubtitle;

  /// No description provided for @pageOpen.
  ///
  /// In en, this message translates to:
  /// **'Your page is open!'**
  String get pageOpen;

  /// No description provided for @memberships.
  ///
  /// In en, this message translates to:
  /// **'Memberships'**
  String get memberships;

  /// No description provided for @tiersHint.
  ///
  /// In en, this message translates to:
  /// **'Up to 3 monthly tiers. Each is a number of kahwas a month at your price.'**
  String get tiersHint;

  /// No description provided for @tierNumber.
  ///
  /// In en, this message translates to:
  /// **'Tier {number}'**
  String tierNumber(int number);

  /// No description provided for @tierName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get tierName;

  /// No description provided for @tierNameExample.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get tierNameExample;

  /// No description provided for @kahwasPerMonth.
  ///
  /// In en, this message translates to:
  /// **'Kahwas a month'**
  String get kahwasPerMonth;

  /// No description provided for @tierCosts.
  ///
  /// In en, this message translates to:
  /// **'{lbp} or {usd} a month'**
  String tierCosts(String lbp, String usd);

  /// No description provided for @perks.
  ///
  /// In en, this message translates to:
  /// **'Perks'**
  String get perks;

  /// No description provided for @perksExample.
  ///
  /// In en, this message translates to:
  /// **'Members-only posts, early access...'**
  String get perksExample;

  /// No description provided for @addTier.
  ///
  /// In en, this message translates to:
  /// **'Add a membership'**
  String get addTier;

  /// No description provided for @tierNameMissing.
  ///
  /// In en, this message translates to:
  /// **'Give this membership a name'**
  String get tierNameMissing;

  /// No description provided for @tierKahwasInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use 1 to 1000 kahwas'**
  String get tierKahwasInvalid;

  /// No description provided for @thankYouNote.
  ///
  /// In en, this message translates to:
  /// **'Thank you note'**
  String get thankYouNote;

  /// No description provided for @thankYouNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Shown to supporters right after they buy you a kahwa.'**
  String get thankYouNoteHint;

  /// No description provided for @goalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Kahwas bought in the currency of the goal count towards it.'**
  String get goalSubtitle;

  /// No description provided for @goalTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get goalTitle;

  /// No description provided for @goalTitleExample.
  ///
  /// In en, this message translates to:
  /// **'A new drawing tablet'**
  String get goalTitleExample;

  /// No description provided for @goalTitleMissing.
  ///
  /// In en, this message translates to:
  /// **'Give your goal a title'**
  String get goalTitleMissing;

  /// No description provided for @goalDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get goalDescription;

  /// No description provided for @goalDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Why it matters to you'**
  String get goalDescriptionHint;

  /// No description provided for @goalTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get goalTarget;

  /// No description provided for @goalTargetInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount above 0'**
  String get goalTargetInvalid;

  /// No description provided for @goalCurrencyHint.
  ///
  /// In en, this message translates to:
  /// **'You can change the currency until the first kahwa counts towards the goal.'**
  String get goalCurrencyHint;

  /// No description provided for @startGoal.
  ///
  /// In en, this message translates to:
  /// **'Start goal'**
  String get startGoal;

  /// No description provided for @startNewGoal.
  ///
  /// In en, this message translates to:
  /// **'Start a new goal'**
  String get startNewGoal;

  /// No description provided for @editGoal.
  ///
  /// In en, this message translates to:
  /// **'Edit goal'**
  String get editGoal;

  /// No description provided for @endGoal.
  ///
  /// In en, this message translates to:
  /// **'End goal'**
  String get endGoal;

  /// No description provided for @endGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'End this goal?'**
  String get endGoalTitle;

  /// No description provided for @endGoalBody.
  ///
  /// In en, this message translates to:
  /// **'It moves to your past goals.'**
  String get endGoalBody;

  /// No description provided for @replaceGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a new goal?'**
  String get replaceGoalTitle;

  /// No description provided for @replaceGoalBody.
  ///
  /// In en, this message translates to:
  /// **'The current one moves to your past goals.'**
  String get replaceGoalBody;

  /// No description provided for @pastGoals.
  ///
  /// In en, this message translates to:
  /// **'Past goals'**
  String get pastGoals;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get last30Days;

  /// No description provided for @last12Months.
  ///
  /// In en, this message translates to:
  /// **'12 months'**
  String get last12Months;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get allTime;

  /// No description provided for @statKahwas.
  ///
  /// In en, this message translates to:
  /// **'Kahwas'**
  String get statKahwas;

  /// No description provided for @statSupporters.
  ///
  /// In en, this message translates to:
  /// **'Supporters'**
  String get statSupporters;

  /// No description provided for @receivedIn.
  ///
  /// In en, this message translates to:
  /// **'Received in {currency}'**
  String receivedIn(String currency);

  /// No description provided for @payingMembers.
  ///
  /// In en, this message translates to:
  /// **'Paying members'**
  String get payingMembers;

  /// No description provided for @monthlyFromMembers.
  ///
  /// In en, this message translates to:
  /// **'Monthly from members'**
  String get monthlyFromMembers;

  /// No description provided for @kahwasOverTime.
  ///
  /// In en, this message translates to:
  /// **'Kahwas over time'**
  String get kahwasOverTime;

  /// No description provided for @topSupporters.
  ///
  /// In en, this message translates to:
  /// **'Top supporters'**
  String get topSupporters;

  /// No description provided for @noSupportersYet.
  ///
  /// In en, this message translates to:
  /// **'No supporters yet'**
  String get noSupportersYet;

  /// No description provided for @noSupportersBody.
  ///
  /// In en, this message translates to:
  /// **'Share your page to get your first kahwa.'**
  String get noSupportersBody;

  /// No description provided for @noMembersYet.
  ///
  /// In en, this message translates to:
  /// **'No members yet.'**
  String get noMembersYet;

  /// No description provided for @allSupporters.
  ///
  /// In en, this message translates to:
  /// **'All supporters'**
  String get allSupporters;

  /// No description provided for @supporterSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Once} other{{count} times}} · last {when}'**
  String supporterSummary(int count, String when);

  /// No description provided for @walletSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What you buy kahwas with, and what you received.'**
  String get walletSubtitle;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// No description provided for @withdrawn.
  ///
  /// In en, this message translates to:
  /// **'Withdrawn'**
  String get withdrawn;

  /// No description provided for @lastTopUp.
  ///
  /// In en, this message translates to:
  /// **'Your last top up'**
  String get lastTopUp;

  /// No description provided for @topUpAdded.
  ///
  /// In en, this message translates to:
  /// **'{amount} was added to your balance.'**
  String topUpAdded(String amount);

  /// No description provided for @topUpNotFound.
  ///
  /// In en, this message translates to:
  /// **'Your transfer of {amount} couldn\'t be found, so nothing was added. If you did send it, try again with the same details.'**
  String topUpNotFound(String amount);

  /// No description provided for @topUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your balance is what you buy kahwas with. You add to it by sending money with WHISH MONEY.'**
  String get topUpSubtitle;

  /// No description provided for @topUpUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Top ups aren\'t available right now.'**
  String get topUpUnavailable;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @amountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount above 0'**
  String get amountInvalid;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @sendWith.
  ///
  /// In en, this message translates to:
  /// **'Send {amount} from your {currency} balance with WHISH MONEY, then come back and confirm.'**
  String sendWith(String amount, String currency);

  /// No description provided for @payingFounder.
  ///
  /// In en, this message translates to:
  /// **'You pay kahwa itself, through its founder’s WHISH account, so no creator has to share their phone number. Each transfer is checked by hand before it reaches your balance, which also stops fraud.'**
  String get payingFounder;

  /// No description provided for @payWithWhish.
  ///
  /// In en, this message translates to:
  /// **'Pay with WHISH'**
  String get payWithWhish;

  /// No description provided for @whishUpdate.
  ///
  /// In en, this message translates to:
  /// **'WHISH didn\'t open on the payment? Install or update the WHISH app and try again.'**
  String get whishUpdate;

  /// No description provided for @scanFromOtherPhone.
  ///
  /// In en, this message translates to:
  /// **'Paying from another phone? Scan this code in the WHISH app.'**
  String get scanFromOtherPhone;

  /// No description provided for @scanCode.
  ///
  /// In en, this message translates to:
  /// **'Scan this code in the WHISH app.'**
  String get scanCode;

  /// No description provided for @senderPhone.
  ///
  /// In en, this message translates to:
  /// **'The WHISH number you sent from'**
  String get senderPhone;

  /// No description provided for @senderPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'So we can find your transfer.'**
  String get senderPhoneHint;

  /// No description provided for @senderPhoneCheck.
  ///
  /// In en, this message translates to:
  /// **'So we can find your transfer. Check it is the number you sent from this time.'**
  String get senderPhoneCheck;

  /// No description provided for @senderPhoneMissing.
  ///
  /// In en, this message translates to:
  /// **'Enter the number you sent the money from'**
  String get senderPhoneMissing;

  /// No description provided for @iSentTheMoney.
  ///
  /// In en, this message translates to:
  /// **'I sent the money'**
  String get iSentTheMoney;

  /// No description provided for @cancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get cancelRequest;

  /// No description provided for @withdrawSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get your balance out to your WHISH account. Requests are paid by hand.'**
  String get withdrawSubtitle;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @billingFirstTitle.
  ///
  /// In en, this message translates to:
  /// **'Billing details first'**
  String get billingFirstTitle;

  /// No description provided for @billingFirst.
  ///
  /// In en, this message translates to:
  /// **'Add your billing details first, so we know where to send your money.'**
  String get billingFirst;

  /// No description provided for @withdrawWaitingTitle.
  ///
  /// In en, this message translates to:
  /// **'Your request is waiting'**
  String get withdrawWaitingTitle;

  /// No description provided for @withdrawWaiting.
  ///
  /// In en, this message translates to:
  /// **'You asked for {amount}, which you get through WHISH MONEY once it is sent. To ask for another amount, cancel this request first.'**
  String withdrawWaiting(String amount);

  /// No description provided for @paidTo.
  ///
  /// In en, this message translates to:
  /// **'Paid to WHISH {phone}'**
  String paidTo(String phone);

  /// No description provided for @requestWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Request withdrawal'**
  String get requestWithdraw;

  /// No description provided for @withdrawAmountMissing.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount to withdraw'**
  String get withdrawAmountMissing;

  /// No description provided for @withdrawTooMuch.
  ///
  /// In en, this message translates to:
  /// **'You can\'t withdraw more than your balance'**
  String get withdrawTooMuch;

  /// No description provided for @requestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get requestSent;

  /// No description provided for @yourRequests.
  ///
  /// In en, this message translates to:
  /// **'Your requests'**
  String get yourRequests;

  /// No description provided for @noRequests.
  ///
  /// In en, this message translates to:
  /// **'No requests yet.'**
  String get noRequests;

  /// No description provided for @statusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// No description provided for @statusRefused.
  ///
  /// In en, this message translates to:
  /// **'Refused'**
  String get statusRefused;

  /// No description provided for @statusWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get statusWaiting;

  /// No description provided for @billingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Withdrawals are sent here with WHISH MONEY.'**
  String get billingSubtitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @whishNumber.
  ///
  /// In en, this message translates to:
  /// **'WHISH number'**
  String get whishNumber;

  /// No description provided for @whishNumberHint.
  ///
  /// In en, this message translates to:
  /// **'The number of your WHISH account.'**
  String get whishNumberHint;

  /// No description provided for @phoneMissing.
  ///
  /// In en, this message translates to:
  /// **'Enter your WHISH number'**
  String get phoneMissing;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a phone number, such as 70 123 456'**
  String get phoneInvalid;

  /// No description provided for @billingPrivate.
  ///
  /// In en, this message translates to:
  /// **'Only you and the kahwa team can see these.'**
  String get billingPrivate;

  /// No description provided for @filterBought.
  ///
  /// In en, this message translates to:
  /// **'Bought'**
  String get filterBought;

  /// No description provided for @filterReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get filterReceived;

  /// No description provided for @filterTopUps.
  ///
  /// In en, this message translates to:
  /// **'Top ups'**
  String get filterTopUps;

  /// No description provided for @filterWithdrawals.
  ///
  /// In en, this message translates to:
  /// **'Withdrawals'**
  String get filterWithdrawals;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Kahwas, top ups and withdrawals show up here.'**
  String get historyEmptyBody;

  /// No description provided for @historyBought.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{A kahwa for {name}} other{{count} kahwas for {name}}}'**
  String historyBought(int count, String name);

  /// No description provided for @historyReceived.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{A kahwa from {name}} other{{count} kahwas from {name}}}'**
  String historyReceived(int count, String name);

  /// No description provided for @historyMembershipTo.
  ///
  /// In en, this message translates to:
  /// **'Membership to {name}'**
  String historyMembershipTo(String name);

  /// No description provided for @historyMembershipFrom.
  ///
  /// In en, this message translates to:
  /// **'Membership from {name}'**
  String historyMembershipFrom(String name);

  /// No description provided for @historyTopUp.
  ///
  /// In en, this message translates to:
  /// **'Top up'**
  String get historyTopUp;

  /// No description provided for @historyTopUpFailed.
  ///
  /// In en, this message translates to:
  /// **'Top up not found'**
  String get historyTopUpFailed;

  /// No description provided for @historyWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal'**
  String get historyWithdrawal;

  /// No description provided for @historyWithdrawalRefused.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal refused'**
  String get historyWithdrawalRefused;

  /// No description provided for @adminOnly.
  ///
  /// In en, this message translates to:
  /// **'For admins only'**
  String get adminOnly;

  /// No description provided for @heldForUsers.
  ///
  /// In en, this message translates to:
  /// **'Held for users'**
  String get heldForUsers;

  /// No description provided for @heldForUsersHint.
  ///
  /// In en, this message translates to:
  /// **'Your WHISH balance should never go below this.'**
  String get heldForUsersHint;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @creators.
  ///
  /// In en, this message translates to:
  /// **'Creators'**
  String get creators;

  /// No description provided for @topUpRequests.
  ///
  /// In en, this message translates to:
  /// **'Top ups'**
  String get topUpRequests;

  /// No description provided for @withdrawRequests.
  ///
  /// In en, this message translates to:
  /// **'Withdrawals'**
  String get withdrawRequests;

  /// No description provided for @nothingWaiting.
  ///
  /// In en, this message translates to:
  /// **'Nothing waiting.'**
  String get nothingWaiting;

  /// No description provided for @sentFrom.
  ///
  /// In en, this message translates to:
  /// **'from {phone}'**
  String sentFrom(String phone);

  /// No description provided for @markReceived.
  ///
  /// In en, this message translates to:
  /// **'Mark as received?'**
  String get markReceived;

  /// No description provided for @markNotReceived.
  ///
  /// In en, this message translates to:
  /// **'Mark as not received?'**
  String get markNotReceived;

  /// No description provided for @notReceived.
  ///
  /// In en, this message translates to:
  /// **'Not received'**
  String get notReceived;

  /// No description provided for @markPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark as paid?'**
  String get markPaid;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @refuse.
  ///
  /// In en, this message translates to:
  /// **'Refuse'**
  String get refuse;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @resumeTitle.
  ///
  /// In en, this message translates to:
  /// **'Resume {tier}?'**
  String resumeTitle(String tier);

  /// No description provided for @resumeBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing is charged now. It renews {date}.'**
  String resumeBody(String date);

  /// No description provided for @resumeHint.
  ///
  /// In en, this message translates to:
  /// **'Your month is paid until {date}, so taking it back is free.'**
  String resumeHint(String date);

  /// No description provided for @copyFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t copy the link'**
  String get copyFailed;

  /// No description provided for @finishMembershipTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish your membership'**
  String get finishMembershipTitle;

  /// No description provided for @finishMembershipBody.
  ///
  /// In en, this message translates to:
  /// **'{tier} with {name}'**
  String finishMembershipBody(String tier, String name);

  /// No description provided for @colorOption.
  ///
  /// In en, this message translates to:
  /// **'Color {n}'**
  String colorOption(int n);

  /// No description provided for @patternOption.
  ///
  /// In en, this message translates to:
  /// **'Pattern {n}'**
  String patternOption(int n);

  /// No description provided for @aboutExample.
  ///
  /// In en, this message translates to:
  /// **'I draw Beirut, one street at a time. Every kahwa buys me paper and paint.'**
  String get aboutExample;

  /// No description provided for @addMoney.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addMoney;

  /// No description provided for @takeMoneyOut.
  ///
  /// In en, this message translates to:
  /// **'Take out'**
  String get takeMoneyOut;

  /// No description provided for @adjustBody.
  ///
  /// In en, this message translates to:
  /// **'This is kept for good. The user sees it with your reason in their history and their activity.'**
  String get adjustBody;

  /// No description provided for @adjustFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not correct the balance. A balance cannot go below zero.'**
  String get adjustFailed;

  /// No description provided for @adjustNote.
  ///
  /// In en, this message translates to:
  /// **'Only for mistakes, such as a transfer counted twice. Answer requests the usual way.'**
  String get adjustNote;

  /// No description provided for @adjustAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add {amount} to {name}?'**
  String adjustAddTitle(String amount, String name);

  /// No description provided for @adjustRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Take {amount} out of {name}’s balance?'**
  String adjustRemoveTitle(String amount, String name);

  /// No description provided for @correctBalance.
  ///
  /// In en, this message translates to:
  /// **'Correct balance'**
  String get correctBalance;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @reasonHint.
  ///
  /// In en, this message translates to:
  /// **'What happened, so anyone can understand it later'**
  String get reasonHint;

  /// No description provided for @reasonMissing.
  ///
  /// In en, this message translates to:
  /// **'Say why, in a few words.'**
  String get reasonMissing;

  /// No description provided for @adminRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get adminRequests;

  /// No description provided for @adminLog.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get adminLog;

  /// No description provided for @answered.
  ///
  /// In en, this message translates to:
  /// **'Answered'**
  String get answered;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change your password?'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordBody.
  ///
  /// In en, this message translates to:
  /// **'We will email a link to {email}. Open it to choose a new password.'**
  String changePasswordBody(String email);

  /// No description provided for @codeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6 digits.'**
  String get codeInvalid;

  /// No description provided for @codeWrong.
  ///
  /// In en, this message translates to:
  /// **'That code is not right. Try the one on screen now.'**
  String get codeWrong;

  /// No description provided for @confirmItsYou.
  ///
  /// In en, this message translates to:
  /// **'Confirm it’s you'**
  String get confirmItsYou;

  /// No description provided for @confirmItsYouBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to go on.'**
  String get confirmItsYouBody;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @creator.
  ///
  /// In en, this message translates to:
  /// **'Creator'**
  String get creator;

  /// No description provided for @devices.
  ///
  /// In en, this message translates to:
  /// **'Signed in devices'**
  String get devices;

  /// No description provided for @devicesHint.
  ///
  /// In en, this message translates to:
  /// **'See where you are signed in'**
  String get devicesHint;

  /// No description provided for @devicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every phone and browser where your account is open.'**
  String get devicesSubtitle;

  /// No description provided for @devicesNote.
  ///
  /// In en, this message translates to:
  /// **'A device you sign out leaves as soon as it is online. If you think someone else has your password, also change it.'**
  String get devicesNote;

  /// No description provided for @thisDevice.
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get thisDevice;

  /// No description provided for @unknownDevice.
  ///
  /// In en, this message translates to:
  /// **'Unknown device'**
  String get unknownDevice;

  /// No description provided for @lastActive.
  ///
  /// In en, this message translates to:
  /// **'Active {time}'**
  String lastActive(String time);

  /// No description provided for @signOutDeviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out of {device}?'**
  String signOutDeviceTitle(String device);

  /// No description provided for @signOutDeviceBody.
  ///
  /// In en, this message translates to:
  /// **'You will have to sign in again there to use kahwa.'**
  String get signOutDeviceBody;

  /// No description provided for @signOutOthers.
  ///
  /// In en, this message translates to:
  /// **'Sign out of all other devices'**
  String get signOutOthers;

  /// No description provided for @signOutOthersTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out everywhere else?'**
  String get signOutOthersTitle;

  /// No description provided for @signedOutOthers.
  ///
  /// In en, this message translates to:
  /// **'Your other devices are signed out.'**
  String get signedOutOthers;

  /// No description provided for @signOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutTitle;

  /// No description provided for @signOutBody.
  ///
  /// In en, this message translates to:
  /// **'You can sign back in any time with the same account.'**
  String get signOutBody;

  /// No description provided for @tapToChangeEmail.
  ///
  /// In en, this message translates to:
  /// **'Tap to change it'**
  String get tapToChangeEmail;

  /// No description provided for @noEmailYet.
  ///
  /// In en, this message translates to:
  /// **'No email on this account yet. Tap to add one.'**
  String get noEmailYet;

  /// No description provided for @addEmail.
  ///
  /// In en, this message translates to:
  /// **'Add an email'**
  String get addEmail;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @securityHint.
  ///
  /// In en, this message translates to:
  /// **'Email and password'**
  String get securityHint;

  /// No description provided for @securitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'kahwa holds money, so keep your account locked tight.'**
  String get securitySubtitle;

  /// No description provided for @emailVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get emailVerified;

  /// No description provided for @emailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Not verified yet. Verify it to buy, top up or withdraw.'**
  String get emailNotVerified;

  /// No description provided for @iVerified.
  ///
  /// In en, this message translates to:
  /// **'I opened the link'**
  String get iVerified;

  /// No description provided for @notVerifiedYet.
  ///
  /// In en, this message translates to:
  /// **'Not verified yet. Open the link in the email we sent.'**
  String get notVerifiedYet;

  /// No description provided for @sendLink.
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get sendLink;

  /// No description provided for @verificationSent.
  ///
  /// In en, this message translates to:
  /// **'A link to verify your email was sent to {email}.'**
  String verificationSent(String email);

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailBody.
  ///
  /// In en, this message translates to:
  /// **'Money only moves on verified accounts. Open the link we sent to {email}, or ask for a new one.'**
  String verifyEmailBody(String email);

  /// No description provided for @verifyEmailBanner.
  ///
  /// In en, this message translates to:
  /// **'Open the link we sent to {email} before buying, topping up or withdrawing.'**
  String verifyEmailBanner(String email);

  /// No description provided for @emailWait.
  ///
  /// In en, this message translates to:
  /// **'An email was just sent. You can ask again in {seconds} s.'**
  String emailWait(int seconds);

  /// No description provided for @twoStep.
  ///
  /// In en, this message translates to:
  /// **'Two-step verification'**
  String get twoStep;

  /// No description provided for @twoStepIsOn.
  ///
  /// In en, this message translates to:
  /// **'On: signing in asks for a code'**
  String get twoStepIsOn;

  /// No description provided for @twoStepIsOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get twoStepIsOff;

  /// No description provided for @twoStepExplain.
  ///
  /// In en, this message translates to:
  /// **'Signing in on a new device will also ask for a 6 digit code from an authenticator app, such as Google Authenticator or Microsoft Authenticator. Your password alone is no longer enough.'**
  String get twoStepExplain;

  /// No description provided for @twoStepBackup.
  ///
  /// In en, this message translates to:
  /// **'Keep your authenticator app backed up, such as with Google Authenticator’s cloud backup. Without it, getting back into your account means contacting us.'**
  String get twoStepBackup;

  /// No description provided for @turnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get turnOn;

  /// No description provided for @turnOff.
  ///
  /// In en, this message translates to:
  /// **'Turn off'**
  String get turnOff;

  /// No description provided for @twoStepOn.
  ///
  /// In en, this message translates to:
  /// **'Two-step verification is on.'**
  String get twoStepOn;

  /// No description provided for @twoStepOff.
  ///
  /// In en, this message translates to:
  /// **'Two-step verification is off.'**
  String get twoStepOff;

  /// No description provided for @twoStepOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn off two-step verification?'**
  String get twoStepOffTitle;

  /// No description provided for @twoStepOffBody.
  ///
  /// In en, this message translates to:
  /// **'Your password alone will be enough to sign in again.'**
  String get twoStepOffBody;

  /// No description provided for @twoStepUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Two-step verification is not available yet. Try again later.'**
  String get twoStepUnavailable;

  /// No description provided for @twoStepSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your authenticator'**
  String get twoStepSetupTitle;

  /// No description provided for @twoStepSetupBody.
  ///
  /// In en, this message translates to:
  /// **'Scan this code with your authenticator app, or type the key into it. Then enter the 6 digit code it shows.'**
  String get twoStepSetupBody;

  /// No description provided for @twoStepKey.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get twoStepKey;

  /// No description provided for @twoStepCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code from the app'**
  String get twoStepCodeLabel;

  /// No description provided for @twoStepCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your code'**
  String get twoStepCodeTitle;

  /// No description provided for @twoStepCodeBody.
  ///
  /// In en, this message translates to:
  /// **'Open your authenticator app and enter the 6 digit code for kahwa.'**
  String get twoStepCodeBody;

  /// No description provided for @openAuthenticator.
  ///
  /// In en, this message translates to:
  /// **'Open in authenticator app'**
  String get openAuthenticator;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @lookAroundFirst.
  ///
  /// In en, this message translates to:
  /// **'Look around first'**
  String get lookAroundFirst;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @historyAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Correction by kahwa'**
  String get historyAdjustment;

  /// No description provided for @paidByWhish.
  ///
  /// In en, this message translates to:
  /// **'paid by WHISH'**
  String get paidByWhish;

  /// No description provided for @kahwaKeptForTopUp.
  ///
  /// In en, this message translates to:
  /// **'Your kahwa is kept. Finish it from Home once your top up is in.'**
  String get kahwaKeptForTopUp;

  /// No description provided for @markReceivedBody.
  ///
  /// In en, this message translates to:
  /// **'{amount} will be added to their balance. Check the transfer is in your WHISH account first.'**
  String markReceivedBody(String amount);

  /// No description provided for @markNotReceivedBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing is added. They are told the transfer was not found.'**
  String get markNotReceivedBody;

  /// No description provided for @markPaidBody.
  ///
  /// In en, this message translates to:
  /// **'Send this to the WHISH number above first. It is taken out of their balance once you confirm.'**
  String get markPaidBody;

  /// No description provided for @refuseBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing is sent and their balance stays the same.'**
  String get refuseBody;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @sentAt.
  ///
  /// In en, this message translates to:
  /// **'Sent at'**
  String get sentAt;

  /// No description provided for @requestedAt.
  ///
  /// In en, this message translates to:
  /// **'Asked on'**
  String get requestedAt;

  /// No description provided for @reference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get reference;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get statusApproved;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Not received'**
  String get statusRejected;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get statusPending;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'Nobody found.'**
  String get noResults;

  /// No description provided for @nothingYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing yet.'**
  String get nothingYet;

  /// No description provided for @searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search by name or username'**
  String get searchUsers;

  /// No description provided for @usersCount.
  ///
  /// In en, this message translates to:
  /// **'{users} users, {creators} of them creators'**
  String usersCount(int users, int creators);

  /// No description provided for @viewPage.
  ///
  /// In en, this message translates to:
  /// **'View page'**
  String get viewPage;

  /// No description provided for @statSpent.
  ///
  /// In en, this message translates to:
  /// **'Spent ({currency})'**
  String statSpent(String currency);

  /// No description provided for @statReceived.
  ///
  /// In en, this message translates to:
  /// **'Received ({currency})'**
  String statReceived(String currency);

  /// No description provided for @statWithdrawn.
  ///
  /// In en, this message translates to:
  /// **'Withdrawn ({currency})'**
  String statWithdrawn(String currency);

  /// No description provided for @paysTo.
  ///
  /// In en, this message translates to:
  /// **'Member of {name}'**
  String paysTo(String name);

  /// No description provided for @paidBy.
  ///
  /// In en, this message translates to:
  /// **'{name} is a member'**
  String paidBy(String name);

  /// No description provided for @logTopUpApproved.
  ///
  /// In en, this message translates to:
  /// **'Top up of {name} received'**
  String logTopUpApproved(String name);

  /// No description provided for @logTopUpRejected.
  ///
  /// In en, this message translates to:
  /// **'Top up of {name} not received'**
  String logTopUpRejected(String name);

  /// No description provided for @logWithdrawPaid.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal of {name} paid'**
  String logWithdrawPaid(String name);

  /// No description provided for @logWithdrawRefused.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal of {name} refused'**
  String logWithdrawRefused(String name);

  /// No description provided for @logAdjustment.
  ///
  /// In en, this message translates to:
  /// **'{admin} corrected the balance of {name}'**
  String logAdjustment(String admin, String name);

  /// No description provided for @activityAdjustment.
  ///
  /// In en, this message translates to:
  /// **'kahwa corrected your balance: {amount}'**
  String activityAdjustment(String amount);

  /// No description provided for @activityDirectPayment.
  ///
  /// In en, this message translates to:
  /// **'{name} says they sent you {amount} by WHISH. Check and confirm it.'**
  String activityDirectPayment(String name, String amount);

  /// No description provided for @activityDirectConfirmed.
  ///
  /// In en, this message translates to:
  /// **'{name} received your {amount}. Thank you!'**
  String activityDirectConfirmed(String name, String amount);

  /// No description provided for @activityDirectRejected.
  ///
  /// In en, this message translates to:
  /// **'{name} did not find your {amount} in WHISH.'**
  String activityDirectRejected(String name, String amount);

  /// No description provided for @directPayTitle.
  ///
  /// In en, this message translates to:
  /// **'Get paid to your WHISH'**
  String get directPayTitle;

  /// No description provided for @directPayHint.
  ///
  /// In en, this message translates to:
  /// **'Let supporters pay you directly'**
  String get directPayHint;

  /// No description provided for @directPaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Supporters can send kahwas straight to your WHISH account instead of from their kahwa balance.'**
  String get directPaySubtitle;

  /// No description provided for @directPaySwitch.
  ///
  /// In en, this message translates to:
  /// **'Take payments to my WHISH account'**
  String get directPaySwitch;

  /// No description provided for @directPaySwitchHint.
  ///
  /// In en, this message translates to:
  /// **'Paying from a kahwa balance keeps working too.'**
  String get directPaySwitchHint;

  /// No description provided for @directPayNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'What changes'**
  String get directPayNoticeTitle;

  /// No description provided for @directPayNotice.
  ///
  /// In en, this message translates to:
  /// **'Supporters who pay this way open your link in WHISH and see your name there, never your number. kahwa cannot see these payments: you confirm each one when it arrives, and only then do the kahwas count on your page. They never go through your kahwa balance.'**
  String get directPayNotice;

  /// No description provided for @directPayLinksHint.
  ///
  /// In en, this message translates to:
  /// **'In the WHISH app, open Whish Me and take a screenshot of your QR code. Then tap the QR button below and pick that screenshot. Add one for each currency you take: WHISH only pays a code from a balance in its currency.'**
  String get directPayLinksHint;

  /// No description provided for @directPayLinkFor.
  ///
  /// In en, this message translates to:
  /// **'Whish Me code in {currency}'**
  String directPayLinkFor(String currency);

  /// No description provided for @directPayFromPicture.
  ///
  /// In en, this message translates to:
  /// **'Read it from your QR screenshot'**
  String get directPayFromPicture;

  /// No description provided for @directPayNoCode.
  ///
  /// In en, this message translates to:
  /// **'No WHISH code found in this picture. Pick the screenshot of your QR code from Whish Me.'**
  String get directPayNoCode;

  /// No description provided for @directPayCodeRead.
  ///
  /// In en, this message translates to:
  /// **'Code read'**
  String get directPayCodeRead;

  /// No description provided for @directPayLinkInvalid.
  ///
  /// In en, this message translates to:
  /// **'Not a WHISH code. Pick your Whish Me picture, or paste its link.'**
  String get directPayLinkInvalid;

  /// No description provided for @directPayLinkMissing.
  ///
  /// In en, this message translates to:
  /// **'Add at least one link.'**
  String get directPayLinkMissing;

  /// No description provided for @directPaymentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payments to confirm'**
  String get directPaymentsTitle;

  /// No description provided for @directPaymentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Kahwas supporters say they sent to your WHISH account. Confirm the ones you find there.'**
  String get directPaymentsSubtitle;

  /// No description provided for @directPaymentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No payments yet.'**
  String get directPaymentsEmpty;

  /// No description provided for @directPaymentsWaiting.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 waiting for you} other{{count} waiting for you}}'**
  String directPaymentsWaiting(int count);

  /// No description provided for @directConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Only if {amount} from {phone} is in your WHISH account. The kahwas then count on your page and the supporter is told.'**
  String directConfirmBody(String amount, String phone);

  /// No description provided for @directRejectBody.
  ///
  /// In en, this message translates to:
  /// **'The kahwas will not count, and the supporter is told you did not find the transfer.'**
  String get directRejectBody;

  /// No description provided for @payWith.
  ///
  /// In en, this message translates to:
  /// **'Pay with'**
  String get payWith;

  /// No description provided for @payWithBalance.
  ///
  /// In en, this message translates to:
  /// **'My balance'**
  String get payWithBalance;

  /// No description provided for @payWithWhishTo.
  ///
  /// In en, this message translates to:
  /// **'WHISH to {name}'**
  String payWithWhishTo(String name);

  /// No description provided for @directSendTo.
  ///
  /// In en, this message translates to:
  /// **'Send {amount} with WHISH to {name}.'**
  String directSendTo(String amount, String name);

  /// No description provided for @directNotice.
  ///
  /// In en, this message translates to:
  /// **'This goes straight to {name}, not through kahwa. The kahwas show on the page once {name} confirms the money arrived.'**
  String directNotice(String name);

  /// No description provided for @senderPhoneHintDirect.
  ///
  /// In en, this message translates to:
  /// **'The number you send from, so they can find your transfer.'**
  String get senderPhoneHintDirect;

  /// No description provided for @iSentAmount.
  ///
  /// In en, this message translates to:
  /// **'I sent {amount}'**
  String iSentAmount(String amount);

  /// No description provided for @directSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Did you send {amount}?'**
  String directSentTitle(String amount);

  /// No description provided for @directSentBody.
  ///
  /// In en, this message translates to:
  /// **'Only confirm once the transfer went through in WHISH. {name} will check it arrived.'**
  String directSentBody(String name);

  /// No description provided for @directWaitingTitle.
  ///
  /// In en, this message translates to:
  /// **'Sent! Waiting for confirmation'**
  String get directWaitingTitle;

  /// No description provided for @directWaitingBody.
  ///
  /// In en, this message translates to:
  /// **'{name} will confirm the money arrived. You will see it in your activity.'**
  String directWaitingBody(String name);

  /// No description provided for @currencyLbp.
  ///
  /// In en, this message translates to:
  /// **'Lebanese lira'**
  String get currencyLbp;

  /// No description provided for @currencyUsd.
  ///
  /// In en, this message translates to:
  /// **'US dollar'**
  String get currencyUsd;

  /// No description provided for @devicesNoteTwoStep.
  ///
  /// In en, this message translates to:
  /// **'A device you sign out leaves as soon as it is online. If you think someone else has your password, also change it and turn on two-step verification.'**
  String get devicesNoteTwoStep;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Your password was changed.'**
  String get passwordChanged;

  /// No description provided for @currentPasswordWrong.
  ///
  /// In en, this message translates to:
  /// **'That is not your current password.'**
  String get currentPasswordWrong;

  /// No description provided for @senderPhoneOf.
  ///
  /// In en, this message translates to:
  /// **'Sent from WHISH number'**
  String get senderPhoneOf;

  /// No description provided for @directPaymentsHint.
  ///
  /// In en, this message translates to:
  /// **'Kahwas sent straight to your WHISH'**
  String get directPaymentsHint;

  /// No description provided for @directPaymentsNoneWaiting.
  ///
  /// In en, this message translates to:
  /// **'Nothing to confirm right now.'**
  String get directPaymentsNoneWaiting;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return L10nAr();
    case 'en':
      return L10nEn();
    case 'fr':
      return L10nFr();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
