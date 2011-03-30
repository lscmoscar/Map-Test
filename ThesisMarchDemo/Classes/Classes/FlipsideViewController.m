//
//  FlipsideViewController.m
//  AudioTour
//
//  Created by Brent Shadel on 9/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FlipsideViewController.h"


@implementation FlipsideViewController

@synthesize delegate;

- (void)viewDidLoad
{
	//NSLog(@"flipsideView did load");
	
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
}


- (IBAction)done:(id)sender
{
	NSString *activeCategory;
	
	if (category1.on)
		activeCategory = @"categories/Tour";
	else if (category2.on)
		activeCategory = @"categories/Demo";
	else
		activeCategory = @"categories";
	
	
	[self.delegate flipsideViewControllerDidFinish:self withCategory:activeCategory];
}


- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

/*
- (IBAction)setActiveValue:(id)sender
{
	NSLog(@"slider toggled (called from flipsideView)");
}
*/

- (void)dealloc
{
    [super dealloc];
}


@end
