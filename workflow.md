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

### Implementation (Future)
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