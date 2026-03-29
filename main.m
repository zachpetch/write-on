#import <Cocoa/Cocoa.h>

// Each document window holds its own text view and file path
@interface DocumentWindow : NSWindow
@property (strong) NSTextView *textView;
@property (strong) NSString *filePath;
@end

@implementation DocumentWindow
@end

@interface AppDelegate : NSObject <NSApplicationDelegate>
@end

@implementation AppDelegate

- (DocumentWindow *)createDocumentWindow {
    NSRect frame = NSMakeRect(0, 0, 800, 600);
    NSUInteger style = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |
                       NSWindowStyleMaskResizable | NSWindowStyleMaskMiniaturizable;
    DocumentWindow *window = [[DocumentWindow alloc] initWithContentRect:frame
                                                              styleMask:style
                                                                backing:NSBackingStoreBuffered
                                                                  defer:NO];
    [window setTitle:@"Untitled"];
    [window setReleasedWhenClosed:NO];

    // Cascade from existing windows
    static NSPoint nextTopLeft = {0, 0};
    nextTopLeft = [window cascadeTopLeftFromPoint:nextTopLeft];

    // Scroll view
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:
                                [[window contentView] bounds]];
    [scrollView setHasVerticalScroller:YES];
    [scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

    // Text view
    NSSize contentSize = [scrollView contentSize];
    NSTextView *textView = [[NSTextView alloc] initWithFrame:
                            NSMakeRect(0, 0, contentSize.width, contentSize.height)];
    [textView setMinSize:NSMakeSize(0, contentSize.height)];
    [textView setMaxSize:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)];
    [textView setVerticallyResizable:YES];
    [textView setHorizontallyResizable:NO];
    [textView setAutoresizingMask:NSViewWidthSizable];
    [[textView textContainer] setWidthTracksTextView:YES];
    [textView setFont:[NSFont monospacedSystemFontOfSize:14
                                                  weight:NSFontWeightRegular]];
    [textView setAllowsUndo:YES];

    [scrollView setDocumentView:textView];
    [window setContentView:scrollView];
    window.textView = textView;

    return window;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [self setupMenuBar];

    DocumentWindow *window = [self createDocumentWindow];
    [window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)setupMenuBar {
    NSMenu *mainMenu = [[NSMenu alloc] init];

    // App menu
    NSMenuItem *appMenuItem = [[NSMenuItem alloc] init];
    NSMenu *appMenu = [[NSMenu alloc] init];
    [appMenu addItemWithTitle:@"Quit write-on"
                       action:@selector(terminate:)
                keyEquivalent:@"q"];
    [appMenuItem setSubmenu:appMenu];
    [mainMenu addItem:appMenuItem];

    // File menu
    NSMenuItem *fileMenuItem = [[NSMenuItem alloc] init];
    NSMenu *fileMenu = [[NSMenu alloc] initWithTitle:@"File"];
    [fileMenu addItemWithTitle:@"New" action:@selector(newDocument:) keyEquivalent:@"n"];
    [fileMenu addItemWithTitle:@"Open..." action:@selector(openDocument:) keyEquivalent:@"o"];
    [fileMenu addItem:[NSMenuItem separatorItem]];
    [fileMenu addItemWithTitle:@"Close" action:@selector(performClose:) keyEquivalent:@"w"];
    [fileMenu addItem:[NSMenuItem separatorItem]];
    [fileMenu addItemWithTitle:@"Save" action:@selector(saveDocument:) keyEquivalent:@"s"];
    NSMenuItem *saveAsItem = [fileMenu addItemWithTitle:@"Save As..."
                                                action:@selector(saveDocumentAs:)
                                         keyEquivalent:@"S"];
    [saveAsItem setKeyEquivalentModifierMask:NSEventModifierFlagCommand |
                                             NSEventModifierFlagShift];
    [fileMenuItem setSubmenu:fileMenu];
    [mainMenu addItem:fileMenuItem];

    // Edit menu
    NSMenuItem *editMenuItem = [[NSMenuItem alloc] init];
    NSMenu *editMenu = [[NSMenu alloc] initWithTitle:@"Edit"];
    [editMenu addItemWithTitle:@"Undo" action:@selector(undo:) keyEquivalent:@"z"];
    NSMenuItem *redoItem = [editMenu addItemWithTitle:@"Redo"
                                               action:@selector(redo:)
                                        keyEquivalent:@"Z"];
    [redoItem setKeyEquivalentModifierMask:NSEventModifierFlagCommand |
                                           NSEventModifierFlagShift];
    [editMenu addItem:[NSMenuItem separatorItem]];
    [editMenu addItemWithTitle:@"Cut" action:@selector(cut:) keyEquivalent:@"x"];
    [editMenu addItemWithTitle:@"Copy" action:@selector(copy:) keyEquivalent:@"c"];
    [editMenu addItemWithTitle:@"Paste" action:@selector(paste:) keyEquivalent:@"v"];
    [editMenu addItemWithTitle:@"Select All" action:@selector(selectAll:) keyEquivalent:@"a"];
    [editMenuItem setSubmenu:editMenu];
    [mainMenu addItem:editMenuItem];

    [NSApp setMainMenu:mainMenu];
}

- (void)newDocument:(id)sender {
    DocumentWindow *window = [self createDocumentWindow];
    [window makeKeyAndOrderFront:nil];
}

- (void)openDocument:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel beginWithCompletionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            NSError *error = nil;
            NSString *contents = [NSString stringWithContentsOfURL:panel.URL
                                                          encoding:NSUTF8StringEncoding
                                                             error:&error];
            if (contents) {
                DocumentWindow *window = [self createDocumentWindow];
                [window.textView setString:contents];
                window.filePath = [panel.URL path];
                [window setTitle:[panel.URL lastPathComponent]];
                [window makeKeyAndOrderFront:nil];
            }
        }
    }];
}

- (void)saveDocument:(id)sender {
    DocumentWindow *window = (DocumentWindow *)[NSApp keyWindow];
    if (![window isKindOfClass:[DocumentWindow class]]) return;

    if (window.filePath) {
        NSError *error = nil;
        [window.textView.string writeToFile:window.filePath
                                 atomically:YES
                                   encoding:NSUTF8StringEncoding
                                      error:&error];
    } else {
        [self saveDocumentAs:sender];
    }
}

- (void)saveDocumentAs:(id)sender {
    DocumentWindow *window = (DocumentWindow *)[NSApp keyWindow];
    if (![window isKindOfClass:[DocumentWindow class]]) return;

    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel beginSheetModalForWindow:window
                  completionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            NSError *error = nil;
            [window.textView.string writeToURL:panel.URL
                                    atomically:YES
                                      encoding:NSUTF8StringEncoding
                                         error:&error];
            window.filePath = [panel.URL path];
            [window setTitle:[panel.URL lastPathComponent]];
        }
    }];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return NO;
}

@end

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        [app setActivationPolicy:NSApplicationActivationPolicyRegular];

        AppDelegate *delegate = [[AppDelegate alloc] init];
        [app setDelegate:delegate];
        [app run];
    }
    return 0;
}
