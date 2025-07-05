# Application Development Workflow

## Overview
This workflow is designed to create a new application through a structured discovery and planning process that ensures thorough understanding before implementation.

## Workflow Phases

### Phase 1: Discovery
- **Objective**: Gather comprehensive information about the application requirements
- **Activities**:
  - Ask targeted questions to understand user needs
  - Research relevant technologies and approaches with links to sources
  - Document findings in `discovery.md`
  - Continuously update Q&A with new questions and answers
- **Output**: Complete discovery documentation

### Phase 2: Planning
- **Objective**: Create a solid architectural plan based on discovery findings
- **Activities**:
  - Analyze discovery information
  - Design application architecture
  - Create implementation roadmap
  - Document plan in `plan.md`
  - Iterate on plan based on user feedback
  - Read and complete tasks from `instructions-1.md`
- **Output**: Detailed implementation plan

### Phase 3: Implementation (Future)
- **Objective**: Build the application according to the plan
- **Activities**: TBD based on completed plan

## Key Files

- **workflow.md**: This file - documents the overall workflow
- **formatting.md**: Formatting guidelines for all documentation files
- **Q&A.md**: Questions and answers organized by status
- **discovery.md**: All discovered information and insights
- **plan.md**: Detailed application architecture and implementation plan
- **backlog.md**: Features and tasks planned for later phases
- **components.md**: UI components needed for the application
- **planning-todo.md**: Planning checklist with tasks marked as `- [ ]` (pending) or `- [✅]` (completed)

## Process Notes

- Questions must be asked to validate discoveries and plans
- User feedback is essential at each phase
- All information should be properly documented in designated files
- Iterate until sufficient information is gathered for solid planning
- When searching the web, include links to relevant information sources
- Always update `plan.md` when receiving new requirements or information

## Instructions Processing

### Reading Instructions Files
- Check for `instructions-1.md` file for specific tasks
- Complete all tasks listed in instructions files
- Update workflow with new processes as instructed
- Mark completed tasks in planning todo lists

## Application Focus Areas

### Core Design Principles
- **Tags-First Approach**: Tags are the main focus of the entire application
- **Quick Capture**: Primary goal is immediate information storage
- **Offline-First**: Application operates offline in first phase
- **Tag-Based Search**: No full-text search, only tag-based filtering

### Application Pages Structure
1. **Store Information Page** - Primary entry point for capturing data
2. **Information Page** - Display individual information items
3. **List Information Page** - Browse and filter stored information

### Automatic Behaviors
- App opens directly to "Store Information" page
- After 15 minutes in background, returning to app goes to "Store Information" page
- Quick search button always accessible

## File Management Rules

### Backlog Management
- Use `backlog.md` for all future/deferred features
- Items to include in backlog:
  - Templates and structures
  - Backend development
  - Import/export functionality
  - Smart suggestions
  - Collaboration preparation

### Documentation Requirements
- Create design documents for major features (tagging, data schema, etc.)
- Maintain component documentation in `components.md`
- Update `plan.md` with all new information received