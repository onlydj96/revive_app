# Supabase 설정 및 배포 가이드

이 문서는 Ezer 교회 관리 앱을 위한 Supabase 데이터베이스 설정과 Mock 데이터를 실제 데이터베이스로 마이그레이션하는 방법을 설명합니다.

## 🎯 주요 업데이트 사항

### ✅ 완료된 작업
- **전체 데이터베이스 스키마 설계**: 10개의 메인 테이블과 관계형 구조
- **Row Level Security (RLS) 정책**: 관리자와 일반 사용자 권한 분리
- **Real-time 기능**: 실시간 데이터 동기화
- **Mock 데이터 → Supabase 연동**: Updates Provider 완전 전환
- **권한 기반 UI**: 관리자만 생성/편집/삭제 가능
- **사용자 관리 시스템**: 관리자가 사용자 역할 변경 가능

## 1. Supabase 프로젝트 생성

1. [Supabase](https://supabase.com)에 로그인
2. "New Project" 클릭
3. 프로젝트 이름 입력 (예: `ezer-church-app`)
4. Strong password 설정
5. Region 선택 (Asia Northeast 1 - Tokyo)
6. "Create new project" 클릭

## 2. 데이터베이스 스키마 설정

### 2.1 마이그레이션 파일 실행

Supabase Dashboard → SQL Editor → "+ New query"에서 다음 순서로 실행:

**1. 초기 스키마 생성** (`supabase/migrations/001_initial_schema.sql`)
**2. 트리거 및 함수** (`supabase/migrations/002_triggers_and_functions.sql`)  
**3. 보안 정책** (`supabase/migrations/003_row_level_security.sql`)
**4. 샘플 데이터** (`supabase/migrations/004_seed_data.sql`) - 선택사항

### 2.2 생성된 테이블 구조

| 테이블명 | 설명 | 주요 기능 |
|---------|------|----------|
| `user_profiles` | 사용자 프로필 및 역할 관리 | **Admin/Member 권한 시스템** |
| `updates` | 교회 공지사항/업데이트 | 실시간 동기화, 핀 기능 |
| `media_items` | 사진/동영상/오디오 자료 | 카테고리별 분류, 북마크 |
| `events` | 일정/이벤트 관리 | 참가 신청, 정원 관리 |
| `teams` | 팀/그룹 관리 | Connect Groups, Hangouts |
| `sermons` | 설교 자료 | 오디오/비디오, 스크립트 |
| `bulletins` | 주보 관리 | PDF 업로드, 테마별 분류 |
| `user_collections` | 사용자 북마크/즐겨찾기 | 개인 컬렉션 관리 |
| `event_registrations` | 이벤트 참가 신청 | 참가자 관리 |
| `team_memberships` | 팀 멤버십 관리 | 팀 가입/탈퇴 |

## 3. 앱 설정 업데이트

### 프로필 테이블
```sql
-- 사용자 프로필 확장 테이블
CREATE TABLE profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE,
  full_name TEXT,
  avatar_url TEXT,
  role TEXT DEFAULT 'Member',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (id)
);

-- RLS (Row Level Security) 활성화
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- 정책 생성
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- 사용자 생성 시 자동으로 프로필 생성하는 함수
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, avatar_url, role)
  VALUES (new.id, new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'avatar_url', 'Member');
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 트리거 생성
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
```

### 이벤트 테이블
```sql
CREATE TABLE events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE NOT NULL,
  location TEXT NOT NULL,
  event_type TEXT NOT NULL,
  image_url TEXT,
  is_highlighted BOOLEAN DEFAULT FALSE,
  requires_signup BOOLEAN DEFAULT FALSE,
  max_participants INTEGER,
  current_participants INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view events" ON events
  FOR SELECT TO authenticated USING (true);
```

### 미디어 테이블
```sql
CREATE TABLE media_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  media_type TEXT NOT NULL,
  category TEXT NOT NULL,
  url TEXT NOT NULL,
  thumbnail_url TEXT,
  photographer TEXT,
  tags TEXT[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE media_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view media" ON media_items
  FOR SELECT TO authenticated USING (true);
```

### 업데이트 테이블
```sql
CREATE TABLE updates (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  update_type TEXT NOT NULL,
  author TEXT NOT NULL,
  is_pinned BOOLEAN DEFAULT FALSE,
  image_url TEXT,
  tags TEXT[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE updates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view updates" ON updates
  FOR SELECT TO authenticated USING (true);
```

### 팀 테이블
```sql
CREATE TABLE teams (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  team_type TEXT NOT NULL,
  image_url TEXT,
  leader TEXT NOT NULL,
  meeting_time TIME,
  meeting_location TEXT,
  requires_application BOOLEAN DEFAULT FALSE,
  max_members INTEGER,
  current_members INTEGER DEFAULT 0,
  requirements TEXT[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE teams ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view teams" ON teams
  FOR SELECT TO authenticated USING (true);
```

### 설교 테이블
```sql
CREATE TABLE sermons (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  speaker TEXT NOT NULL,
  sermon_date DATE NOT NULL,
  audio_url TEXT,
  video_url TEXT,
  transcript TEXT,
  thumbnail_url TEXT,
  tags TEXT[],
  series TEXT NOT NULL,
  bible_passage TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE sermons ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view sermons" ON sermons
  FOR SELECT TO authenticated USING (true);
```

## 4. 인증 설정

### URL 설정 (매우 중요!)
Supabase 대시보드에서 Authentication > URL Configuration으로 이동하여 다음을 설정:

1. **Site URL**: `ezer://auth-callback`
2. **Redirect URLs** 섹션에 다음 추가:
   - `ezer://auth-callback/**`
   - `http://localhost:3000/**` (웹 테스트용)
   - `https://localhost:3000/**` (웹 테스트용)

### 이메일 설정
1. Authentication > Settings로 이동
2. **Enable email confirmations** 체크
3. **Email Templates** > **Confirm signup**에서 템플릿 확인
   - 기본 템플릿의 `{{ .SiteURL }}` 부분이 `ezer://auth-callback`로 리디렉션됨
4. 필요한 경우 소셜 로그인 제공업체 설정

## 5. 스토리지 설정 (선택사항)

미디어 파일 업로드를 위한 스토리지 버킷 생성:
1. Storage 섹션으로 이동
2. 새 버킷 생성 (예: 'media', 'avatars')
3. 적절한 정책 설정

## 6. Deep Link 테스트

### Android 테스트
```bash
# 터미널에서 deep link 테스트
adb shell am start \
  -W -a android.intent.action.VIEW \
  -d "ezer://auth-callback?access_token=test&refresh_token=test" \
  com.example.ezer
```

### iOS 테스트
시뮬레이터에서 Safari를 열고 `ezer://auth-callback` 입력

## 7. 앱 테스트

앱을 실행하고:
1. 새 계정 생성
2. 이메일 확인 (자동으로 앱으로 리디렉션됨)
3. 로그인 테스트
4. 프로필 업데이트 테스트

### 문제 해결
- **이메일 링크가 작동하지 않는 경우**: Supabase Site URL이 `ezer://auth-callback`로 설정되었는지 확인
- **앱이 열리지 않는 경우**: 디바이스에서 deep link가 제대로 등록되었는지 확인
- **인증이 완료되지 않는 경우**: 콘솔 로그를 확인하여 deep link 파라미터 확인

## 주의사항

- **보안**: 실제 프로덕션에서는 환경 변수를 사용하여 API 키를 관리하세요
- **RLS**: 모든 테이블에 적절한 Row Level Security 정책을 설정하세요
- **백업**: 중요한 데이터는 정기적으로 백업하세요