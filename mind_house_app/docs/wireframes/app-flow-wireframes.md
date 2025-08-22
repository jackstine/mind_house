# 📐 Mind House App Flow Wireframes
*Text-based wireframe documentation for complete user workflows*

## 🎯 **Overview**
This document provides comprehensive ASCII art wireframes for the Mind House information management app, covering all primary user flows across Store, Browse, and View functionality.

## 📱 **Mobile Layout Standards**
- **Screen Width**: 375px (iPhone standard)
- **Touch Targets**: Minimum 48dp (Android) / 44pt (iOS) 
- **Safe Areas**: Top 44pt, Bottom 34pt (iPhone X+)
- **Content Width**: 343px (16px margins)

---

## 🏠 **1. App Home & Navigation Structure**

### **1.1 Main Navigation Layout**
```
┌─────────────────────────┐ ← 375px width
│ ┌─┐ Mind House    ┌─┐   │ ← Header (44pt)
│ │≡│               │⚙│   │   [Menu] [Settings]
│ └─┘               └─┘   │
├─────────────────────────┤
│                         │
│                         │ ← Content Area
│      [CONTENT]          │   (Dynamic based on tab)
│                         │
│                         │
│                         │
│                         │
├─────────────────────────┤
│ [Store] [Browse] [View] │ ← Bottom Navigation (56dp)
│   ●       ○       ○     │   ● = Active, ○ = Inactive
└─────────────────────────┘ ← Safe area (34pt)
```

### **1.2 Navigation States**
```
Store Tab Active:                Browse Tab Active:              View Tab Active:
┌─────────────────────────┐     ┌─────────────────────────┐     ┌─────────────────────────┐
│ [Store] [Browse] [View] │     │ [Store] [Browse] [View] │     │ [Store] [Browse] [View] │
│   ●       ○       ○     │     │   ○       ●       ○     │     │   ○       ○       ●     │
└─────────────────────────┘     └─────────────────────────┘     └─────────────────────────┘
```

---

## 📝 **2. Store Information Flow**

### **2.1 Content Creation Screen**
```
┌─────────────────────────┐
│ ← Mind House        ✓   │ ← Header with back & save
├─────────────────────────┤
│                         │
│ ┌─────────────────────┐ │ ← Content Input Area
│ │ What's on your mind?│ │   (Expandable text field)
│ │                     │ │   Min height: 120dp
│ │ [Cursor here]       │ │   Max height: 240dp
│ │                     │ │   Auto-resize enabled
│ │                     │ │
│ │                     │ │
│ └─────────────────────┘ │
│                         │
│ ┌─────────────────────┐ │ ← Tag Input Area
│ │ Tags: #idea #work + │ │   Height: 48dp
│ └─────────────────────┘ │   Chips + input field
│                         │
│ ┌─────────────────────┐ │ ← Primary Action
│ │        SAVE         │ │   Height: 48dp
│ └─────────────────────┘ │   Material Design 3 button
│                         │
├─────────────────────────┤
│ [Store] [Browse] [View] │ ← Navigation remains visible
│   ●       ○       ○     │
└─────────────────────────┘
```

### **2.2 Tag Input States**

#### **Empty State:**
```
┌─────────────────────┐
│ Add tags...         │ ← Placeholder text
└─────────────────────┘
```

#### **Typing State:**
```
┌─────────────────────┐
│ work|               │ ← Active cursor
└─────────────────────┘
┌─────────────────────┐ ← Suggestion dropdown
│ • work              │   (Appears below input)
│ • workflow          │
│ • workplace         │
└─────────────────────┘
```

#### **With Tags State:**
```
┌─────────────────────┐
│ [work] [idea] +     │ ← Chips + add button
└─────────────────────┘
```

### **2.3 Save Success Flow**
```
┌─────────────────────────┐
│        SUCCESS!         │ ← Success message
│   Information saved     │   (Toast notification)
├─────────────────────────┤
│                         │ ← Automatically transitions
│   Redirecting to        │   to Browse tab after 2s
│      Browse...          │
│                         │
├─────────────────────────┤
│ [Store] [Browse] [View] │
│   ○       ●       ○     │ ← Switches to Browse
└─────────────────────────┘
```

---

## 🔍 **3. Browse Information Flow**

### **3.1 Browse Landing Screen**
```
┌─────────────────────────┐
│ 🔍 Search...        ⚙   │ ← Search bar + settings
├─────────────────────────┤
│ ┌─────────────────────┐ │ ← Filter chips
│ │ [All] [work] [idea] │ │   Horizontal scroll
│ └─────────────────────┘ │
├─────────────────────────┤
│ ┌─────────────────────┐ │ ← Information card
│ │ 💡 Meeting ideas    │ │   Title with icon
│ │ Quick notes for...  │ │   Preview text
│ │ #work #meeting     │ │   Tags
│ │ 2 hours ago        │ │   Timestamp
│ └─────────────────────┘ │
│                         │
│ ┌─────────────────────┐ │ ← Information card
│ │ 📝 Project plan     │ │
│ │ Need to outline... │ │
│ │ #work #planning    │ │
│ │ Yesterday          │ │
│ └─────────────────────┘ │
│                         │
│ ┌─────────────────────┐ │ ← Information card
│ │ 🎯 Goals for Q1     │ │
│ │ Personal and...    │ │
│ │ #goals #personal   │ │
│ │ 3 days ago         │ │
│ └─────────────────────┘ │
├─────────────────────────┤
│ [Store] [Browse] [View] │
│   ○       ●       ○     │
└─────────────────────────┘
```

### **3.2 Search Active State**
```
┌─────────────────────────┐
│ 🔍 meeting|         ✕   │ ← Active search + clear
├─────────────────────────┤
│ ┌─────────────────────┐ │ ← Search suggestions
│ │ • meeting ideas     │ │   (Real-time results)
│ │ • meeting notes     │ │
│ │ • team meeting      │ │
│ └─────────────────────┘ │
├─────────────────────────┤
│ ┌─────────────────────┐ │ ← Filtered results
│ │ 💡 Meeting ideas    │ │   Only matching items
│ │ Quick notes for...  │ │
│ │ #work #meeting     │ │
│ │ 2 hours ago        │ │
│ └─────────────────────┘ │
│                         │
│ No more results...      │ ← End indicator
├─────────────────────────┤
│ [Store] [Browse] [View] │
│   ○       ●       ○     │
└─────────────────────────┘
```

### **3.3 Empty State**
```
┌─────────────────────────┐
│ 🔍 Search...        ⚙   │
├─────────────────────────┤
│                         │
│        📝               │ ← Large icon
│                         │
│  No information yet     │ ← Primary message
│                         │
│ Tap Store to create     │ ← Action guidance
│   your first note!      │
│                         │
│ ┌─────────────────────┐ │ ← CTA button
│ │    CREATE NOTE      │ │
│ └─────────────────────┘ │
│                         │
├─────────────────────────┤
│ [Store] [Browse] [View] │
│   ○       ●       ○     │
└─────────────────────────┘
```

---

## 👁️ **4. View Information Flow**

### **4.1 Information Selection Screen**
```
┌─────────────────────────┐
│ ← Select Information    │ ← Header with back
├─────────────────────────┤
│                         │
│ Choose information      │ ← Instruction text
│ to view and edit:       │
│                         │
│ ┌─────────────────────┐ │ ← Selectable list
│ │ ○ Meeting ideas     │ │   Radio buttons
│ │   #work #meeting    │ │
│ └─────────────────────┘ │
│                         │
│ ┌─────────────────────┐ │
│ │ ● Project plan      │ │ ← Selected item
│ │   #work #planning   │ │
│ └─────────────────────┘ │
│                         │
│ ┌─────────────────────┐ │
│ │ ○ Goals for Q1      │ │
│ │   #goals #personal  │ │
│ └─────────────────────┘ │
│                         │
│ ┌─────────────────────┐ │ ← Action button
│ │       VIEW          │ │   (Enabled when selected)
│ └─────────────────────┘ │
├─────────────────────────┤
│ [Store] [Browse] [View] │
│   ○       ○       ●     │
└─────────────────────────┘
```

### **4.2 Information Detail View**
```
┌─────────────────────────┐
│ ← Project plan      ⋯   │ ← Header with menu
├─────────────────────────┤
│                         │
│ 📝 Project plan         │ ← Title with icon
│ Created: Yesterday      │ ← Metadata
│ Modified: 1 hour ago    │
│                         │
├─────────────────────────┤ ← Content separator
│                         │
│ Need to outline the     │ ← Full content display
│ new project structure   │   (Scrollable)
│ and timeline for Q1.    │
│                         │
│ Key areas:              │
│ - Research phase        │
│ - Design phase          │
│ - Development phase     │
│ - Testing phase         │
│                         │
│ Timeline: 3 months      │
│                         │
├─────────────────────────┤ ← Tags separator
│ Tags:                   │
│ [work] [planning]       │ ← Tag chips
│ [project] [timeline]    │
├─────────────────────────┤
│ ┌─────────┐ ┌─────────┐ │ ← Action buttons
│ │  EDIT   │ │ DELETE  │ │   Primary + Secondary
│ └─────────┘ └─────────┘ │
├─────────────────────────┤
│ [Store] [Browse] [View] │
│   ○       ○       ●     │
└─────────────────────────┘
```

### **4.3 Edit Mode**
```
┌─────────────────────────┐
│ ← Edit Mode         ✓   │ ← Save changes
├─────────────────────────┤
│                         │
│ ┌─────────────────────┐ │ ← Editable title
│ │ Project plan        │ │
│ └─────────────────────┘ │
│                         │
│ ┌─────────────────────┐ │ ← Editable content
│ │ Need to outline the │ │   (Full editing)
│ │ new project struct..│ │
│ │                     │ │
│ │ [Cursor here]       │ │
│ │                     │ │
│ │                     │ │
│ └─────────────────────┘ │
│                         │
│ ┌─────────────────────┐ │ ← Editable tags
│ │ [work] [planning] + │ │
│ └─────────────────────┘ │
│                         │
│ ┌─────────┐ ┌─────────┐ │ ← Save/Cancel
│ │  SAVE   │ │ CANCEL  │ │
│ └─────────┘ └─────────┘ │
├─────────────────────────┤
│ [Store] [Browse] [View] │
│   ○       ○       ●     │
└─────────────────────────┘
```

---

## 🔄 **5. Cross-Tab User Flows**

### **5.1 Complete Information Lifecycle**
```
1. CREATE (Store Tab)
┌─────────────────────────┐
│ Content Input           │
│ ↓                       │
│ Tag Addition            │
│ ↓                       │
│ Save Action             │
└─────────────────────────┘
           ↓
2. DISCOVER (Browse Tab)
┌─────────────────────────┐
│ Auto-redirect to Browse │
│ ↓                       │
│ See new item in list    │
│ ↓                       │
│ Search/Filter options   │
└─────────────────────────┘
           ↓
3. VIEW/EDIT (View Tab)
┌─────────────────────────┐
│ Select information      │
│ ↓                       │
│ View full details       │
│ ↓                       │
│ Edit if needed          │
└─────────────────────────┘
```

### **5.2 Quick Actions Flow**
```
From Any Tab:
┌─────────────────────────┐
│ Quick Create (FAB)      │ → Store Tab
│ Quick Search (⌘F)       │ → Browse Tab
│ Quick View Recent       │ → View Tab
└─────────────────────────┘
```

---

## 📊 **6. Loading & Error States**

### **6.1 Loading States**
```
Loading Content:                  Loading Search:
┌─────────────────────────┐     ┌─────────────────────────┐
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  │     │ 🔍 Searching...    ⏳   │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓         │     ├─────────────────────────┤
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓      │     │ ┌─────────────────────┐ │
│                         │     │ │ ░░░░░░░░░░░░░░░░░░░ │ │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  │     │ │ ░░░░░░░░░░░         │ │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓           │     │ │ ░░░░░░░░░░░░░░░     │ │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓       │     │ └─────────────────────┘ │
└─────────────────────────┘     └─────────────────────────┘
    Skeleton Loading               Search Loading
```

### **6.2 Error States**
```
Network Error:                    Validation Error:
┌─────────────────────────┐     ┌─────────────────────────┐
│        ⚠️                │     │        ⚠️                │
│                         │     │                         │
│   Connection failed     │     │   Content required      │
│                         │     │                         │
│ Check your internet     │     │ Please enter some text  │
│ connection and retry    │     │ before saving           │
│                         │     │                         │
│ ┌─────────────────────┐ │     │ ┌─────────────────────┐ │
│ │      RETRY          │ │     │ │        OK           │ │
│ └─────────────────────┘ │     │ └─────────────────────┘ │
└─────────────────────────┘     └─────────────────────────┘
```

---

## 📝 **7. Annotation Legend**

### **7.1 UI Element Symbols**
- `┌─┐ └─┘ ├─┤` - Container borders
- `[Button]` - Tappable buttons
- `○ ●` - Radio buttons (empty/filled)
- `≡` - Hamburger menu
- `⚙` - Settings icon
- `🔍` - Search icon
- `✓` - Checkmark/save
- `✕` - Close/cancel
- `+` - Add action
- `←` - Back navigation
- `⋯` - More options menu
- `|` - Text cursor
- `▓` - Loading content (filled)
- `░` - Loading content (empty)

### **7.2 Touch Target Specifications**
- Minimum touch target: 48dp (Android) / 44pt (iOS)
- Recommended spacing between targets: 8dp minimum
- Text input minimum height: 48dp
- Button minimum height: 48dp
- Navigation bar height: 56dp (Android) / 49pt (iOS)

### **7.3 Responsive Breakpoints**
- Mobile: 375px width (used in these wireframes)
- Tablet: 768px width
- Desktop: 1024px+ width

---

**📅 Document Version**: 1.0  
**📝 Last Updated**: 2025-08-21  
**👤 Created By**: AI Design System Team  
**🔄 Status**: Phase 1 Complete

This wireframe documentation provides the visual structure foundation for implementing the Mind House information management app with clear user flows, component layouts, and interaction patterns.