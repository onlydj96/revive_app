// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '에셀 - 리바이브 교회';

  @override
  String get home => '홈';

  @override
  String get resources => '자료실';

  @override
  String get schedule => '일정';

  @override
  String get teams => '팀';

  @override
  String get updates => '소식';

  @override
  String get profile => '프로필';

  @override
  String get settings => '설정';

  @override
  String get signOut => '로그아웃';

  @override
  String get cancel => '취소';

  @override
  String get save => '저장';

  @override
  String get ok => '확인';

  @override
  String get confirm => '확인';

  @override
  String get delete => '삭제';

  @override
  String get edit => '수정';

  @override
  String get close => '닫기';

  @override
  String get undo => '되돌리기';

  @override
  String get unknown => '알 수 없음';

  @override
  String get editProfile => '프로필 수정';

  @override
  String get editProfileComingSoon => '프로필 수정 기능이 곧 출시됩니다!';

  @override
  String get noUserData => '사용자 정보가 없습니다';

  @override
  String get churchInformation => '교회 정보';

  @override
  String get role => '직분';

  @override
  String get member => '성도';

  @override
  String get memberSince => '등록일';

  @override
  String get administrator => '관리자';

  @override
  String get mySavedResources => '저장한 자료';

  @override
  String get myEvents => '내 일정';

  @override
  String get myTeams => '내 팀';

  @override
  String get helpAndSupport => '도움말 및 지원';

  @override
  String get comingSoon => '곧 출시';

  @override
  String featureComingSoon(String feature) {
    return '$feature 기능이 곧 출시됩니다!';
  }

  @override
  String get signOutConfirmTitle => '로그아웃';

  @override
  String get signOutConfirmMessage => '정말 로그아웃 하시겠습니까?';

  @override
  String get appearance => '화면';

  @override
  String get themeMode => '테마 모드';

  @override
  String get lightMode => '라이트 모드';

  @override
  String get lightModeDesc => '항상 밝은 테마 사용';

  @override
  String get darkMode => '다크 모드';

  @override
  String get darkModeDesc => '항상 어두운 테마 사용';

  @override
  String get systemMode => '시스템';

  @override
  String get systemModeDesc => '시스템 테마 따라가기';

  @override
  String currentTheme(String mode, String system) {
    return '현재: $mode | 시스템: $system';
  }

  @override
  String get language => '언어';

  @override
  String get languageDesc => '사용할 언어를 선택하세요';

  @override
  String get english => 'English';

  @override
  String get korean => '한국어';

  @override
  String get about => '정보';

  @override
  String get appVersion => '앱 버전';

  @override
  String get reviveChurch => '리바이브 교회';

  @override
  String get churchManagementAssistant => '교회 관리 도우미';

  @override
  String get login => '로그인';

  @override
  String get signUp => '회원가입';

  @override
  String get email => '이메일';

  @override
  String get password => '비밀번호';

  @override
  String get confirmPassword => '비밀번호 확인';

  @override
  String get name => '이름';

  @override
  String get fullName => '성명';

  @override
  String get forgotPassword => '비밀번호를 잊으셨나요?';

  @override
  String get dontHaveAccount => '계정이 없으신가요?';

  @override
  String get alreadyHaveAccount => '이미 계정이 있으신가요?';

  @override
  String get createAccount => '계정 만들기';

  @override
  String get welcomeBack => '다시 오신 것을 환영합니다';

  @override
  String get loginToContinue => '계속하려면 로그인하세요';

  @override
  String get createYourAccount => '계정을 만드세요';

  @override
  String get joinOurCommunity => '우리 공동체에 함께하세요';

  @override
  String get orContinueWith => '또는 다음으로 계속';

  @override
  String get bySigningUp => '가입하시면 다음에 동의하는 것입니다:';

  @override
  String get termsOfService => '서비스 약관';

  @override
  String get and => '및';

  @override
  String get privacyPolicy => '개인정보 처리방침';

  @override
  String get welcomeToEzer => '에셀에 오신 것을 환영합니다';

  @override
  String get signInToContinue => '계속하려면 로그인하세요';

  @override
  String get rememberMe => '로그인 상태 유지';

  @override
  String get signIn => '로그인';

  @override
  String get or => '또는';

  @override
  String get continueWithGoogle => 'Google로 계속';

  @override
  String get joinReviveChurch => '리바이브 교회에 오신 것을 환영합니다';

  @override
  String get createAccountToStart => '시작하려면 계정을 만드세요';

  @override
  String get pleaseEnterFullName => '성명을 입력해 주세요';

  @override
  String get nameTooShort => '이름은 2자 이상이어야 합니다';

  @override
  String get pleaseEnterEmail => '이메일을 입력해 주세요';

  @override
  String get pleaseEnterValidEmail => '유효한 이메일을 입력해 주세요';

  @override
  String get acceptTerms => '이용약관에 동의해 주세요';

  @override
  String get iAgreeToThe => '다음에 동의합니다:';

  @override
  String get search => '검색';

  @override
  String get searchHint => '검색...';

  @override
  String get searchFoldersAndMedia => '폴더 및 미디어 검색...';

  @override
  String get noResultsFound => '검색 결과가 없습니다';

  @override
  String noSearchResults(String query) {
    return '\"$query\"에 대한 결과가 없습니다';
  }

  @override
  String get clearSearch => '검색 초기화';

  @override
  String get loading => '로딩 중...';

  @override
  String get loadingMore => '더 불러오는 중...';

  @override
  String get error => '오류';

  @override
  String get retry => '다시 시도';

  @override
  String get refresh => '새로고침';

  @override
  String get today => '오늘';

  @override
  String get tomorrow => '내일';

  @override
  String get yesterday => '어제';

  @override
  String get thisWeek => '이번 주';

  @override
  String get thisMonth => '이번 달';

  @override
  String daysAgo(int days) {
    return '$days일 전';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours시간 전';
  }

  @override
  String minutesAgo(int minutes) {
    return '$minutes분 전';
  }

  @override
  String inDays(int days) {
    return '$days일 후';
  }

  @override
  String inHours(int hours) {
    return '$hours시간 후';
  }

  @override
  String inMinutes(int minutes) {
    return '$minutes분 후';
  }

  @override
  String get ongoing => '진행 중';

  @override
  String get events => '행사';

  @override
  String get noUpcomingEvents => '예정된 행사가 없습니다';

  @override
  String get noEventsScheduled => '예정된 일정이 없습니다';

  @override
  String forDate(String date) {
    return '$date';
  }

  @override
  String eventsFor(String date) {
    return '$date 일정';
  }

  @override
  String get eventDetails => '행사 상세';

  @override
  String get addEvent => '일정 추가';

  @override
  String get createEvent => '일정 만들기';

  @override
  String get editEvent => '일정 수정';

  @override
  String get deleteEvent => '일정 삭제';

  @override
  String eventCreatedSuccess(String title) {
    return '\"$title\" 일정이 생성되었습니다!';
  }

  @override
  String eventUpdatedSuccess(String title) {
    return '\"$title\" 일정이 수정되었습니다!';
  }

  @override
  String get eventDeletedSuccess => '일정이 삭제되었습니다';

  @override
  String get failedToCreateEvent => '일정 생성 실패';

  @override
  String get failedToUpdateEvent => '일정 수정 실패';

  @override
  String get failedToDeleteEvent => '일정 삭제 실패';

  @override
  String get join => '참가';

  @override
  String get joined => '참가 중';

  @override
  String get leave => '나가기';

  @override
  String get full => '마감';

  @override
  String joinedCount(int current, int max) {
    return '$current/$max명 참가';
  }

  @override
  String get successfullyRegistered => '등록이 완료되었습니다!';

  @override
  String get cancelledRegistration => '등록이 취소되었습니다';

  @override
  String leftEvent(String title) {
    return '$title에서 나갔습니다';
  }

  @override
  String joinedEvent(String title) {
    return '$title에 참가했습니다!';
  }

  @override
  String get featured => '추천';

  @override
  String get worshipFeedbackMap => '예배 피드백 지도';

  @override
  String get shareLocationFeedback => '위치 및 피드백 공유하기';

  @override
  String get helpImproveWorship => '더 나은 예배 환경을 위해 의견을 들려주세요';

  @override
  String get thisWeeksBulletin => '이번 주 주보';

  @override
  String weekOf(String date) {
    return '$date 주간';
  }

  @override
  String andMoreItems(int count) {
    return '외 $count개 항목...';
  }

  @override
  String viewAllBulletins(int year) {
    return '$year년 주보 전체보기';
  }

  @override
  String get connectGroups => '소그룹';

  @override
  String get hangouts => '모임';

  @override
  String get createTeam => '팀 만들기';

  @override
  String get joinTeam => '팀 가입';

  @override
  String get leaveTeam => '팀 탈퇴';

  @override
  String get teamDetails => '팀 상세';

  @override
  String get noTeamsAvailable => '가능한 팀이 없습니다';

  @override
  String get applicationPending => '신청 대기 중';

  @override
  String get applicationApproved => '신청 승인됨';

  @override
  String get applicationRejected => '신청 거절됨';

  @override
  String get aboutConnectGroups => '소그룹 소개';

  @override
  String get connectGroupsDescription => '소그룹은 영적 성장, 교제, 제자훈련을 위한 정기적인 신청제 모임입니다. 헌신이 필요하며 특정 요건이 있을 수 있습니다.';

  @override
  String get availableGroups => '참여 가능한 그룹';

  @override
  String get noConnectGroupsAvailable => '소그룹이 없습니다';

  @override
  String get checkBackLaterForGroups => '나중에 새 그룹을 확인하세요';

  @override
  String get aboutHangouts => '모임 소개';

  @override
  String get hangoutsDescription => '모임은 교제, 즐거움, 관계 형성을 위한 개방적이고 캐주얼한 행사입니다. 누구나 환영하며 신청이 필요 없습니다!';

  @override
  String get joinAHangout => '모임 참가하기';

  @override
  String get noHangoutsAvailable => '모임이 없습니다';

  @override
  String get checkBackLaterForActivities => '나중에 새 활동을 확인하세요';

  @override
  String get applicationRequired => '신청 필요';

  @override
  String get openToAll => '누구나 참여 가능';

  @override
  String ledBy(String name) {
    return '$name 리더';
  }

  @override
  String membersCount(int count) {
    return '$count명';
  }

  @override
  String spotsFilled(int current, int max) {
    return '$current/$max명 참여';
  }

  @override
  String activeMembers(int count) {
    return '$count명 활동 중';
  }

  @override
  String get apply => '신청';

  @override
  String get reapply => '재신청';

  @override
  String leftTeam(String name) {
    return '$name에서 나갔습니다';
  }

  @override
  String cancelledApplication(String name) {
    return '$name 신청이 취소되었습니다';
  }

  @override
  String applicationSubmitted(String name) {
    return '$name에 신청되었습니다';
  }

  @override
  String joinedTeam(String name) {
    return '$name에 참가했습니다!';
  }

  @override
  String failedToLeaveTeam(String name) {
    return '$name 탈퇴 실패';
  }

  @override
  String get failedToCancelApplication => '신청 취소 실패';

  @override
  String failedToApplyTeam(String name) {
    return '$name 신청 실패';
  }

  @override
  String failedToJoinTeam(String name) {
    return '$name 참가 실패';
  }

  @override
  String get bulletin => '주보';

  @override
  String get latestSermon => '최신 설교';

  @override
  String get recentUpdates => '최근 소식';

  @override
  String get pinnedUpdates => '고정된 소식';

  @override
  String get upcomingEvents => '다가오는 행사';

  @override
  String get viewAll => '전체 보기';

  @override
  String get updatesRefreshed => '소식이 새로고침되었습니다';

  @override
  String get noUpdates => '소식이 없습니다';

  @override
  String get checkBackLater => '나중에 교회 뉴스와 공지사항을 확인하세요';

  @override
  String get updateCreatedSuccess => '소식이 성공적으로 생성되었습니다!';

  @override
  String get failedToCreateUpdate => '소식 생성 실패';

  @override
  String get editUpdate => '소식 수정';

  @override
  String get deleteUpdate => '소식 삭제';

  @override
  String editing(String title) {
    return '\"$title\" 수정 중';
  }

  @override
  String get deleteConfirmTitle => '소식 삭제';

  @override
  String deleteConfirmMessage(String title) {
    return '\"$title\"을(를) 삭제하시겠습니까? 이 작업은 취소할 수 없습니다.';
  }

  @override
  String deleted(String title) {
    return '\"$title\"이(가) 삭제되었습니다';
  }

  @override
  String get failedToDelete => '삭제 실패';

  @override
  String get updateTypeAnnouncement => '공지';

  @override
  String get updateTypeNews => '뉴스';

  @override
  String get updateTypePrayer => '기도';

  @override
  String get updateTypeCelebration => '축하';

  @override
  String get updateTypeUrgent => '긴급';

  @override
  String get photos => '사진';

  @override
  String get videos => '영상';

  @override
  String get audio => '오디오';

  @override
  String get sermons => '설교';

  @override
  String get media => '미디어';

  @override
  String get folders => '폴더';

  @override
  String get createFolder => '폴더 만들기';

  @override
  String get uploadMedia => '미디어 업로드';

  @override
  String get showDeletedItems => '삭제된 항목 보기';

  @override
  String get hideDeletedItems => '삭제된 항목 숨기기';

  @override
  String get folderManagement => '폴더 관리';

  @override
  String get restoreFolder => '폴더 복구';

  @override
  String restoreFolderDesc(String name) {
    return '$name 폴더를 복구합니다';
  }

  @override
  String get permanentDelete => '영구 삭제';

  @override
  String get permanentDeleteDesc => '폴더를 완전히 삭제합니다 (복구 불가)';

  @override
  String get editThumbnail => '썸네일 수정';

  @override
  String get addThumbnail => '폴더 썸네일 추가';

  @override
  String get changeThumbnail => '폴더 썸네일 변경';

  @override
  String get deleteFolder => '폴더 삭제';

  @override
  String deleteFolderDesc(String name) {
    return '$name 폴더를 삭제합니다';
  }

  @override
  String get deleteFolderConfirmTitle => '폴더 삭제 확인';

  @override
  String deleteFolderConfirmMessage(String name) {
    return '정말로 \"$name\" 폴더를 삭제하시겠습니까?';
  }

  @override
  String get deleteFolderNote => '이 작업은 되돌릴 수 있습니다. 폴더와 내용물이 숨겨지지만 완전히 삭제되지는 않습니다.';

  @override
  String get permanentDeleteConfirmTitle => '영구 삭제 확인';

  @override
  String permanentDeleteConfirmMessage(String name) {
    return '정말로 \"$name\" 폴더를 영구 삭제하시겠습니까?';
  }

  @override
  String get permanentDeleteWarning => '이 작업은 되돌릴 수 없습니다. 폴더와 모든 내용이 완전히 삭제됩니다.';

  @override
  String folderDeletedSuccess(String name) {
    return '$name 폴더가 삭제되었습니다';
  }

  @override
  String folderDeletedAdminNote(String name) {
    return '$name 폴더가 삭제되었습니다 (관리자 모드에서는 계속 보입니다)';
  }

  @override
  String folderRestoredSuccess(String name) {
    return '$name 폴더가 복구되었습니다';
  }

  @override
  String folderPermanentlyDeleted(String name) {
    return '$name 폴더가 영구적으로 삭제되었습니다';
  }

  @override
  String thumbnailUpdatedSuccess(String name) {
    return '$name 폴더의 썸네일이 업데이트되었습니다';
  }

  @override
  String get folderCreatedSuccess => '폴더가 성공적으로 생성되었습니다!';

  @override
  String get uploadingThumbnail => '썸네일 업로드 중...';

  @override
  String get failedToDeleteFolder => '폴더 삭제 실패';

  @override
  String get failedToRestoreFolder => '폴더 복구 실패';

  @override
  String get failedToUpdateThumbnail => '썸네일 업데이트 실패';

  @override
  String get failedToPermanentDelete => '영구 삭제 실패';

  @override
  String get failedToCreateFolder => '폴더 생성 실패';

  @override
  String get failedToUpload => '업로드 실패';

  @override
  String mediaDeletedSuccess(String title) {
    return '$title이(가) 삭제되었습니다';
  }

  @override
  String get failedToDeleteMedia => '미디어 삭제 실패';

  @override
  String get loadingMoreMedia => '미디어 더 불러오는 중...';

  @override
  String get emptyFolder => '폴더가 비어있습니다';

  @override
  String get emptyFolderAdmin => '새 폴더를 만들거나 미디어를 업로드하세요';

  @override
  String get emptyFolderUser => '아직 콘텐츠가 업로드되지 않았습니다';

  @override
  String get sortFolders => '폴더 정렬';

  @override
  String get sortMedia => '미디어 정렬';

  @override
  String get ascending => '오름차순';

  @override
  String get descending => '내림차순';

  @override
  String get errorLoadingFolders => '폴더 로딩 오류';

  @override
  String get createFolderTitle => '폴더 만들기';

  @override
  String get createFolderDesc => '새 폴더를 생성하여 미디어를 정리';

  @override
  String get uploadMediaTitle => '미디어 업로드';

  @override
  String get uploadMediaDesc => '사진이나 동영상을 현재 폴더에 업로드';

  @override
  String welcomeMessage(String name) {
    return '환영합니다, $name!';
  }

  @override
  String get goodMorning => '좋은 아침입니다';

  @override
  String get goodAfternoon => '좋은 오후입니다';

  @override
  String get goodEvening => '좋은 저녁입니다';

  @override
  String get verifyEmail => '이메일 인증';

  @override
  String get verificationEmailSent => '인증 이메일이 발송되었습니다';

  @override
  String get checkYourEmail => '이메일을 확인하세요';

  @override
  String get resendVerification => '인증 재발송';

  @override
  String get emailVerified => '이메일 인증 완료';

  @override
  String get notifications => '알림';

  @override
  String get noNotifications => '알림이 없습니다';

  @override
  String get markAllAsRead => '모두 읽음 표시';

  @override
  String get worshipFeedback => '예배 피드백';

  @override
  String get submitFeedback => '피드백 제출';

  @override
  String get feedbackSubmitted => '피드백이 제출되었습니다';

  @override
  String get helpUsImproveExperience => '더 나은 예배 경험을 위해 도와주세요';

  @override
  String get tapMapInstruction => '지도에서 대략적인 위치를 탭하고 환경 피드백을 공유해 주세요.';

  @override
  String get tapMapHint => '예배당 지도에서 아무 곳이나 탭하여 위치를 표시하세요';

  @override
  String get howsEnvironment => '환경은 어떠신가요?';

  @override
  String get feedbackTooCold => '너무 추워요';

  @override
  String get feedbackTooHot => '너무 더워요';

  @override
  String get feedbackJustRight => '딱 좋아요';

  @override
  String get feedbackTooLoud => '너무 시끄러워요';

  @override
  String get feedbackTooQuiet => '너무 조용해요';

  @override
  String get feedbackLighting => '조명 문제';

  @override
  String get thankYouFeedback => '피드백 감사합니다! 더 나은 환경을 만들기 위해 노력하겠습니다.';

  @override
  String get stage => '강단';

  @override
  String get entrance => '입구';

  @override
  String get weeklyBulletin => '주간 주보';

  @override
  String get bulletinNotFound => '주보를 찾을 수 없습니다';

  @override
  String get worshipSchedule => '예배 순서';

  @override
  String get details => '상세 내용';

  @override
  String get worship => '예배';

  @override
  String get deleteBulletin => '주보 삭제';

  @override
  String deleteBulletinConfirm(String date) {
    return '$date 주보를 삭제하시겠습니까?';
  }

  @override
  String deleteBulletinDetails(String theme, int itemCount, int scheduleCount) {
    return '다음 항목이 영구 삭제됩니다:\n• \"$theme\" 주보\n• 모든 $itemCount개 주보 항목\n• 모든 $scheduleCount개 예배 순서 항목\n\n이 작업은 취소할 수 없습니다.';
  }

  @override
  String get deletingBulletin => '주보 삭제 중...';

  @override
  String get bulletinDeletedSuccess => '주보가 성공적으로 삭제되었습니다';

  @override
  String get failedToDeleteBulletin => '주보 삭제 실패';

  @override
  String yearBulletins(int year) {
    return '$year년 주보';
  }

  @override
  String get noBulletinsAvailable => '주보가 없습니다';

  @override
  String get bulletinsRefreshed => '주보가 새로고침되었습니다';

  @override
  String get cannotBeUndone => '이 작업은 취소할 수 없습니다.';

  @override
  String itemsCount(int count) {
    return '$count개 항목';
  }

  @override
  String get errorLoadingData => '데이터 로딩 오류';

  @override
  String get somethingWentWrong => '문제가 발생했습니다';

  @override
  String get tryAgain => '다시 시도';

  @override
  String get noInternetConnection => '인터넷 연결이 없습니다';

  @override
  String get checkConnection => '연결을 확인하고 다시 시도해주세요';

  @override
  String get exitApp => '앱 종료';

  @override
  String get exitAppConfirm => '정말 종료하시겠습니까?';

  @override
  String get exit => '종료';

  @override
  String get location => '위치';

  @override
  String get justNow => '방금 전';
}
