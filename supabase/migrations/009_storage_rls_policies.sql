-- =============================================
-- Storage Bucket RLS Policies for Ezer App
-- =============================================

-- =============================================
-- 1. MEDIA BUCKET POLICIES
-- =============================================

-- Allow authenticated users to upload to media bucket
CREATE POLICY "Allow authenticated uploads to media"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'media');

-- Allow public read access to media bucket
CREATE POLICY "Allow public reads from media"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'media');

-- Allow authenticated users to update their own files in media bucket
CREATE POLICY "Allow authenticated updates to media"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'media');

-- Allow authenticated users to delete from media bucket
CREATE POLICY "Allow authenticated deletes from media"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'media');

-- =============================================
-- 2. MEDIA-THUMBNAILS BUCKET POLICIES
-- =============================================

-- Allow authenticated users to upload to media-thumbnails bucket
CREATE POLICY "Allow authenticated uploads to media-thumbnails"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'media-thumbnails');

-- Allow public read access to media-thumbnails bucket
CREATE POLICY "Allow public reads from media-thumbnails"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'media-thumbnails');

-- Allow authenticated users to update their own files in media-thumbnails bucket
CREATE POLICY "Allow authenticated updates to media-thumbnails"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'media-thumbnails');

-- Allow authenticated users to delete from media-thumbnails bucket
CREATE POLICY "Allow authenticated deletes from media-thumbnails"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'media-thumbnails');

-- =============================================
-- 3. EVENTS BUCKET POLICIES
-- =============================================

-- Allow authenticated users to upload to events bucket
CREATE POLICY "Allow authenticated uploads to events"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'events');

-- Allow public read access to events bucket
CREATE POLICY "Allow public reads from events"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'events');

-- Allow authenticated users to update their own files in events bucket
CREATE POLICY "Allow authenticated updates to events"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'events');

-- Allow authenticated users to delete from events bucket
CREATE POLICY "Allow authenticated deletes from events"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'events');

-- =============================================
-- Reload schema cache
-- =============================================
NOTIFY pgrst, 'reload schema';
