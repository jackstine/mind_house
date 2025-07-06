# Questions & Answers

## Questions

## Answered

1. What type of application are we building (web app, mobile app, desktop app, API, etc.)?
   - Mobile application for both iOS and Android

2. Who is the primary target user/audience for this application?
   - Anyone/any person seeking a tool to organize information like a mind map
   - Users who want to enhance their memory and information retrieval

3. What is the main problem this application will solve?
   - Quick information retrieval
   - Fast information input
   - Acts as a "second mind" with persistent memory
   - Provides cutting edge memory enhancement
   - Easy to use UX/UI

4. What is the expected scale/volume (number of users, data size, etc.)?
   - Approximately 1000 users initially

5. Are there any specific technologies or frameworks you prefer or want to avoid?
   - Open to any technology

6. What is your timeline and budget for this project?
   - No specific timeline

7. Do you need to integrate with any existing systems or APIs?
   - No

8. Are there any specific security or compliance requirements?
   - No

9. What specific features should the mind map have? (visual nodes, search, tags, etc.)
   - Creating a design doc to explore feature options

10. Should the mind map be visual/graphical or text-based?
   - Creating a visualization design doc to explore options

11. How will users input information? (voice, text, images, etc.)
   - Text input for now

12. Should it support collaboration/sharing between users?
   - No sharing initially, but may add later

13. Do you want offline functionality?
   - Yes, offline functionality is of utmost importance

14. What types of data should it store? (text notes, images, files, links, etc.)
   - Creating a data storage design doc to explore options

15. Should it have AI/smart features for organizing or suggesting connections?
   - No AI features

16. What is the primary focus of the application interface?
   - Tags are the main focus of the entire application
   - UI should be focused around tags and tag-based organization

17. What type of search functionality should the app have?
   - Tag-based search only (no full-text search)
   - Filter by tags for information retrieval

18. Should the app work offline in the first phase?
   - Yes, offline-first approach for Phase 1
   - No backend required initially

19. What should happen when the user opens the app?
   - App should open directly to "Store Information" page for quick capture
   - After 15 minutes in background, returning should go to "Store Information" page

20. How many pages should the application have?
   - Three core pages: Store Information, Information Page, List Information Page
   - No additional pages needed for MVP

22. How should we handle data synchronization conflicts between devices?
   - No cross-platform syncing initially (put in backlog for future)
   - Focus on single-device offline-first approach

23. Should the app support data export/import features?
   - Yes, but moved to backlog for Phase 2

24. What authentication method should we use?
   - No authentication required for Phase 1 (offline-only)

25. Should we implement data encryption for user privacy?
   - Put data encryption in backlog for future consideration

26. Which Flutter libraries should we use for development?
   - Material Design Components for chips and UI
   - BLoC for state management
   - SQLite for local database
   - NO flutter_tagging_plus (explicitly avoid this package)
   - Use Flutter's built-in components and Material Design