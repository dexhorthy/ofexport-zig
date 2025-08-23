# OFExport Zig Port - Implementation Plan

## Overview
Porting OmniFocus export tool from TypeScript/JavaScript to Zig.

## Source Repository Analysis
- **Main Language**: TypeScript/JavaScript with Bun runtime
- **Key Dependencies**: 
  - @boundaryml/baml (AI/ML integrations)
  - commander (CLI framework)
  - zod (schema validation)
- **Core Script**: `script3.js` - JXA bridge to OmniFocus
- **Build System**: Bun with TypeScript compilation

## Core Components Identified

### 1. AppleScript Bridge (Priority 1)
- **Source**: `script3.js` - JXA bridge to OmniFocus
- **Target**: Create FFI bindings to AppleScript/osascript
- **Key Functionality**:
  - Get all tasks via `doc.flattenedTasks`
  - Filter incomplete/non-deferred tasks
  - Export as JSON
  - Properties to extract: name, note, dates, flags, tags, project info

### 2. Task Data Model (Priority 2)
- Define Zig structs for OmniFocus data:
  - Task (id, name, note, dates, completion status, flags)
  - Project (name, status)
  - Tag (name)
  - Date handling (ISO8601 format)

### 3. Export Formats (Priority 3)
- JSON export (primary)
- Support export modes:
  - complete: All tasks
  - inbox: Inbox tasks only
  - filtered: Active, non-deferred tasks

### 4. CLI Interface (Priority 4)
- Command parsing
- Export modes (complete/inbox/filtered)
- Output redirection support

## Implementation Order

### Phase 1: Core Foundation
1. ✅ Setup Zig project structure (build.zig)
2. Create AppleScript FFI bridge module
3. Basic task export to JSON

### Phase 2: Data Processing
1. Task filtering logic
2. Date handling utilities
3. Project/tag relationships

### Phase 3: CLI & Features
1. Command-line interface
2. Multiple export modes
3. Configuration handling

### Phase 4: Testing (20% effort)
1. Unit tests for data structures
2. Integration tests for AppleScript bridge
3. End-to-end export tests

## Technical Decisions

- Use Zig's built-in JSON serialization (std.json)
- Execute osascript via std.process.Child
- Single binary output
- Cross-compilation support for macOS targets
- No external dependencies (pure Zig)

## File Structure
```
ofexport-zig/
├── build.zig           # Build configuration
├── src/
│   ├── main.zig       # CLI entry point
│   ├── applescript.zig # AppleScript bridge
│   ├── models.zig     # Data structures
│   ├── export.zig     # Export logic
│   └── json.zig       # JSON serialization
├── test/
│   ├── applescript_test.zig
│   ├── models_test.zig
│   └── export_test.zig
└── agent/
    └── PORTING_PLAN.md # This file
```

## Next Steps
1. Initialize Zig project with build.zig
2. Create basic AppleScript bridge module
3. Port script3.js functionality to Zig