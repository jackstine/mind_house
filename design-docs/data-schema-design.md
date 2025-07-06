# Data Schema Design Documentation

## Overview
This document defines the exact data schema for the Mind Map application's SQLite database, focusing on tag-based information storage and offline functionality.

## Schema Requirements

### Core Data Types
1. **Information Items** - The main content users store
2. **Tags** - Organizational labels for information
3. **Tag Associations** - Many-to-many relationships between information and tags
4. **User Preferences** - Application settings and configurations

### Design Principles
- **Normalization**: Prevent tag duplication while allowing many-to-many relationships
- **Performance**: Optimized for tag-based queries and filtering
- **Simplicity**: Clean schema focused on core use cases
- **Extensibility**: Room for future enhancements without major migrations

## SQLite Schema Definition

### Information Table
```sql
CREATE TABLE information (
    id TEXT PRIMARY KEY,  -- UUID for unique identification
    content TEXT NOT NULL,  -- Main text content
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,  -- Soft delete for data recovery
    position INTEGER DEFAULT 0  -- For future ordering features
);

-- Indexes for performance
CREATE INDEX idx_information_created_at ON information(created_at);
CREATE INDEX idx_information_updated_at ON information(updated_at);
CREATE INDEX idx_information_is_deleted ON information(is_deleted);
```

**Field Explanations**:
- `id`: UUID string for reliable cross-device identification
- `content`: User's information text (no length limit for flexibility)
- `created_at`: Automatic timestamp for chronological sorting
- `updated_at`: Tracks last modification for sync purposes
- `is_deleted`: Soft delete allows data recovery and sync conflict resolution
- `position`: Reserved for user-defined ordering (future enhancement)

### Tags Table
```sql
CREATE TABLE tags (
    id TEXT PRIMARY KEY,  -- UUID for unique identification
    name TEXT NOT NULL UNIQUE,  -- Tag name (normalized)
    display_name TEXT NOT NULL,  -- Original case for display
    color TEXT NOT NULL DEFAULT '#2196F3',  -- Hex color code for visual categorization
    usage_count INTEGER DEFAULT 0,  -- Frequency tracking for suggestions
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_used_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_tags_name ON tags(name);
CREATE INDEX idx_tags_usage_count ON tags(usage_count DESC);
CREATE INDEX idx_tags_last_used ON tags(last_used_at DESC);
CREATE INDEX idx_tags_color ON tags(color);
```

**Field Explanations**:
- `id`: UUID for consistent identification
- `name`: Lowercase, trimmed tag name for matching
- `display_name`: Preserves user's original capitalization
- `color`: **Required** hex color for visual categorization (default: Material Blue #2196F3)
- `usage_count`: Tracks frequency for autocomplete ordering
- `last_used_at`: Recent usage for intelligent suggestions

### Information_Tags Junction Table
```sql
CREATE TABLE information_tags (
    information_id TEXT NOT NULL,
    tag_id TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (information_id, tag_id),
    FOREIGN KEY (information_id) REFERENCES information(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
);

-- Indexes for efficient querying
CREATE INDEX idx_information_tags_info_id ON information_tags(information_id);
CREATE INDEX idx_information_tags_tag_id ON information_tags(tag_id);
```

**Field Explanations**:
- Composite primary key prevents duplicate associations
- `created_at`: Tracks when tag was added to information
- Cascade deletes maintain referential integrity

### User Preferences Table (Moved to Backlog)
**Note**: User preferences have been moved to the backlog for future implementation.

The core application will use sensible defaults without user customization in Phase 1:
- App always opens to "Store Information" page
- Returns to "Store Information" after 15 minutes in background
- Tag suggestions always enabled
- Auto-save always enabled
- Default theme (light mode)

## Alternative Schema Considerations

### Single Table Approach (Rejected)
```sql
-- Alternative: Denormalized approach
CREATE TABLE information_items (
    id TEXT PRIMARY KEY,
    content TEXT NOT NULL,
    tags TEXT NOT NULL,  -- JSON array or comma-separated
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

**Rejected Because**:
- Difficult tag filtering and searching
- Tag analytics impossible
- No tag reuse tracking
- Complex tag management

### Graph-Style Schema (Considered)
```sql
-- Alternative: Node and edge tables
CREATE TABLE nodes (
    id TEXT PRIMARY KEY,
    type TEXT NOT NULL,  -- 'information' or 'tag'
    content TEXT,
    properties TEXT  -- JSON
);

CREATE TABLE edges (
    from_id TEXT,
    to_id TEXT,
    relationship_type TEXT,
    PRIMARY KEY (from_id, to_id)
);
```

**Not Chosen Because**:
- Over-engineered for current needs
- Complex queries for simple operations
- Performance overhead for basic tag filtering

## Query Patterns

### Common Operations

**1. Get Information with Tags**
```sql
SELECT 
    i.id, i.content, i.created_at,
    GROUP_CONCAT(t.display_name) as tags
FROM information i
LEFT JOIN information_tags it ON i.id = it.information_id
LEFT JOIN tags t ON it.tag_id = t.id
WHERE i.is_deleted = FALSE
GROUP BY i.id
ORDER BY i.created_at DESC;
```

**2. Filter by Single Tag**
```sql
SELECT DISTINCT i.id, i.content, i.created_at
FROM information i
JOIN information_tags it ON i.id = it.information_id
JOIN tags t ON it.tag_id = t.id
WHERE t.name = ? AND i.is_deleted = FALSE
ORDER BY i.created_at DESC;
```

**3. Filter by Multiple Tags (AND)**
```sql
SELECT i.id, i.content, i.created_at
FROM information i
WHERE i.is_deleted = FALSE
AND i.id IN (
    SELECT it.information_id
    FROM information_tags it
    JOIN tags t ON it.tag_id = t.id
    WHERE t.name IN (?, ?, ?)  -- Tag names
    GROUP BY it.information_id
    HAVING COUNT(DISTINCT t.id) = 3  -- Number of tags
)
ORDER BY i.created_at DESC;
```

**4. Tag Suggestions (Autocomplete)**
```sql
SELECT display_name, usage_count
FROM tags
WHERE name LIKE ? || '%'
ORDER BY usage_count DESC, last_used_at DESC
LIMIT 10;
```

**5. Most Used Tags**
```sql
SELECT display_name, usage_count
FROM tags
WHERE usage_count > 0
ORDER BY usage_count DESC, last_used_at DESC
LIMIT 20;
```

## Performance Optimization

### Index Strategy
- Primary indexes on foreign keys for join performance
- Composite indexes for common query patterns
- Partial indexes on filtered columns (is_deleted = FALSE)

### Maintenance Operations
```sql
-- Update tag usage counts
UPDATE tags SET usage_count = (
    SELECT COUNT(*) FROM information_tags 
    WHERE tag_id = tags.id
) WHERE id = ?;

-- Clean up unused tags (optional)
DELETE FROM tags WHERE usage_count = 0 AND created_at < date('now', '-30 days');

-- Update last_used_at when tag is used
UPDATE tags SET last_used_at = CURRENT_TIMESTAMP WHERE id = ?;
```

## Migration Strategy

### Version Control
```sql
CREATE TABLE schema_version (
    version INTEGER PRIMARY KEY,
    applied_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO schema_version (version) VALUES (1);
```

### Future Migrations
- **Version 2**: Add hierarchical tag relationships
- **Version 3**: Add attachment support
- **Version 4**: Add sync metadata for cloud integration

## Data Validation Rules

### Application-Level Constraints
- Tag names must be non-empty and trimmed
- Content must be non-empty for information items
- Tag colors must be valid hex codes (if provided)
- UUIDs must be properly formatted

### Triggers for Data Integrity
```sql
-- Auto-update information.updated_at
CREATE TRIGGER update_information_timestamp 
AFTER UPDATE ON information
BEGIN
    UPDATE information SET updated_at = CURRENT_TIMESTAMP 
    WHERE id = NEW.id;
END;

-- Update tag usage count when associations change
CREATE TRIGGER increment_tag_usage 
AFTER INSERT ON information_tags
BEGIN
    UPDATE tags SET 
        usage_count = usage_count + 1,
        last_used_at = CURRENT_TIMESTAMP
    WHERE id = NEW.tag_id;
END;

CREATE TRIGGER decrement_tag_usage 
AFTER DELETE ON information_tags
BEGIN
    UPDATE tags SET usage_count = usage_count - 1
    WHERE id = OLD.tag_id;
END;
```

## Security Considerations

### Data Protection
- No sensitive data stored in plain text
- UUIDs prevent enumeration attacks
- Soft deletes allow data recovery
- Local storage only (no network exposure)

### Privacy
- All data remains on device
- No telemetry or usage tracking in database
- User controls all data deletion

## Backup and Recovery

### Export Format (JSON)
```json
{
  "version": 1,
  "exported_at": "2025-07-05T12:00:00Z",
  "information": [
    {
      "id": "uuid",
      "content": "text",
      "tags": ["tag1", "tag2"],
      "created_at": "2025-07-05T12:00:00Z"
    }
  ],
  "tags": [
    {
      "name": "tag1",
      "display_name": "Tag1",
      "color": "#FF0000"
    }
  ]
}
```

### Recovery Procedures
- Import from JSON maintains tag relationships
- Duplicate detection during import
- Incremental sync support for future cloud features

## Next Steps
- Implement schema creation in chosen mobile framework
- Create data access layer with optimized queries
- Build tag management utilities
- Design data migration and upgrade system