-- Add linked_bulletin_item_id column to worship_schedule_items table
-- This links each worship schedule item to its corresponding bulletin item detail

ALTER TABLE worship_schedule_items
ADD COLUMN IF NOT EXISTS linked_bulletin_item_id UUID;

-- Add foreign key constraint to ensure referential integrity
ALTER TABLE worship_schedule_items
ADD CONSTRAINT fk_linked_bulletin_item
FOREIGN KEY (linked_bulletin_item_id)
REFERENCES bulletin_items(id)
ON DELETE CASCADE;

-- Create index for better query performance
CREATE INDEX IF NOT EXISTS idx_worship_schedule_linked_item
ON worship_schedule_items(linked_bulletin_item_id);

-- Add comment
COMMENT ON COLUMN worship_schedule_items.linked_bulletin_item_id IS 'Links to the corresponding bulletin_items.id for detail content';
