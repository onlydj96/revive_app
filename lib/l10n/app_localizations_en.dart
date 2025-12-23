// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Ezer - Revive Church';

  @override
  String get home => 'Home';

  @override
  String get resources => 'Resources';

  @override
  String get schedule => 'Schedule';

  @override
  String get teams => 'Teams';

  @override
  String get updates => 'Updates';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get signOut => 'Sign Out';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get ok => 'OK';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get undo => 'Undo';

  @override
  String get unknown => 'Unknown';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get editProfileComingSoon => 'Edit Profile feature coming soon!';

  @override
  String get noUserData => 'No user data available';

  @override
  String get churchInformation => 'Church Information';

  @override
  String get role => 'Role';

  @override
  String get member => 'Member';

  @override
  String get memberSince => 'Member Since';

  @override
  String get administrator => 'ADMINISTRATOR';

  @override
  String get mySavedResources => 'My Saved Resources';

  @override
  String get myEvents => 'My Events';

  @override
  String get myTeams => 'My Teams';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String featureComingSoon(String feature) {
    return '$feature feature coming soon!';
  }

  @override
  String get signOutConfirmTitle => 'Sign Out';

  @override
  String get signOutConfirmMessage => 'Are you sure you want to sign out?';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get lightModeDesc => 'Always use light theme';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkModeDesc => 'Always use dark theme';

  @override
  String get systemMode => 'System';

  @override
  String get systemModeDesc => 'Follow system theme';

  @override
  String currentTheme(String mode, String system) {
    return 'Current: $mode | System: $system';
  }

  @override
  String get language => 'Language';

  @override
  String get languageDesc => 'Select your preferred language';

  @override
  String get english => 'English';

  @override
  String get korean => '한국어';

  @override
  String get about => 'About';

  @override
  String get appVersion => 'App Version';

  @override
  String get reviveChurch => 'Revive Church';

  @override
  String get churchManagementAssistant => 'Church Management Assistant';

  @override
  String get login => 'Login';

  @override
  String get signUp => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get name => 'Name';

  @override
  String get fullName => 'Full Name';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get createAccount => 'Create Account';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get loginToContinue => 'Login to continue';

  @override
  String get createYourAccount => 'Create your account';

  @override
  String get joinOurCommunity => 'Join our community';

  @override
  String get orContinueWith => 'Or continue with';

  @override
  String get bySigningUp => 'By signing up, you agree to our:';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get and => 'and';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get welcomeToEzer => 'Welcome to Ezer';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get signIn => 'Sign In';

  @override
  String get or => 'or';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get joinReviveChurch => 'Join Revive Church';

  @override
  String get createAccountToStart => 'Create your account to get started';

  @override
  String get pleaseEnterFullName => 'Please enter your full name';

  @override
  String get nameTooShort => 'Name must be at least 2 characters';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get acceptTerms => 'Please accept the terms and conditions';

  @override
  String get iAgreeToThe => 'I agree to the';

  @override
  String get search => 'Search';

  @override
  String get searchHint => 'Search...';

  @override
  String get searchFoldersAndMedia => 'Search folders and media...';

  @override
  String get noResultsFound => 'No results found';

  @override
  String noSearchResults(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get clearSearch => 'Clear search';

  @override
  String get loading => 'Loading...';

  @override
  String get loadingMore => 'Loading more...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get refresh => 'Refresh';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get thisWeek => 'THIS WEEK';

  @override
  String get thisMonth => 'This Month';

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours hours ago';
  }

  @override
  String minutesAgo(int minutes) {
    return '$minutes minutes ago';
  }

  @override
  String inDays(int days) {
    return 'In $days days';
  }

  @override
  String inHours(int hours) {
    return 'In $hours hours';
  }

  @override
  String inMinutes(int minutes) {
    return 'In $minutes minutes';
  }

  @override
  String get ongoing => 'Ongoing';

  @override
  String get events => 'Events';

  @override
  String get noUpcomingEvents => 'No upcoming events';

  @override
  String get noEventsScheduled => 'No events scheduled';

  @override
  String forDate(String date) {
    return 'for $date';
  }

  @override
  String eventsFor(String date) {
    return 'Events for $date';
  }

  @override
  String get eventDetails => 'Event Details';

  @override
  String get addEvent => 'Add Event';

  @override
  String get createEvent => 'Create Event';

  @override
  String get editEvent => 'Edit Event';

  @override
  String get deleteEvent => 'Delete Event';

  @override
  String eventCreatedSuccess(String title) {
    return 'Event \"$title\" created successfully!';
  }

  @override
  String eventUpdatedSuccess(String title) {
    return 'Event \"$title\" updated successfully!';
  }

  @override
  String get eventDeletedSuccess => 'Event deleted successfully';

  @override
  String get failedToCreateEvent => 'Failed to create event';

  @override
  String get failedToUpdateEvent => 'Failed to update event';

  @override
  String get failedToDeleteEvent => 'Failed to delete event';

  @override
  String get join => 'Join';

  @override
  String get joined => 'Joined';

  @override
  String get leave => 'Leave';

  @override
  String get full => 'Full';

  @override
  String joinedCount(int current, int max) {
    return '$current/$max joined';
  }

  @override
  String get successfullyRegistered => 'Successfully registered!';

  @override
  String get cancelledRegistration => 'Cancelled registration';

  @override
  String leftEvent(String title) {
    return 'Left $title';
  }

  @override
  String joinedEvent(String title) {
    return 'Joined $title!';
  }

  @override
  String get featured => 'FEATURED';

  @override
  String get worshipFeedbackMap => 'Worship Feedback Map';

  @override
  String get shareLocationFeedback => 'Share your location & feedback';

  @override
  String get helpImproveWorship => 'Help us improve your worship experience';

  @override
  String get thisWeeksBulletin => 'This Week\'s Bulletin';

  @override
  String weekOf(String date) {
    return 'Week of $date';
  }

  @override
  String andMoreItems(int count) {
    return 'and $count more items...';
  }

  @override
  String viewAllBulletins(int year) {
    return 'View All $year Bulletins';
  }

  @override
  String get connectGroups => 'Connect Groups';

  @override
  String get hangouts => 'Hangouts';

  @override
  String get createTeam => 'Create Team';

  @override
  String get joinTeam => 'Join Team';

  @override
  String get leaveTeam => 'Leave Team';

  @override
  String get teamDetails => 'Team Details';

  @override
  String get noTeamsAvailable => 'No teams available';

  @override
  String get applicationPending => 'Application pending';

  @override
  String get applicationApproved => 'Application approved';

  @override
  String get applicationRejected => 'Application rejected';

  @override
  String get aboutConnectGroups => 'About Connect Groups';

  @override
  String get connectGroupsDescription => 'Connect Groups are regular, application-based gatherings focused on spiritual growth, fellowship, and discipleship. These groups require commitment and may have specific requirements.';

  @override
  String get availableGroups => 'Available Groups';

  @override
  String get noConnectGroupsAvailable => 'No Connect Groups Available';

  @override
  String get checkBackLaterForGroups => 'Check back later for new groups';

  @override
  String get aboutHangouts => 'About Hangouts';

  @override
  String get hangoutsDescription => 'Hangouts are open, casual events for fellowship, fun, and building relationships. Everyone is welcome to join - no application required!';

  @override
  String get joinAHangout => 'Join a Hangout';

  @override
  String get noHangoutsAvailable => 'No Hangouts Available';

  @override
  String get checkBackLaterForActivities => 'Check back later for new activities';

  @override
  String get applicationRequired => 'APPLICATION REQUIRED';

  @override
  String get openToAll => 'OPEN TO ALL';

  @override
  String ledBy(String name) {
    return 'Led by $name';
  }

  @override
  String membersCount(int count) {
    return '$count members';
  }

  @override
  String spotsFilled(int current, int max) {
    return '$current/$max spots filled';
  }

  @override
  String activeMembers(int count) {
    return '$count active members';
  }

  @override
  String get apply => 'Apply';

  @override
  String get reapply => 'Reapply';

  @override
  String leftTeam(String name) {
    return 'Left $name';
  }

  @override
  String cancelledApplication(String name) {
    return 'Cancelled application to $name';
  }

  @override
  String applicationSubmitted(String name) {
    return 'Application submitted for $name';
  }

  @override
  String joinedTeam(String name) {
    return 'Joined $name!';
  }

  @override
  String failedToLeaveTeam(String name) {
    return 'Failed to leave $name';
  }

  @override
  String get failedToCancelApplication => 'Failed to cancel application';

  @override
  String failedToApplyTeam(String name) {
    return 'Failed to apply to $name';
  }

  @override
  String failedToJoinTeam(String name) {
    return 'Failed to join $name';
  }

  @override
  String get bulletin => 'Bulletin';

  @override
  String get latestSermon => 'Latest Sermon';

  @override
  String get recentUpdates => 'Recent Updates';

  @override
  String get pinnedUpdates => 'Pinned Updates';

  @override
  String get upcomingEvents => 'Upcoming Events';

  @override
  String get viewAll => 'View All';

  @override
  String get updatesRefreshed => 'Updates refreshed';

  @override
  String get noUpdates => 'No Updates';

  @override
  String get checkBackLater => 'Check back later for church news and announcements';

  @override
  String get updateCreatedSuccess => 'Update created successfully!';

  @override
  String get failedToCreateUpdate => 'Failed to create update';

  @override
  String get editUpdate => 'Edit Update';

  @override
  String get deleteUpdate => 'Delete Update';

  @override
  String editing(String title) {
    return 'Editing \"$title\"';
  }

  @override
  String get deleteConfirmTitle => 'Delete Update';

  @override
  String deleteConfirmMessage(String title) {
    return 'Are you sure you want to delete \"$title\"? This action cannot be undone.';
  }

  @override
  String deleted(String title) {
    return 'Deleted \"$title\"';
  }

  @override
  String get failedToDelete => 'Failed to delete';

  @override
  String get updateTypeAnnouncement => 'ANNOUNCEMENT';

  @override
  String get updateTypeNews => 'NEWS';

  @override
  String get updateTypePrayer => 'PRAYER';

  @override
  String get updateTypeCelebration => 'CELEBRATION';

  @override
  String get updateTypeUrgent => 'URGENT';

  @override
  String get photos => 'Photos';

  @override
  String get videos => 'Videos';

  @override
  String get audio => 'Audio';

  @override
  String get sermons => 'Sermons';

  @override
  String get media => 'Media';

  @override
  String get folders => 'Folders';

  @override
  String get createFolder => 'Create Folder';

  @override
  String get uploadMedia => 'Upload Media';

  @override
  String get showDeletedItems => 'Show deleted items';

  @override
  String get hideDeletedItems => 'Hide deleted items';

  @override
  String get folderManagement => 'Folder Management';

  @override
  String get restoreFolder => 'Restore Folder';

  @override
  String restoreFolderDesc(String name) {
    return 'Restore $name folder';
  }

  @override
  String get permanentDelete => 'Permanent Delete';

  @override
  String get permanentDeleteDesc => 'Completely delete the folder (cannot be undone)';

  @override
  String get editThumbnail => 'Edit Thumbnail';

  @override
  String get addThumbnail => 'Add folder thumbnail';

  @override
  String get changeThumbnail => 'Change folder thumbnail';

  @override
  String get deleteFolder => 'Delete Folder';

  @override
  String deleteFolderDesc(String name) {
    return 'Delete $name folder';
  }

  @override
  String get deleteFolderConfirmTitle => 'Delete Folder Confirmation';

  @override
  String deleteFolderConfirmMessage(String name) {
    return 'Are you sure you want to delete \"$name\" folder?';
  }

  @override
  String get deleteFolderNote => 'This action can be undone. The folder and contents will be hidden but not completely deleted.';

  @override
  String get permanentDeleteConfirmTitle => 'Permanent Delete Confirmation';

  @override
  String permanentDeleteConfirmMessage(String name) {
    return 'Are you sure you want to permanently delete \"$name\" folder?';
  }

  @override
  String get permanentDeleteWarning => 'This action cannot be undone. The folder and all contents will be completely deleted.';

  @override
  String folderDeletedSuccess(String name) {
    return '$name folder has been deleted';
  }

  @override
  String folderDeletedAdminNote(String name) {
    return '$name folder has been deleted (still visible in admin mode)';
  }

  @override
  String folderRestoredSuccess(String name) {
    return '$name folder has been restored';
  }

  @override
  String folderPermanentlyDeleted(String name) {
    return '$name folder has been permanently deleted';
  }

  @override
  String thumbnailUpdatedSuccess(String name) {
    return '$name folder thumbnail has been updated';
  }

  @override
  String get folderCreatedSuccess => 'Folder created successfully!';

  @override
  String get uploadingThumbnail => 'Uploading thumbnail...';

  @override
  String get failedToDeleteFolder => 'Failed to delete folder';

  @override
  String get failedToRestoreFolder => 'Failed to restore folder';

  @override
  String get failedToUpdateThumbnail => 'Failed to update thumbnail';

  @override
  String get failedToPermanentDelete => 'Failed to permanently delete';

  @override
  String get failedToCreateFolder => 'Failed to create folder';

  @override
  String get failedToUpload => 'Failed to upload';

  @override
  String mediaDeletedSuccess(String title) {
    return '$title has been deleted';
  }

  @override
  String get failedToDeleteMedia => 'Failed to delete media';

  @override
  String get loadingMoreMedia => 'Loading more media...';

  @override
  String get emptyFolder => 'Folder is empty';

  @override
  String get emptyFolderAdmin => 'Create a new folder or upload media';

  @override
  String get emptyFolderUser => 'No content has been uploaded yet';

  @override
  String get sortFolders => 'Sort folders';

  @override
  String get sortMedia => 'Sort media';

  @override
  String get ascending => 'Ascending';

  @override
  String get descending => 'Descending';

  @override
  String get errorLoadingFolders => 'Error loading folders';

  @override
  String get createFolderTitle => 'Create Folder';

  @override
  String get createFolderDesc => 'Create a new folder to organize media';

  @override
  String get uploadMediaTitle => 'Upload Media';

  @override
  String get uploadMediaDesc => 'Upload photos or videos to the current folder';

  @override
  String welcomeMessage(String name) {
    return 'Welcome, $name!';
  }

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get verifyEmail => 'Verify Email';

  @override
  String get verificationEmailSent => 'Verification email sent';

  @override
  String get checkYourEmail => 'Check your email';

  @override
  String get resendVerification => 'Resend verification';

  @override
  String get emailVerified => 'Email verified';

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get worshipFeedback => 'Worship Feedback';

  @override
  String get submitFeedback => 'Submit Feedback';

  @override
  String get feedbackSubmitted => 'Feedback submitted';

  @override
  String get helpUsImproveExperience => 'Help Us Improve Your Experience';

  @override
  String get tapMapInstruction => 'Tap on the map to indicate your approximate location, then share your environmental feedback.';

  @override
  String get tapMapHint => 'Tap anywhere on the worship area map to indicate your location';

  @override
  String get howsEnvironment => 'How\'s the environment?';

  @override
  String get feedbackTooCold => 'Too Cold';

  @override
  String get feedbackTooHot => 'Too Hot';

  @override
  String get feedbackJustRight => 'Just Right';

  @override
  String get feedbackTooLoud => 'Too Loud';

  @override
  String get feedbackTooQuiet => 'Too Quiet';

  @override
  String get feedbackLighting => 'Lighting Issue';

  @override
  String get thankYouFeedback => 'Thank you for your feedback! We\'ll work to improve the experience.';

  @override
  String get stage => 'STAGE';

  @override
  String get entrance => 'ENTRANCE';

  @override
  String get weeklyBulletin => 'Weekly Bulletin';

  @override
  String get bulletinNotFound => 'Bulletin not found';

  @override
  String get worshipSchedule => 'Worship Schedule';

  @override
  String get details => 'Details';

  @override
  String get worship => 'Worship';

  @override
  String get deleteBulletin => 'Delete Bulletin';

  @override
  String deleteBulletinConfirm(String date) {
    return 'Are you sure you want to delete the bulletin for $date?';
  }

  @override
  String deleteBulletinDetails(String theme, int itemCount, int scheduleCount) {
    return 'This will permanently delete:\n• The bulletin \"$theme\"\n• All $itemCount bulletin items\n• All $scheduleCount worship schedule items\n\nThis action cannot be undone.';
  }

  @override
  String get deletingBulletin => 'Deleting bulletin...';

  @override
  String get bulletinDeletedSuccess => 'Bulletin deleted successfully';

  @override
  String get failedToDeleteBulletin => 'Failed to delete bulletin';

  @override
  String yearBulletins(int year) {
    return '$year Bulletins';
  }

  @override
  String get noBulletinsAvailable => 'No bulletins available';

  @override
  String get bulletinsRefreshed => 'Bulletins refreshed';

  @override
  String get cannotBeUndone => 'This action cannot be undone.';

  @override
  String itemsCount(int count) {
    return '$count items';
  }

  @override
  String get errorLoadingData => 'Error loading data';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get tryAgain => 'Try again';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String get checkConnection => 'Please check your connection and try again';

  @override
  String get exitApp => 'Exit App';

  @override
  String get exitAppConfirm => 'Are you sure you want to exit?';

  @override
  String get exit => 'Exit';

  @override
  String get location => 'Location';

  @override
  String get justNow => 'Just now';
}
