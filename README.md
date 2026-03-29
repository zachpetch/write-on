# write-on

A minimal plain-text editor for macOS, built with native Cocoa and no external dependencies.

## Features

- Multi-window editing with independent documents
- Open files (Cmd+O), save (Cmd+S), save as (Shift+Cmd+S)
- New window (Cmd+N), close window (Cmd+W), quit (Cmd+Q)
- Undo/redo, cut/copy/paste, select all
- Monospace font, size 14

## Requirements

- macOS 10.15+
- Xcode Command Line Tools (`xcode-select --install`)

## Build and Run

```
make
./write-on
```

To build as a macOS .app bundle (provides dock icon persistence and file type associations):

```
make app
open write-on.app
```

## Usage

Launch the editor and start typing. Each document opens in its own window.

### Keyboard Shortcuts

| Shortcut | Action |
|---|---|
| Cmd+N | New document (opens a new window) |
| Cmd+O | Open a file (opens in a new window) |
| Cmd+S | Save the current document |
| Shift+Cmd+S | Save as a new file |
| Cmd+W | Close the current window |
| Cmd+Q | Quit the application |
| Cmd+Z | Undo |
| Shift+Cmd+Z | Redo |
| Cmd+X | Cut |
| Cmd+C | Copy |
| Cmd+V | Paste |
| Cmd+A | Select all |

The application stays open after the last window is closed, so you can use Cmd+N or Cmd+O to continue working.

## Limitations

- Only reads and writes UTF-8 encoded files
- No warning when closing a window with unsaved changes
- No drag-and-drop file opening
- No recent files list
- No printing support
- The .app bundle is not code-signed (macOS may show a security warning on first launch)

## Possible Improvements

- Unsaved changes indicator in the title bar and a confirmation dialog on close
- Line and column number display in a status bar
- Find and replace (Cmd+F, Cmd+G)
- Go to line number (Cmd+L)
- Tab size and indentation settings
- Word count display
- Drag-and-drop to open files
- Open files via command-line arguments (`./write-on file.txt`)
- Remember window size and position between sessions
- Configurable font and font size
- Dark mode / light mode toggle
- Auto-save and crash recovery
- Encoding detection for non-UTF-8 files
- Custom app icon (.icns)
- Code signing for distribution
- Print support (Cmd+P)
- Recent files menu (File > Open Recent)
- Tab or sidebar interface for multiple documents in one window
