

#import "ThesisMarchDemoAppDelegate.h"
#import "ThesisMarchDemoViewController.h"
#import <MapKit/MapKit.h>
#import "Annotation.h"


@implementation ThesisMarchDemoAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize locationManager;

#pragma mark -
#pragma mark Application lifecycle


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	[window addSubview:viewController.view]; 
    [window makeKeyAndVisible];
	
	self.locationManager = [[[CLLocationManager alloc] init] autorelease]; //for retain count 
	//adds one to retain count with alloc; then we autorelease to decrement retain count with autorelease 3
	
	if (self.locationManager.locationServicesEnabled)
	{
		//if location services are on
		
		self.locationManager.delegate = self; //sets itself as delegate 
		self.locationManager.distanceFilter = 3; // sets 2000 METERS as minimum poll distance
		// self.locationManager.desiredAccuracy = 1; //determines the radio being used, depending on accuracy
		// more accurate results with GPS, but more polls take longer to populate 
		
		
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest; //Best accuracy, most battery intensive. 
		
		
		[self.locationManager startUpdatingLocation]; //get location, send back to delegate 
		
		
	}
	
	else {
		
		
		viewController.whereabouts.text=@"This application cannot function without Location Services. Please relaunch and enable.";
		//.applicationWillTerminate;
		//exit(0);
	}
	
	
	CLLocation *position = self.locationManager.location;
	if (!position) {
		NSLog(@"Balls");	
	}
	
	CLLocationCoordinate2D where = [position coordinate];
	double x = where.latitude;
	double y = where.longitude;
	int o = position.course; 
	
	NSLog(@"%s %d,%d","You are at coordinates", x, y);
	NSLog(@"%s %i %s", "Your orientation is", o, "degrees."); 
	
	NSString* loc = [NSString stringWithFormat:@"Your orientation is %d, %d", x, y];
	

	viewController.whereabouts.text= loc;
	
	if (loc){
		NSLog(@"Yes, loc is there.");
		
		
	}
	
	
	//----------------------------------------------------------------------------//	
	
	// check if the hardware has a compass
	
	
	
	if ([locationManager headingAvailable] == NO) {
		
		// No compass is available. This application cannot function without a compass, 
		// so a dialog will be displayed and no magnetic data will be measured.
		
		//self.locationManager = nil; 
		
		//This nil kills the mapview and all methods that depend on a CLLocation manager.  Not desired. Would rather display an alert. Commented out for testing on 3G.
		
		UIAlertView *noCompassAlert = [[UIAlertView alloc] initWithTitle:@"Not gonna work here anymore!" 
																 message:@"This device does not have a compass. Orientation tracking will not function properly and this application may not make sense." 
																delegate:nil cancelButtonTitle:@"I'm sorry!" otherButtonTitles:nil];
		noCompassAlert.cancelButtonIndex = 0; 
		[noCompassAlert show];
		[noCompassAlert release];
		
		
	} 
	
	else {
		// heading service configuration
		locationManager.headingFilter = kCLHeadingFilterNone;
		
		// setup delegate callbacks
		locationManager.delegate = self;
		
		// start the compass
		[locationManager startUpdatingHeading];
		
		if (self.locationManager.headingFilter) {
			NSLog(@"There is a heading filter");
		} else {
			NSLog(@"Damn, no heading filter");
		}
		
	}
	
	return YES;
	
}


- (void) locationManager:(CLLocationManager *)locationManager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)location {
	
	// need to account for mapness, meaning greater distance from equator 
	
	/* Refuse updates more than a minute old - Stack Overflow suggestion */
    if (abs([newLocation.timestamp timeIntervalSinceNow]) > 60.0) {
        return;
	}
	
	double size = 10.0;
	double scaling = ABS(cos(2*M_PI*newLocation.coordinate.latitude/360.0)); //this scales views properly
	
	MKCoordinateSpan span; // LOOK no * - C structure
	
	span.latitudeDelta = size / 100.0;
	span.longitudeDelta = size/ (scaling * 100.0);
	
	MKCoordinateRegion region; //structure
	region.span = span; 
	region.center = newLocation.coordinate; 
	
	NSLog(@"Location updated");
	
	[viewController.map setRegion:region animated:YES]; //animates to map
	viewController.map.showsUserLocation = YES; //shows a dot
	
	/*
	 
	 
	 NSMutableArray *coordinates = [[NSMutableArray array] autorelease];
	 
	 Annotation * testAnnotation;
	 testAnnotation.latitude = 40.72;
	 testAnnotation.longitude = -74.04;
	 [testAnnotation setCoordinate:(CLLocationCoordinate2D)testAnnotation.coordinate];
	 NSLog (@"coordintates are %f", testAnnotation.coordinate); 
	 
	 //Use NSMutableArray if annotating more than one location
	 
	 [coordinates addObject:testAnnotation];
	 
	 //Right now is just a single annotation. When using the addAnnotations method, takes an array as argument. 
	 //[viewController.map addAnnotations:coordinates];
	 
	 [viewController.map addAnnotation:testAnnotation];
	 
	 */
}




- (void)locationManager:(CLLocationManager *)locationManager didUpdateHeading:(CLHeading *)heading {
	

	
	[viewController.map setTransform:CGAffineTransformMakeRotation(-1 * heading.magneticHeading * 3.14159 / 180)];
	
	// From stack overflow example. The heading information should be passed by this method, and the transform should be a rotation 
	// that converts from degrees to radians.
	
}




- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */ 
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
	
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	
	[locationManager release];
	[viewController release];
    [window release];
    [super dealloc];
}

@end