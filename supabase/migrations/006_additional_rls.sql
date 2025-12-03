-- =============================================
-- Row Level Security for Additional Tables
-- =============================================

-- Enable RLS
ALTER TABLE public.event_signups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.team_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.hangout_joins ENABLE ROW LEVEL SECURITY;

-- =============================================
-- Event Signups Policies
-- =============================================

-- Users can view signups for events they signed up for
CREATE POLICY "Users can view relevant event signups" ON public.event_signups
    FOR SELECT USING (
        auth.uid() = user_id OR
        public.is_admin() OR
        EXISTS (SELECT 1 FROM public.events WHERE id = event_id AND created_by = auth.uid())
    );

-- Users can sign up themselves for events
CREATE POLICY "Users can sign up for events" ON public.event_signups
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own signups, admins can update any
CREATE POLICY "Users can update own signups" ON public.event_signups
    FOR UPDATE USING (auth.uid() = user_id OR public.is_admin());

-- Users can cancel their own signups, admins can cancel any
CREATE POLICY "Users can cancel own signups" ON public.event_signups
    FOR DELETE USING (auth.uid() = user_id OR public.is_admin());

-- =============================================
-- Team Applications Policies
-- =============================================

-- Users can view their own applications, team leaders can view applications to their teams
CREATE POLICY "Users can view relevant team applications" ON public.team_applications
    FOR SELECT USING (
        auth.uid() = user_id OR
        public.is_admin() OR
        EXISTS (SELECT 1 FROM public.teams WHERE id = team_id AND leader_id = auth.uid())
    );

-- Users can submit applications for themselves
CREATE POLICY "Users can submit team applications" ON public.team_applications
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own pending applications
CREATE POLICY "Users can update own applications" ON public.team_applications
    FOR UPDATE USING (
        (auth.uid() = user_id AND status = 'pending') OR
        public.is_admin() OR
        EXISTS (SELECT 1 FROM public.teams WHERE id = team_id AND leader_id = auth.uid())
    );

-- Users can withdraw their own applications
CREATE POLICY "Users can withdraw applications" ON public.team_applications
    FOR DELETE USING (
        auth.uid() = user_id OR
        public.is_admin() OR
        EXISTS (SELECT 1 FROM public.teams WHERE id = team_id AND leader_id = auth.uid())
    );

-- =============================================
-- Hangout Joins Policies
-- =============================================

-- Users can view joins for hangouts they're in or lead
CREATE POLICY "Users can view hangout joins" ON public.hangout_joins
    FOR SELECT USING (
        auth.uid() = user_id OR
        public.is_admin() OR
        EXISTS (SELECT 1 FROM public.teams WHERE id = team_id AND (leader_id = auth.uid() OR type = 'hangout'))
    );

-- Users can join hangouts themselves
CREATE POLICY "Users can join hangouts" ON public.hangout_joins
    FOR INSERT WITH CHECK (
        auth.uid() = user_id AND
        EXISTS (SELECT 1 FROM public.teams WHERE id = team_id AND type = 'hangout' AND is_active = true)
    );

-- Users can update their own join status
CREATE POLICY "Users can update own hangout joins" ON public.hangout_joins
    FOR UPDATE USING (
        auth.uid() = user_id OR
        public.is_admin() OR
        EXISTS (SELECT 1 FROM public.teams WHERE id = team_id AND leader_id = auth.uid())
    );

-- Users can leave hangouts, leaders and admins can remove members
CREATE POLICY "Users can leave hangouts" ON public.hangout_joins
    FOR DELETE USING (
        auth.uid() = user_id OR
        public.is_admin() OR
        EXISTS (SELECT 1 FROM public.teams WHERE id = team_id AND leader_id = auth.uid())
    );
