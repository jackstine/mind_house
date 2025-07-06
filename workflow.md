# Application Development Workflow

## Overview
This workflow is designed to create a new application through a structured discovery and planning process that ensures thorough understanding before implementation.

## Tasks
the following is a set of tasks that can be performed from time to time.

### Instruction
- **Objective**: Gather tasks and prompts from the user in instruction files.
- **Activities**:
  - You must not access the files unless instructed directly by the user.
  - You will read and perform the set of tasks instructed in the instruction file.
  - Instruction files will be `instruction-x.md` where `x` is a number, denoted the `xth` instruction. Do not perform tasks from a previous instruction.
  - instructions can be found in the `instruction` folder.

### Discovery
- **Objective**: Gather comprehensive information about the application requirements
- **Activities**:
  - Ask targeted questions to understand user needs
  - Research relevant technologies and approaches with links to sources
  - Document findings in `discovery.md`
  - Continuously update Q&A with new questions and answers
- **Output**: Complete discovery documentation

### Planning
- **Objective**: Create a solid architectural plan based on discovery findings
- **Activities**:
  - Analyze discovery information
  - Design application architecture
  - Create implementation roadmap
  - Document plan in `plan.md`
  - Iterate on plan based on user feedback
- **Output**: Detailed implementation plan

### Development Todo List Creation
- **Objective**: Create comprehensive, dependency-aware todo lists for application development
- **Activities**:
  - Analyze all design documents in `design-docs/` folder
  - Create categorized todo lists with clear dependencies
  - Ensure each task is one finite unit of work (1-4 hours)
  - Organize by priority, dependencies, and grouping
  - Reference components.md, data-schema-design.md, and other design docs
- **Output**: Structured development todo list with dependency mapping

### Implementation
- **Objective**: Build the application according to the plan and todo list
- **Activities**: 
  - Follow dependency-aware todo list
  - Complete categories in proper order
  - Ensure all dependencies are met before starting new categories

## Key Files

- **workflow.md**: This file - documents the overall workflow
- **formatting.md**: Formatting guidelines for all documentation files
- **Q&A.md**: Questions and answers organized by status
- **discovery.md**: All discovered information and insights
- **plan.md**: Detailed application architecture and implementation plan
- **backlog.md**: Features and tasks planned for later phases
- **components.md**: UI components needed for the application
- **development-todo.md**: Comprehensive development checklist with dependencies and categories

## Process Notes

- Questions must be asked to validate discoveries and plans
- User feedback is essential at each phase
- All information should be properly documented in designated files
- Iterate until sufficient information is gathered for solid planning
- When searching the web, include links to relevant information sources
- Include links in a `links.md` file with a heading showing the category of the types of links.
- Always update `plan.md` when receiving new requirements or information

## Instructions Processing

### Reading Instructions Files
- Check for `instructions-1.md` file for specific tasks
- Complete all tasks listed in instructions files
- Update workflow with new processes as instructed
- Mark completed tasks in planning todo lists


## File Management Rules

### Folder Organization
- **design-docs/**: All design documents should be placed in this folder
- **previous-todos/**: Completed todo files should be moved here when finished
- **answered.md**: Questions not in Q&A.md and their answers go here

### Backlog Management
- Use `backlog.md` for all future/deferred features

### Documentation Requirements
- Create design documents for major features in `design-docs/` folder
- Maintain component documentation in `components.md`
- Update `plan.md` with all new information received
- When completing a todo file, move it to `previous-todos/` folder
- When user asks questions not in Q&A.md, document in `answered.md`

## Development Todo List Methodology

### Category Organization
Development tasks should be organized into logical categories that group related work together:
- **Environment Setup**: Development environment configuration
- **Database Layer**: Database schema and data access
- **Core Models**: Data models and business entities
- **State Management**: Application state management (BLoC pattern)
- **Core UI Components**: Reusable UI widgets
- **Page Components**: Screen-level components
- **Navigation**: App navigation and routing
- **Business Logic**: Feature integration and workflows
- **Testing Infrastructure**: Testing framework setup
- **Testing Implementation**: Writing and executing tests
- **Optimization**: Performance and size optimization
- **Deployment**: Build and release processes

### Dependency Management
Each category must clearly define its dependencies:
- **Format**: "Category X depends on (A, B, C)"
- **Rule**: Cannot start work in a category until ALL dependencies are 100% complete
- **Example**: "F (Page Components) depends on A, C, D, E"

### Task Granularity
Each individual task should be:
- **Finite**: One specific, completable unit of work
- **Timeboxed**: 1-4 hours of work maximum
- **Testable**: Clear definition of "done"
- **Independent**: Can be completed without waiting for other tasks in same category

### Priority Classification
- **Critical**: Must be completed for basic functionality
- **High**: Important for user experience
- **Medium**: Enhances functionality
- **Low**: Nice-to-have features

### Development Flow
1. **Complete all tasks in a category before moving to dependent categories**
2. **Tasks within a category can be worked on in parallel**
3. **Regular testing and validation after each category completion**
4. **Code reviews should happen after completing each category**