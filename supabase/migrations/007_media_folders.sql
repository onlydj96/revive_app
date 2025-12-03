-- =============================================
-- Media Folders Table
-- =============================================

-- Create media_folders table
CREATE TABLE IF NOT EXISTS public.media_folders (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    parent_id UUID REFERENCES public.media_folders(id) ON DELETE CASCADE,
    folder_path TEXT NOT NULL, -- Storage path like "worship/2025/january"
    thumbnail_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID REFERENCES auth.users(id) ON DELETE SET NULL
);

-- Add folder_id column to media_items table
ALTER TABLE public.media_items
ADD COLUMN IF NOT EXISTS folder_id UUID REFERENCES public.media_folders(id) ON DELETE SET NULL;

-- Add deleted_at and deleted_by columns to media_items for soft delete
ALTER TABLE public.media_items
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS deleted_by UUID REFERENCES auth.users(id) ON DELETE SET NULL;

-- =============================================
-- Indexes for Performance
-- =============================================
CREATE INDEX IF NOT EXISTS idx_media_folders_parent_id ON public.media_folders(parent_id);
CREATE INDEX IF NOT EXISTS idx_media_folders_folder_path ON public.media_folders(folder_path);
CREATE INDEX IF NOT EXISTS idx_media_folders_created_at ON public.media_folders(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_media_folders_created_by ON public.media_folders(created_by);
CREATE INDEX IF NOT EXISTS idx_media_folders_deleted_at ON public.media_folders(deleted_at);

CREATE INDEX IF NOT EXISTS idx_media_items_folder_id ON public.media_items(folder_id);
CREATE INDEX IF NOT EXISTS idx_media_items_deleted_at ON public.media_items(deleted_at);

-- =============================================
-- Triggers for updated_at
-- =============================================
CREATE TRIGGER set_updated_at_media_folders
    BEFORE UPDATE ON public.media_folders
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
