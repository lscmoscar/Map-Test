//
//  Annotation.m
//  thesis_test
//
//  Created by Russell de Moose on 2/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Annotation.h"


@implementation Annotation

@synthesize latitude, longitude, coordinate;

- (CLLocationCoordinate2D)setcoordinate
{
	CLLocationCoordinate2D coord = {self.latitude, self.longitude};
	return coord;
}

- (NSString *)title

{
	NSString * thisTitle;
	return thisTitle;
}


@end
