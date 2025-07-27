# Supabase 설정 가이드

## 1. Supabase 프로젝트 생성

1. [Supabase](https://supabase.com)에 회원가입
2. 새 프로젝트 생성
3. 프로젝트 URL과 anon key 확인

## 2. 앱 설정

`lib/config/supabase_config.dart` 파일에서 다음 값들을 실제 Supabase 프로젝트 정보로 교체:

```dart
class SupabaseConfig {
  static const String url = 'YOUR_ACTUAL_SUPABASE_URL';
  static const String anonKey = 'YOUR_ACTUAL_SUPABASE_ANON_KEY';
}
```

## 3. 데이터베이스 스키마 설정

Supabase SQL 편집기에서 다음 테이블들을 생성:

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