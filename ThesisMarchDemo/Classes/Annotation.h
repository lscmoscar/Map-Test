//
//  Annotation.h
//  thesis_test
//
//  Created by Russell de Moose on 2/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface Annotation : NSObject <MKAnnotation> {

	float latitude;
	float longitude;
	CLLocationCoordinate2D coordinate;
	
}

@property (nonatomic) float latitude;
@property (nonatomic) float longitude;

//2-axis coordinates, as only property of MKAnnotation.
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (NSString *)title;
- (CLLocationCoordinate2D)setcoordinate;

@end
