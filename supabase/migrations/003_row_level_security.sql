-- =============================================
-- Row Level Security (RLS) Policies
-- =============================================

-- Enable RLS on all tables
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.updates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.media_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sermons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bulletins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_registrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.team_memberships ENABLE ROW LEVEL SECURITY;

-- =============================================
-- Helper Functions for RLS
-- =============================================

-- Function to check if user is admin
CREATE OR REPLACE FUNCTION public.is_admin(user_id UUID DEFAULT auth.uid())
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.user_profiles 
        WHERE id = user_id AND role = 'admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get current user profile
CREATE OR REPLACE FUNCTION public.get_user_profile(user_id UUID DEFAULT auth.uid())
RETURNS public.user_profiles AS $$
DECLARE
    profile public.user_profiles;
BEGIN
    SELECT * INTO profile FROM public.user_profiles WHERE id = user_id;
    RETURN profile;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- User Profiles Policies
-- =============================================

-- Users can view all profiles
CREATE POLICY "Users can view all profiles" ON public.user_profiles
    FOR SELECT USING (auth.role() = 'authenticated');

-- Users can update their own profile
CREATE POLICY "Users can update own profile" ON public.user_profiles
    FOR UPDATE USING (auth.uid() = id);

-- Admins can update any profile
CREATE POLICY "Admins can update any profile" ON public.user_profiles
    FOR UPDATE USING (public.is_admin());

-- Only system can insert profiles (via trigger)
CREATE POLICY "System can insert profiles" ON public.user_profiles
    FOR INSERT WITH CHECK (true);

-- =============================================
-- Updates Policies
-- =============================================

-- Everyone can view updates
CREATE POLICY "Everyone can view updates" ON public.updates
    FOR SELECT USING (true);

-- Only admins can create updates
CREATE POLICY "Admins can create updates" ON public.updates
    FOR INSERT WITH CHECK (public.is_admin());

-- Admins can update any update, authors can update their own
CREATE POLICY "Admins and authors can update updates" ON public.updates
    FOR UPDATE USING (
        public.is_admin() OR auth.uid() = author_id
    );

-- Admins can delete any update, authors can delete their own
CREATE POLICY "Admins and authors can delete updates" ON public.updates
    FOR DELETE USING (
        public.is_admin() OR auth.uid() = author_id
    );

-- =============================================
-- Media Items Policies
-- =============================================

-- Everyone can view media items
CREATE POLICY "Everyone can view media items" ON public.media_items
    FOR SELECT USING (true);

-- Only admins can create media items
CREATE POLICY "Admins can create media items" ON public.media_items
    FOR INSERT WITH CHECK (public.is_admin());

-- Admins can update any media, uploaders can update their own
CREATE POLICY "Admins and uploaders can update media" ON public.media_items
    FOR UPDATE USING (
        public.is_admin() OR auth.uid() = uploaded_by
    );

-- Admins can delete any media, uploaders can delete their own
CREATE POLICY "Admins and uploaders can delete media" ON public.media_items
    FOR DELETE USING (
        public.is_admin() OR auth.uid() = uploaded_by
    );

-- =============================================
-- Events Policies
-- =============================================

-- Everyone can view events
CREATE POLICY "Everyone can view events" ON public.events
    FOR SELECT USING (true);

-- Only admins can create events
CREATE POLICY "Admins can create events" ON public.events
    FOR INSERT WITH CHECK (public.is_admin());

-- Admins can update any event, creators can update their own
CREATE POLICY "Admins and creators can update events" ON public.events
    FOR UPDATE USING (
        public.is_admin() OR auth.uid() = created_by
    );

-- Admins can delete any event, creators can delete their own
CREATE POLICY "Admins and creators can delete events" ON public.events
    FOR DELETE USING (
        public.is_admin() OR auth.uid() = created_by
    );

-- =============================================
-- Teams Policies
-- =============================================

-- Everyone can view active teams
CREATE POLICY "Everyone can view active teams" ON public.teams
    FOR SELECT USING (is_active = true);

-- Only admins can create teams
CREATE POLICY "Admins can create teams" ON public.teams
    FOR INSERT WITH CHECK (public.is_admin());

-- Admins and team leaders can update teams
CREATE POLICY "Admins and leaders can update teams" ON public.teams
    FOR UPDATE USING (
        public.is_admin() OR auth.uid() = leader_id
    );

-- Only admins can delete teams
CREATE POLICY "Admins can delete teams" ON public.teams
    FOR DELETE USING (public.is_admin());

-- =============================================
-- Sermons Policies
-- =============================================

-- Everyone can view sermons
CREATE POLICY "Everyone can view sermons" ON public.sermons
    FOR SELECT USING (true);

-- Only admins can create sermons
CREATE POLICY "Admins can create sermons" ON public.sermons
    FOR INSERT WITH CHECK (public.is_admin());

-- Admins can update any sermon, uploaders can update their own
CREATE POLICY "Admins and uploaders can update sermons" ON public.sermons
    FOR UPDATE USING (
        public.is_admin() OR auth.uid() = uploaded_by
    );

-- Admins can delete any sermon, uploaders can delete their own
CREATE POLICY "Admins and uploaders can delete sermons" ON public.sermons
    FOR DELETE USING (
        public.is_admin() OR auth.uid() = uploaded_by
    );

-- =============================================
-- Bulletins Policies
-- =============================================

-- Everyone can view bulletins
CREATE POLICY "Everyone can view bulletins" ON public.bulletins
    FOR SELECT USING (true);

-- Only admins can create bulletins
CREATE POLICY "Admins can create bulletins" ON public.bulletins
    FOR INSERT WITH CHECK (public.is_admin());

-- Admins can update any bulletin, creators can update their own
CREATE POLICY "Admins and creators can update bulletins" ON public.bulletins
    FOR UPDATE USING (
        public.is_admin() OR auth.uid() = created_by
    );

-- Admins can delete any bulletin, creators can delete their own
CREATE POLICY "Admins and creators can delete bulletins" ON public.bulletins
    FOR DELETE USING (
        public.is_admin() OR auth.uid() = created_by
    );

-- =============================================
-- User Collections Policies
-- =============================================

-- Users can only see their own collections
CREATE POLICY "Users can view own collections" ON public.user_collections
    FOR SELECT USING (auth.uid() = user_id);

-- Users can create their own collections
CREATE POLICY "Users can create own collections" ON public.user_collections
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can delete their own collections
CREATE POLICY "Users can delete own collections" ON public.user_collections
    FOR DELETE USING (auth.uid() = user_id);

-- =============================================
-- Event Registrations Policies
-- =============================================

-- Users can view registrations for events they can see
CREATE POLICY "Users can view event registrations" ON public.event_registrations
    FOR SELECT USING (
        auth.uid() = user_id OR 
        public.is_admin() OR
        EXISTS (SELECT 1 FROM public.events WHERE id = event_id AND created_by = auth.uid())
    );

-- Users can register themselves for events
CREATE POLICY "Users can register for events" ON public.event_registrations
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own registrations
CREATE POLICY "Users can update own registrations" ON public.event_registrations
    FOR UPDATE USING (auth.uid() = user_id OR public.is_admin());

-- Users can cancel their own registrations
CREATE POLICY "Users can cancel own registrations" ON public.event_registrations
    FOR DELETE USING (auth.uid() = user_id OR public.is_admin());

-- =============================================
-- Team Memberships Policies
-- =============================================

-- Users can view memberships for teams they're in or lead
CREATE POLICY "Users can view relevant team memberships" ON public.team_memberships
    FOR SELECT USING (
        auth.uid() = user_id OR 
        public.is_admin() OR
        EXISTS (SELECT 1 FROM public.teams WHERE id = team_id AND leader_id = auth.uid())
    );

-- Team leaders and admins can add members
CREATE POLICY "Leaders can add team members" ON public.team_memberships
    FOR INSERT WITH CHECK (
        public.is_admin() OR
        EXISTS (SELECT 1 FROM public.teams WHERE id = team_id AND leader_id = auth.uid())
    );

-- Team leaders and admins can update memberships
CREATE POLICY "Leaders can update team memberships" ON public.team_memberships
    FOR UPDATE USING (
        public.is_admin() OR
        EXISTS (SELECT 1 FROM public.teams WHERE id = team_id AND leader_id = auth.uid())
    );

-- Team leaders, admins, and members themselves can remove memberships
CREATE POLICY "Leaders and members can remove memberships" ON public.team_memberships
    FOR DELETE USING (
        auth.uid() = user_id OR
        public.is_admin() OR
        EXISTS (SELECT 1 FROM public.teams WHERE id = team_id AND leader_id = auth.uid())
    );