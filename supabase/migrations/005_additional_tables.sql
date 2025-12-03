-- =============================================
-- Additional Tables for Ezer App
-- =============================================

-- =============================================
-- Event Signups Table (similar to event_registrations but separate)
-- =============================================
CREATE TABLE IF NOT EXISTS public.event_signups (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    event_id UUID REFERENCES public.events(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    user_name TEXT NOT NULL,
    user_email TEXT NOT NULL,
    signup_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status TEXT NOT NULL DEFAULT 'confirmed' CHECK (status IN ('confirmed', 'cancelled', 'attended', 'waitlist')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(event_id, user_id)
);

-- =============================================
-- Team Applications Table
-- =============================================
CREATE TABLE IF NOT EXISTS public.team_applications (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    team_id UUID REFERENCES public.teams(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    user_name TEXT NOT NULL,
    user_email TEXT NOT NULL,
    phone TEXT,
    message TEXT,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'withdrawn')),
    applied_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    reviewed_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    review_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(team_id, user_id)
);

-- =============================================
-- Hangout Joins Table
-- =============================================
CREATE TABLE IF NOT EXISTS public.hangout_joins (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    team_id UUID REFERENCES public.teams(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    user_name TEXT NOT NULL,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'left')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(team_id, user_id)
);

-- =============================================
-- Indexes for Performance
-- =============================================
CREATE INDEX IF NOT EXISTS idx_event_signups_event_id ON public.event_signups(event_id);
CREATE INDEX IF NOT EXISTS idx_event_signups_user_id ON public.event_signups(user_id);
CREATE INDEX IF NOT EXISTS idx_event_signups_status ON public.event_signups(status);

CREATE INDEX IF NOT EXISTS idx_team_applications_team_id ON public.team_applications(team_id);
CREATE INDEX IF NOT EXISTS idx_team_applications_user_id ON public.team_applications(user_id);
CREATE INDEX IF NOT EXISTS idx_team_applications_status ON public.team_applications(status);

CREATE INDEX IF NOT EXISTS idx_hangout_joins_team_id ON public.hangout_joins(team_id);
CREATE INDEX IF NOT EXISTS idx_hangout_joins_user_id ON public.hangout_joins(user_id);
CREATE INDEX IF NOT EXISTS idx_hangout_joins_status ON public.hangout_joins(status);

-- =============================================
-- Triggers for updated_at
-- =============================================
CREATE TRIGGER set_updated_at_event_signups
    BEFORE UPDATE ON public.event_signups
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_team_applications
    BEFORE UPDATE ON public.team_applications
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_hangout_joins
    BEFORE UPDATE ON public.hangout_joins
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
