-- =============================================
-- Ezer Church Management App - Initial Schema
-- =============================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================
-- User Profiles Table
-- =============================================
CREATE TABLE public.user_profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    full_name TEXT NOT NULL,
    email TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('admin', 'member')),
    profile_image_url TEXT,
    phone TEXT,
    address TEXT,
    emergency_contact TEXT,
    join_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- Updates/Announcements Table
-- =============================================
CREATE TABLE public.updates (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('announcement', 'news', 'prayer', 'celebration', 'urgent')),
    author_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    author_name TEXT NOT NULL,
    image_url TEXT,
    is_pinned BOOLEAN DEFAULT FALSE,
    tags TEXT[] DEFAULT '{}',
    view_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- Media Items Table
-- =============================================
CREATE TABLE public.media_items (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    type TEXT NOT NULL CHECK (type IN ('photo', 'video', 'audio')),
    category TEXT NOT NULL CHECK (category IN ('worship', 'sermon', 'fellowship', 'outreach', 'youth', 'children', 'general')),
    file_url TEXT NOT NULL,
    thumbnail_url TEXT,
    photographer TEXT,
    duration INTEGER, -- For video/audio in seconds
    file_size BIGINT, -- File size in bytes
    mime_type TEXT,
    tags TEXT[] DEFAULT '{}',
    view_count INTEGER DEFAULT 0,
    download_count INTEGER DEFAULT 0,
    uploaded_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- Events Table
-- =============================================
CREATE TABLE public.events (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    location TEXT NOT NULL,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    is_all_day BOOLEAN DEFAULT FALSE,
    max_attendees INTEGER,
    current_attendees INTEGER DEFAULT 0,
    registration_required BOOLEAN DEFAULT FALSE,
    registration_deadline TIMESTAMP WITH TIME ZONE,
    category TEXT NOT NULL CHECK (category IN ('worship', 'study', 'fellowship', 'outreach', 'youth', 'children', 'special')),
    image_url TEXT,
    contact_info TEXT,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- Teams Table
-- =============================================
CREATE TABLE public.teams (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    type TEXT NOT NULL CHECK (type IN ('connect_group', 'hangout')),
    category TEXT NOT NULL CHECK (category IN ('worship', 'outreach', 'youth', 'children', 'admin', 'fellowship')),
    leader_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    leader_name TEXT NOT NULL,
    max_members INTEGER,
    current_members INTEGER DEFAULT 0,
    meeting_schedule TEXT,
    meeting_location TEXT,
    contact_info TEXT,
    image_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    application_required BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- Sermons Table
-- =============================================
CREATE TABLE public.sermons (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    speaker TEXT NOT NULL,
    series TEXT,
    scripture_reference TEXT,
    description TEXT,
    audio_url TEXT,
    video_url TEXT,
    transcript TEXT,
    thumbnail_url TEXT,
    duration INTEGER, -- Duration in seconds
    service_date DATE NOT NULL,
    view_count INTEGER DEFAULT 0,
    download_count INTEGER DEFAULT 0,
    tags TEXT[] DEFAULT '{}',
    uploaded_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- Bulletins Table
-- =============================================
CREATE TABLE public.bulletins (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    service_date DATE NOT NULL,
    theme TEXT,
    scripture_reading TEXT,
    announcements TEXT,
    prayer_requests TEXT,
    upcoming_events TEXT,
    pdf_url TEXT,
    image_url TEXT,
    view_count INTEGER DEFAULT 0,
    download_count INTEGER DEFAULT 0,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- User Collections (Bookmarks/Favorites)
-- =============================================
CREATE TABLE public.user_collections (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    collection_type TEXT NOT NULL CHECK (collection_type IN ('media', 'sermon', 'event', 'team')),
    item_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, collection_type, item_id)
);

-- =============================================
-- Event Registrations
-- =============================================
CREATE TABLE public.event_registrations (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    event_id UUID REFERENCES public.events(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    user_name TEXT NOT NULL,
    user_email TEXT NOT NULL,
    registration_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status TEXT NOT NULL DEFAULT 'registered' CHECK (status IN ('registered', 'cancelled', 'attended')),
    notes TEXT,
    UNIQUE(event_id, user_id)
);

-- =============================================
-- Team Memberships
-- =============================================
CREATE TABLE public.team_memberships (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    team_id UUID REFERENCES public.teams(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    user_name TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('leader', 'co_leader', 'member')),
    join_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'pending')),
    UNIQUE(team_id, user_id)
);

-- =============================================
-- Indexes for Performance
-- =============================================
CREATE INDEX idx_updates_created_at ON public.updates(created_at DESC);
CREATE INDEX idx_updates_type ON public.updates(type);
CREATE INDEX idx_updates_is_pinned ON public.updates(is_pinned);
CREATE INDEX idx_updates_author_id ON public.updates(author_id);

CREATE INDEX idx_media_type ON public.media_items(type);
CREATE INDEX idx_media_category ON public.media_items(category);
CREATE INDEX idx_media_created_at ON public.media_items(created_at DESC);
CREATE INDEX idx_media_uploaded_by ON public.media_items(uploaded_by);

CREATE INDEX idx_events_start_time ON public.events(start_time);
CREATE INDEX idx_events_category ON public.events(category);
CREATE INDEX idx_events_created_by ON public.events(created_by);

CREATE INDEX idx_teams_type ON public.teams(type);
CREATE INDEX idx_teams_category ON public.teams(category);
CREATE INDEX idx_teams_is_active ON public.teams(is_active);

CREATE INDEX idx_sermons_service_date ON public.sermons(service_date DESC);
CREATE INDEX idx_sermons_speaker ON public.sermons(speaker);
CREATE INDEX idx_sermons_series ON public.sermons(series);

CREATE INDEX idx_bulletins_service_date ON public.bulletins(service_date DESC);

CREATE INDEX idx_user_collections_user_id ON public.user_collections(user_id);
CREATE INDEX idx_user_collections_type_item ON public.user_collections(collection_type, item_id);

CREATE INDEX idx_event_registrations_event_id ON public.event_registrations(event_id);
CREATE INDEX idx_event_registrations_user_id ON public.event_registrations(user_id);

CREATE INDEX idx_team_memberships_team_id ON public.team_memberships(team_id);
CREATE INDEX idx_team_memberships_user_id ON public.team_memberships(user_id);