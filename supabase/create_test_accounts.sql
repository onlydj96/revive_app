-- ==========================================
-- 테스트 계정 생성 스크립트
-- ==========================================
-- 실행 방법: Supabase Dashboard → SQL Editor → New Query → 붙여넣기 → Run
-- ==========================================

-- 🔍 1단계: 기존 테스트 계정 확인 및 삭제 (선택사항)
-- 이미 계정이 있다면 먼저 삭제
DELETE FROM user_profiles WHERE email IN ('testuser@example.com', 'testadmin@example.com');
DELETE FROM auth.users WHERE email IN ('testuser@example.com', 'testadmin@example.com');

-- ==========================================
-- 👤 Test User 계정 생성 (일반 회원)
-- ==========================================
-- Email: testuser@example.com
-- Password: testpassword123
-- Role: member
-- ==========================================

DO $$
DECLARE
    new_user_id UUID;
BEGIN
    -- 1. auth.users에 사용자 생성
    INSERT INTO auth.users (
        instance_id,
        id,
        aud,
        role,
        email,
        encrypted_password,
        email_confirmed_at,
        recovery_sent_at,
        last_sign_in_at,
        raw_app_meta_data,
        raw_user_meta_data,
        created_at,
        updated_at,
        confirmation_token,
        email_change,
        email_change_token_new,
        recovery_token
    ) VALUES (
        '00000000-0000-0000-0000-000000000000',
        gen_random_uuid(),
        'authenticated',
        'authenticated',
        'testuser@example.com',
        crypt('testpassword123', gen_salt('bf')),
        NOW(),
        NOW(),
        NOW(),
        '{"provider":"email","providers":["email"]}'::jsonb,
        '{"full_name":"Test User"}'::jsonb,
        NOW(),
        NOW(),
        '',
        '',
        '',
        ''
    ) RETURNING id INTO new_user_id;

    -- 2. user_profiles에 프로필 생성
    INSERT INTO user_profiles (
        id,
        full_name,
        email,
        role,
        join_date,
        is_active,
        created_at,
        updated_at
    ) VALUES (
        new_user_id,
        'Test User',
        'testuser@example.com',
        'member',
        NOW(),
        true,
        NOW(),
        NOW()
    );

    RAISE NOTICE '✅ Test User 계정 생성 완료: testuser@example.com';
END $$;

-- ==========================================
-- 👨‍💼 Test Admin 계정 생성 (관리자)
-- ==========================================
-- Email: testadmin@example.com
-- Password: adminpassword123
-- Role: admin
-- ==========================================

DO $$
DECLARE
    new_admin_id UUID;
BEGIN
    -- 1. auth.users에 관리자 생성
    INSERT INTO auth.users (
        instance_id,
        id,
        aud,
        role,
        email,
        encrypted_password,
        email_confirmed_at,
        recovery_sent_at,
        last_sign_in_at,
        raw_app_meta_data,
        raw_user_meta_data,
        created_at,
        updated_at,
        confirmation_token,
        email_change,
        email_change_token_new,
        recovery_token
    ) VALUES (
        '00000000-0000-0000-0000-000000000000',
        gen_random_uuid(),
        'authenticated',
        'authenticated',
        'testadmin@example.com',
        crypt('adminpassword123', gen_salt('bf')),
        NOW(),
        NOW(),
        NOW(),
        '{"provider":"email","providers":["email"]}'::jsonb,
        '{"full_name":"Test Admin"}'::jsonb,
        NOW(),
        NOW(),
        '',
        '',
        '',
        ''
    ) RETURNING id INTO new_admin_id;

    -- 2. user_profiles에 관리자 프로필 생성
    INSERT INTO user_profiles (
        id,
        full_name,
        email,
        role,
        join_date,
        is_active,
        created_at,
        updated_at
    ) VALUES (
        new_admin_id,
        'Test Admin',
        'testadmin@example.com',
        'admin',
        NOW(),
        true,
        NOW(),
        NOW()
    );

    RAISE NOTICE '✅ Test Admin 계정 생성 완료: testadmin@example.com';
END $$;

-- ==========================================
-- 🔍 생성된 계정 확인
-- ==========================================

SELECT
  '👤 TEST USER' as account_type,
  CASE
    WHEN au.id IS NULL THEN '❌ 없음'
    WHEN au.email_confirmed_at IS NULL THEN '⚠️ 이메일 미인증'
    ELSE '✅ 정상'
  END as auth_status,
  CASE
    WHEN up.id IS NULL THEN '❌ 없음'
    WHEN up.role = 'member' THEN '✅ 정상 (member)'
    ELSE '⚠️ 역할 오류'
  END as profile_status,
  au.email,
  up.full_name,
  up.role,
  au.created_at as created_at
FROM (SELECT 'testuser@example.com' as email) t
LEFT JOIN auth.users au ON au.email = t.email
LEFT JOIN user_profiles up ON up.email = t.email

UNION ALL

SELECT
  '👨‍💼 TEST ADMIN' as account_type,
  CASE
    WHEN au.id IS NULL THEN '❌ 없음'
    WHEN au.email_confirmed_at IS NULL THEN '⚠️ 이메일 미인증'
    ELSE '✅ 정상'
  END as auth_status,
  CASE
    WHEN up.id IS NULL THEN '❌ 없음'
    WHEN up.role = 'admin' THEN '✅ 정상 (admin)'
    ELSE '⚠️ 역할 오류'
  END as profile_status,
  au.email,
  up.full_name,
  up.role,
  au.created_at as created_at
FROM (SELECT 'testadmin@example.com' as email) t
LEFT JOIN auth.users au ON au.email = t.email
LEFT JOIN user_profiles up ON up.email = t.email;

-- ==========================================
-- 📝 생성된 계정 정보 요약
-- ==========================================

SELECT '
========================================
✅ 테스트 계정 생성 완료!
========================================

👤 Test User (일반 회원)
   Email: testuser@example.com
   Password: testpassword123
   Role: member

👨‍💼 Test Admin (관리자)
   Email: testadmin@example.com
   Password: adminpassword123
   Role: admin

========================================
🚀 다음 단계:
========================================
1. 앱에서 로그인 테스트
2. 권한 확인 (Admin은 Schedule에 + 버튼 있음)
3. 필요시 역할 변경:
   UPDATE user_profiles SET role = ''admin''
   WHERE email = ''testuser@example.com'';
========================================
' as "생성 완료";
