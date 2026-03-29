#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (strong) NSWindow *window;
@property (strong) NSTextView *textView;
@property (strong) NSString *currentFilePath;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    // Window
    NSRect frame = NSMakeRect(0, 0, 800, 600);
    NSUInteger style = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |
                       NSWindowStyleMaskResizable | NSWindowStyleMaskMiniaturizable;
    self.window = [[NSWindow alloc] initWithContentRect:frame
                                              styleMask:style
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
    [self.window setTitle:@"Untitled"];
    [self.window center];

    // Scroll view
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:
                                [[self.window contentView] bounds]];
    [scrollView setHasVerticalScroller:YES];
    [scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

    // Text view
    NSSize contentSize = [scrollView contentSize];
    self.textView = [[NSTextView alloc] initWithFrame:
                     NSMakeRect(0, 0, contentSize.width, contentSize.height)];
    [self.textView setMinSize:NSMakeSize(0, contentSize.height)];
    [self.textView setMaxSize:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)];
    [self.textView setVerticallyResizable:YES];
    [self.textView setHorizontallyResizable:NO];
    [self.textView setAutoresizingMask:NSViewWidthSizable];
    [[self.textView textContainer] setWidthTracksTextView:YES];
    [self.textView setFont:[NSFont monospacedSystemFontOfSize:14
                                                       weight:NSFontWeightRegular]];
    [self.textView setAllowsUndo:YES];

    [scrollView setDocumentView:self.textView];
    [self.window setContentView:scrollView];

    // Menu bar
    [self setupMenuBar];

    // Show window and activate
    [self.window makeKeyAndOrderFront:nil];
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
    [self.textView setString:@""];
    self.currentFilePath = nil;
    [self.window setTitle:@"Untitled"];
}

- (void)openDocument:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel beginSheetModalForWindow:self.window
                  completionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            NSError *error = nil;
            NSString *contents = [NSString stringWithContentsOfURL:panel.URL
                                                          encoding:NSUTF8StringEncoding
                                                             error:&error];
            if (contents) {
                [self.textView setString:contents];
                self.currentFilePath = [panel.URL path];
                [self.window setTitle:[panel.URL lastPathComponent]];
            }
        }
    }];
}

- (void)saveDocument:(id)sender {
    if (self.currentFilePath) {
        NSError *error = nil;
        [self.textView.string writeToFile:self.currentFilePath
                               atomically:YES
                                 encoding:NSUTF8StringEncoding
                                    error:&error];
    } else {
        [self saveDocumentAs:sender];
    }
}

- (void)saveDocumentAs:(id)sender {
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel beginSheetModalForWindow:self.window
                  completionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            NSError *error = nil;
            [self.textView.string writeToURL:panel.URL
                                  atomically:YES
                                    encoding:NSUTF8StringEncoding
                                       error:&error];
            self.currentFilePath = [panel.URL path];
            [self.window setTitle:[panel.URL lastPathComponent]];
        }
    }];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
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
