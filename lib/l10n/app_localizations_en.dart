// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get tagline => 'Buy your favorite Lebanese creators a kahwa';

  @override
  String get welcomeSubtitle =>
      'Support the people who make what you love, one cup at a time. Monthly memberships, posts and goals, all in one page.';

  @override
  String get madeInLebanon => 'Made in Lebanon';

  @override
  String get exploreCreators => 'Explore creators';

  @override
  String get startYourPage => 'Start your page';

  @override
  String get howItWorks => 'How it works';

  @override
  String get step1 => 'Top up your balance with WHISH MONEY.';

  @override
  String get step2 => 'Buy a creator kahwas, or join their monthly membership.';

  @override
  String get step3 =>
      'Creators withdraw what they receive to their WHISH account.';

  @override
  String get meetCreators => 'Meet the creators';

  @override
  String get seeAll => 'See all';

  @override
  String get openSource => 'kahwa is open source';

  @override
  String get featureKahwaTitle => 'Kahwas that add up';

  @override
  String get featureKahwaBody =>
      'Buy a kahwa or a few, leave a message, and watch your support grow their goal.';

  @override
  String get featureMembersTitle => 'Monthly memberships';

  @override
  String get featureMembersBody =>
      'Support every month and unlock members-only posts and perks.';

  @override
  String get featurePageTitle => 'Your page in two minutes';

  @override
  String get featurePageBody =>
      'Pick a color, an avatar and a price. Share your link and start receiving kahwas.';

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get saved => 'Saved';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get remove => 'Remove';

  @override
  String get send => 'Send';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get retry => 'Try again';

  @override
  String get clear => 'Clear';

  @override
  String get all => 'All';

  @override
  String get or => 'or';

  @override
  String get share => 'Share';

  @override
  String get continueAction => 'Continue';

  @override
  String get somethingWrong => 'Something went wrong. Try again.';

  @override
  String get loadFailed => 'Couldn\'t load this';

  @override
  String get loadFailedHint => 'Check your connection and try again.';

  @override
  String get linkFailed => 'Couldn\'t open the link';

  @override
  String get justNow => 'just now';

  @override
  String get someone => 'Someone';

  @override
  String get private => 'Private';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This week';

  @override
  String get earlier => 'Earlier';

  @override
  String get showMore => 'Show more';

  @override
  String get more => 'More';

  @override
  String get fewer => 'Fewer';

  @override
  String get tabHome => 'Home';

  @override
  String get tabExplore => 'Explore';

  @override
  String get tabActivity => 'Activity';

  @override
  String get tabMe => 'Me';

  @override
  String get tabWall => 'Wall';

  @override
  String get tabPosts => 'Posts';

  @override
  String get tabMemberships => 'Memberships';

  @override
  String get tabAbout => 'About';

  @override
  String get signInTitle => 'Welcome to kahwa';

  @override
  String get signInSubtitle =>
      'Sign in, or create your account with the same form.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get newAccountHint =>
      'New here? Enter your email and a password and your account is created.';

  @override
  String get emailMissing => 'Enter your email';

  @override
  String get emailInvalid => 'That email doesn\'t look right';

  @override
  String get passwordMissing => 'Enter your password';

  @override
  String get passwordShort => 'Use at least 6 characters';

  @override
  String get passwordWrong => 'Wrong email or password';

  @override
  String get tooManyAttempts => 'Too many attempts. Try again later.';

  @override
  String get noInternet => 'Check your internet connection';

  @override
  String get signInFailed => 'Couldn\'t sign in. Try again.';

  @override
  String get googleFailed => 'Google sign in didn\'t work. Try again.';

  @override
  String get googleUsesPassword => 'This email signs in with a password';

  @override
  String get resetTitle => 'Reset your password';

  @override
  String get resetSubtitle => 'We\'ll email you a link to choose a new one.';

  @override
  String get sendResetLink => 'Send link';

  @override
  String get resetSentTitle => 'Check your inbox';

  @override
  String resetSent(String email) {
    return 'A link to reset your password was sent to $email.';
  }

  @override
  String get setupNameTitle => 'What should we call you?';

  @override
  String get setupNameSubtitle =>
      'Your name shows on your page and next to the kahwas you buy.';

  @override
  String get setupLookTitle => 'Pick your look';

  @override
  String get setupLookSubtitle =>
      'An avatar and a color for your page. You can change them any time.';

  @override
  String get setupRoleTitle => 'How will you use kahwa?';

  @override
  String get setupRoleSubtitle => 'You can always do both later.';

  @override
  String get setupCreatorTitle => 'Open your page';

  @override
  String get setupCreatorSubtitle =>
      'Tell people what you make and set the price of a kahwa.';

  @override
  String get roleCreatorTitle => 'I make things';

  @override
  String get roleCreatorBody =>
      'Open a page and receive kahwas and memberships.';

  @override
  String get roleSupporterTitle => 'I\'m here to support';

  @override
  String get roleSupporterBody => 'Find creators and buy them kahwas.';

  @override
  String get yourName => 'Your name';

  @override
  String get username => 'Username';

  @override
  String get usernameHint => 'The address of your page. Optional.';

  @override
  String usernameLength(int min, int max) {
    return 'Use $min to $max characters';
  }

  @override
  String get usernameCharacters => 'Use only letters, numbers and underscores';

  @override
  String get usernameReserved => 'This username isn\'t available';

  @override
  String get usernameTaken => 'Someone already has this username';

  @override
  String get nameMissing => 'Enter a name';

  @override
  String get avatar => 'Avatar';

  @override
  String get pageColor => 'Page color';

  @override
  String get pageColorHint =>
      'Your color is used for your banner and every button on your page.';

  @override
  String get bannerPattern => 'Banner pattern';

  @override
  String get taglineLabel => 'Tagline';

  @override
  String get taglineHint => 'One line under your name.';

  @override
  String get taglineExample => 'Illustrator in Beirut';

  @override
  String get whatYouMake => 'What you make';

  @override
  String get kahwaPrice => 'Price of a kahwa';

  @override
  String get kahwaPriceHint => 'Supporters pay in L.L. or \$, so set both.';

  @override
  String get priceInvalid => 'Enter a price above 0 in both currencies';

  @override
  String get openMyPage => 'Open my page';

  @override
  String get categoryArt => 'Art';

  @override
  String get categoryMusic => 'Music';

  @override
  String get categoryWriting => 'Writing';

  @override
  String get categoryVideo => 'Video';

  @override
  String get categoryPhotography => 'Photography';

  @override
  String get categoryGaming => 'Gaming';

  @override
  String get categoryPodcast => 'Podcasts';

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryEducation => 'Education';

  @override
  String get categoryTech => 'Tech';

  @override
  String get categoryComedy => 'Comedy';

  @override
  String get categoryCommunity => 'Community';

  @override
  String get categoryOther => 'Other';

  @override
  String get exploreTitle => 'Explore';

  @override
  String get explore => 'Explore';

  @override
  String get searchHint => 'Search creators';

  @override
  String get sortPopular => 'Most fans';

  @override
  String get sortNewest => 'Newest';

  @override
  String creatorsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count creators',
      one: '1 creator',
    );
    return '$_temp0';
  }

  @override
  String get noResultsTitle => 'No creators found';

  @override
  String get noResultsBody => 'Try another name or category.';

  @override
  String get noTagline => 'A creator on kahwa';

  @override
  String kahwasLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'kahwas',
      one: 'kahwa',
    );
    return '$_temp0';
  }

  @override
  String supportersLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'supporters',
      one: 'supporter',
    );
    return '$_temp0';
  }

  @override
  String get fansTitle => 'Fans';

  @override
  String fansLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'fans',
      one: 'fan',
    );
    return '$_temp0';
  }

  @override
  String kahwasCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kahwas',
      one: '1 kahwa',
    );
    return '$_temp0';
  }

  @override
  String boughtKahwas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'bought $count kahwas',
      one: 'bought a kahwa',
    );
    return '$_temp0';
  }

  @override
  String paidMembership(String tier) {
    return 'supports monthly · $tier';
  }

  @override
  String buyKahwaFor(String name) {
    return 'Buy $name a kahwa';
  }

  @override
  String get notAcceptingYet => 'Not accepting kahwas yet';

  @override
  String get becomeFan => 'Become a fan';

  @override
  String get unfan => 'Stop being a fan';

  @override
  String get shareMyPage => 'Share my page';

  @override
  String get editPage => 'Edit page';

  @override
  String get wallEmptyTitle => 'No kahwas yet';

  @override
  String wallEmptyBody(String name) {
    return 'Be the first to buy $name a kahwa.';
  }

  @override
  String get reply => 'Reply';

  @override
  String get editReply => 'Edit reply';

  @override
  String get sayThanks => 'Say thanks';

  @override
  String get replyHint => 'Thank you so much!';

  @override
  String get removeMessage => 'Remove message';

  @override
  String get removeMessageTitle => 'Remove this message?';

  @override
  String get removeMessageBody =>
      'It will no longer show on your page. The kahwas stay.';

  @override
  String get newPost => 'New post';

  @override
  String get postsEmptyTitle => 'No posts yet';

  @override
  String get postsEmptyOwner => 'Share news, work in progress, or a thank you.';

  @override
  String postsEmptyBody(String name) {
    return '$name has not posted anything yet.';
  }

  @override
  String membershipsIntro(String name) {
    return 'Support $name every month and get more in return.';
  }

  @override
  String get membershipsHowItWorks =>
      'Paid from your kahwa balance every 30 days, when you open kahwa. Cancel any time.';

  @override
  String get perMonth => 'a month';

  @override
  String kahwasEachMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kahwas each month',
      one: '1 kahwa each month',
    );
    return '$_temp0';
  }

  @override
  String get yourTier => 'Your tier';

  @override
  String get youAreMember => 'You\'re a member';

  @override
  String get join => 'Join';

  @override
  String get rejoin => 'Join again';

  @override
  String get becomeMember => 'Become a member';

  @override
  String cancelledUntil(String date) {
    return 'Cancelled, perks until $date';
  }

  @override
  String aboutTitle(String name) {
    return 'About $name';
  }

  @override
  String get noAbout => 'Nothing written here yet.';

  @override
  String joinedOn(String date) {
    return 'On kahwa since $date';
  }

  @override
  String get pageNotFound => 'This page doesn\'t exist';

  @override
  String get pageNotFoundBody =>
      'The link may be wrong, or the username changed.';

  @override
  String get goalLabel => 'Goal';

  @override
  String get goalReached => 'Reached';

  @override
  String goalOf(String target) {
    return 'of $target';
  }

  @override
  String get membersOnly => 'Members';

  @override
  String get lockedPost => 'This post is for members.';

  @override
  String get edited => 'edited';

  @override
  String get like => 'Like';

  @override
  String get unlike => 'Unlike';

  @override
  String get deletePostTitle => 'Delete this post?';

  @override
  String get deletePostBody => 'It\'s removed for everyone.';

  @override
  String get editPost => 'Edit post';

  @override
  String get publish => 'Publish';

  @override
  String get postHint => 'What\'s new?';

  @override
  String get postEmpty => 'Write something first';

  @override
  String get posted => 'Posted';

  @override
  String get membersOnlyPost => 'For members only';

  @override
  String get membersOnlyHint => 'Only you and paying members can read it.';

  @override
  String get membersOnlyNeedsTiers =>
      'Add a membership first, in Prices and memberships.';

  @override
  String shareTitle(String name) {
    return '$name\'s page';
  }

  @override
  String shareText(String name, String link) {
    return 'Buy $name a kahwa: $link';
  }

  @override
  String get copyLink => 'Copy link';

  @override
  String get linkCopied => 'Link copied';

  @override
  String buyTitle(String name) {
    return 'Buy $name a kahwa';
  }

  @override
  String joinTitle(String name) {
    return 'Join $name\'s membership';
  }

  @override
  String get oneTime => 'One time';

  @override
  String get monthly => 'Monthly';

  @override
  String get payIn => 'Pay in';

  @override
  String get message => 'Message';

  @override
  String get messageHint => 'Say something nice (optional)';

  @override
  String get keepPrivate => 'Keep it private';

  @override
  String keepPrivateHint(String name) {
    return 'Only $name sees your name and message.';
  }

  @override
  String get total => 'Total';

  @override
  String get eachMonth => 'Each month';

  @override
  String get yourBalance => 'Your balance';

  @override
  String get afterThis => 'After this';

  @override
  String get notEnoughShort => 'Not enough';

  @override
  String get membershipRenewHint =>
      'Renews from your balance every 30 days, the next time you open kahwa. Cancel any time from Me, My memberships.';

  @override
  String get topUpToContinue => 'Top up to continue';

  @override
  String supportFor(String amount) {
    return 'Support $amount';
  }

  @override
  String joinFor(String amount) {
    return 'Join for $amount a month';
  }

  @override
  String confirmBuyTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Buy $count kahwas?',
      one: 'Buy a kahwa?',
    );
    return '$_temp0';
  }

  @override
  String confirmBuyBody(String amount, String name) {
    return '$amount goes from your balance to $name.';
  }

  @override
  String confirmJoinTitle(String tier) {
    return 'Join $tier?';
  }

  @override
  String confirmJoinBody(String amount) {
    return '$amount now, then every 30 days.';
  }

  @override
  String get buy => 'Buy';

  @override
  String get pageChanged =>
      'This page just changed. Check the price and try again.';

  @override
  String get paymentFailed =>
      'The payment didn\'t go through. Nothing was taken.';

  @override
  String get notEnoughTitle => 'Not enough balance';

  @override
  String notEnoughBody(String amount) {
    return 'You need $amount more. Top up now and come back to finish: your kahwa is kept for you.';
  }

  @override
  String topUpAmount(String amount) {
    return 'Top up $amount';
  }

  @override
  String get resumedKahwa => 'Your kahwa was kept while you topped up.';

  @override
  String get cannotSupportTitle => 'You can\'t support this page';

  @override
  String get cannotSupportBody =>
      'It\'s your own page, or it doesn\'t accept kahwas yet.';

  @override
  String thankYouKahwas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Your $count kahwas are on their way!',
      one: 'Your kahwa is on its way!',
    );
    return '$_temp0';
  }

  @override
  String thankYouMember(String tier) {
    return 'Welcome to $tier!';
  }

  @override
  String get defaultThanks => 'Thank you so much for the kahwa!';

  @override
  String backToPage(String name) {
    return 'Back to $name\'s page';
  }

  @override
  String get tellFriends => 'Tell your friends';

  @override
  String goodMorning(String name) {
    return 'Good morning, $name';
  }

  @override
  String goodAfternoon(String name) {
    return 'Good afternoon, $name';
  }

  @override
  String goodEvening(String name) {
    return 'Good evening, $name';
  }

  @override
  String get yourCreators => 'Your creators';

  @override
  String get noCreatorsTitle => 'Find creators you love';

  @override
  String get noCreatorsBody => 'Tap the heart on a page to see it here.';

  @override
  String get latestPosts => 'Latest posts';

  @override
  String get feedEmpty => 'Posts from creators you are a fan of show up here.';

  @override
  String get startPageTitle => 'Start your creator page';

  @override
  String get startPageBody => 'Set a price and start receiving kahwas.';

  @override
  String get setUpPage => 'Set up your page';

  @override
  String get checkUsername => 'Pick a username';

  @override
  String get checkAbout => 'Write about yourself';

  @override
  String get checkLinks => 'Add your links';

  @override
  String get checkGoal => 'Set a goal';

  @override
  String get checkTiers => 'Offer a membership';

  @override
  String get checkPost => 'Write your first post';

  @override
  String get membershipUnpaidTitle => 'A membership couldn\'t renew';

  @override
  String membershipUnpaidBody(String name, String amount) {
    return 'Your membership to $name needs $amount. Top up and it renews the next time you open kahwa.';
  }

  @override
  String get finishKahwaTitle => 'Finish your kahwa';

  @override
  String finishKahwaBody(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kahwas for $name',
      one: '1 kahwa for $name',
    );
    return '$_temp0';
  }

  @override
  String get finish => 'Finish';

  @override
  String get forget => 'Forget it';

  @override
  String get topUpCheckingTitle => 'Top up being checked';

  @override
  String topUpChecking(String amount) {
    return 'Your transfer of $amount is being checked. Your balance goes up as soon as it is found.';
  }

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get clearRead => 'Clear read';

  @override
  String get activityEmptyTitle => 'Nothing here yet';

  @override
  String get activityEmptyBody => 'Kahwas, new fans and replies show up here.';

  @override
  String activityKahwa(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name bought you $count kahwas',
      one: '$name bought you a kahwa',
    );
    return '$_temp0';
  }

  @override
  String activityMembership(String name, String amount) {
    return '$name supports you monthly · $amount';
  }

  @override
  String activityFan(String name) {
    return '$name is now your fan';
  }

  @override
  String activityReply(String name) {
    return '$name replied to your message';
  }

  @override
  String activityTopUpOk(String amount) {
    return '$amount was added to your balance';
  }

  @override
  String activityTopUpFailed(String amount) {
    return 'Your top up of $amount couldn\'t be found';
  }

  @override
  String activityWithdrawOk(String amount) {
    return '$amount was sent to your WHISH';
  }

  @override
  String activityWithdrawRefused(String amount) {
    return 'Your withdrawal of $amount was refused';
  }

  @override
  String get yourPage => 'Your page';

  @override
  String get viewMyPage => 'View my page';

  @override
  String get noUsername => 'No username yet';

  @override
  String get editPageHint => 'Name, avatar, colors, links';

  @override
  String get pricesAndMemberships => 'Prices and memberships';

  @override
  String pricesHint(String price, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count memberships',
      one: '1 membership',
      zero: 'no memberships',
    );
    return '$price a kahwa · $_temp0';
  }

  @override
  String get goal => 'Goal';

  @override
  String get goalHint => 'What you are saving for';

  @override
  String get newPostHint => 'Share an update';

  @override
  String get stats => 'Stats';

  @override
  String get statsHint => 'Kahwas over time, top supporters';

  @override
  String get supportersAndMembers => 'Supporters and members';

  @override
  String get youSupport => 'You support';

  @override
  String get myMemberships => 'My memberships';

  @override
  String activeMemberships(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active',
      one: '1 active',
      zero: 'None active',
    );
    return '$_temp0';
  }

  @override
  String get history => 'History';

  @override
  String get historyHint => 'Everything that moved your balance';

  @override
  String get account => 'Account';

  @override
  String get settings => 'Settings';

  @override
  String get settingsHint => 'Account, security, theme, language';

  @override
  String get billingDetails => 'Billing details';

  @override
  String get billingHint => 'Where withdrawals are paid';

  @override
  String get admin => 'Admin';

  @override
  String get feedback => 'Send feedback';

  @override
  String get balance => 'Balance';

  @override
  String get topUp => 'Top up';

  @override
  String get withdraw => 'Withdraw';

  @override
  String get myMembershipsSubtitle => 'Creators you support every month.';

  @override
  String get noMembershipsTitle => 'No memberships yet';

  @override
  String get noMembershipsBody => 'Join a creator to support them every month.';

  @override
  String get cancelMembership => 'Cancel';

  @override
  String get keepMembership => 'Keep it';

  @override
  String get cancelMembershipTitle => 'Cancel this membership?';

  @override
  String cancelMembershipBody(String date) {
    return 'It stops renewing. Your perks last until $date.';
  }

  @override
  String get membershipDue => 'Renews now: open kahwa with enough balance';

  @override
  String renewsOn(String date) {
    return 'Renews $date';
  }

  @override
  String get membershipEnded => 'Ended';

  @override
  String get changeTier => 'Change tier';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'Same as device';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get languageDevice => 'Device\'s language';

  @override
  String get changeEmail => 'Change email';

  @override
  String get changeEmailHint => 'We send a link to the new address';

  @override
  String get newEmail => 'New email';

  @override
  String get currentPassword => 'Current password';

  @override
  String emailChangeSent(String email) {
    return 'We sent a link to $email. Open it to finish the change, then sign in with your new email.';
  }

  @override
  String get emailInUse => 'Another account already uses this email';

  @override
  String get emailSame => 'That\'s already your email';

  @override
  String get passwordFieldHint => 'At least 6 characters';

  @override
  String get oneTimeHint =>
      'A one-off thank you. It doesn\'t unlock members-only posts.';

  @override
  String get monthlyHint =>
      'Charged from your balance every 30 days. Unlocks members-only posts and the perks of your tier.';

  @override
  String alreadyInTier(String date) {
    return 'You\'re already in this tier. It renews $date.';
  }

  @override
  String get goalCurrencyLocked =>
      'Kahwas have already counted towards this goal, so its currency stays.';

  @override
  String get changePassword => 'Change password';

  @override
  String get changePasswordHint => 'Your current password, then a new one';

  @override
  String get aboutKahwa => 'About kahwa';

  @override
  String get about => 'About';

  @override
  String get aboutHint => 'Who you are and what kahwas help you do.';

  @override
  String get links => 'Links';

  @override
  String get linksHint => 'Instagram, YouTube, your website... up to 8.';

  @override
  String get addLink => 'Add a link';

  @override
  String get linkInvalid => 'That link doesn\'t look right';

  @override
  String get openPageSubtitle =>
      'Setting a price opens your page to kahwas and lists it on Explore.';

  @override
  String get pageOpen => 'Your page is open!';

  @override
  String get memberships => 'Memberships';

  @override
  String get tiersHint =>
      'Up to 3 monthly tiers. Each is a number of kahwas a month at your price.';

  @override
  String tierNumber(int number) {
    return 'Tier $number';
  }

  @override
  String get tierName => 'Name';

  @override
  String get tierNameExample => 'Regular';

  @override
  String get kahwasPerMonth => 'Kahwas a month';

  @override
  String tierCosts(String lbp, String usd) {
    return '$lbp or $usd a month';
  }

  @override
  String get perks => 'Perks';

  @override
  String get perksExample => 'Members-only posts, early access...';

  @override
  String get addTier => 'Add a membership';

  @override
  String get tierNameMissing => 'Give this membership a name';

  @override
  String get tierKahwasInvalid => 'Use 1 to 1000 kahwas';

  @override
  String get thankYouNote => 'Thank you note';

  @override
  String get thankYouNoteHint =>
      'Shown to supporters right after they buy you a kahwa.';

  @override
  String get goalSubtitle =>
      'Kahwas bought in the currency of the goal count towards it.';

  @override
  String get goalTitle => 'Title';

  @override
  String get goalTitleExample => 'A new drawing tablet';

  @override
  String get goalTitleMissing => 'Give your goal a title';

  @override
  String get goalDescription => 'Description';

  @override
  String get goalDescriptionHint => 'Why it matters to you';

  @override
  String get goalTarget => 'Target';

  @override
  String get goalTargetInvalid => 'Enter an amount above 0';

  @override
  String get goalCurrencyHint =>
      'You can change the currency until the first kahwa counts towards the goal.';

  @override
  String get startGoal => 'Start goal';

  @override
  String get startNewGoal => 'Start a new goal';

  @override
  String get editGoal => 'Edit goal';

  @override
  String get endGoal => 'End goal';

  @override
  String get endGoalTitle => 'End this goal?';

  @override
  String get endGoalBody => 'It moves to your past goals.';

  @override
  String get replaceGoalTitle => 'Start a new goal?';

  @override
  String get replaceGoalBody => 'The current one moves to your past goals.';

  @override
  String get pastGoals => 'Past goals';

  @override
  String get last30Days => '30 days';

  @override
  String get last12Months => '12 months';

  @override
  String get allTime => 'All time';

  @override
  String get statKahwas => 'Kahwas';

  @override
  String get statSupporters => 'Supporters';

  @override
  String receivedIn(String currency) {
    return 'Received in $currency';
  }

  @override
  String get payingMembers => 'Paying members';

  @override
  String get monthlyFromMembers => 'Monthly from members';

  @override
  String get kahwasOverTime => 'Kahwas over time';

  @override
  String get topSupporters => 'Top supporters';

  @override
  String get noSupportersYet => 'No supporters yet';

  @override
  String get noSupportersBody => 'Share your page to get your first kahwa.';

  @override
  String get noMembersYet => 'No members yet.';

  @override
  String get allSupporters => 'All supporters';

  @override
  String supporterSummary(int count, String when) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: 'Once',
    );
    return '$_temp0 · last $when';
  }

  @override
  String get walletSubtitle =>
      'What you buy kahwas with, and what you received.';

  @override
  String get received => 'Received';

  @override
  String get spent => 'Spent';

  @override
  String get withdrawn => 'Withdrawn';

  @override
  String get lastTopUp => 'Your last top up';

  @override
  String topUpAdded(String amount) {
    return '$amount was added to your balance.';
  }

  @override
  String topUpNotFound(String amount) {
    return 'Your transfer of $amount couldn\'t be found, so nothing was added. If you did send it, try again with the same details.';
  }

  @override
  String get topUpSubtitle =>
      'Your balance is what you buy kahwas with. You add to it by sending money with WHISH MONEY.';

  @override
  String get topUpUnavailable => 'Top ups aren\'t available right now.';

  @override
  String get amount => 'Amount';

  @override
  String get amountInvalid => 'Enter an amount above 0';

  @override
  String get currency => 'Currency';

  @override
  String sendWith(String amount, String currency) {
    return 'Send $amount from your $currency balance with WHISH MONEY, then come back and confirm.';
  }

  @override
  String get payingFounder =>
      'You pay kahwa itself, through its founder’s WHISH account, so no creator has to share their phone number. Each transfer is checked by hand before it reaches your balance, which also stops fraud.';

  @override
  String get payWithWhish => 'Pay with WHISH';

  @override
  String get whishUpdate =>
      'WHISH didn\'t open on the payment? Install or update the WHISH app and try again.';

  @override
  String get scanFromOtherPhone =>
      'Paying from another phone? Scan this code in the WHISH app.';

  @override
  String get scanCode => 'Scan this code in the WHISH app.';

  @override
  String get senderPhone => 'The WHISH number you sent from';

  @override
  String get senderPhoneHint => 'So we can find your transfer.';

  @override
  String get senderPhoneCheck =>
      'So we can find your transfer. Check it is the number you sent from this time.';

  @override
  String get senderPhoneMissing => 'Enter the number you sent the money from';

  @override
  String get iSentTheMoney => 'I sent the money';

  @override
  String get cancelRequest => 'Cancel request';

  @override
  String get withdrawSubtitle =>
      'Get your balance out to your WHISH account. Requests are paid by hand.';

  @override
  String get available => 'Available';

  @override
  String get billingFirstTitle => 'Billing details first';

  @override
  String get billingFirst =>
      'Add your billing details first, so we know where to send your money.';

  @override
  String get withdrawWaitingTitle => 'Your request is waiting';

  @override
  String withdrawWaiting(String amount) {
    return 'You asked for $amount, which you get through WHISH MONEY once it is sent. To ask for another amount, cancel this request first.';
  }

  @override
  String paidTo(String phone) {
    return 'Paid to WHISH $phone';
  }

  @override
  String get requestWithdraw => 'Request withdrawal';

  @override
  String get withdrawAmountMissing => 'Enter an amount to withdraw';

  @override
  String get withdrawTooMuch => 'You can\'t withdraw more than your balance';

  @override
  String get requestSent => 'Request sent';

  @override
  String get yourRequests => 'Your requests';

  @override
  String get noRequests => 'No requests yet.';

  @override
  String get statusPaid => 'Paid';

  @override
  String get statusRefused => 'Refused';

  @override
  String get statusWaiting => 'Waiting';

  @override
  String get billingSubtitle => 'Withdrawals are sent here with WHISH MONEY.';

  @override
  String get fullName => 'Full name';

  @override
  String get whishNumber => 'WHISH number';

  @override
  String get whishNumberHint => 'The number of your WHISH account.';

  @override
  String get phoneMissing => 'Enter your WHISH number';

  @override
  String get phoneInvalid => 'Enter a phone number, such as 70 123 456';

  @override
  String get billingPrivate => 'Only you and the kahwa team can see these.';

  @override
  String get filterBought => 'Bought';

  @override
  String get filterReceived => 'Received';

  @override
  String get filterTopUps => 'Top ups';

  @override
  String get filterWithdrawals => 'Withdrawals';

  @override
  String get historyEmptyTitle => 'Nothing here yet';

  @override
  String get historyEmptyBody =>
      'Kahwas, top ups and withdrawals show up here.';

  @override
  String historyBought(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kahwas for $name',
      one: 'A kahwa for $name',
    );
    return '$_temp0';
  }

  @override
  String historyReceived(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kahwas from $name',
      one: 'A kahwa from $name',
    );
    return '$_temp0';
  }

  @override
  String historyMembershipTo(String name) {
    return 'Membership to $name';
  }

  @override
  String historyMembershipFrom(String name) {
    return 'Membership from $name';
  }

  @override
  String get historyTopUp => 'Top up';

  @override
  String get historyTopUpFailed => 'Top up not found';

  @override
  String get historyWithdrawal => 'Withdrawal';

  @override
  String get historyWithdrawalRefused => 'Withdrawal refused';

  @override
  String get adminOnly => 'For admins only';

  @override
  String get heldForUsers => 'Held for users';

  @override
  String get heldForUsersHint =>
      'Your WHISH balance should never go below this.';

  @override
  String get users => 'Users';

  @override
  String get creators => 'Creators';

  @override
  String get topUpRequests => 'Top ups';

  @override
  String get withdrawRequests => 'Withdrawals';

  @override
  String get nothingWaiting => 'Nothing waiting.';

  @override
  String sentFrom(String phone) {
    return 'from $phone';
  }

  @override
  String get markReceived => 'Mark as received?';

  @override
  String get markNotReceived => 'Mark as not received?';

  @override
  String get notReceived => 'Not received';

  @override
  String get markPaid => 'Mark as paid?';

  @override
  String get paid => 'Paid';

  @override
  String get refuse => 'Refuse';

  @override
  String get resume => 'Resume';

  @override
  String resumeTitle(String tier) {
    return 'Resume $tier?';
  }

  @override
  String resumeBody(String date) {
    return 'Nothing is charged now. It renews $date.';
  }

  @override
  String resumeHint(String date) {
    return 'Your month is paid until $date, so taking it back is free.';
  }

  @override
  String get copyFailed => 'Couldn\'t copy the link';

  @override
  String get finishMembershipTitle => 'Finish your membership';

  @override
  String finishMembershipBody(String tier, String name) {
    return '$tier with $name';
  }

  @override
  String colorOption(int n) {
    return 'Color $n';
  }

  @override
  String patternOption(int n) {
    return 'Pattern $n';
  }

  @override
  String get aboutExample =>
      'I draw Beirut, one street at a time. Every kahwa buys me paper and paint.';

  @override
  String get addMoney => 'Add';

  @override
  String get takeMoneyOut => 'Take out';

  @override
  String get adjustBody =>
      'This is kept for good. The user sees it with your reason in their history and their activity.';

  @override
  String get adjustFailed =>
      'Could not correct the balance. A balance cannot go below zero.';

  @override
  String get adjustNote =>
      'Only for mistakes, such as a transfer counted twice. Answer requests the usual way.';

  @override
  String adjustAddTitle(String amount, String name) {
    return 'Add $amount to $name?';
  }

  @override
  String adjustRemoveTitle(String amount, String name) {
    return 'Take $amount out of $name’s balance?';
  }

  @override
  String get correctBalance => 'Correct balance';

  @override
  String get reason => 'Reason';

  @override
  String get reasonHint => 'What happened, so anyone can understand it later';

  @override
  String get reasonMissing => 'Say why, in a few words.';

  @override
  String get adminRequests => 'Requests';

  @override
  String get adminLog => 'Log';

  @override
  String get answered => 'Answered';

  @override
  String get changePasswordTitle => 'Change your password?';

  @override
  String changePasswordBody(String email) {
    return 'We will email a link to $email. Open it to choose a new password.';
  }

  @override
  String get codeInvalid => 'Enter the 6 digits.';

  @override
  String get codeWrong => 'That code is not right. Try the one on screen now.';

  @override
  String get confirmItsYou => 'Confirm it’s you';

  @override
  String get confirmItsYouBody => 'Enter your password to go on.';

  @override
  String get copy => 'Copy';

  @override
  String get copied => 'Copied';

  @override
  String get creator => 'Creator';

  @override
  String get devices => 'Signed in devices';

  @override
  String get devicesHint => 'See where you are signed in';

  @override
  String get devicesSubtitle =>
      'Every phone and browser where your account is open.';

  @override
  String get devicesNote =>
      'A device you sign out leaves as soon as it is online. If you think someone else has your password, also change it.';

  @override
  String get thisDevice => 'This device';

  @override
  String get unknownDevice => 'Unknown device';

  @override
  String lastActive(String time) {
    return 'Active $time';
  }

  @override
  String signOutDeviceTitle(String device) {
    return 'Sign out of $device?';
  }

  @override
  String get signOutDeviceBody =>
      'You will have to sign in again there to use kahwa.';

  @override
  String get signOutOthers => 'Sign out of all other devices';

  @override
  String get signOutOthersTitle => 'Sign out everywhere else?';

  @override
  String get signedOutOthers => 'Your other devices are signed out.';

  @override
  String get signOutTitle => 'Sign out?';

  @override
  String get signOutBody =>
      'You can sign back in any time with the same account.';

  @override
  String get tapToChangeEmail => 'Tap to change it';

  @override
  String get noEmailYet => 'No email on this account yet. Tap to add one.';

  @override
  String get addEmail => 'Add an email';

  @override
  String get security => 'Security';

  @override
  String get securityHint => 'Email and password';

  @override
  String get securitySubtitle =>
      'kahwa holds money, so keep your account locked tight.';

  @override
  String get emailVerified => 'Verified';

  @override
  String get emailNotVerified =>
      'Not verified yet. Verify it to buy, top up or withdraw.';

  @override
  String get iVerified => 'I opened the link';

  @override
  String get notVerifiedYet =>
      'Not verified yet. Open the link in the email we sent.';

  @override
  String get sendLink => 'Send link';

  @override
  String verificationSent(String email) {
    return 'A link to verify your email was sent to $email.';
  }

  @override
  String get verifyEmailTitle => 'Verify your email';

  @override
  String verifyEmailBody(String email) {
    return 'Money only moves on verified accounts. Open the link we sent to $email, or ask for a new one.';
  }

  @override
  String verifyEmailBanner(String email) {
    return 'Open the link we sent to $email before buying, topping up or withdrawing.';
  }

  @override
  String emailWait(int seconds) {
    return 'An email was just sent. You can ask again in $seconds s.';
  }

  @override
  String get twoStep => 'Two-step verification';

  @override
  String get twoStepIsOn => 'On: signing in asks for a code';

  @override
  String get twoStepIsOff => 'Off';

  @override
  String get twoStepExplain =>
      'Signing in on a new device will also ask for a 6 digit code from an authenticator app, such as Google Authenticator or Microsoft Authenticator. Your password alone is no longer enough.';

  @override
  String get twoStepBackup =>
      'Keep your authenticator app backed up, such as with Google Authenticator’s cloud backup. Without it, getting back into your account means contacting us.';

  @override
  String get turnOn => 'Turn on';

  @override
  String get turnOff => 'Turn off';

  @override
  String get twoStepOn => 'Two-step verification is on.';

  @override
  String get twoStepOff => 'Two-step verification is off.';

  @override
  String get twoStepOffTitle => 'Turn off two-step verification?';

  @override
  String get twoStepOffBody =>
      'Your password alone will be enough to sign in again.';

  @override
  String get twoStepUnavailable =>
      'Two-step verification is not available yet. Try again later.';

  @override
  String get twoStepSetupTitle => 'Set up your authenticator';

  @override
  String get twoStepSetupBody =>
      'Scan this code with your authenticator app, or type the key into it. Then enter the 6 digit code it shows.';

  @override
  String get twoStepKey => 'Key';

  @override
  String get twoStepCodeLabel => 'Code from the app';

  @override
  String get twoStepCodeTitle => 'Enter your code';

  @override
  String get twoStepCodeBody =>
      'Open your authenticator app and enter the 6 digit code for kahwa.';

  @override
  String get openAuthenticator => 'Open in authenticator app';

  @override
  String get getStarted => 'Get started';

  @override
  String get lookAroundFirst => 'Look around first';

  @override
  String get skip => 'Skip';

  @override
  String get historyAdjustment => 'Correction by kahwa';

  @override
  String get paidByWhish => 'paid by WHISH';

  @override
  String get kahwaKeptForTopUp =>
      'Your kahwa is kept. Finish it from Home once your top up is in.';

  @override
  String markReceivedBody(String amount) {
    return '$amount will be added to their balance. Check the transfer is in your WHISH account first.';
  }

  @override
  String get markNotReceivedBody =>
      'Nothing is added. They are told the transfer was not found.';

  @override
  String get markPaidBody =>
      'Send this to the WHISH number above first. It is taken out of their balance once you confirm.';

  @override
  String get refuseBody => 'Nothing is sent and their balance stays the same.';

  @override
  String get user => 'User';

  @override
  String get sentAt => 'Sent at';

  @override
  String get requestedAt => 'Asked on';

  @override
  String get reference => 'Reference';

  @override
  String get status => 'Status';

  @override
  String get statusApproved => 'Received';

  @override
  String get statusRejected => 'Not received';

  @override
  String get statusPending => 'Waiting';

  @override
  String get noResults => 'Nobody found.';

  @override
  String get nothingYet => 'Nothing yet.';

  @override
  String get searchUsers => 'Search by name or username';

  @override
  String usersCount(int users, int creators) {
    return '$users users, $creators of them creators';
  }

  @override
  String get viewPage => 'View page';

  @override
  String statSpent(String currency) {
    return 'Spent ($currency)';
  }

  @override
  String statReceived(String currency) {
    return 'Received ($currency)';
  }

  @override
  String statWithdrawn(String currency) {
    return 'Withdrawn ($currency)';
  }

  @override
  String paysTo(String name) {
    return 'Member of $name';
  }

  @override
  String paidBy(String name) {
    return '$name is a member';
  }

  @override
  String logTopUpApproved(String name) {
    return 'Top up of $name received';
  }

  @override
  String logTopUpRejected(String name) {
    return 'Top up of $name not received';
  }

  @override
  String logWithdrawPaid(String name) {
    return 'Withdrawal of $name paid';
  }

  @override
  String logWithdrawRefused(String name) {
    return 'Withdrawal of $name refused';
  }

  @override
  String logAdjustment(String admin, String name) {
    return '$admin corrected the balance of $name';
  }

  @override
  String activityAdjustment(String amount) {
    return 'kahwa corrected your balance: $amount';
  }

  @override
  String activityDirectPayment(String name, String amount) {
    return '$name says they sent you $amount by WHISH. Check and confirm it.';
  }

  @override
  String activityDirectConfirmed(String name, String amount) {
    return '$name received your $amount. Thank you!';
  }

  @override
  String activityDirectRejected(String name, String amount) {
    return '$name did not find your $amount in WHISH.';
  }

  @override
  String get directPayTitle => 'Get paid to your WHISH';

  @override
  String get directPayHint => 'Let supporters pay you directly';

  @override
  String get directPaySubtitle =>
      'Supporters can send kahwas straight to your WHISH account instead of from their kahwa balance.';

  @override
  String get directPaySwitch => 'Take payments to my WHISH account';

  @override
  String get directPaySwitchHint =>
      'Paying from a kahwa balance keeps working too.';

  @override
  String get directPayNoticeTitle => 'What changes';

  @override
  String get directPayNotice =>
      'Supporters who pay this way open your link in WHISH and see your name there, never your number. kahwa cannot see these payments: you confirm each one when it arrives, and only then do the kahwas count on your page. They never go through your kahwa balance.';

  @override
  String get directPayLinksHint =>
      'In the WHISH app, open Whish Me and take a screenshot of your QR code. Then tap the QR button below and pick that screenshot. Add one for each currency you take: WHISH only pays a code from a balance in its currency.';

  @override
  String directPayLinkFor(String currency) {
    return 'Whish Me code in $currency';
  }

  @override
  String get directPayFromPicture => 'Read it from your QR screenshot';

  @override
  String get directPayNoCode =>
      'No WHISH code found in this picture. Pick the screenshot of your QR code from Whish Me.';

  @override
  String get directPayCodeRead => 'Code read';

  @override
  String get directPayLinkInvalid =>
      'Not a WHISH code. Pick your Whish Me picture, or paste its link.';

  @override
  String get directPayLinkMissing => 'Add at least one link.';

  @override
  String get directPaymentsTitle => 'Payments to confirm';

  @override
  String get directPaymentsSubtitle =>
      'Kahwas supporters say they sent to your WHISH account. Confirm the ones you find there.';

  @override
  String get directPaymentsEmpty => 'No payments yet.';

  @override
  String directPaymentsWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count waiting for you',
      one: '1 waiting for you',
    );
    return '$_temp0';
  }

  @override
  String directConfirmBody(String amount, String phone) {
    return 'Only if $amount from $phone is in your WHISH account. The kahwas then count on your page and the supporter is told.';
  }

  @override
  String get directRejectBody =>
      'The kahwas will not count, and the supporter is told you did not find the transfer.';

  @override
  String get payWith => 'Pay with';

  @override
  String get payWithBalance => 'My balance';

  @override
  String payWithWhishTo(String name) {
    return 'WHISH to $name';
  }

  @override
  String directSendTo(String amount, String name) {
    return 'Send $amount with WHISH to $name.';
  }

  @override
  String directNotice(String name) {
    return 'This goes straight to $name, not through kahwa. The kahwas show on the page once $name confirms the money arrived.';
  }

  @override
  String get senderPhoneHintDirect =>
      'The number you send from, so they can find your transfer.';

  @override
  String iSentAmount(String amount) {
    return 'I sent $amount';
  }

  @override
  String directSentTitle(String amount) {
    return 'Did you send $amount?';
  }

  @override
  String directSentBody(String name) {
    return 'Only confirm once the transfer went through in WHISH. $name will check it arrived.';
  }

  @override
  String get directWaitingTitle => 'Sent! Waiting for confirmation';

  @override
  String directWaitingBody(String name) {
    return '$name will confirm the money arrived. You will see it in your activity.';
  }

  @override
  String get currencyLbp => 'Lebanese lira';

  @override
  String get currencyUsd => 'US dollar';

  @override
  String get devicesNoteTwoStep =>
      'A device you sign out leaves as soon as it is online. If you think someone else has your password, also change it and turn on two-step verification.';

  @override
  String get newPassword => 'New password';

  @override
  String get passwordChanged => 'Your password was changed.';

  @override
  String get currentPasswordWrong => 'That is not your current password.';

  @override
  String get senderPhoneOf => 'Sent from WHISH number';

  @override
  String get directPaymentsHint => 'Kahwas sent straight to your WHISH';

  @override
  String get directPaymentsNoneWaiting => 'Nothing to confirm right now.';
}
