# Changelog

All notable changes to MiniNote will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-03

### Added
- Hot corner detection in bottom-right corner
- Markdown editor with live rendering
- Support for headers (H1, H2, H3)
- Support for bullet lists
- Support for task lists with interactive checkboxes
- Support for bold, italic, and inline code
- Automatic note persistence to disk
- Debounced auto-save (500ms)
- Accessibility permissions handling
- Native macOS integration (no Dock icon)
- Clean, minimal UI following macOS design guidelines

### Features
- **Smart markdown editing**: Type markdown, see it rendered in real-time
- **Interactive tasks**: Click checkboxes to toggle task completion
- **Persistent storage**: Notes saved to `~/Library/Application Support/MiniNote/`
- **Hot corner toggle**: Show/hide note window by moving mouse to bottom-right

### Technical
- Built with Swift 5.9+ and SwiftUI
- MVVM architecture with Combine
- Custom NSTextView-based markdown editor
- Timer-based hot corner detection (0.1s interval)
- Memory-efficient with proper lifecycle management

### Documentation
- Comprehensive README with installation and usage instructions
- ARCHITECTURE.md explaining design decisions and patterns
- DEVELOPMENT.md with development workflow and debugging tips
- Inline code documentation

### Build System
- Swift Package Manager setup
- Makefile with convenient commands
- Support for debug and release builds
- Installation script for /Applications

## [Unreleased]

### Planned Features
- [ ] Multiple notes support
- [ ] iCloud sync
- [ ] Custom themes (light/dark)
- [ ] Configurable hot corners
- [ ] Keyboard shortcuts
- [ ] Export to PDF/HTML
- [ ] More markdown features (tables, quotes, images)
- [ ] Search within notes
- [ ] Tags and categories
- [ ] Menu bar icon for quick access

### Technical Improvements
- [ ] Unit tests for core logic
- [ ] UI tests for interactions
- [ ] Performance profiling and optimization
- [ ] SwiftLint integration
- [ ] CI/CD pipeline
- [ ] App Store distribution
