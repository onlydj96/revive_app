-- =============================================
-- Triggers and Functions for Ezer App
-- =============================================

-- =============================================
-- Function to update updated_at timestamp
-- =============================================
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- Function to handle new user registration
-- =============================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_profiles (id, full_name, email, role)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'role', 'member')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- Function to update team member count
-- =============================================
CREATE OR REPLACE FUNCTION public.update_team_member_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.teams 
        SET current_members = (
            SELECT COUNT(*) 
            FROM public.team_memberships 
            WHERE team_id = NEW.team_id AND status = 'active'
        )
        WHERE id = NEW.team_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.teams 
        SET current_members = (
            SELECT COUNT(*) 
            FROM public.team_memberships 
            WHERE team_id = OLD.team_id AND status = 'active'
        )
        WHERE id = OLD.team_id;
        RETURN OLD;
    ELSIF TG_OP = 'UPDATE' THEN
        -- Update both teams if team changed
        IF OLD.team_id != NEW.team_id THEN
            UPDATE public.teams 
            SET current_members = (
                SELECT COUNT(*) 
                FROM public.team_memberships 
                WHERE team_id = OLD.team_id AND status = 'active'
            )
            WHERE id = OLD.team_id;
        END IF;
        
        UPDATE public.teams 
        SET current_members = (
            SELECT COUNT(*) 
            FROM public.team_memberships 
            WHERE team_id = NEW.team_id AND status = 'active'
        )
        WHERE id = NEW.team_id;
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- Function to update event attendee count
-- =============================================
CREATE OR REPLACE FUNCTION public.update_event_attendee_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.events 
        SET current_attendees = (
            SELECT COUNT(*) 
            FROM public.event_registrations 
            WHERE event_id = NEW.event_id AND status = 'registered'
        )
        WHERE id = NEW.event_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.events 
        SET current_attendees = (
            SELECT COUNT(*) 
            FROM public.event_registrations 
            WHERE event_id = OLD.event_id AND status = 'registered'
        )
        WHERE id = OLD.event_id;
        RETURN OLD;
    ELSIF TG_OP = 'UPDATE' THEN
        UPDATE public.events 
        SET current_attendees = (
            SELECT COUNT(*) 
            FROM public.event_registrations 
            WHERE event_id = NEW.event_id AND status = 'registered'
        )
        WHERE id = NEW.event_id;
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- Apply Triggers
-- =============================================

-- Updated_at triggers
CREATE TRIGGER set_updated_at_user_profiles
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_updates
    BEFORE UPDATE ON public.updates
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_media_items
    BEFORE UPDATE ON public.media_items
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_events
    BEFORE UPDATE ON public.events
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_teams
    BEFORE UPDATE ON public.teams
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_sermons
    BEFORE UPDATE ON public.sermons
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_bulletins
    BEFORE UPDATE ON public.bulletins
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- New user registration trigger
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Team member count triggers
CREATE TRIGGER update_team_count_on_insert
    AFTER INSERT ON public.team_memberships
    FOR EACH ROW EXECUTE FUNCTION public.update_team_member_count();

CREATE TRIGGER update_team_count_on_update
    AFTER UPDATE ON public.team_memberships
    FOR EACH ROW EXECUTE FUNCTION public.update_team_member_count();

CREATE TRIGGER update_team_count_on_delete
    AFTER DELETE ON public.team_memberships
    FOR EACH ROW EXECUTE FUNCTION public.update_team_member_count();

-- Event attendee count triggers
CREATE TRIGGER update_event_count_on_insert
    AFTER INSERT ON public.event_registrations
    FOR EACH ROW EXECUTE FUNCTION public.update_event_attendee_count();

CREATE TRIGGER update_event_count_on_update
    AFTER UPDATE ON public.event_registrations
    FOR EACH ROW EXECUTE FUNCTION public.update_event_attendee_count();

CREATE TRIGGER update_event_count_on_delete
    AFTER DELETE ON public.event_registrations
    FOR EACH ROW EXECUTE FUNCTION public.update_event_attendee_count();