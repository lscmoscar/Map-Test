//
//  FlipsideViewController.h
//  AudioTour
//
//  Created by Brent Shadel on 9/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FlipsideViewControllerDelegate;


@interface FlipsideViewController : UIViewController
{
	id <FlipsideViewControllerDelegate> delegate;
	
	// combine these into an NSMutableArray of buttons?
	IBOutlet UISwitch *category1;
	IBOutlet UISwitch *category2;
	IBOutlet UISwitch *category3;
	IBOutlet UISwitch *category4;
	IBOutlet UISwitch *category5;
	IBOutlet UISwitch *category6;
	IBOutlet UISwitch *category7;
}



@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;
- (IBAction)done:(id)sender;
//- (IBAction)setActiveValue:(id)sender;
@end


@protocol FlipsideViewControllerDelegate
//- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller :(NSMutableArray*)activeCategories;
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller withCategory:(NSString*)activeCategory;
@end

