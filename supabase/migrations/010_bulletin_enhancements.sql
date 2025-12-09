-- =============================================
-- Bulletin Enhancements
-- =============================================
-- Migration: 010_bulletin_enhancements
-- Purpose: Add worship schedule and bulletin items as separate tables
-- Date: 2025-01-08

-- =============================================
-- Worship Schedule Items Table
-- =============================================
CREATE TABLE public.worship_schedule_items (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    bulletin_id UUID REFERENCES public.bulletins(id) ON DELETE CASCADE NOT NULL,
    time TEXT NOT NULL,
    activity TEXT NOT NULL,
    leader TEXT,
    display_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for faster queries
CREATE INDEX idx_worship_schedule_bulletin ON public.worship_schedule_items(bulletin_id);
CREATE INDEX idx_worship_schedule_order ON public.worship_schedule_items(bulletin_id, display_order);

-- =============================================
-- Bulletin Items Table
-- =============================================
CREATE TABLE public.bulletin_items (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    bulletin_id UUID REFERENCES public.bulletins(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    display_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for faster queries
CREATE INDEX idx_bulletin_items_bulletin ON public.bulletin_items(bulletin_id);
CREATE INDEX idx_bulletin_items_order ON public.bulletin_items(bulletin_id, display_order);

-- =============================================
-- Update Bulletins Table
-- =============================================
-- Add banner_image_url column
ALTER TABLE public.bulletins ADD COLUMN IF NOT EXISTS banner_image_url TEXT;

-- Rename service_date to week_of for clarity
ALTER TABLE public.bulletins RENAME COLUMN service_date TO week_of;

-- =============================================
-- Updated Trigger for bulletins
-- =============================================
DROP TRIGGER IF EXISTS update_bulletins_updated_at ON public.bulletins;
CREATE TRIGGER update_bulletins_updated_at
    BEFORE UPDATE ON public.bulletins
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =============================================
-- Triggers for worship_schedule_items
-- =============================================
CREATE TRIGGER update_worship_schedule_items_updated_at
    BEFORE UPDATE ON public.worship_schedule_items
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =============================================
-- Triggers for bulletin_items
-- =============================================
CREATE TRIGGER update_bulletin_items_updated_at
    BEFORE UPDATE ON public.bulletin_items
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =============================================
-- Row Level Security (RLS)
-- =============================================

-- Enable RLS on new tables
ALTER TABLE public.worship_schedule_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bulletin_items ENABLE ROW LEVEL SECURITY;

-- Worship Schedule Items Policies
CREATE POLICY "Worship schedule items are viewable by everyone"
    ON public.worship_schedule_items FOR SELECT
    USING (true);

CREATE POLICY "Worship schedule items are insertable by authenticated users"
    ON public.worship_schedule_items FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Worship schedule items are updatable by authenticated users"
    ON public.worship_schedule_items FOR UPDATE
    USING (auth.role() = 'authenticated');

CREATE POLICY "Worship schedule items are deletable by authenticated users"
    ON public.worship_schedule_items FOR DELETE
    USING (auth.role() = 'authenticated');

-- Bulletin Items Policies
CREATE POLICY "Bulletin items are viewable by everyone"
    ON public.bulletin_items FOR SELECT
    USING (true);

CREATE POLICY "Bulletin items are insertable by authenticated users"
    ON public.bulletin_items FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Bulletin items are updatable by authenticated users"
    ON public.bulletin_items FOR UPDATE
    USING (auth.role() = 'authenticated');

CREATE POLICY "Bulletin items are deletable by authenticated users"
    ON public.bulletin_items FOR DELETE
    USING (auth.role() = 'authenticated');

-- =============================================
-- Comments for Documentation
-- =============================================
COMMENT ON TABLE public.worship_schedule_items IS 'Stores worship schedule items for each bulletin';
COMMENT ON TABLE public.bulletin_items IS 'Stores bulletin content items (announcements, prayer requests, etc.)';
COMMENT ON COLUMN public.bulletins.week_of IS 'The Sunday date for which this bulletin is relevant';
COMMENT ON COLUMN public.bulletins.banner_image_url IS 'Optional banner image URL for the bulletin';
