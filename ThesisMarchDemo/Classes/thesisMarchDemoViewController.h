//Russell de Moose
//March Thesis Demo


#include <UIKit/UIKit.h>
#include <Foundation/Foundation.h>
#include "CoreLocation/CoreLocation.h"
#include "AudioToolbox/AudioToolbox.h"
#include "OpenAL/al.h"
#include "OpenAL/alc.h"
#include <math.h>
#import "ThesisMarchDemoAppDelegate.h"
#import "Annotation.h"
#import <MapKit/MapKit.h>



@interface ThesisMarchDemoViewController : UIViewController <MKMapViewDelegate, UIAlertViewDelegate>


{	
	// Map objects 
	
	MKMapView *map;	  
	IBOutlet UITextView *whereabouts; 
	
	// OpenAL and audio objects
	
	ALCcontext *mContext;
	ALCdevice *mDevice;
	
	NSMutableArray *bufferStorageArray;
	NSMutableArray *soundLibrary;
	
	
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
	
}

@property (nonatomic, retain) IBOutlet MKMapView *map;
@property (readonly, nonatomic) IBOutlet UITextView *whereabouts;



// OpenAL and audio methods

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


@end
