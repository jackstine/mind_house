# Answered Questions

## Overview
This file contains questions asked by the user that were not previously in the Q&A.md file, along with their researched answers.

## Questions and Answers

### Can we use SQLite on Android or iOS applications?

**Answer**: Yes, absolutely. SQLite is fully supported on both Android and iOS platforms.

**Key Points**:
- **Native Support**: SQLite has been embedded with iOS and Android since the beginning
- **Cross-Platform**: SQLite is the most used database engine in the world and is built into all mobile phones
- **File Compatibility**: SQLite databases are simple files that can be copied between Android and iOS platforms
- **Performance**: Well-optimized for mobile use with low memory footprint

**Platform-Specific Details**:

**Android**:
- Built-in SQLite support through Android SDK
- Google recommends Jetpack Room library for optimal integration
- Best practices documentation available from Android Developers
- Excellent performance with proper optimization

**iOS**:
- Native SQLite support through iOS SDK
- Can use Core Data (which uses SQLite under the hood) or direct SQLite
- Performance can be optimized using prepared statements
- Strong integration with iOS development patterns

**2025 Advantages**:
- Enhanced query optimizer
- Improved concurrency handling
- New data types and security enhancements
- Maintained low memory footprint
- Write-Ahead Logging (WAL) for better performance

**Best Practices for Mobile**:
- Use indexes for frequently queried columns
- Minimize data retrieval (read fewer rows/columns)
- Push computations to SQLite engine rather than application
- Enable Write-Ahead Logging for better concurrent access
- Use prepared statements for repeated queries

**Sources**:
- [SQLite Official Documentation](https://www.sqlite.org/)
- [Android SQLite Best Practices](https://developer.android.com/topic/performance/sqlite-performance-best-practices)
- [Mobile Databases Guide](https://greenrobot.org/news/mobile-databases-sqlite-alternatives-and-nosql-for-android-and-ios/)
- [SQLite Performance Benchmarks 2025](https://toxigon.com/sqlite-performance-benchmarks-2025-edition)

**Conclusion**: SQLite is an excellent choice for our offline-first Mind Map application, providing reliable, fast local storage that works consistently across both Android and iOS platforms.