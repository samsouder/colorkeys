#import "LetterView.h"

@implementation LetterView

@synthesize letterLayer, theLetter, extraLayer, extraInfo;

# pragma mark init/awakeFromNib/dealloc

- (void)awakeFromNib
{
	theLetter = @"Hi.";
	extraInfo = @"Hello there little person! Touch letters and hear sounds!";
	
	CALayer *mainLayer = [CALayer layer];
	mainLayer.name = @"mainLayer";
	mainLayer.frame = NSRectToCGRect(self.frame);
	mainLayer.delegate = self;
	mainLayer.layoutManager = self;
	[self setLayer:mainLayer];
	[self setWantsLayer:YES];
	// call drawing delegate to make background
	[mainLayer setNeedsDisplay];
	
	letterLayer = [CATextLayer layer];
	letterLayer.name = @"letterLayer";
	letterLayer.anchorPoint = CGPointMake(0.5, 0.5);
	letterLayer.string = theLetter;
	letterLayer.font = @"Arial Rounded MT Bold";
	letterLayer.fontSize = mainLayer.frame.size.height/1.5;
	letterLayer.alignmentMode = kCAAlignmentCenter;
	letterLayer.shadowOpacity = 0.75;
	letterLayer.shadowOffset = CGSizeMake(2, -2);
	[mainLayer addSublayer:letterLayer];
	
	extraLayer = [CATextLayer layer];
	extraLayer.name = @"extraLayer";
	extraLayer.anchorPoint = CGPointMake(0.0, 0.0);
	extraLayer.string = extraInfo;
	extraLayer.font = @"Arial Rounded MT Bold";
	extraLayer.fontSize = mainLayer.frame.size.height/50.0;
	extraLayer.alignmentMode = kCAAlignmentLeft;
	[mainLayer addSublayer:extraLayer];
	
	// force layout of layers
	[mainLayer layoutIfNeeded];
	
	// register to see changes to theString and extraInfo
	[self addObserver:self forKeyPath:@"theLetter" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:NULL];
	[self addObserver:self forKeyPath:@"extraInfo" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:NULL];
	
	// force layout of layers on bounds change (w/o changing the background color by redrawing background on bounds change)
	[self setPostsFrameChangedNotifications:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(frameDidChange:) name:NSViewFrameDidChangeNotification object:self];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:self];
	[letterLayer release];
	[theLetter release];
	[extraLayer release];
	[extraInfo release];
	[super dealloc];
}

# pragma mark -
# pragma mark Delegate methods

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)cgContext
{
	// DEBUG
	// NSLog(@"Drawing layer: %@", layer.name);
	
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:cgContext flipped:NO]];
	
	// NSRect theRect = NSRectFromCGRect(CGContextGetClipBoundingBox(cgContext));
	
	if ( [layer.name isEqualToString:@"mainLayer"] )
	{
		// draw a basic gradient for the view background
		float r = (float)(random() % 100) * 0.01;
		float g = (float)(random() % 100) * 0.01;
		float b = (float)(random() % 100) * 0.01;
		NSColor *gradientBottom = [NSColor colorWithCalibratedWhite:0.10 alpha:1.0];
		NSColor *gradientTop = [NSColor colorWithCalibratedRed:r green:g blue:b alpha:1.0];
		
		NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:gradientBottom endingColor:gradientTop];
		[gradient drawInRect:self.bounds angle:90.0];
		[gradient release];
	}
	else
	{
		// draw all other layers normally
        [super drawLayer:layer inContext:cgContext];
	}
	
	[NSGraphicsContext restoreGraphicsState];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	// DEBUG
	// NSLog(@"value updated for keypath: %@ with change: %@", keyPath, [change description]);
	
	if ( [keyPath isEqualToString:@"theLetter"] )
	{
		// update letter refresh the background display
		letterLayer.string = theLetter;
		[[self layer] setNeedsDisplay];
	}
	else if ( [keyPath isEqualToString:@"extraInfo"] )
	{
		// update extra info
		extraLayer.string = extraInfo;
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)frameDidChange:(NSNotification *)notification
{
	[letterLayer layoutSublayers];
}

#pragma mark -
#pragma mark CALayoutManager Protocol Methods

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
	// DEBUG
	// NSLog(@"Laying out sublayers of %@...", layer.name);
	CATextLayer *tempLayer;
	CGRect tempBounds;
	
	// layout letterLayer
	tempLayer = [[layer sublayers] objectAtIndex:0];
	tempBounds = tempLayer.bounds;
	tempLayer.fontSize = [self layer].bounds.size.height/1.5;
	// set the width of the layer to the width of the window so that letters are never cut off by accident
	tempBounds.size = CGSizeMake([self bounds].size.width, [tempLayer preferredFrameSize].height);
	tempLayer.bounds = tempBounds;
	tempLayer.position = CGPointMake(NSMidX([self bounds]), NSMidY([self bounds]));
	
	// layout extraLayer
	tempLayer = [[layer sublayers] objectAtIndex:1];
	tempBounds = tempLayer.bounds;
	tempLayer.fontSize = [self layer].bounds.size.height/50.0;
	tempBounds.size = [tempLayer preferredFrameSize];
	tempLayer.bounds = tempBounds;
	tempLayer.position = CGPointMake(10.0, 10.0);
}

@end
