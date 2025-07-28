-- =============================================
-- Seed Data for Ezer Church Management App
-- =============================================

-- Note: This file contains sample data to populate the database
-- Run this after the initial schema and triggers are set up

-- =============================================
-- Sample Updates/Announcements
-- =============================================
INSERT INTO public.updates (id, title, content, type, author_name, is_pinned, tags) VALUES
('11111111-1111-1111-1111-111111111111', 'Easter Service Times', 'Join us for our special Easter services on April 7th at 9:00 AM and 11:00 AM. Come celebrate the resurrection of our Lord!', 'announcement', 'Pastor Mike', true, ARRAY['easter', 'service']),
('22222222-2222-2222-2222-222222222222', 'Prayer Request: Johnson Family', 'Please keep the Johnson family in your prayers as they navigate through this difficult time.', 'prayer', 'Sarah Wilson', false, ARRAY['prayer', 'family']),
('33333333-3333-3333-3333-333333333333', 'New Youth Program Launch', 'Exciting news! We are launching a new youth program for ages 13-18. First meeting is this Friday at 7 PM in the youth room.', 'announcement', 'Mark Rodriguez', true, ARRAY['youth', 'program']),
('44444444-4444-4444-4444-444444444444', 'Community Food Drive Success', 'Thanks to everyone who participated in our community food drive! We collected over 500 items for local families in need.', 'celebration', 'Linda Chen', false, ARRAY['community', 'outreach']),
('55555555-5555-5555-5555-555555555555', 'Building Maintenance Notice', 'The main sanctuary will be closed for maintenance on Tuesday, March 15th from 9 AM to 3 PM. Please use the fellowship hall entrance.', 'urgent', 'David Park', false, ARRAY['maintenance', 'building']);

-- =============================================
-- Sample Media Items
-- =============================================
INSERT INTO public.media_items (id, title, description, type, category, file_url, thumbnail_url, photographer, tags) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Easter Sunday Worship', 'Beautiful moments from our Easter Sunday celebration with the congregation', 'photo', 'worship', 'https://images.unsplash.com/photo-1438232992991-995b7058bbb3', 'https://images.unsplash.com/photo-1438232992991-995b7058bbb3?w=300', 'Sarah Johnson', ARRAY['easter', 'worship', 'celebration']),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Youth Group Fun Day', 'Photos from our youth group outdoor activities and games', 'photo', 'youth', 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac', 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=300', 'Mike Wilson', ARRAY['youth', 'activities', 'fellowship']),
('cccccccc-cccc-cccc-cccc-cccccccccccc', 'Sunday Sermon: Hope in Times of Trouble', 'Pastor Mike shares a powerful message about finding hope during difficult times', 'audio', 'sermon', 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300', 'Tech Team', ARRAY['sermon', 'hope', 'encouragement']),
('dddddddd-dddd-dddd-dddd-dddddddddddd', 'Community Outreach Video', 'Highlights from our community service projects this quarter', 'video', 'outreach', 'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4', 'https://images.unsplash.com/photo-1559027615-cd4628902d4a?w=300', 'David Lee', ARRAY['outreach', 'community', 'service']),
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'Childrens Choir Performance', 'Our amazing children performing "Jesus Loves Me" during Sunday service', 'video', 'children', 'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4', 'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?w=300', 'Anna Martinez', ARRAY['children', 'choir', 'performance']);

-- =============================================
-- Sample Events
-- =============================================
INSERT INTO public.events (id, title, description, location, start_time, end_time, max_attendees, category, registration_required) VALUES
('77777777-7777-7777-7777-777777777777', 'Sunday Worship Service', 'Join us for our weekly worship service with inspiring music and biblical teaching', 'Main Sanctuary', '2024-03-10 10:00:00+00', '2024-03-10 11:30:00+00', 200, 'worship', false),
('88888888-8888-8888-8888-888888888888', 'Bible Study: Book of Romans', 'Deep dive into Paul''s letter to the Romans. All are welcome!', 'Conference Room A', '2024-03-12 19:00:00+00', '2024-03-12 20:30:00+00', 30, 'study', true),
('99999999-9999-9999-9999-999999999999', 'Youth Game Night', 'Fun evening of games, snacks, and fellowship for teens ages 13-18', 'Youth Room', '2024-03-15 19:00:00+00', '2024-03-15 21:00:00+00', 25, 'youth', true),
('10101010-1010-1010-1010-101010101010', 'Community Food Drive', 'Help us collect food items for local families in need', 'Church Parking Lot', '2024-03-20 09:00:00+00', '2024-03-20 15:00:00+00', null, 'outreach', false),
('12121212-1212-1212-1212-121212121212', 'Easter Egg Hunt', 'Annual Easter egg hunt for children and families', 'Church Playground', '2024-03-31 14:00:00+00', '2024-03-31 16:00:00+00', 50, 'children', true);

-- =============================================
-- Sample Teams
-- =============================================
INSERT INTO public.teams (id, name, description, type, category, leader_name, max_members, meeting_schedule, meeting_location, application_required) VALUES
('13131313-1313-1313-1313-131313131313', 'Worship Team', 'Musicians and singers who lead our congregation in worship', 'connect_group', 'worship', 'Sarah Johnson', 15, 'Wednesdays 7:00 PM, Sundays 8:00 AM', 'Sanctuary', true),
('14141414-1414-1414-1414-141414141414', 'Youth Ministry', 'Dedicated to ministering to teenagers and young adults', 'connect_group', 'youth', 'Mark Rodriguez', 20, 'Fridays 7:00 PM', 'Youth Room', false),
('15151515-1515-1515-1515-151515151515', 'Coffee Fellowship', 'Casual group that meets for coffee and conversation', 'hangout', 'fellowship', 'Linda Chen', 12, 'Sundays after service', 'Fellowship Hall', false),
('16161616-1616-1616-1616-161616161616', 'Community Outreach', 'Organizing service projects and community engagement', 'connect_group', 'outreach', 'David Park', 25, 'Second Saturday of each month, 9:00 AM', 'Conference Room B', true),
('17171717-1717-1717-1717-171717171717', 'Children''s Ministry', 'Teaching and caring for our youngest members', 'connect_group', 'children', 'Anna Martinez', 18, 'Sundays 9:00 AM', 'Children''s Wing', true);

-- =============================================
-- Sample Sermons
-- =============================================
INSERT INTO public.sermons (id, title, speaker, series, scripture_reference, description, service_date, duration, tags) VALUES
('18181818-1818-1818-1818-181818181818', 'Walking in Faith', 'Pastor Mike', 'Faith in Action', 'Hebrews 11:1-16', 'Exploring what it means to live by faith and trust in God''s promises', '2024-03-03', 2100, ARRAY['faith', 'trust', 'promises']),
('19191919-1919-1919-1919-191919191919', 'Love Your Neighbor', 'Pastor Sarah', 'Greatest Commandments', 'Matthew 22:34-40', 'Understanding how to practically love our neighbors as ourselves', '2024-02-25', 1950, ARRAY['love', 'neighbor', 'commandments']),
('20202020-2020-2020-2020-202020202020', 'Hope in Difficult Times', 'Pastor Mike', 'Finding Hope', 'Romans 15:13', 'How to maintain hope when facing life''s challenges', '2024-02-18', 2250, ARRAY['hope', 'trials', 'encouragement']),
('21212121-2121-2121-2121-212121212121', 'The Power of Prayer', 'Guest Speaker John Davis', 'Prayer Life', '1 Thessalonians 5:16-18', 'Developing a consistent and powerful prayer life', '2024-02-11', 2400, ARRAY['prayer', 'spiritual-growth', 'discipline']),
('22222222-2222-2222-2222-222222222222', 'Forgiveness and Grace', 'Pastor Sarah', 'Grace Series', 'Ephesians 4:31-32', 'Understanding God''s forgiveness and extending grace to others', '2024-02-04', 2050, ARRAY['forgiveness', 'grace', 'relationships']);

-- =============================================
-- Sample Bulletins
-- =============================================
INSERT INTO public.bulletins (id, title, service_date, theme, scripture_reading, announcements, prayer_requests) VALUES
('23232323-2323-2323-2323-232323232323', 'Sunday Worship Bulletin - March 3, 2024', '2024-03-03', 'Walking in Faith', 'Hebrews 11:1-16', 'Easter service planning meeting this Wednesday at 7 PM. Youth group game night this Friday. Community food drive next Saturday.', 'Please pray for the Johnson family during their difficult time. Pray for our mission team preparing for their summer trip.'),
('24242424-2424-2424-2424-242424242424', 'Sunday Worship Bulletin - February 25, 2024', '2024-02-25', 'Love Your Neighbor', 'Matthew 22:34-40', 'New member orientation next Sunday after service. Signup sheets for Easter egg hunt volunteers are available. Bible study resumes this Tuesday.', 'Pray for healing for Mrs. Patterson. Remember our college students during exam season.'),
('25252525-2525-2525-2525-252525252525', 'Sunday Worship Bulletin - February 18, 2024', '2024-02-18', 'Hope in Difficult Times', 'Romans 15:13', 'Church workday this Saturday from 9 AM to 3 PM. Sign up for small groups starting next month. Youth fundraiser car wash next weekend.', 'Lift up the Miller family as they mourn the loss of their grandfather. Pray for our community outreach efforts.');

-- =============================================
-- Update sequences and constraints
-- =============================================

-- Note: In a real deployment, you would need actual user IDs from auth.users
-- These sample records use placeholder IDs that should be updated with real user data