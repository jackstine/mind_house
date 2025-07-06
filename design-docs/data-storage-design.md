# Data Storage Design Documentation

## Overview
This document explores different data storage approaches for the Mind Map mobile application, analyzing what types of data to store and how to structure it for optimal performance, offline functionality, and synchronization across devices.

## Data Types to Store

### Type 1: Core Node Data
**Description**: The fundamental information units that users create and organize.

**What to Store**:
- Node ID (UUID)
- Title/Label (text)
- Content/Description (text)
- Creation timestamp
- Last modified timestamp
- Position coordinates (for visual layout)

**Why Store**:
- Essential for basic functionality
- Forms the foundation of the mind map
- Required for any meaningful interaction
- Minimal storage overhead

### Type 2: Relationship Data
**Description**: Connections between nodes that create the mind map structure.

**What to Store**:
- Relationship ID
- Parent node ID
- Child node ID
- Relationship type (hierarchical, associative)
- Order/Position (for sibling nodes)
- Connection style metadata

**Why Store**:
- Defines the structure of information
- Enables navigation between ideas
- Critical for visualization
- Allows flexible organization patterns

### Type 3: Metadata and Organization
**Description**: Additional information for categorizing and finding content.

**What to Store**:
- Tags (array of strings)
- Categories/Folders
- Color coding
- Priority/Importance levels
- Custom properties (key-value pairs)

**Why Store**:
- Enhances searchability
- Enables filtering and organization
- Supports personalization
- Improves retrieval speed

### Type 4: User Preferences and Settings
**Description**: Application and user-specific configurations.

**What to Store**:
- Default view preferences
- Theme/Color schemes
- Layout preferences
- Sync settings
- Privacy settings

**Why Store**:
- Personalizes user experience
- Maintains consistency across sessions
- Reduces setup time
- Enables customization

### Type 5: Sync and Version Data
**Description**: Information required for offline functionality and synchronization.

**What to Store**:
- Sync timestamps
- Version numbers
- Conflict resolution data
- Device identifiers
- Change logs/Delta data

**Why Store**:
- Enables offline-first architecture
- Prevents data loss
- Handles multi-device scenarios
- Ensures data consistency

## Storage Architecture Options

### Option 1: Hybrid Relational + Document Store
**Description**: PostgreSQL with JSONB for flexible node content, relational tables for structure.

**Pros**:
- Best of both worlds
- Flexible content storage
- Strong relationship queries
- ACID compliance
- Mature technology

**Cons**:
- More complex queries
- Potential performance overhead
- Requires careful indexing
- Schema migration complexity

**Schema Example**:
```sql
-- Nodes table
nodes (
  id UUID PRIMARY KEY,
  title TEXT NOT NULL,
  content JSONB,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  sync_version INTEGER
)

-- Relationships table
relationships (
  id UUID PRIMARY KEY,
  parent_id UUID REFERENCES nodes(id),
  child_id UUID REFERENCES nodes(id),
  position INTEGER,
  relationship_type VARCHAR(50)
)

-- Tags table
tags (
  id UUID PRIMARY KEY,
  node_id UUID REFERENCES nodes(id),
  tag_name VARCHAR(100)
)
```

### Option 2: Pure Document Store
**Description**: Store entire mind map as nested JSON documents.

**Pros**:
- Simple data model
- Easy to sync entire maps
- Natural hierarchy representation
- Flexible schema evolution

**Cons**:
- Complex queries for relationships
- Potential data duplication
- Harder to query across maps
- May hit document size limits

### Option 3: Graph-Inspired Relational
**Description**: Normalized relational schema mimicking graph database patterns.

**Pros**:
- Efficient relationship queries
- No data duplication
- Scalable structure
- Standard SQL queries

**Cons**:
- More complex joins
- Potentially slower for deep hierarchies
- Requires careful optimization
- More tables to manage

## Local Storage Strategy (Mobile)

### SQLite Schema for Offline
```sql
-- Local nodes table (simplified)
local_nodes (
  id TEXT PRIMARY KEY,
  data TEXT, -- JSON serialized
  is_dirty BOOLEAN,
  last_sync TIMESTAMP
)

-- Sync queue
sync_queue (
  id INTEGER PRIMARY KEY,
  operation TEXT, -- CREATE, UPDATE, DELETE
  entity_type TEXT,
  entity_id TEXT,
  data TEXT,
  created_at TIMESTAMP
)
```

### Offline-First Principles
1. **Local First**: All operations happen locally first
2. **Queue Changes**: Track modifications for later sync
3. **Conflict Resolution**: Last-write-wins with manual override option
4. **Delta Sync**: Only sync changes, not entire dataset
5. **Background Sync**: Automatic when connection available

## Data Storage Comparison

| Aspect | Hybrid Relational | Pure Document | Graph-Inspired |
|--------|------------------|---------------|----------------|
| Query Flexibility | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ |
| Schema Evolution | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ |
| Performance | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| Sync Complexity | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ |
| Storage Efficiency | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| Offline Support | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |

## Recommended Approach

**Primary Choice: Hybrid Relational + Document Store**

**Backend (PostgreSQL)**:
- Relational tables for structure and relationships
- JSONB columns for flexible content
- Full-text search on content
- Efficient indexing for performance

**Mobile (SQLite)**:
- Simplified schema for offline use
- JSON serialization for complex data
- Sync queue for changes
- Periodic cleanup and optimization

**Sync Strategy**:
- UUID-based identification
- Timestamp-based conflict resolution
- Delta synchronization
- Batch operations for efficiency

## Data Retention and Privacy

### What NOT to Store
- Personal identifiable information (unless encrypted)
- External API keys or passwords
- Large media files (use references instead)
- Temporary UI state

### Privacy Considerations
- Local encryption for sensitive data
- Clear data deletion policies
- User control over sync
- Anonymous usage analytics only

## Performance Optimizations

### Indexing Strategy
- Index on frequently searched fields (title, tags)
- Composite indexes for common query patterns
- Full-text search indexes
- Spatial indexes for visual layout (if needed)

### Caching Strategy
- In-memory cache for active mind map
- Recently accessed nodes cache
- Search results cache
- Prepared query cache

## Next Steps
- Define exact PostgreSQL schema
- Create SQLite migration scripts
- Design sync protocol specification
- Plan data encryption approach