#import "AppController.h"

#define kSoundsPath @"/Library/Audio/Apple Loops/Apple/iLife Sound Effects/"
#define kSoundDurationLimit 20

@implementation AppController

#pragma mark init & awakeFromNib

- (id)init
{
	self = [super init];
	if (self != nil) {
		// Seed the random number generator for later use
		srandom(time(NULL));
		
		// Start the escapeSequenceCounter
		escapeCounter = 0;
		
		// Start up the sounds array
		theSounds = [[NSMutableArray alloc] initWithArray:[[NSFileManager defaultManager] subpathsAtPath:kSoundsPath]];
		
		// Pick out unwanted sounds
		removeIndexes = [NSMutableIndexSet indexSet];
		for (NSUInteger i=0; i < [theSounds count]; i++)
		{
			// Mark to remove any folder/file _not_ aiff && caf
			if ( [[theSounds objectAtIndex:i] rangeOfString:@"aif" options:NSCaseInsensitiveSearch].location == NSNotFound && [[theSounds objectAtIndex:i] rangeOfString:@"caf" options:NSCaseInsensitiveSearch].location == NSNotFound ) [removeIndexes addIndex:i];
			
			// Mark to remove anything in the Jingle folder
			if ( [[theSounds objectAtIndex:i] rangeOfString:@"jingles" options:NSCaseInsensitiveSearch].location != NSNotFound ) [removeIndexes addIndex:i];
			
			// Mark to remove anything in the Stingers folder
			if ( [[theSounds objectAtIndex:i] rangeOfString:@"stingers" options:NSCaseInsensitiveSearch].location != NSNotFound ) [removeIndexes addIndex:i];
			
			// Mark to remove anything in the Textures folder
			if ( [[theSounds objectAtIndex:i] rangeOfString:@"textures" options:NSCaseInsensitiveSearch].location != NSNotFound ) [removeIndexes addIndex:i];
			
			// Mark to remove anything in the Booms folder
			if ( [[theSounds objectAtIndex:i] rangeOfString:@"booms" options:NSCaseInsensitiveSearch].location != NSNotFound ) [removeIndexes addIndex:i];
			
			// Mark to remove anything in the Sci-Fi
			if ( [[theSounds objectAtIndex:i] rangeOfString:@"sci-fi" options:NSCaseInsensitiveSearch].location != NSNotFound ) [removeIndexes addIndex:i];
			
			// Mark to remove anything with 'boo' in the name
			if ( [[theSounds objectAtIndex:i] rangeOfString:@"boo" options:NSCaseInsensitiveSearch].location != NSNotFound ) [removeIndexes addIndex:i];
		}
		
		// Perform the actual removing of unneeded sound files
		[theSounds removeObjectsAtIndexes:removeIndexes];
		
		// DEBUG
		// NSLog(@"sounds count: %d", [theSounds count]);
		// NSLog(@"sounds: %@", theSounds);
		
		// Start up the keys array for replacing bad keys with later
		theKeys = [[NSArray alloc] initWithObjects:@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z",@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9", nil];
		
		// Start up the display string
		tempString = @"Hi.";
	}
	return self;
}

- (void)awakeFromNib
{
	[mainWindow center];
	
	// Go fullscreen if not already
	if ( ![letterView isInFullScreenMode] ) [self toggleFullscreen:nil];
}

- (void)dealloc
{
	[tempString release];
	[aSound release];
	[aSoundPath release];
	[theSounds release];
	[theKeys release];
	[removeIndexes release];
	[super dealloc];
}

# pragma mark -
# pragma mark Actions

- (IBAction)toggleFullscreen:(id)sender {
	if ( [letterView isInFullScreenMode] )
		[letterView exitFullScreenModeWithOptions:nil];
	else
		[letterView enterFullScreenMode:[NSScreen mainScreen] withOptions:nil];
}

# pragma mark -
# pragma mark Delegate Methods

- (void)sendEvent:(NSEvent *)theEvent
{
	if ( [theEvent type] == NSKeyDown )
	{
		// DEBUG
		// NSLog(@"event: %@", theEvent);
		// NSLog(@"keycode: %i", [theEvent keyCode]);
		// NSLog(@"chars: |%@|", [theEvent characters]);
		// NSLog(@"hex chars: |%x|", [theEvent characters]);
		
		// If user presses 'escape' key, increment the escapeCounter
		if ( [theEvent keyCode] == 53 )
		{
			escapeCounter++;
			
			// If this is the 15th time, exit the program
			if (escapeCounter == 15) [NSApp terminate:nil];
		}
		else if ( [theEvent keyCode] == 3 && [theEvent modifierFlags] & NSCommandKeyMask )
		{
			// Enable fullscreen key (command+f) to raise up
			[super sendEvent:theEvent];
		}
		else if ( ![theEvent isARepeat] )
		{
			// Reset escapeCounter
			escapeCounter = 0;
			
			// Select a random key from theKeys if the given string is undesirable
			if (
				[theEvent keyCode] == 49 ||
				[theEvent keyCode] == 48 ||
				[theEvent keyCode] == 36 ||
				[theEvent keyCode] == 122 ||
				[theEvent keyCode] == 120 ||
				[theEvent keyCode] == 99 ||
				[theEvent keyCode] == 118 ||
				[theEvent keyCode] == 96 ||
				[theEvent keyCode] == 97 ||
				[theEvent keyCode] == 98 ||
				[theEvent keyCode] == 100 ||
				[theEvent keyCode] == 101 ||
				[theEvent keyCode] == 109 ||
				[theEvent keyCode] == 103 ||
				[theEvent keyCode] == 111 ||
				[theEvent keyCode] == 105 ||
				[theEvent keyCode] == 106 ||
				[theEvent keyCode] == 114 ||
				[theEvent keyCode] == 115 ||
				[theEvent keyCode] == 116 ||
				[theEvent keyCode] == 117 ||
				[theEvent keyCode] == 119 ||
				[theEvent keyCode] == 121 ||
				[theEvent keyCode] == 123 ||
				[theEvent keyCode] == 125 ||
				[theEvent keyCode] == 126 ||
				[theEvent keyCode] == 124 ||
				[theEvent keyCode] == 71 ||
				[theEvent keyCode] == 76
				)
				tempString = [theKeys objectAtIndex:(random() % ([theKeys count] -1))];
			else
				tempString = [NSMutableString stringWithString:[theEvent characters]];
			
			// Play random sound when last one is done
			if ( [aSound isPlaying] == NO )
			{
				[aSound release];
				
				NSInteger randomSoundIndex = random() % ([theSounds count] - 1);
				aSoundPath = [theSounds objectAtIndex:randomSoundIndex];
				
				// DEBUG
				// NSLog(@"Random of %d: %d", [theSounds count], randomSoundIndex);
				// NSLog(@"path to sound: %@", aSoundPath);
				
				aSound = [[NSSound alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@%@", kSoundsPath, aSoundPath] byReference:YES];
				
				while ( [aSound duration] > kSoundDurationLimit )
				{
					// DEBUG
					NSLog(@"removing sound from use: %@ ::OVER %d SECONDS::", aSoundPath, kSoundDurationLimit);
					
					// Remove this sound so it isn't tried again later
					[theSounds removeObjectAtIndex:randomSoundIndex];
					
					NSInteger randomSoundIndex = random() % ([theSounds count] - 1);
					aSoundPath = [theSounds objectAtIndex:randomSoundIndex];
					
					// DEBUG
					// NSLog(@"Random of %d: %d", [theSounds count], randomSoundIndex);
					// NSLog(@"path to sound: %@", aSoundPath);
					
					aSound = [[NSSound alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@%@", kSoundsPath, aSoundPath] byReference:YES];
				}
				
				[aSound play];
			}
			
			// Refresh the display with a new color, the key pressed and the name of the sound playing
			[letterView setTheLetter:tempString];
			[letterView setExtraInfo:[aSoundPath stringByDeletingPathExtension]];
		}
	}
	else
	{
		[super sendEvent:theEvent];
	}
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}

@end
