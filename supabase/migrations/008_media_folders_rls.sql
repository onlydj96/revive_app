-- =============================================
-- Row Level Security for Media Folders
-- =============================================

-- Enable RLS on media_folders table
ALTER TABLE public.media_folders ENABLE ROW LEVEL SECURITY;

-- =============================================
-- Media Folders Policies
-- =============================================

-- Allow anyone to view non-deleted folders (public read access)
CREATE POLICY "Anyone can view active media folders"
    ON public.media_folders
    FOR SELECT
    USING (deleted_at IS NULL);

-- Allow admins to view all folders including deleted ones
CREATE POLICY "Admins can view all media folders"
    ON public.media_folders
    FOR SELECT
    TO authenticated
    USING (
        auth.jwt() ->> 'role' = 'authenticated'
        AND EXISTS (
            SELECT 1 FROM public.user_profiles
            WHERE id = auth.uid()
            AND role = 'admin'
        )
    );

-- Allow authenticated users with create_content permission to insert folders
CREATE POLICY "Authenticated users can create media folders"
    ON public.media_folders
    FOR INSERT
    TO authenticated
    WITH CHECK (
        auth.jwt() ->> 'role' = 'authenticated'
    );

-- Allow users to update their own folders or admins to update any folder
CREATE POLICY "Users can update their own media folders"
    ON public.media_folders
    FOR UPDATE
    TO authenticated
    USING (
        created_by = auth.uid()
        OR EXISTS (
            SELECT 1 FROM public.user_profiles
            WHERE id = auth.uid()
            AND role = 'admin'
        )
    )
    WITH CHECK (
        created_by = auth.uid()
        OR EXISTS (
            SELECT 1 FROM public.user_profiles
            WHERE id = auth.uid()
            AND role = 'admin'
        )
    );

-- Allow users to delete their own folders or admins to delete any folder
CREATE POLICY "Users can delete their own media folders"
    ON public.media_folders
    FOR DELETE
    TO authenticated
    USING (
        created_by = auth.uid()
        OR EXISTS (
            SELECT 1 FROM public.user_profiles
            WHERE id = auth.uid()
            AND role = 'admin'
        )
    );

-- =============================================
-- Update Media Items RLS for Folder Support
-- =============================================

-- Drop existing policies if they conflict
DROP POLICY IF EXISTS "Anyone can view media items" ON public.media_items;
DROP POLICY IF EXISTS "Authenticated users can upload media" ON public.media_items;
DROP POLICY IF EXISTS "Users can update their own media" ON public.media_items;
DROP POLICY IF EXISTS "Users can delete their own media" ON public.media_items;

-- Allow anyone to view non-deleted media items
CREATE POLICY "Anyone can view active media items"
    ON public.media_items
    FOR SELECT
    USING (deleted_at IS NULL);

-- Allow admins to view all media items including deleted ones
CREATE POLICY "Admins can view all media items"
    ON public.media_items
    FOR SELECT
    TO authenticated
    USING (
        auth.jwt() ->> 'role' = 'authenticated'
        AND EXISTS (
            SELECT 1 FROM public.user_profiles
            WHERE id = auth.uid()
            AND role = 'admin'
        )
    );

-- Allow authenticated users to upload media
CREATE POLICY "Authenticated users can upload media items"
    ON public.media_items
    FOR INSERT
    TO authenticated
    WITH CHECK (
        auth.jwt() ->> 'role' = 'authenticated'
    );

-- Allow users to update their own media or admins to update any media
CREATE POLICY "Users can update their own media items"
    ON public.media_items
    FOR UPDATE
    TO authenticated
    USING (
        uploaded_by = auth.uid()
        OR EXISTS (
            SELECT 1 FROM public.user_profiles
            WHERE id = auth.uid()
            AND role = 'admin'
        )
    )
    WITH CHECK (
        uploaded_by = auth.uid()
        OR EXISTS (
            SELECT 1 FROM public.user_profiles
            WHERE id = auth.uid()
            AND role = 'admin'
        )
    );

-- Allow users to delete their own media or admins to delete any media
CREATE POLICY "Users can delete their own media items"
    ON public.media_items
    FOR DELETE
    TO authenticated
    USING (
        uploaded_by = auth.uid()
        OR EXISTS (
            SELECT 1 FROM public.user_profiles
            WHERE id = auth.uid()
            AND role = 'admin'
        )
    );
