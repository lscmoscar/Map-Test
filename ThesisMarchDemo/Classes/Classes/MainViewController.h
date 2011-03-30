//
//  MainViewController.h
//  AudioTour
//
//  Created by Brent Shadel on 9/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


//#import "MainView.h"
#import "FlipsideViewController.h"

#include <UIKit/UIKit.h>
#include <Foundation/Foundation.h>
#include "CoreLocation/CoreLocation.h"
#include "AudioToolbox/AudioToolbox.h"
#include "OpenAL/al.h"
#include "OpenAL/alc.h"
#include <math.h>


//@interface MainViewController : UIViewController <CLLocationManagerDelegate>
@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, CLLocationManagerDelegate>
{
	IBOutlet UIButton *playSound;
	IBOutlet UIButton *stopSounds;
	
	IBOutlet UIButton *toggleButton;
	IBOutlet UIButton *reset;
	
	//IBOutlet UIButton *playLeft;
	//IBOutlet UIButton *playFL;
	//IBOutlet UIButton *playFront;
	//IBOutlet UIButton *playFR;
	//IBOutlet UIButton *playRight;
	//IBOutlet UIButton *playRS;
	//IBOutlet UIButton *playSurround;
	//IBOutlet UIButton *playLS;
	//IBOutlet UIButton *playCenter;
	
	IBOutlet UISlider *angleWidthSlider;
	IBOutlet UILabel *angleWidthSliderValue;
	//IBOutlet UISlider *gainScaleSlider;
	//IBOutlet UITextField *gainScaleSliderValue;
	
	IBOutlet UISlider *gainFloorSlider;
	IBOutlet UILabel *gainFloorSliderValue;
	
	
	IBOutlet UILabel *orientation;
	IBOutlet UILabel *xDir;
	IBOutlet UILabel *yDir;
	//IBOutlet UITextField *sourceOr;
	//IBOutlet UITextField *sourceXField;
	//IBOutlet UITextField *sourceYField;
	
	IBOutlet UILabel *categoryLabel;
	IBOutlet UILabel *closestSourceLabel;
	IBOutlet UILabel *smallestDistanceLabel;
	
	
	
	ALCcontext *mContext;
	ALCdevice *mDevice;
	
	NSMutableArray *bufferStorageArray;
	NSMutableArray *soundLibrary;
	//NSMutableArray *fileNames;
	
	BOOL tracking;
	BOOL soundsLoaded;
	UInt32 bufferSize;
	ALenum format;
	ALsizei freq;
	int numBuffers;
	UInt32 filterSize;
	float defaultGaussianC;
	float defaultGainScale;
	float gaussianC;
	float defaultGainFloor;
	float gainFloor;
	//float angleWidth;
	//float gainScale;
	
		
	
	CLLocationManager *locationManager;
	CLHeading *heading;
	
	
	//IBOutlet UIButton *loadSounds;
	//IBOutlet UIButton *testValues;
	//IBOutlet UITextField *xValue;
	//IBOutlet UITextField *zValue;
}



- (void)initOpenAL;
- (IBAction)loadSounds:(NSString*)activeCategory;
- (AudioFileID)openAudioFile:(NSString *)filePath;
- (UInt32)audioFileSize:(AudioFileID)fileDescriptor;
- (BOOL)loadNextStreamingBufferForSound:(NSMutableDictionary*)record intoBuffer:(NSUInteger)bufferID;
- (void)rotateBufferThread:(NSMutableDictionary*)record;
- (BOOL)rotateBufferForStreamingSound:(NSMutableDictionary*)record;

- (IBAction)togglePlayback:(id)sender;
- (void)playAllSounds;
- (void)pauseAllSounds;
- (IBAction)stopAllSounds;
- (void)playLongSoundFromRecord:(NSMutableDictionary*)record;
- (void)cleanUpOpenAL:(id)sender;

- (IBAction)toggleTracking;

- (IBAction)updateAngleWidth;
- (IBAction)updateGainFloor;

//- (unsigned char)convolve:(unsigned char*)outData forHeading:(float)heading;
//- (unsigned char *)convolve:(unsigned char *)outData withFilter:(unsigned char *)filter forRecord:(NSMutableDictionary*)record;

- (IBAction)showInfo:(id)sender;
- (float)gaussianBellCurve:(float)difference;
- (void)convolve:(unsigned char *)outData withFilter:(unsigned char *)filter;




//- (IBAction)setTestValues;
//- (IBAction)updateOrientation:(id)sender;
//- (IBAction)updateGainScale;


@end
