# Mind House User Flow Wireframes - Phase 3

## 📱 User Flow Wireframes with Mobile Considerations

This document maps complete user journeys through the Mind House application, showing how users move between different screens and components on mobile, tablet, and desktop devices.

---

## 1. New User Onboarding Flow

### Mobile Flow (Portrait - 375px)
```
Step 1: Welcome Screen
┌───────────────────┐
│ ◯◯◯ 12:34 PM ◯◯ │ ← Status bar
├───────────────────┤
│                   │
│        👋         │
│                   │
│   Welcome to      │
│   Mind House!     │
│                   │
│ Your personal     │
│ information       │
│ companion         │
│                   │
│ ┌───────────────┐ │
│ │ Get Started → │ │ ← Primary CTA
│ └───────────────┘ │
│                   │
│    Skip Tour      │ ← Secondary action
└───────────────────┘

Step 2: Feature Overview
┌───────────────────┐
│ ◉◯◯ Mind House   │ ← Progress dots
├───────────────────┤
│                   │
│      📝 STORE     │ ← Icon + title
│                   │
│ Capture thoughts, │
│ ideas, and notes  │
│ instantly         │
│                   │
│ • Rich text       │ ← Feature list
│ • Auto-save       │
│ • Smart tags      │
│                   │
│ ┌───────────────┐ │
│ │    Next →     │ │ ← Navigation
│ └───────────────┘ │
│                   │
│  ← Back    Skip   │
└───────────────────┘

Step 3: Permissions
┌───────────────────┐
│ ◯◉◯ Permissions   │
├───────────────────┤
│                   │
│       🔐          │
│                   │
│ We need your      │
│ permission to:    │
│                   │
│ ✓ Store data      │ ← Permission list
│   locally         │
│                   │
│ ✓ Send            │
│   notifications   │
│                   │
│ ┌───────────────┐ │
│ │ Allow Access  │ │ ← Primary action
│ └───────────────┘ │
│                   │
│   Maybe Later     │ ← Secondary
└───────────────────┘

Step 4: First Note Creation
┌───────────────────┐
│ ◯◯◉ Get Started   │
├───────────────────┤
│                   │
│ Create your first │
│ information!      │
│                   │
│ ┌───────────────┐ │ ← Content input
│ │ What's on your│ │
│ │ mind today?   │ │
│ │               │ │
│ │ |             │ │ ← Cursor
│ └───────────────┘ │
│                   │
│ Tags (optional):  │
│ ┌───────────────┐ │
│ │ [           ] │ │ ← Tag input
│ └───────────────┘ │
│                   │
│ ┌───────────────┐ │
│ │   Save Note   │ │ ← Save action
│ └───────────────┘ │
└───────────────────┘
```

---

## 2. Daily Information Capture Flow

### Mobile: Quick Note Creation
```
Entry Point: Home Screen Widget
┌───────────────────┐
│ Mind House Widget │ ← Widget on home
├───────────────────┤
│ 📝 Quick Note     │
│ 🔍 Search         │
│ 👁️ Recent        │
└───────────────────┘
        ↓ Tap Quick Note
        
App Opens to Store Tab:
┌───────────────────┐
│ ← Mind House   ✓  │ ← Auto-save indicator
├───────────────────┤
│ Content           │
├───────────────────┤
│ ┌───────────────┐ │ ← Content area
│ │ What's on your│ │   (auto-focused)
│ │ mind?         │ │
│ │               │ │
│ │ |             │ │ ← Active cursor
│ │               │ │
│ └───────────────┘ │
│                   │
│ Tags:             │
│ ┌───────────────┐ │
│ │ [           ] │ │ ← Tag input
│ └───────────────┘ │
│                   │
├───────────────────┤
│📝  🔍  👁️  ⚙️  │ ← Bottom navigation
│●   ○   ○   ○     │   (Store active)
└───────────────────┘

User Types Content:
┌───────────────────┐
│ ← Mind House   💾 │ ← Auto-saving
├───────────────────┤
│ Content           │
├───────────────────┤
│ ┌───────────────┐ │
│ │ Remember to   │ │ ← User content
│ │ call mom about│ │
│ │ the family    │ │
│ │ dinner this   │ │
│ │ weekend|      │ │ ← Cursor position
│ └───────────────┘ │
│                   │
│ Tags:             │
│ ┌───────────────┐ │
│ │ [family|]     │ │ ← Tag being typed
│ └───────────────┘ │
│ ▼ family, personal│ ← Suggestions
│                   │
├───────────────────┤
│📝  🔍  👁️  ⚙️  │
│●   ○   ○   ○     │
└───────────────────┘

Auto-Save Completion:
┌───────────────────┐
│ ← Mind House   ✅ │ ← Saved indicator
├───────────────────┤
│ ✅ Saved!         │ ← Success message
│                   │
│ ┌───────────────┐ │
│ │ 📝 New Note   │ │ ← Create another
│ └───────────────┘ │
│                   │
│ ┌───────────────┐ │
│ │ 🔍 Browse All │ │ ← Browse option
│ └───────────────┘ │
│                   │
│ Recent:           │
│ ┌───────────────┐ │ ← Recent items
│ │ 📝 Family     │ │   preview
│ │ dinner call   │ │
│ │ 🏷️ family    │ │
│ └───────────────┘ │
├───────────────────┤
│📝  🔍  👁️  ⚙️  │
│●   ○   ○   ○     │
└───────────────────┘
```

---

## 3. Information Discovery Flow

### Mobile: Search and Browse Journey
```
Step 1: Browse Tab Access
┌───────────────────┐
│ Mind House        │
├───────────────────┤
│ ┌───────────────┐ │ ← Search input
│ │ 🔍 Search...  │ │
│ └───────────────┘ │
│                   │
│ Quick Filters:    │
│ 🏷️ All  📅 Recent│ ← Filter chips
│ 🏷️ Work 🏷️ Personal│
│                   │
│ Recent Items:     │
│ ┌───────────────┐ │
│ │ 📝 Family     │ │ ← Recent item
│ │ dinner call   │ │
│ │ 🏷️ family    │ │
│ │ 📅 2 min ago  │ │
│ └───────────────┘ │
│                   │
├───────────────────┤
│📝  🔍  👁️  ⚙️  │
│○   ●   ○   ○     │ ← Browse active
└───────────────────┘

Step 2: Search Input
┌───────────────────┐
│ Mind House        │
├───────────────────┤
│ ┌───────────────┐ │
│ │ 🔍 family|    │ │ ← User typing
│ └───────────────┘ │
│                   │
│ 🕒 Recent:        │
│ • family dinner   │ ← Search history
│ • family meeting  │
│                   │
│ 💡 Suggestions:   │
│ • family          │ ← Auto-complete
│ • familiar        │
│                   │
│ ┌───────────────┐ │
│ │ 🎤 Voice      │ │ ← Voice search
│ └───────────────┘ │
├───────────────────┤
│📝  🔍  👁️  ⚙️  │
│○   ●   ○   ○     │
└───────────────────┘

Step 3: Search Results
┌───────────────────┐
│ ← "family"     🔽 │ ← Back + filter
├───────────────────┤
│ 📊 2 results      │ ← Result count
│                   │
│ ┌───────────────┐ │
│ │ 📝 **Family** │ │ ← Highlighted
│ │ dinner call   │ │   search terms
│ │ Remember to   │ │
│ │ call mom...   │ │
│ │ 🏷️ **family**│ │
│ │ 📅 2 min ago  │ │
│ └───────────────┘ │
│                   │
│ ┌───────────────┐ │
│ │ 📝 **Family** │ │
│ │ vacation      │ │
│ │ Planning our  │ │
│ │ summer trip...|│
│ │ 🏷️ **family**│ │
│ │ 📅 1 week ago │ │
│ └───────────────┘ │
├───────────────────┤
│📝  🔍  👁️  ⚙️  │
│○   ●   ○   ○     │
└───────────────────┘

Step 4: Result Selection → View
┌───────────────────┐
│ ← Back        ✏️  │ ← Navigation
├───────────────────┤
│ Family dinner call│ ← Full title
│                   │
│ Remember to call  │ ← Full content
│ mom about the     │
│ family dinner     │
│ this weekend.     │
│ Need to confirm   │
│ guest count and   │
│ dietary needs.    │
│                   │
│ 🏷️ family        │ ← Tags
│                   │
│ 📅 Created:       │ ← Metadata
│ Today, 12:32 PM   │
│                   │
│ 📝 Word count: 23 │
├───────────────────┤
│📝  🔍  👁️  ⚙️  │
│○   ○   ●   ○     │ ← View active
└───────────────────┘
```

---

## 4. Tablet Layout Flow (768px - 1024px)

### Landscape Orientation
```
Home Dashboard:
┌─────────────────────────────────────────────────────────┐
│ Mind House                              🔍 Search   ⚙️ │ ← Header
├─────────────────────┬───────────────────────────────────┤
│ Quick Actions       │ Recent Information                │
│                     │                                   │
│ ┌─────────────────┐ │ ┌─────────┬─────────┬─────────┐   │
│ │ 📝 New Note     │ │ │ 📝 Note │ 📝 Note │ 📝 Note │   │ ← 3-column grid
│ └─────────────────┘ │ │ Family  │ Work    │ Ideas   │   │
│                     │ │ dinner  │ meeting │ for app │   │
│ ┌─────────────────┐ │ │ 🏷️ fam │ 🏷️ work│ 🏷️ dev │   │
│ │ 🔍 Search All   │ │ │ 2m ago  │ 1h ago  │ 3h ago  │   │
│ └─────────────────┘ │ └─────────┴─────────┴─────────┘   │
│                     │                                   │
│ ┌─────────────────┐ │ ┌─────────┬─────────┬─────────┐   │
│ │ 🏷️ Browse Tags │ │ │ 📝 Note │ 📝 Note │ 📝 Note │   │
│ └─────────────────┘ │ │ Flutter │ Meeting │ Ideas   │   │
│                     │ │ tips    │ notes   │ list    │   │
│ Tags:               │ │ 🏷️ dev  │ 🏷️ work│ 🏷️ todo│   │
│ 🏷️ family (3)      │ │ 1d ago  │ 2d ago  │ 1w ago  │   │
│ 🏷️ work (5)        │ └─────────┴─────────┴─────────┘   │
│ 🏷️ dev (2)         │                                   │
│ 🏷️ personal (4)    │ ┌─────────────────────────────┐   │
│                     │ │ 📊 Load More...             │   │ ← Load more
│                     │ └─────────────────────────────┘   │
└─────────────────────┴───────────────────────────────────┘
```

### Split-Screen Creation Mode
```
Content Creation (Landscape Tablet):
┌─────────────────────────────────────────────────────────┐
│ ← Cancel                                      Save ✅   │
├─────────────────────┬───────────────────────────────────┤
│ Editor              │ Preview & Tools                   │
│                     │                                   │
│ Title:              │ Live Preview:                     │
│ ┌─────────────────┐ │ ┌─────────────────────────────┐   │
│ │ Meeting Notes   │ │ │ Meeting Notes               │   │
│ └─────────────────┘ │ └─────────────────────────────┘   │
│                     │                                   │
│ Content:            │ Quick Actions:                    │
│ ┌─────────────────┐ │ ┌─────────────────────────────┐   │
│ │ # Today's Agenda│ │ │ 📝 Templates                │   │
│ │                 │ │ │ 🏷️ Suggested Tags          │   │
│ │ - Review Q4     │ │ │ 📅 Set Reminder             │   │
│ │ - Plan Q1       │ │ │ 📎 Add Attachment           │   │
│ │ - Team updates  │ │ └─────────────────────────────┘   │
│ │                 │ │                                   │
│ │ Action items:   │ │ Metadata:                         │
│ │ - [ ] Follow up │ │ ┌─────────────────────────────┐   │
│ │ |               │ │ │ Words: 24                   │   │
│ └─────────────────┘ │ │ Characters: 156             │   │
│                     │ │ Created: Just now           │   │
│ Tags:               │ │ Auto-save: ✅ Enabled      │   │
│ ┌─────────────────┐ │ └─────────────────────────────┘   │
│ │ meeting work    │ │                                   │
│ └─────────────────┘ │                                   │
└─────────────────────┴───────────────────────────────────┘
```

---

## 5. Desktop Layout Flow (1200px+)

### Three-Column Dashboard
```
Desktop Main Interface:
┌─────────────────────────────────────────────────────────────────────────────┐
│ ☰ Mind House                               🔍 Search...            👤 ⚙️   │
├─────────────┬─────────────────────────────┬─────────────────────────────────┤
│ Navigation  │ Main Content Area           │ Details Panel                   │
│             │                             │                                 │
│ 📝 Store    │ ┌─────────┬─────────┬─────┐ │ Quick Stats:                    │
│   ● All     │ │ 📝 Note │ 📝 Note │ 📝  │ │ ┌─────────────────────────────┐ │
│   ○ Drafts  │ │ Family  │ Work    │ Idea│ │ │ 📊 Total: 23 notes          │ │
│             │ │ dinner  │ meeting │ for │ │ │ 📅 This week: 5 new         │ │
│ 🔍 Browse   │ │ call... │ about   │ app │ │ │ 🏷️ Most used: work (8)     │ │
│   ○ Recent  │ │ 🏷️ fam │ Q4...   │ dev │ │ └─────────────────────────────┘ │
│   ○ Tags    │ │ 2m ago  │ 1h ago  │ 3h  │ │                                 │
│   ○ Search  │ └─────────┴─────────┴─────┘ │ Recent Activity:                │
│             │                             │ ┌─────────────────────────────┐ │
│ 👁️ View     │ ┌─────────┬─────────┬─────┐ │ │ ✏️ Edited "Work meeting"   │ │
│   ○ Favorites│ │ 📝 Note │ 📝 Note │ 📝  │ │ │ 📝 Created "Family dinner" │ │
│   ○ Archive │ │ Flutter │ Meeting │ Todo│ │ │ 🔍 Searched "project"      │ │
│             │ │ tips    │ notes   │ list│ │ │ 🏷️ Added tag "urgent"     │ │
│ ⚙️ Settings │ │ 🏷️ dev  │ 🏷️ work│ 📋  │ │ └─────────────────────────────┘ │
│ 🌙 Dark Mode│ │ 1d ago  │ 2d ago  │ 1w  │ │                                 │
│             │ └─────────┴─────────┴─────┘ │ Quick Actions:                  │
│ ────────    │                             │ ┌─────────────────────────────┐ │
│             │ ┌─────────────────────────┐   │ │ 📝 New Note                 │ │
│ Tags:       │ │ 📊 Load More (12 more)  │   │ │ 🔍 Advanced Search          │ │
│ 🏷️ work (8) │ └─────────────────────────┘   │ │ 📤 Export Data              │ │
│ 🏷️ family(3)│                             │ │ 📥 Import Notes             │ │
│ 🏷️ dev (2)  │                             │ │ 🏷️ Manage Tags             │ │
│ 🏷️ todo (5) │                             │ └─────────────────────────────┘ │
│ + Add more  │                             │                                 │
│             │                             │                                 │
└─────────────┴─────────────────────────────┴─────────────────────────────────┘
```

### Desktop Detail View with Split Panels
```
Information Detail View (Desktop):
┌─────────────────────────────────────────────────────────────────────────────┐
│ ← Back to Browse                                          Edit ✏️  Share 📤 │
├─────────────┬─────────────────────────────────────────────┬─────────────────┤
│ Content     │ Main Article View                           │ Metadata        │
│ Navigator   │                                             │                 │
│             │ # Weekly Team Meeting - Q4 Planning        │ Properties:     │
│ Outline:    │                                             │ ┌─────────────┐ │
│ ○ Agenda    │ **Date:** December 15, 2024                 │ │ 📅 Created  │ │
│ ○ Updates   │ **Duration:** 2 hours                       │ │ Dec 15      │ │
│ ○ Action    │ **Attendees:** Product team, Engineering    │ │ 12:34 PM    │ │
│   Items     │                                             │ └─────────────┘ │
│ ○ Notes     │ ## Agenda Items                             │                 │
│             │                                             │ ┌─────────────┐ │
│ Word Count: │ ### 1. Q4 Goal Review                       │ │ ✏️ Modified │ │
│ 247 words   │ - Current progress: **85% complete**        │ │ Dec 15      │ │
│             │ - Remaining milestones for December         │ │ 4:15 PM     │ │
│ Reading:    │ - Team performance metrics                  │ └─────────────┘ │
│ ~1 min      │                                             │                 │
│             │ ### 2. Resource Planning                    │ Tags:           │
│ Links:      │ - Team allocation for Q1 2025               │ 🏷️ meeting    │
│ ○ Project   │ - Budget considerations and approvals       │ 🏷️ planning   │
│   Board     │ - Hiring pipeline updates                   │ 🏷️ q4         │
│ ○ Calendar  │                                             │ 🏷️ team       │
│             │ ### 3. Action Items                         │                 │
│ Related:    │ - [ ] **John:** Update project timeline     │ Related Notes:  │
│ ○ Q3 Review │ - [ ] **Sarah:** Review budget proposal     │ ┌─────────────┐ │
│ ○ Budget    │ - [ ] **Mike:** Setup Q1 kickoff meeting   │ │ 📝 Q3 Review│ │
│   Planning  │                                             │ │ 📝 Team     │ │
│             │ ## Meeting Notes                            │ │   Updates   │ │
│             │                                             │ │ 📝 Project  │ │
│             │ Great discussion about team dynamics and    │ │   Planning  │ │
│             │ how we can improve collaboration in Q1.     │ └─────────────┘ │
│             │ The consensus is that we need to focus on   │                 │
│             │ better communication tools and processes.   │ Actions:        │
│             │                                             │ ┌─────────────┐ │
│             │ **Key Decisions:**                          │ │ 📝 Edit     │ │
│             │ - Proceed with hiring 2 new developers      │ │ 🗑️ Delete   │ │
│             │ - Implement new project management tools    │ │ 📋 Duplicate│ │
│             │ - Increase weekly sync frequency            │ │ 📎 Archive  │ │
│             │                                             │ │ 🔗 Copy Link│ │
│             │                                             │ └─────────────┘ │
└─────────────┴─────────────────────────────────────────────┴─────────────────┘
```

---

## 6. Mobile-Specific User Patterns

### Swipe Gestures and Touch Interactions
```
Card Swipe Actions (Mobile):
Default State:
┌───────────────────┐
│ 📝 Meeting Notes  │ ← Card in neutral position
│ Team sync about Q4│
│ 🏷️ meeting       │
│ 📅 2 hours ago    │
└───────────────────┘

Swipe Right (→) - Quick Actions:
┌─────────────────────────────────────┐
│ ⭐        📝 Meeting Notes     ✏️  │ ← Star + Edit revealed
│ Favorite   Team sync about Q4  Edit │
│            🏷️ meeting              │
│            📅 2 hours ago           │
└─────────────────────────────────────┘

Swipe Left (←) - Danger Actions:
┌─────────────────────────────────────┐
│ ✏️  📝 Meeting Notes       🗑️  📋  │ ← Edit + Delete + Archive
│ Edit Team sync about Q4   Del  Arch │
│      🏷️ meeting                    │
│      📅 2 hours ago                 │
└─────────────────────────────────────┘

Pull to Refresh:
┌───────────────────┐
│        ↓          │ ← Pull indicator
│    🔄 Release     │
│   to refresh      │
├───────────────────┤
│ Recent Information│
│                   │
│ ┌───────────────┐ │
│ │ 📝 Note 1     │ │
│ └───────────────┘ │
└───────────────────┘
```

### Floating Action Button (FAB) Flow
```
Browse Screen with FAB:
┌───────────────────┐
│ Mind House        │
├───────────────────┤
│ ┌───────────────┐ │
│ │ 📝 Note 1     │ │
│ │ Content...    │ │
│ └───────────────┘ │
│                   │
│ ┌───────────────┐ │
│ │ 📝 Note 2     │ │
│ │ Content...    │ │
│ └───────────────┘ │
│                   │
│               ┌─┐ │ ← FAB for quick create
│               │+│ │
│               └─┘ │
└───────────────────┘

FAB Tap - Quick Create:
┌───────────────────┐
│ New Information   │
├───────────────────┤
│ ┌───────────────┐ │ ← Slide-up modal
│ │ Quick thought?│ │
│ │               │ │
│ │ |             │ │ ← Auto-focused input
│ └───────────────┘ │
│                   │
│ ┌─────┐ ┌───────┐ │
│ │Save │ │Cancel │ │ ← Action buttons
│ └─────┘ └───────┘ │
│                   │
│ 🎤 Voice Input    │ ← Voice option
└───────────────────┘
```

### Mobile Search Patterns
```
Search Focus with Keyboard:
┌───────────────────┐
│ ← Cancel          │ ← Back button appears
├───────────────────┤
│ ┌───────────────┐ │
│ │ 🔍 meeting|   │ │ ← Focused search
│ └───────────────┘ │
│                   │
│ 🕒 Recent:        │
│ meeting notes     │
│ meeting agenda    │
│                   │
│ 💡 Suggestions:   │
│ meeting           │
│ meetings          │
│                   │
│ ┌───────────────┐ │
│ │ 🎤 Voice      │ │ ← Voice search
│ └───────────────┘ │
├───────────────────┤ ← Keyboard area
│ q w e r t y u i o │   (shown when
│ a s d f g h j k l │    input focused)
│ z x c v b n m   ⌫ │
│ 123   space   ⏎   │
└───────────────────┘

Search Results with Filters:
┌───────────────────┐
│ ← "meeting"    🔽 │ ← Back + filter toggle
├───────────────────┤
│ Filters:          │ ← Filter panel
│ 🏷️ All tags      │   (slides down)
│ 📅 Any date      │
│ 📝 All types     │
│ ┌─────────────┐   │
│ │ Apply       │   │
│ └─────────────┘   │
├───────────────────┤
│ 📊 3 results      │
│                   │
│ ┌───────────────┐ │
│ │ 📝 **Meeting**│ │ ← Results with
│ │ Notes         │ │   highlighted
│ │ Team sync...  │ │   search terms
│ │ 🏷️ **meeting**│ │
│ └───────────────┘ │
└───────────────────┘
```

---

## 7. Cross-Device Continuity Flow

### Handoff Between Devices
```
Phone Start:
┌───────────────────┐
│ Mind House        │
├───────────────────┤
│ ┌───────────────┐ │
│ │ Draft: Project│ │ ← Creating note
│ │ meeting ideas │ │   on phone
│ │               │ │
│ │ - Discuss Q1  │ │
│ │ - Review team │ │
│ │ - Budget plan │ │
│ │ |             │ │ ← Cursor position
│ └───────────────┘ │
│                   │
│ 💾 Auto-saved     │ ← Cloud sync indicator
│ 📱→💻 Continue on │ ← Handoff prompt
│     computer      │
└───────────────────┘

Desktop Continue:
┌─────────────────────────────────────────────────────────────────────────────┐
│ 🔔 Continue from iPhone: "Project meeting ideas"                     × Close │ ← Handoff notification
├─────────────────────────────────────────────────────────────────────────────┤
│ ☰ Mind House                                              👤 ⚙️            │
├─────────────┬─────────────────────────────────────────────┬─────────────────┤
│ Navigation  │ Editor - Continued from iPhone              │ Details         │
│             │                                             │                 │
│ 📝 Store    │ Title: Project meeting ideas                │ Sync Status:    │
│ 🔍 Browse   │ ┌─────────────────────────────────────────┐ │ ✅ Synced      │
│ 👁️ View     │ │ - Discuss Q1 goals and objectives       │ │ 📱 From iPhone │
│             │ │ - Review team performance metrics       │ │ 📅 Just now    │
│             │ │ - Budget planning for next quarter      │ │                 │
│             │ │                                         │ │ Handoff:        │
│             │ │ Additional items to cover:              │ │ ┌─────────────┐ │
│             │ │ - Resource allocation                   │ │ │ 📱 Available│ │
│             │ │ - Timeline adjustments                  │ │ │ 📱 iPad     │ │
│             │ │ - Stakeholder communication             │ │ │ 💻 This Mac │ │
│             │ │ |                                       │ │ └─────────────┘ │
│             │ └─────────────────────────────────────────┘ │                 │
│             │                                             │                 │
│             │ 💾 Synced across devices • 127 words       │                 │
└─────────────┴─────────────────────────────────────────────┴─────────────────┘
```

---

## 8. Error States and Recovery Flow

### Network Connection Issues
```
Offline Mode (Mobile):
┌───────────────────┐
│ 📶 Offline        │ ← Connection indicator
├───────────────────┤
│ ⚠️ No Connection  │
│                   │
│ Working offline.  │
│ Changes will sync │
│ when connected.   │
│                   │
│ ┌───────────────┐ │
│ │ 🔄 Try Again  │ │ ← Retry button
│ └───────────────┘ │
│                   │
│ Offline Features: │
│ ✅ Create notes   │ ← Available features
│ ✅ Edit existing  │
│ ✅ View all       │
│ ❌ Sync changes   │
│ ❌ Search cloud   │
├───────────────────┤
│📝  🔍  👁️  ⚙️  │
│●   ○   ○   ○     │
└───────────────────┘

Connection Restored:
┌───────────────────┐
│ 📶 Connected      │ ← Status update
├───────────────────┤
│ ✅ Back Online    │
│                   │
│ Syncing changes...│
│ ████████████░░░░░ │ ← Progress bar
│                   │
│ 📤 Uploading:     │
│ • Project notes   │
│ • Meeting agenda  │
│ • 2 new tags      │
│                   │
│ ┌───────────────┐ │
│ │ ✅ All Synced │ │ ← Completion
│ └───────────────┘ │
├───────────────────┤
│📝  🔍  👁️  ⚙️  │
│●   ○   ○   ○     │
└───────────────────┘
```

### Data Recovery Flow
```
Unsaved Changes Warning:
┌───────────────────┐
│ ⚠️ Unsaved Changes│
├───────────────────┤
│ You have unsaved  │
│ changes in:       │
│                   │
│ • Meeting notes   │
│ • Project ideas   │
│                   │
│ What would you    │
│ like to do?       │
│                   │
│ ┌───────────────┐ │
│ │ 💾 Save All   │ │ ← Primary action
│ └───────────────┘ │
│                   │
│ ┌───────────────┐ │
│ │ 📱 Review     │ │ ← Secondary action
│ └───────────────┘ │
│                   │
│ ┌───────────────┐ │
│ │ 🗑️ Discard    │ │ ← Destructive action
│ └───────────────┘ │
└───────────────────┘

Auto-Recovery Screen:
┌───────────────────┐
│ 🔄 Recovery Mode  │
├───────────────────┤
│ Found unsaved     │
│ content from your │
│ last session:     │
│                   │
│ ┌───────────────┐ │
│ │ 📝 Draft 1    │ │ ← Recovered content
│ │ Meeting prep  │ │
│ │ 47 words      │ │
│ │ 2m ago        │ │
│ │ ┌─────┐┌────┐ │ │
│ │ │Keep││Skip│ │ │ ← Actions per item
│ │ └─────┘└────┘ │ │
│ └───────────────┘ │
│                   │
│ ┌───────────────┐ │
│ │ 📝 Draft 2    │ │
│ │ Project ideas │ │
│ │ 23 words      │ │
│ │ 5m ago        │ │
│ │ ┌─────┐┌────┐ │ │
│ │ │Keep││Skip│ │ │
│ │ └─────┘└────┘ │ │
│ └───────────────┘ │
│                   │
│ ┌───────────────┐ │
│ │ Continue →    │ │ ← Proceed
│ └───────────────┘ │
└───────────────────┘
```

---

## 9. Accessibility-Focused User Flows

### Screen Reader Navigation
```
VoiceOver Mode (iOS):
┌───────────────────┐
│ 🔊 VoiceOver On   │ ← Accessibility indicator
├───────────────────┤
│ ╔═══════════════╗ │ ← Focus indicator
│ ║ 📝 Meeting    ║ │   (thick border)
│ ║ Notes         ║ │
│ ╚═══════════════╝ │
│                   │
│ 🔊 "Information   │ ← VoiceOver speech
│ card: Meeting     │   output display
│ Notes. Created    │
│ today at 2:30 PM. │
│ Double tap to     │
│ open."            │
│                   │
│ ⌨️ Navigation:    │ ← Gesture hints
│ Swipe → Next      │
│ Swipe ← Previous  │
│ Double tap: Open  │
├───────────────────┤
│📝  🔍  👁️  ⚙️  │
│●   ○   ○   ○     │
└───────────────────┘

High Contrast Mode:
┌━━━━━━━━━━━━━━━━━━━┐
│ ▓▓ MIND HOUSE ▓▓ │ ← High contrast
┣━━━━━━━━━━━━━━━━━━━┫   colors and
│                   │   bold borders
│ ┏━━━━━━━━━━━━━━━┓ │
│ ┃ 📝 MEETING    ┃ │
│ ┃ NOTES         ┃ │
│ ┃ TEAM SYNC...  ┃ │
│ ┃ 🏷️ MEETING   ┃ │
│ ┗━━━━━━━━━━━━━━━┛ │
│                   │
│ ┏━━━━━━━━━━━━━━━┓ │
│ ┃ 📝 PROJECT    ┃ │
│ ┃ IDEAS         ┃ │
│ ┃ QUARTERLY...  ┃ │
│ ┃ 🏷️ WORK      ┃ │
│ ┗━━━━━━━━━━━━━━━┛ │
├━━━━━━━━━━━━━━━━━━━┤
│📝  🔍  👁️  ⚙️  │
│▓   ○   ○   ○     │
└━━━━━━━━━━━━━━━━━━━┘
```

### Voice Control Flow
```
Voice Commands (iOS/Android):
┌───────────────────┐
│ 🎤 Voice Control  │ ← Voice mode indicator
├───────────────────┤
│ Listening...      │ ← Status
│                   │
│ Available commands│
│                   │
│ "Create note"     │ ← Voice commands
│ "Search meeting"  │   shown to user
│ "Open settings"   │
│ "Show recent"     │
│                   │
│ ┌───────────────┐ │ ← Visual elements
│ │ 1 📝 Meeting  │ │   numbered for
│ │   Notes       │ │   voice reference
│ └───────────────┘ │
│                   │
│ ┌───────────────┐ │
│ │ 2 📝 Project  │ │
│ │   Ideas       │ │
│ └───────────────┘ │
│                   │
│ Say "Open 1" or   │ ← Instructions
│ "Tap 1" to select │
├───────────────────┤
│📝  🔍  👁️  ⚙️  │
│●   ○   ○   ○     │
└───────────────────┘

Voice Command Executed:
┌───────────────────┐
│ 🎤 "Create note"  │ ← Command heard
├───────────────────┤
│ ✅ Creating new   │ ← Confirmation
│ note...           │
│                   │
│ ┌───────────────┐ │ ← New note opens
│ │ What's on your│ │   automatically
│ │ mind?         │ │
│ │               │ │
│ │ 🎤 Listening...│ │ ← Voice input ready
│ └───────────────┘ │
│                   │
│ Say your content  │ ← Voice prompts
│ or "Stop" to      │
│ finish.           │
│                   │
│ ┌───────────────┐ │
│ │ 🎤 Stop       │ │ ← Stop button
│ └───────────────┘ │
├───────────────────┤
│📝  🔍  👁️  ⚙️  │
│●   ○   ○   ○     │
└───────────────────┘
```

---

## 10. Performance Considerations

### Progressive Loading States
```
Initial App Launch (Mobile):
Frame 1 (0-100ms):
┌───────────────────┐
│                   │ ← Splash screen
│        🏠         │   (app icon)
│   Mind House      │
│                   │
└───────────────────┘

Frame 2 (100-300ms):
┌───────────────────┐
│ Mind House        │ ← Header appears
├───────────────────┤
│ ░░░░░░░░░░░░░░░░░ │ ← Content skeleton
│ ░░░░░░░░░░░░░░░░░ │   loading
│ ░░░░░░░░░░░░░░░░░ │
├───────────────────┤
│📝  🔍  👁️  ⚙️  │ ← Navigation ready
│○   ○   ○   ○     │
└───────────────────┘

Frame 3 (300-600ms):
┌───────────────────┐
│ Mind House        │
├───────────────────┤
│ ┌───────────────┐ │ ← Content appears
│ │ 📝 Meeting    │ │   progressively
│ │ Notes         │ │
│ │ ░░░░░░░░░░░░░ │ │ ← Some still loading
│ └───────────────┘ │
│                   │
│ ░░░░░░░░░░░░░░░░░ │
├───────────────────┤
│📝  🔍  👁️  ⚙️  │
│●   ○   ○   ○     │
└───────────────────┘

Frame 4 (600ms+):
┌───────────────────┐
│ Mind House        │
├───────────────────┤
│ ┌───────────────┐ │ ← Fully loaded
│ │ 📝 Meeting    │ │
│ │ Notes         │ │
│ │ Team sync Q4  │ │
│ │ 🏷️ meeting   │ │
│ └───────────────┘ │
│                   │
│ ┌───────────────┐ │
│ │ 📝 Project    │ │
│ │ Ideas         │ │
│ └───────────────┘ │
├───────────────────┤
│📝  🔍  👁️  ⚙️  │
│●   ○   ○   ○     │
└───────────────────┘
```

---

This comprehensive user flow wireframe documentation maps the complete user journey through the Mind House application across all device types, showing how users navigate between features, handle edge cases, and interact with accessibility features. The wireframes demonstrate responsive behavior, error handling, and performance considerations to ensure a smooth user experience across all scenarios.