# OFExport Zig Port - Implementation Plan

## Overview
Porting OmniFocus export tool from TypeScript/JavaScript to Zig.

## Core Components Identified

### 1. AppleScript Bridge (Priority 1)
- **Source**: `script3.js` - JXA bridge to OmniFocus
- **Target**: Create FFI bindings to AppleScript/osascript
- **Key Functionality**:
  - Get tasks from OmniFocus
  - Filter incomplete/non-deferred tasks
  - Export as JSON

### 2. Task Data Model (Priority 2)
- Define Zig structs for OmniFocus data:
  - Task
  - Project
  - Tag
  - Date handling

### 3. Export Formats (Priority 3)
- JSON export (primary)
- Additional formats from original codebase

### 4. CLI Interface (Priority 4)
- Command parsing
- Export modes (complete/inbox/filtered)

## Implementation Order

### Phase 1: Core Foundation
1. Setup Zig project structure
2. Create AppleScript FFI bridge
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

- Use Zig's built-in JSON serialization
- FFI to system osascript command
- Single binary output
- Cross-compilation support for macOS targets

## Next Steps
1. Initialize Zig project with build.zig
2. Create basic AppleScript bridge module
3. Port script3.js functionality