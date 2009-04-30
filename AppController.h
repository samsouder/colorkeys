#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "LetterView.h"

@interface AppController : NSApplication {
	IBOutlet NSWindow *mainWindow;
	IBOutlet LetterView *letterView;
	
	NSMutableString *tempString;
	NSSound *aSound;
	NSMutableString *aSoundPath;
	NSMutableArray *theSounds;
	NSMutableIndexSet *removeIndexes;
	NSArray *theKeys;
	NSUInteger escapeCounter;
}

- (IBAction)toggleFullscreen:(id)sender;

@end
