import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Ezer - Revive Church'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @resources.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get resources;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @teams.
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get teams;

  /// No description provided for @updates.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get updates;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
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

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

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

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @editProfileComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile feature coming soon!'**
  String get editProfileComingSoon;

  /// No description provided for @noUserData.
  ///
  /// In en, this message translates to:
  /// **'No user data available'**
  String get noUserData;

  /// No description provided for @churchInformation.
  ///
  /// In en, this message translates to:
  /// **'Church Information'**
  String get churchInformation;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get memberSince;

  /// No description provided for @administrator.
  ///
  /// In en, this message translates to:
  /// **'ADMINISTRATOR'**
  String get administrator;

  /// No description provided for @mySavedResources.
  ///
  /// In en, this message translates to:
  /// **'My Saved Resources'**
  String get mySavedResources;

  /// No description provided for @myEvents.
  ///
  /// In en, this message translates to:
  /// **'My Events'**
  String get myEvents;

  /// No description provided for @myTeams.
  ///
  /// In en, this message translates to:
  /// **'My Teams'**
  String get myTeams;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'{feature} feature coming soon!'**
  String featureComingSoon(String feature);

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirmMessage;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @lightModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Always use light theme'**
  String get lightModeDesc;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @darkModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Always use dark theme'**
  String get darkModeDesc;

  /// No description provided for @systemMode.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemMode;

  /// No description provided for @systemModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Follow system theme'**
  String get systemModeDesc;

  /// No description provided for @currentTheme.
  ///
  /// In en, this message translates to:
  /// **'Current: {mode} | System: {system}'**
  String currentTheme(String mode, String system);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageDesc.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language'**
  String get languageDesc;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @korean.
  ///
  /// In en, this message translates to:
  /// **'한국어'**
  String get korean;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @reviveChurch.
  ///
  /// In en, this message translates to:
  /// **'Revive Church'**
  String get reviveChurch;

  /// No description provided for @churchManagementAssistant.
  ///
  /// In en, this message translates to:
  /// **'Church Management Assistant'**
  String get churchManagementAssistant;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

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

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @loginToContinue.
  ///
  /// In en, this message translates to:
  /// **'Login to continue'**
  String get loginToContinue;

  /// No description provided for @createYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createYourAccount;

  /// No description provided for @joinOurCommunity.
  ///
  /// In en, this message translates to:
  /// **'Join our community'**
  String get joinOurCommunity;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// No description provided for @bySigningUp.
  ///
  /// In en, this message translates to:
  /// **'By signing up, you agree to our:'**
  String get bySigningUp;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @welcomeToEzer.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Ezer'**
  String get welcomeToEzer;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @joinReviveChurch.
  ///
  /// In en, this message translates to:
  /// **'Join Revive Church'**
  String get joinReviveChurch;

  /// No description provided for @createAccountToStart.
  ///
  /// In en, this message translates to:
  /// **'Create your account to get started'**
  String get createAccountToStart;

  /// No description provided for @pleaseEnterFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get pleaseEnterFullName;

  /// No description provided for @nameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameTooShort;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @acceptTerms.
  ///
  /// In en, this message translates to:
  /// **'Please accept the terms and conditions'**
  String get acceptTerms;

  /// No description provided for @iAgreeToThe.
  ///
  /// In en, this message translates to:
  /// **'I agree to the'**
  String get iAgreeToThe;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchHint;

  /// No description provided for @searchFoldersAndMedia.
  ///
  /// In en, this message translates to:
  /// **'Search folders and media...'**
  String get searchFoldersAndMedia;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String noSearchResults(String query);

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @loadingMore.
  ///
  /// In en, this message translates to:
  /// **'Loading more...'**
  String get loadingMore;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'THIS WEEK'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(int days);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String hoursAgo(int hours);

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes ago'**
  String minutesAgo(int minutes);

  /// No description provided for @inDays.
  ///
  /// In en, this message translates to:
  /// **'In {days} days'**
  String inDays(int days);

  /// No description provided for @inHours.
  ///
  /// In en, this message translates to:
  /// **'In {hours} hours'**
  String inHours(int hours);

  /// No description provided for @inMinutes.
  ///
  /// In en, this message translates to:
  /// **'In {minutes} minutes'**
  String inMinutes(int minutes);

  /// No description provided for @ongoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get ongoing;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @noUpcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'No upcoming events'**
  String get noUpcomingEvents;

  /// No description provided for @noEventsScheduled.
  ///
  /// In en, this message translates to:
  /// **'No events scheduled'**
  String get noEventsScheduled;

  /// No description provided for @forDate.
  ///
  /// In en, this message translates to:
  /// **'for {date}'**
  String forDate(String date);

  /// No description provided for @eventsFor.
  ///
  /// In en, this message translates to:
  /// **'Events for {date}'**
  String eventsFor(String date);

  /// No description provided for @eventDetails.
  ///
  /// In en, this message translates to:
  /// **'Event Details'**
  String get eventDetails;

  /// No description provided for @addEvent.
  ///
  /// In en, this message translates to:
  /// **'Add Event'**
  String get addEvent;

  /// No description provided for @createEvent.
  ///
  /// In en, this message translates to:
  /// **'Create Event'**
  String get createEvent;

  /// No description provided for @editEvent.
  ///
  /// In en, this message translates to:
  /// **'Edit Event'**
  String get editEvent;

  /// No description provided for @deleteEvent.
  ///
  /// In en, this message translates to:
  /// **'Delete Event'**
  String get deleteEvent;

  /// No description provided for @eventCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Event \"{title}\" created successfully!'**
  String eventCreatedSuccess(String title);

  /// No description provided for @eventUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Event \"{title}\" updated successfully!'**
  String eventUpdatedSuccess(String title);

  /// No description provided for @eventDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Event deleted successfully'**
  String get eventDeletedSuccess;

  /// No description provided for @failedToCreateEvent.
  ///
  /// In en, this message translates to:
  /// **'Failed to create event'**
  String get failedToCreateEvent;

  /// No description provided for @failedToUpdateEvent.
  ///
  /// In en, this message translates to:
  /// **'Failed to update event'**
  String get failedToUpdateEvent;

  /// No description provided for @failedToDeleteEvent.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete event'**
  String get failedToDeleteEvent;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @joined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get joined;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @full.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get full;

  /// No description provided for @joinedCount.
  ///
  /// In en, this message translates to:
  /// **'{current}/{max} joined'**
  String joinedCount(int current, int max);

  /// No description provided for @successfullyRegistered.
  ///
  /// In en, this message translates to:
  /// **'Successfully registered!'**
  String get successfullyRegistered;

  /// No description provided for @cancelledRegistration.
  ///
  /// In en, this message translates to:
  /// **'Cancelled registration'**
  String get cancelledRegistration;

  /// No description provided for @leftEvent.
  ///
  /// In en, this message translates to:
  /// **'Left {title}'**
  String leftEvent(String title);

  /// No description provided for @joinedEvent.
  ///
  /// In en, this message translates to:
  /// **'Joined {title}!'**
  String joinedEvent(String title);

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'FEATURED'**
  String get featured;

  /// No description provided for @worshipFeedbackMap.
  ///
  /// In en, this message translates to:
  /// **'Worship Feedback Map'**
  String get worshipFeedbackMap;

  /// No description provided for @shareLocationFeedback.
  ///
  /// In en, this message translates to:
  /// **'Share your location & feedback'**
  String get shareLocationFeedback;

  /// No description provided for @helpImproveWorship.
  ///
  /// In en, this message translates to:
  /// **'Help us improve your worship experience'**
  String get helpImproveWorship;

  /// No description provided for @thisWeeksBulletin.
  ///
  /// In en, this message translates to:
  /// **'This Week\'s Bulletin'**
  String get thisWeeksBulletin;

  /// No description provided for @weekOf.
  ///
  /// In en, this message translates to:
  /// **'Week of {date}'**
  String weekOf(String date);

  /// No description provided for @andMoreItems.
  ///
  /// In en, this message translates to:
  /// **'and {count} more items...'**
  String andMoreItems(int count);

  /// No description provided for @viewAllBulletins.
  ///
  /// In en, this message translates to:
  /// **'View All {year} Bulletins'**
  String viewAllBulletins(int year);

  /// No description provided for @connectGroups.
  ///
  /// In en, this message translates to:
  /// **'Connect Groups'**
  String get connectGroups;

  /// No description provided for @hangouts.
  ///
  /// In en, this message translates to:
  /// **'Hangouts'**
  String get hangouts;

  /// No description provided for @createTeam.
  ///
  /// In en, this message translates to:
  /// **'Create Team'**
  String get createTeam;

  /// No description provided for @joinTeam.
  ///
  /// In en, this message translates to:
  /// **'Join Team'**
  String get joinTeam;

  /// No description provided for @leaveTeam.
  ///
  /// In en, this message translates to:
  /// **'Leave Team'**
  String get leaveTeam;

  /// No description provided for @teamDetails.
  ///
  /// In en, this message translates to:
  /// **'Team Details'**
  String get teamDetails;

  /// No description provided for @noTeamsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No teams available'**
  String get noTeamsAvailable;

  /// No description provided for @applicationPending.
  ///
  /// In en, this message translates to:
  /// **'Application pending'**
  String get applicationPending;

  /// No description provided for @applicationApproved.
  ///
  /// In en, this message translates to:
  /// **'Application approved'**
  String get applicationApproved;

  /// No description provided for @applicationRejected.
  ///
  /// In en, this message translates to:
  /// **'Application rejected'**
  String get applicationRejected;

  /// No description provided for @aboutConnectGroups.
  ///
  /// In en, this message translates to:
  /// **'About Connect Groups'**
  String get aboutConnectGroups;

  /// No description provided for @connectGroupsDescription.
  ///
  /// In en, this message translates to:
  /// **'Connect Groups are regular, application-based gatherings focused on spiritual growth, fellowship, and discipleship. These groups require commitment and may have specific requirements.'**
  String get connectGroupsDescription;

  /// No description provided for @availableGroups.
  ///
  /// In en, this message translates to:
  /// **'Available Groups'**
  String get availableGroups;

  /// No description provided for @noConnectGroupsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Connect Groups Available'**
  String get noConnectGroupsAvailable;

  /// No description provided for @checkBackLaterForGroups.
  ///
  /// In en, this message translates to:
  /// **'Check back later for new groups'**
  String get checkBackLaterForGroups;

  /// No description provided for @aboutHangouts.
  ///
  /// In en, this message translates to:
  /// **'About Hangouts'**
  String get aboutHangouts;

  /// No description provided for @hangoutsDescription.
  ///
  /// In en, this message translates to:
  /// **'Hangouts are open, casual events for fellowship, fun, and building relationships. Everyone is welcome to join - no application required!'**
  String get hangoutsDescription;

  /// No description provided for @joinAHangout.
  ///
  /// In en, this message translates to:
  /// **'Join a Hangout'**
  String get joinAHangout;

  /// No description provided for @noHangoutsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Hangouts Available'**
  String get noHangoutsAvailable;

  /// No description provided for @checkBackLaterForActivities.
  ///
  /// In en, this message translates to:
  /// **'Check back later for new activities'**
  String get checkBackLaterForActivities;

  /// No description provided for @applicationRequired.
  ///
  /// In en, this message translates to:
  /// **'APPLICATION REQUIRED'**
  String get applicationRequired;

  /// No description provided for @openToAll.
  ///
  /// In en, this message translates to:
  /// **'OPEN TO ALL'**
  String get openToAll;

  /// No description provided for @ledBy.
  ///
  /// In en, this message translates to:
  /// **'Led by {name}'**
  String ledBy(String name);

  /// No description provided for @membersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String membersCount(int count);

  /// No description provided for @spotsFilled.
  ///
  /// In en, this message translates to:
  /// **'{current}/{max} spots filled'**
  String spotsFilled(int current, int max);

  /// No description provided for @activeMembers.
  ///
  /// In en, this message translates to:
  /// **'{count} active members'**
  String activeMembers(int count);

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @reapply.
  ///
  /// In en, this message translates to:
  /// **'Reapply'**
  String get reapply;

  /// No description provided for @leftTeam.
  ///
  /// In en, this message translates to:
  /// **'Left {name}'**
  String leftTeam(String name);

  /// No description provided for @cancelledApplication.
  ///
  /// In en, this message translates to:
  /// **'Cancelled application to {name}'**
  String cancelledApplication(String name);

  /// No description provided for @applicationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Application submitted for {name}'**
  String applicationSubmitted(String name);

  /// No description provided for @joinedTeam.
  ///
  /// In en, this message translates to:
  /// **'Joined {name}!'**
  String joinedTeam(String name);

  /// No description provided for @failedToLeaveTeam.
  ///
  /// In en, this message translates to:
  /// **'Failed to leave {name}'**
  String failedToLeaveTeam(String name);

  /// No description provided for @failedToCancelApplication.
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel application'**
  String get failedToCancelApplication;

  /// No description provided for @failedToApplyTeam.
  ///
  /// In en, this message translates to:
  /// **'Failed to apply to {name}'**
  String failedToApplyTeam(String name);

  /// No description provided for @failedToJoinTeam.
  ///
  /// In en, this message translates to:
  /// **'Failed to join {name}'**
  String failedToJoinTeam(String name);

  /// No description provided for @bulletin.
  ///
  /// In en, this message translates to:
  /// **'Bulletin'**
  String get bulletin;

  /// No description provided for @latestSermon.
  ///
  /// In en, this message translates to:
  /// **'Latest Sermon'**
  String get latestSermon;

  /// No description provided for @recentUpdates.
  ///
  /// In en, this message translates to:
  /// **'Recent Updates'**
  String get recentUpdates;

  /// No description provided for @pinnedUpdates.
  ///
  /// In en, this message translates to:
  /// **'Pinned Updates'**
  String get pinnedUpdates;

  /// No description provided for @upcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Events'**
  String get upcomingEvents;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @updatesRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Updates refreshed'**
  String get updatesRefreshed;

  /// No description provided for @noUpdates.
  ///
  /// In en, this message translates to:
  /// **'No Updates'**
  String get noUpdates;

  /// No description provided for @checkBackLater.
  ///
  /// In en, this message translates to:
  /// **'Check back later for church news and announcements'**
  String get checkBackLater;

  /// No description provided for @updateCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Update created successfully!'**
  String get updateCreatedSuccess;

  /// No description provided for @failedToCreateUpdate.
  ///
  /// In en, this message translates to:
  /// **'Failed to create update'**
  String get failedToCreateUpdate;

  /// No description provided for @editUpdate.
  ///
  /// In en, this message translates to:
  /// **'Edit Update'**
  String get editUpdate;

  /// No description provided for @deleteUpdate.
  ///
  /// In en, this message translates to:
  /// **'Delete Update'**
  String get deleteUpdate;

  /// No description provided for @editing.
  ///
  /// In en, this message translates to:
  /// **'Editing \"{title}\"'**
  String editing(String title);

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Update'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"? This action cannot be undone.'**
  String deleteConfirmMessage(String title);

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted \"{title}\"'**
  String deleted(String title);

  /// No description provided for @failedToDelete.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete'**
  String get failedToDelete;

  /// No description provided for @updateTypeAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'ANNOUNCEMENT'**
  String get updateTypeAnnouncement;

  /// No description provided for @updateTypeNews.
  ///
  /// In en, this message translates to:
  /// **'NEWS'**
  String get updateTypeNews;

  /// No description provided for @updateTypePrayer.
  ///
  /// In en, this message translates to:
  /// **'PRAYER'**
  String get updateTypePrayer;

  /// No description provided for @updateTypeCelebration.
  ///
  /// In en, this message translates to:
  /// **'CELEBRATION'**
  String get updateTypeCelebration;

  /// No description provided for @updateTypeUrgent.
  ///
  /// In en, this message translates to:
  /// **'URGENT'**
  String get updateTypeUrgent;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @sermons.
  ///
  /// In en, this message translates to:
  /// **'Sermons'**
  String get sermons;

  /// No description provided for @media.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get media;

  /// No description provided for @folders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get folders;

  /// No description provided for @createFolder.
  ///
  /// In en, this message translates to:
  /// **'Create Folder'**
  String get createFolder;

  /// No description provided for @uploadMedia.
  ///
  /// In en, this message translates to:
  /// **'Upload Media'**
  String get uploadMedia;

  /// No description provided for @showDeletedItems.
  ///
  /// In en, this message translates to:
  /// **'Show deleted items'**
  String get showDeletedItems;

  /// No description provided for @hideDeletedItems.
  ///
  /// In en, this message translates to:
  /// **'Hide deleted items'**
  String get hideDeletedItems;

  /// No description provided for @folderManagement.
  ///
  /// In en, this message translates to:
  /// **'Folder Management'**
  String get folderManagement;

  /// No description provided for @restoreFolder.
  ///
  /// In en, this message translates to:
  /// **'Restore Folder'**
  String get restoreFolder;

  /// No description provided for @restoreFolderDesc.
  ///
  /// In en, this message translates to:
  /// **'Restore {name} folder'**
  String restoreFolderDesc(String name);

  /// No description provided for @permanentDelete.
  ///
  /// In en, this message translates to:
  /// **'Permanent Delete'**
  String get permanentDelete;

  /// No description provided for @permanentDeleteDesc.
  ///
  /// In en, this message translates to:
  /// **'Completely delete the folder (cannot be undone)'**
  String get permanentDeleteDesc;

  /// No description provided for @editThumbnail.
  ///
  /// In en, this message translates to:
  /// **'Edit Thumbnail'**
  String get editThumbnail;

  /// No description provided for @addThumbnail.
  ///
  /// In en, this message translates to:
  /// **'Add folder thumbnail'**
  String get addThumbnail;

  /// No description provided for @changeThumbnail.
  ///
  /// In en, this message translates to:
  /// **'Change folder thumbnail'**
  String get changeThumbnail;

  /// No description provided for @deleteFolder.
  ///
  /// In en, this message translates to:
  /// **'Delete Folder'**
  String get deleteFolder;

  /// No description provided for @deleteFolderDesc.
  ///
  /// In en, this message translates to:
  /// **'Delete {name} folder'**
  String deleteFolderDesc(String name);

  /// No description provided for @deleteFolderConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Folder Confirmation'**
  String get deleteFolderConfirmTitle;

  /// No description provided for @deleteFolderConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\" folder?'**
  String deleteFolderConfirmMessage(String name);

  /// No description provided for @deleteFolderNote.
  ///
  /// In en, this message translates to:
  /// **'This action can be undone. The folder and contents will be hidden but not completely deleted.'**
  String get deleteFolderNote;

  /// No description provided for @permanentDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Permanent Delete Confirmation'**
  String get permanentDeleteConfirmTitle;

  /// No description provided for @permanentDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete \"{name}\" folder?'**
  String permanentDeleteConfirmMessage(String name);

  /// No description provided for @permanentDeleteWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. The folder and all contents will be completely deleted.'**
  String get permanentDeleteWarning;

  /// No description provided for @folderDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'{name} folder has been deleted'**
  String folderDeletedSuccess(String name);

  /// No description provided for @folderDeletedAdminNote.
  ///
  /// In en, this message translates to:
  /// **'{name} folder has been deleted (still visible in admin mode)'**
  String folderDeletedAdminNote(String name);

  /// No description provided for @folderRestoredSuccess.
  ///
  /// In en, this message translates to:
  /// **'{name} folder has been restored'**
  String folderRestoredSuccess(String name);

  /// No description provided for @folderPermanentlyDeleted.
  ///
  /// In en, this message translates to:
  /// **'{name} folder has been permanently deleted'**
  String folderPermanentlyDeleted(String name);

  /// No description provided for @thumbnailUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'{name} folder thumbnail has been updated'**
  String thumbnailUpdatedSuccess(String name);

  /// No description provided for @folderCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Folder created successfully!'**
  String get folderCreatedSuccess;

  /// No description provided for @uploadingThumbnail.
  ///
  /// In en, this message translates to:
  /// **'Uploading thumbnail...'**
  String get uploadingThumbnail;

  /// No description provided for @failedToDeleteFolder.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete folder'**
  String get failedToDeleteFolder;

  /// No description provided for @failedToRestoreFolder.
  ///
  /// In en, this message translates to:
  /// **'Failed to restore folder'**
  String get failedToRestoreFolder;

  /// No description provided for @failedToUpdateThumbnail.
  ///
  /// In en, this message translates to:
  /// **'Failed to update thumbnail'**
  String get failedToUpdateThumbnail;

  /// No description provided for @failedToPermanentDelete.
  ///
  /// In en, this message translates to:
  /// **'Failed to permanently delete'**
  String get failedToPermanentDelete;

  /// No description provided for @failedToCreateFolder.
  ///
  /// In en, this message translates to:
  /// **'Failed to create folder'**
  String get failedToCreateFolder;

  /// No description provided for @failedToUpload.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload'**
  String get failedToUpload;

  /// No description provided for @mediaDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'{title} has been deleted'**
  String mediaDeletedSuccess(String title);

  /// No description provided for @failedToDeleteMedia.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete media'**
  String get failedToDeleteMedia;

  /// No description provided for @loadingMoreMedia.
  ///
  /// In en, this message translates to:
  /// **'Loading more media...'**
  String get loadingMoreMedia;

  /// No description provided for @emptyFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder is empty'**
  String get emptyFolder;

  /// No description provided for @emptyFolderAdmin.
  ///
  /// In en, this message translates to:
  /// **'Create a new folder or upload media'**
  String get emptyFolderAdmin;

  /// No description provided for @emptyFolderUser.
  ///
  /// In en, this message translates to:
  /// **'No content has been uploaded yet'**
  String get emptyFolderUser;

  /// No description provided for @sortFolders.
  ///
  /// In en, this message translates to:
  /// **'Sort folders'**
  String get sortFolders;

  /// No description provided for @sortMedia.
  ///
  /// In en, this message translates to:
  /// **'Sort media'**
  String get sortMedia;

  /// No description provided for @ascending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get ascending;

  /// No description provided for @descending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get descending;

  /// No description provided for @errorLoadingFolders.
  ///
  /// In en, this message translates to:
  /// **'Error loading folders'**
  String get errorLoadingFolders;

  /// No description provided for @createFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Folder'**
  String get createFolderTitle;

  /// No description provided for @createFolderDesc.
  ///
  /// In en, this message translates to:
  /// **'Create a new folder to organize media'**
  String get createFolderDesc;

  /// No description provided for @uploadMediaTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload Media'**
  String get uploadMediaTitle;

  /// No description provided for @uploadMediaDesc.
  ///
  /// In en, this message translates to:
  /// **'Upload photos or videos to the current folder'**
  String get uploadMediaDesc;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}!'**
  String welcomeMessage(String name);

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get verifyEmail;

  /// No description provided for @verificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent'**
  String get verificationEmailSent;

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get checkYourEmail;

  /// No description provided for @resendVerification.
  ///
  /// In en, this message translates to:
  /// **'Resend verification'**
  String get resendVerification;

  /// No description provided for @emailVerified.
  ///
  /// In en, this message translates to:
  /// **'Email verified'**
  String get emailVerified;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @worshipFeedback.
  ///
  /// In en, this message translates to:
  /// **'Worship Feedback'**
  String get worshipFeedback;

  /// No description provided for @submitFeedback.
  ///
  /// In en, this message translates to:
  /// **'Submit Feedback'**
  String get submitFeedback;

  /// No description provided for @feedbackSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Feedback submitted'**
  String get feedbackSubmitted;

  /// No description provided for @helpUsImproveExperience.
  ///
  /// In en, this message translates to:
  /// **'Help Us Improve Your Experience'**
  String get helpUsImproveExperience;

  /// No description provided for @tapMapInstruction.
  ///
  /// In en, this message translates to:
  /// **'Tap on the map to indicate your approximate location, then share your environmental feedback.'**
  String get tapMapInstruction;

  /// No description provided for @tapMapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere on the worship area map to indicate your location'**
  String get tapMapHint;

  /// No description provided for @howsEnvironment.
  ///
  /// In en, this message translates to:
  /// **'How\'s the environment?'**
  String get howsEnvironment;

  /// No description provided for @feedbackTooCold.
  ///
  /// In en, this message translates to:
  /// **'Too Cold'**
  String get feedbackTooCold;

  /// No description provided for @feedbackTooHot.
  ///
  /// In en, this message translates to:
  /// **'Too Hot'**
  String get feedbackTooHot;

  /// No description provided for @feedbackJustRight.
  ///
  /// In en, this message translates to:
  /// **'Just Right'**
  String get feedbackJustRight;

  /// No description provided for @feedbackTooLoud.
  ///
  /// In en, this message translates to:
  /// **'Too Loud'**
  String get feedbackTooLoud;

  /// No description provided for @feedbackTooQuiet.
  ///
  /// In en, this message translates to:
  /// **'Too Quiet'**
  String get feedbackTooQuiet;

  /// No description provided for @feedbackLighting.
  ///
  /// In en, this message translates to:
  /// **'Lighting Issue'**
  String get feedbackLighting;

  /// No description provided for @thankYouFeedback.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback! We\'ll work to improve the experience.'**
  String get thankYouFeedback;

  /// No description provided for @stage.
  ///
  /// In en, this message translates to:
  /// **'STAGE'**
  String get stage;

  /// No description provided for @entrance.
  ///
  /// In en, this message translates to:
  /// **'ENTRANCE'**
  String get entrance;

  /// No description provided for @weeklyBulletin.
  ///
  /// In en, this message translates to:
  /// **'Weekly Bulletin'**
  String get weeklyBulletin;

  /// No description provided for @bulletinNotFound.
  ///
  /// In en, this message translates to:
  /// **'Bulletin not found'**
  String get bulletinNotFound;

  /// No description provided for @worshipSchedule.
  ///
  /// In en, this message translates to:
  /// **'Worship Schedule'**
  String get worshipSchedule;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @worship.
  ///
  /// In en, this message translates to:
  /// **'Worship'**
  String get worship;

  /// No description provided for @deleteBulletin.
  ///
  /// In en, this message translates to:
  /// **'Delete Bulletin'**
  String get deleteBulletin;

  /// No description provided for @deleteBulletinConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the bulletin for {date}?'**
  String deleteBulletinConfirm(String date);

  /// No description provided for @deleteBulletinDetails.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete:\n• The bulletin \"{theme}\"\n• All {itemCount} bulletin items\n• All {scheduleCount} worship schedule items\n\nThis action cannot be undone.'**
  String deleteBulletinDetails(String theme, int itemCount, int scheduleCount);

  /// No description provided for @deletingBulletin.
  ///
  /// In en, this message translates to:
  /// **'Deleting bulletin...'**
  String get deletingBulletin;

  /// No description provided for @bulletinDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Bulletin deleted successfully'**
  String get bulletinDeletedSuccess;

  /// No description provided for @failedToDeleteBulletin.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete bulletin'**
  String get failedToDeleteBulletin;

  /// No description provided for @yearBulletins.
  ///
  /// In en, this message translates to:
  /// **'{year} Bulletins'**
  String yearBulletins(int year);

  /// No description provided for @noBulletinsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No bulletins available'**
  String get noBulletinsAvailable;

  /// No description provided for @bulletinsRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Bulletins refreshed'**
  String get bulletinsRefreshed;

  /// No description provided for @cannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get cannotBeUndone;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemsCount(int count);

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No description provided for @checkConnection.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again'**
  String get checkConnection;

  /// No description provided for @exitApp.
  ///
  /// In en, this message translates to:
  /// **'Exit App'**
  String get exitApp;

  /// No description provided for @exitAppConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit?'**
  String get exitAppConfirm;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ko': return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
