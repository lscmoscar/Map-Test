//
//  MainViewController.m
//  AudioTour
//
//  Created by Brent Shadel on 9/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import "MainViewController.h"
//#import "MainView.h"


@implementation MainViewController



- (void)awakeFromNib
{
	// boolean value to keep track of whether we are tracking or not (to test popup)
	tracking = NO;
	soundsLoaded = NO;
	
	// change positionSliderSurround to a vertical slider
	//positionSliderSurround.transform = CGAffineTransformRotate(positionSliderSurround.transform, 270.0/180*M_PI);
	
	// initialize CLLocationManager, set delegate and accuracy
	locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	heading = [[CLHeading alloc] init];
	
	// initialize soundLibrary
	// this NSMutableDictionary holds records, allowing for the lookup of each large file
	soundLibrary = [[NSMutableArray alloc] init];
	
	// set buffer size
	bufferSize = 44100;
	//bufferSize = 4096;
	// set numBuffers
	numBuffers = 3;
	//numBuffers = 3;
	// set filter size
	filterSize = 1;
	
	gaussianC = 0.2;
	
	
	// when format is set to mono, the freq has to be 2x 44100 = 88200 Hz
	// when set to stereo, 44100 Hz is correct
	// how is the format 16 bit when mData is an array of 8 bit UInts??
	format = AL_FORMAT_MONO16;
	freq = 44100;
	
	// set angle width (for gain scaling of flashlight model)
	defaultGaussianC = 0.2;
	defaultGainScale = 1;
	
	gainFloor = 0;
	defaultGainFloor = 0;
	
	//angleWidthSlider.value = defaultAngleWidth;
	//gainScaleSlider.value = defaultGainScale;
	//angleWidthSliderValue = [NSString stringWithFormat:@"%.02f",defaultAngleWidth];
	//gainScaleSliderValue = [NSString stringWithFormat:@"%.02f",defaultGainScale];
	
	

	/**
	// set initial values for listener object (may be unnecessary)
	ALfloat listenerPos[] = {0.0, 0.0, 0.0};
	ALfloat listenerVel[] = {0.0, 0.0, 0.0};
	// this default orientation is for a listener pointed straight ahead
	ALfloat listenerOri[] = {0.0, 0.0, -1.0, 0.0, 1.0, 0.0};
	
	alListenerfv(AL_ORIENTATION, listenerOri);
	alListenerfv(AL_VELOCITY, listenerVel);
	alListenerfv(AL_POSITION, listenerPos);
	 **/
	
	/**
	// initialize fileNames
	// this NSMutableArray holds the file names of each sound to play
	fileNames = [[NSMutableArray alloc] init];
	
	// find files and populate fileNames
	
	NSString* fileName1 = [[NSBundle mainBundle] pathForResource:@"allthat2" ofType:@"caf"];
	NSString* fileName2 = [[NSBundle mainBundle] pathForResource:@"1618" ofType:@"caf"];
	NSString* fileName3 = [[NSBundle mainBundle] pathForResource:@"anhkmech" ofType:@"caf"];
	NSString* fileName4 = [[NSBundle mainBundle] pathForResource:@"cu" ofType:@"caf"];
	NSString* fileName5 = [[NSBundle mainBundle] pathForResource:@"dynsym" ofType:@"caf"];
	NSString* fileName6 = [[NSBundle mainBundle] pathForResource:@"gmk" ofType:@"caf"];
	NSString* fileName7 = [[NSBundle mainBundle] pathForResource:@"intloc" ofType:@"caf"];
		
	[fileNames addObject:fileName1];
	[fileNames addObject:fileName2];
	[fileNames addObject:fileName3];
	[fileNames addObject:fileName4];
	[fileNames addObject:fileName5];
	[fileNames addObject:fileName6];
	[fileNames addObject:fileName7];
	**/
	
	
	// code used for testing on xcode simulator
	/**
	 [fileNames addObject:@"/Users/brentshadel/Desktop/dynsym.caf"];
	 [fileNames addObject:@"/Users/brentshadel/Desktop/intloc.caf"];
	 [fileNames addObject:@"/Users/brentshadel/Desktop/1618.caf"];
	 [fileNames addObject:@"/Users/brentshadel/Desktop/cu.caf"];
	 [fileNames addObject:@"/Users/brentshadel/Desktop/anhkmech.caf"];
	 [fileNames addObject:@"/Users/brentshadel/Desktop/gmk.caf"];
	 **/
	
	
	// initialize OpenAL
	[self initOpenAL];
}


// function to initialize OpenAL
// takes no arguments
// returns no arguments
-(void)initOpenAL
{
	// create a device and context, set context for device
	mDevice = alcOpenDevice(NULL);
	if (mDevice)
	{
		mContext = alcCreateContext(mDevice,NULL);
		alcMakeContextCurrent(mContext);
	}
	
	NSLog(@"openAL initialized");
}



// function to load all sounds
// takes NSString which is the name of the category to load sounds from
-(IBAction)loadSounds:(NSString*)activeCategory
{
	NSLog(@"loading sounds for category: %@",activeCategory);
	NSArray *fileNames = [[NSBundle mainBundle] pathsForResourcesOfType:@"caf" inDirectory:activeCategory];
	NSLog(@"fileNames initialized");
	
	if (!soundsLoaded)
	{
		for (NSString *fileName in fileNames)
		{
			NSLog(@"fileName: %@",fileName);
			NSString *shortFileName = [fileName lastPathComponent];
			NSLog(@"shortFileName = %@",shortFileName);
			
			NSString *soundFilePosition = [NSString stringWithFormat:@"%@.txt",[fileName stringByDeletingPathExtension]];
			NSString *contents = [[NSString alloc] initWithContentsOfFile:soundFilePosition];
			NSLog(@"soundFilePosition = %@",contents);
			
			NSArray *chunks = [contents componentsSeparatedByString:@":"];
			float z = [[chunks objectAtIndex:0] floatValue] * -1;
			float y = [[chunks objectAtIndex:1] floatValue];
			float x = [[chunks objectAtIndex:2] floatValue];
			ALfloat defaultSourcePosition[] = {x, y, z};
						
			// open audio file
			AudioFileID fileID = [self openAudioFile:fileName];
			// get file size
			UInt32 fileSize = [self audioFileSize:fileID];
			// initialize bufferIndex to 0
			UInt32 bufferIndex = 0;
			// initialize loops to YES
			BOOL loops = YES;
			
			
			
			
			// create record to hold the sound file's relevant information
			NSMutableDictionary *record = [NSMutableDictionary dictionary];
			// add record to soundLibrary
			[soundLibrary addObject:record];
			
			// set initial values for record
			[record setObject:fileName forKey:@"fileName"];
			[record setObject:[NSNumber numberWithUnsignedInteger:fileSize] forKey:@"fileSize"];
			[record setObject:[NSNumber numberWithUnsignedInteger:bufferIndex] forKey:@"bufferIndex"];
			[record setObject:[NSNumber numberWithBool:loops] forKey:@"loops"];
			[record setObject:[NSNumber numberWithFloat:x] forKey:@"defaultSourceX"];
			[record setObject:[NSNumber numberWithFloat:z] forKey:@"defaultSourceY"];
			
			
			// generate buffers for this record
			// the number of buffers indicates how far ahead the algorithm will look
			NSMutableArray *bufferList = [NSMutableArray array];
			int i;
			for (i = 0; i < numBuffers; i++)
			{
				NSUInteger bufferID;
				//NSLog(@"bufferID: %@",[NSNumber numberWithUnsignedInteger:bufferID]);
				alGenBuffers(1, &bufferID);
				[bufferList addObject:[NSNumber numberWithUnsignedInteger:bufferID]];
			}
			// add bufferList to dictionary
			[record setObject:bufferList forKey:@"bufferList"];
			// close file
			AudioFileClose(fileID);
			
			
			// generate a source for this record
			NSLog(@"generating sources");
			NSUInteger sourceID;
			alGenSources(1, &sourceID);
			
			// initialize default source settings
			alSourcef(sourceID, AL_PITCH, 1.0f);
			alSourcef(sourceID, AL_GAIN, 1.0f);
			alSourcei(sourceID, AL_LOOPING, AL_FALSE);
			
			alSourcefv(sourceID, AL_POSITION, defaultSourcePosition);
			
			[record setObject:[NSNumber numberWithUnsignedInteger:sourceID] forKey:@"sourceID"];
			
			
			for (NSNumber *bufferNumber in bufferList)
			{
				NSUInteger bufferID = [bufferNumber unsignedIntegerValue];
				
				[self loadNextStreamingBufferForSound:record intoBuffer:bufferID];
				
				alSourceQueueBuffers(sourceID, 1, &bufferID);
			} // end for (NSNumber *bufferNumber in bufferList)
		} // end for (NSString *fileName in fileNames)
		
		soundsLoaded = YES;
	} // end if (!soundsLoaded)	
}



-(AudioFileID)openAudioFile:(NSString *)filePath
{
	AudioFileID outAFID;
	
	NSURL *afUrl = [NSURL fileURLWithPath:filePath];
	
#if TARGET_OS_IPHONE
	OSStatus result = AudioFileOpenURL((CFURLRef)afUrl, kAudioFileReadPermission, 0, &outAFID);
#else
	OSStatus result = AudioFileOpenURL((CFURLRef)afUrl, fsRdPerm, 0, &outAFID);
#endif
	if (result != 0) NSLog(@"cannot open file: %@",filePath);
	return outAFID;
}



-(UInt32)audioFileSize:(AudioFileID)fileDescriptor
{
	UInt64 outDataSize = 0;
	UInt32 thePropSize = sizeof(UInt64);
	OSStatus result = AudioFileGetProperty(fileDescriptor, kAudioFilePropertyAudioDataByteCount, &thePropSize, &outDataSize);
	if(result != 0) NSLog(@"cannot find file size");
	return (UInt32)outDataSize;
}



// play/pause toggle function
-(IBAction)togglePlayback:(id)sender
{
	UIButton *senderButton = (UIButton *)sender;
	NSString *senderTitle = senderButton.currentTitle;
	
	if ([senderTitle isEqualToString:@"Play"])
	{
		// if no sound is loaded, cannot start playback
		if (!soundsLoaded)
		{
			NSLog(@"no sounds are loaded");
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@"Error" message:@"No Sounds Loaded" delegate:self
								  cancelButtonTitle:@"Return" otherButtonTitles:nil];
			[alert show];
			[alert release];
			return;
		}
		
		[sender setTitle:@"Pause" forState:UIControlStateNormal];
		[self playAllSounds];
	}
	else if ([senderTitle isEqualToString:@"Pause"])
	{
		[sender setTitle:@"Play" forState:UIControlStateNormal];
		[self pauseAllSounds];
	}
}
	

-(void)playAllSounds
{
	for (NSMutableDictionary *record in soundLibrary)
	{
		//NSLog(@"bufferIndex: %@",[record objectForKey:@"bufferIndex"]);
		[self playLongSoundFromRecord:record];
	}
}



- (void)pauseAllSounds
{
	for (NSMutableDictionary *record in soundLibrary)
	{
		NSUInteger sourceID = [[record objectForKey:@"sourceID"] unsignedIntegerValue];
		alSourcePause(sourceID);
	}
}



- (IBAction)stopAllSounds
{
	NSLog(@"stopAllSounds called");
	for (NSMutableDictionary *record in soundLibrary)
	{
		NSUInteger sourceID = [[record objectForKey:@"sourceID"] unsignedIntegerValue];
		alSourceStop(sourceID);
		alSourceRewind(sourceID);
	}
	[playSound setTitle:@"Play" forState:UIControlStateNormal];
	
	// this needs to reset the buffers too
}



-(void)playLongSoundFromRecord:(NSMutableDictionary*)record
{
	NSUInteger sourceID = [[record objectForKey:@"sourceID"] unsignedIntegerValue];
	alSourcePlay(sourceID);
	[NSThread detachNewThreadSelector:@selector(rotateBufferThread:) toTarget:self withObject:record];
}



-(BOOL)loadNextStreamingBufferForSound:(NSMutableDictionary*)record intoBuffer:(NSUInteger)bufferID
{
	UInt32 tempBufferSize = bufferSize;
	//NSLog(@"entered loadNextStreamingBufferForSound");
	
	//NSMutableDictionary *record = [soundLibrary objectForKey:soundKey];
	AudioFileID fileID = [self openAudioFile:[record objectForKey:@"fileName"]];
	
	UInt32 fileSize = [[record objectForKey:@"fileSize"] unsignedIntegerValue];
	UInt32 bufferIndex = [[record objectForKey:@"bufferIndex"] unsignedIntegerValue];
	
	//NSLog(@"fileName: %@",[record objectForKey:@"fileName"]);
	//NSLog(@"bufferIndex: %@",[NSNumber numberWithUnsignedInt:bufferIndex]);
	
	
	NSInteger totalChunks = fileSize / bufferSize;
	
	if (bufferIndex > totalChunks)
	{
		NSLog(@"bufferIndex > totalChunks");
		return NO;
	}
	
	NSUInteger startOffset = bufferIndex * bufferSize;
	
	if (bufferIndex == totalChunks)
	{
		NSLog(@"bufferIndex == totalChunks");
		NSInteger leftOverBytes = fileSize - (bufferSize * totalChunks);
		tempBufferSize = leftOverBytes;
	}
	
	// this is where the audio data will live for the moment
	// outData is a pointer to type unsigned char
	//unsigned char *outData = malloc(bufferSize);
	unsigned char *outData = (unsigned char *)malloc(tempBufferSize);
	
	
	//NSLog(@"outData before AudioFileReadBytes: %@",[NSNumber numberWithUnsignedChar:*outData]);
	
	
	// this where we actually get the bytes from the file and put them
	// into the data buffer
	UInt32 bytesToRead = tempBufferSize;
	OSStatus result = noErr;
	
	
	result = AudioFileReadBytes(fileID, false, startOffset, &bytesToRead, outData);
	if (result != 0) NSLog(@"cannot load stream: %@",[record objectForKey:@"fileName"]);
	
	// if we are past the end, and no bytes were read, then no need to Q a buffer
	// this should not happen if the math above is correct, but to be sae we will add it
	if (bytesToRead == 0)
	{
		NSLog(@"bytesToRead = 0");
		free(outData);
		return NO; // no more file!
	}
	
	
	
	
	
	
	
	
	
	
	/**
	for (int i = 0; i < 1000; i++)
	{
		NSLog(@"value at location outData: %@",[NSNumber numberWithUnsignedChar:outData[i]]);
	}
	 **/
	
	
	
	
	
	
	
	
	
	
		//unsigned char *filter = malloc(filterSize);
	//filter[0] = 1;
	
	//[self convolve:outData withFilter:filter];
	
	//NSLog(@"value at location outData (after convolve): %@",[NSNumber numberWithUnsignedChar:outData[0]]);
	//NSLog(@"value at location outData + 1 (after convolve): %@",[NSNumber numberWithUnsignedChar:outData[1]]);
	
	
	// this is where convolution should take place
	// 1. frame outData
	// 2. add previousTail to outData
	// 3. find correct HRIR
	// 4. perform convolution
	// 5. of the 639 bits returned, grab the first 512 for this buffer
	// ... and save the remaining 127 as previousTail
	
	
	// unsigned char* HRIR = [HRIRSet objectForKey(heading)];
	// outData = outData * frame;
	// outData = outData + previousTail;
	// outData = [self convolve:outData HRIR];
	
	
	
	
	
	
	// then, jam the audio data into the supplied buffer
	// once the data is in here, it is impossible to access
	// and process it.
	alBufferData(bufferID,format,outData,bytesToRead,freq);
	
	
	
	// clean up the temporary storage location
	free(outData);
	outData = NULL;
	
	// close file
	AudioFileClose(fileID);
	
	// increment the index so that next time we get the next chunk
	bufferIndex++;
	//NSLog(@"bufferIndex: %@",[NSNumber numberWithUnsignedInteger:bufferIndex]);
	// are we looping? if so then flip back to 0
	if ((bufferIndex > totalChunks) && ([[record objectForKey:@"loops"] boolValue]))
	{
		NSLog(@"set bufferIndex to 0");
		bufferIndex = 0;
	}
	[record setObject:[NSNumber numberWithUnsignedInteger:bufferIndex] forKey:@"bufferIndex"];
	
	
	//NSLog(@"fileName: %@",[record objectForKey:@"fileName"]);
	//NSLog(@"bufferIndex: %@",[record objectForKey:@"bufferIndex"]);
	
	
	return YES;	
}



-(void)rotateBufferThread:(NSMutableDictionary*)record
{
	NSAutoreleasePool * apool = [[NSAutoreleasePool alloc] init];
	BOOL stillPlaying = YES;
	while (stillPlaying) {
		stillPlaying = [self rotateBufferForStreamingSound:record];
	}
	[apool release];
}



//-(unsigned char)convolve:(unsigned char*)outData forHeading:(float)heading
//{
// convolve HRIR and outData
//}



-(BOOL)rotateBufferForStreamingSound:(NSMutableDictionary*)record
{
	
	NSUInteger sourceID = [[record objectForKey:@"sourceID"] unsignedIntegerValue];
	
	// check to see if we are stopped
	NSInteger sourceState;
	alGetSourcei(sourceID, AL_SOURCE_STATE, &sourceState);
	if (sourceState != AL_PLAYING)
		return NO; // we are stopped, do not load any more buffers
	
	
	// get the processed buffer count
	NSInteger buffersProcessed = 0;
	alGetSourcei(sourceID, AL_BUFFERS_PROCESSED, &buffersProcessed);
	
	// check to see if we have a buffer to deQ
	if (buffersProcessed > 0)
	{
		// great! deQ a buffer and re-fill it
		NSUInteger bufferID;
		// remove the buffer form the source
		alSourceUnqueueBuffers(sourceID, 1, &bufferID);
		// fill the buffer up and reQ!
		// if we cant fill it up then we are finished
		// in which case we dont need to re-Q
		// return NO if we dont have more buffers to Q
		if (![self loadNextStreamingBufferForSound:record intoBuffer:bufferID]) return NO;
		// Q the loaded buffer
		alSourceQueueBuffers(sourceID, 1, &bufferID);
	}
	
	return YES;
}


/**
- (IBAction)updateOrientation:(id)sender
{
	//NSLog(@"updateOrientation called");
	
	
	return;
	
	for (NSDictionary *record in soundLibrary)
	{
		NSNumber *numVal1 = [record objectForKey:@"sourceID"];
		NSUInteger sourceID = [numVal1 unsignedIntValue];
		
		if (soundsLoaded)
		{
			if ((sender == positionSliderStereo) || (sender == positionSliderSurround))
			{
				ALfloat sourcePos[] = {positionSliderStereo.value, 0.0, positionSliderSurround.value * -1};
				alSourcefv(sourceID, AL_POSITION, sourcePos);
			} // end if
			else
			{
				ALfloat sourcePosLeft[] = {-1.0, 0.0, 0.0};
				ALfloat sourcePosFL[] = {-1.0, 0.0, -1.0};
				ALfloat sourcePosFront[] = {0.0, 0.0, -1.0};
				ALfloat sourcePosFR[] = {1.0, 0.0, -1.0};
				ALfloat sourcePosRight[] = {1.0, 0.0, 0.0};
				ALfloat sourcePosRS[] = {1.0, 0.0, 1.0};
				ALfloat sourcePosSurround[] = {0.0, 0.0, 1.0};
				ALfloat sourcePosLS[] = {-1.0, 0.0, 1.0};
				ALfloat sourcePosC[] = {0.0, 0.0, 0.0};
				
				if (sender == playLeft)
					alSourcefv(sourceID, AL_POSITION, sourcePosLeft);
				else if (sender == playFL)
					alSourcefv(sourceID, AL_POSITION, sourcePosFL);
				else if (sender == playFront)
					alSourcefv(sourceID, AL_POSITION, sourcePosFront);
				else if (sender == playFR)
					alSourcefv(sourceID, AL_POSITION, sourcePosFR);
				else if (sender == playRight)
					alSourcefv(sourceID, AL_POSITION, sourcePosRight);
				else if (sender == playRS)
					alSourcefv(sourceID, AL_POSITION, sourcePosRS);
				else if (sender == playSurround)
					alSourcefv(sourceID, AL_POSITION, sourcePosSurround);
				else if (sender == playLS)
					alSourcefv(sourceID, AL_POSITION, sourcePosLS);
				else if (sender == playCenter)
					alSourcefv(sourceID, AL_POSITION, sourcePosC);
			} // end else
			
			
			
			//xValue.text = [NSString stringWithFormat:@"%.02f",pos[0]];
			//zValue.text = [NSString stringWithFormat:@"%.02f",pos[2]];// * -1];
		}
		
		ALfloat pos[3];
		
		alGetSourcefv(sourceID, AL_POSITION, pos);
		
		if ((sender != positionSliderStereo) && (sender != positionSliderSurround))
		{
			positionSliderStereo.value = pos[0];
			positionSliderSurround.value = pos[2] * -1;
		}
	} // end if sound loaded
}
**/


-(void)cleanUpOpenAL:(id)sender
{
	NSLog(@"cleanUpOpenAL called");
	
	if (!soundsLoaded)
		return;
	
	
	// delete the sources
	for (NSDictionary *record in soundLibrary)
	{
		//NSLog(@"fileSize in cleanup: %@",[record objectForKey:@"fileSize"]);
		NSUInteger sourceID = [[record objectForKey:@"sourceID"] unsignedIntegerValue];
		alDeleteSources(1, &sourceID);
		NSLog(@"source deleted");
		for (NSNumber *bufferNumber in [record objectForKey:@"bufferList"])
		{
			NSUInteger bufferID = [bufferNumber unsignedIntegerValue];
			alDeleteBuffers(1, &bufferID);
			NSLog(@"buffer deleted");
		}
	}
	[soundLibrary removeAllObjects];
	
	
	
	NSLog(@"success before crash");
	
	soundsLoaded = NO;
	[playSound setTitle:@"Play" forState:UIControlStateNormal];
	angleWidthSlider.value = defaultGaussianC;
	angleWidthSliderValue.text = [NSString stringWithFormat:@"%.02f",defaultGaussianC];
	gainFloorSlider.value = defaultGainFloor;
	gainFloorSliderValue.text = [NSString stringWithFormat:@"%.02f",defaultGainFloor];
	categoryLabel.text = @"No Sounds Loaded";
	closestSourceLabel.text = @"No Sounds Loaded";
	//gainScaleSlider.value = defaultGainScale;
	//gainScaleSliderValue.text = [NSString stringWithFormat:@"%.02f",defaultGainScale];
}


// update each source position
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)outLocation
{
	NSString *closestSource = @"test";
	float smallestDistance = 1000;
	
	float GPSX = newLocation.coordinate.longitude;
	float GPSY = newLocation.coordinate.latitude * -1;
	xDir.text = [NSString stringWithFormat:@"%.2f",GPSX];
	yDir.text = [NSString stringWithFormat:@"%.2f",GPSY];
	
	float maxVal;
	for (NSDictionary *record in soundLibrary)
	{
		NSString *shortFileName = [[[record objectForKey:@"fileName"] lastPathComponent] stringByDeletingPathExtension];
		NSUInteger sourceID = [[record objectForKey:@"sourceID"] unsignedIntegerValue];
		float sourceXDir = [[record objectForKey:@"defaultSourceX"] floatValue] - GPSX;
		float sourceYDir = [[record objectForKey:@"defaultSourceY"] floatValue] - GPSY;
		
		float currentDistance = (sourceXDir * sourceXDir) + (sourceYDir * sourceYDir);
		NSLog(@"shortFileName: %@",shortFileName);
		NSLog(@"smallestDistance: %@",[NSNumber numberWithFloat:smallestDistance]);
		if (currentDistance < smallestDistance)
		{
			smallestDistance = currentDistance;
			closestSource = shortFileName;
		}			
		
		if (fabs(sourceXDir) > fabs(sourceYDir))
			maxVal = fabs(sourceXDir);
		else
			maxVal = fabs(sourceYDir);

		ALfloat normSourceXDir = sourceXDir / maxVal;
		ALfloat normSourceYDir = sourceYDir / maxVal;
		
		ALfloat newSourcePos[] = {normSourceXDir, 0, normSourceYDir};
		alSourcefv(sourceID, AL_POSITION, newSourcePos);
		
		
		//NSString *test5 = [NSString stringWithFormat:@"%.14f",normSourceXDir];
		//NSString *test6 = [NSString stringWithFormat:@"%.14f",normSourceYDir];
		//sourceXField.text = test5;
		//sourceYField.text = test6;
	}
	
	closestSourceLabel.text = @"@%",closestSource;
	smallestDistanceLabel.text = [NSString stringWithFormat:@"%.10f",smallestDistance];
}


// update listener orientation and source volumes
- (void)locationManager:(CLLocationManager*)manager didUpdateHeading:(CLHeading*)newHeading
{
	float newRotation = newHeading.trueHeading;
	NSString *test1 = [NSString stringWithFormat:@"%.02f",newRotation];
	
	// get new rotation in radians
	float newRotationRad = newRotation * M_PI / 180;
	
	float newXDir = sin(newRotationRad);
	//NSString *test2 = [NSString stringWithFormat:@"%.02f",newXDir];
	float newYDir = cos(newRotationRad * -1) * -1;
	//NSString *test3 = [NSString stringWithFormat:@"%.02f",newYDir];
	
	/**
	ALfloat listenerXPos;
	ALfloat listenerYPos;
	ALfloat listenerZPos;
	alGetListener3f(AL_POSITION, &listenerXPos, &listenerZPos, &listenerYPos);
	 **/
	
	ALfloat newListenerOrientation[] = {newXDir, 0.0, newYDir, 0.0, 1.0, 0.0};
	alListenerfv(AL_ORIENTATION, newListenerOrientation);
	
	orientation.text = test1;
	//xDir.text = test2;
	//yDir.text = test3;
	
		
	// for each record, update its source's volume
	for (NSDictionary *record in soundLibrary)
	{
		NSUInteger sourceID = [[record objectForKey:@"sourceID"] unsignedIntegerValue];
		//float defaultRotation = [[record objectForKey:@"defaultRotation"] floatValue];
		
		ALfloat sourceXDir;
		ALfloat sourceZDir;
		ALfloat sourceYDir;
		alGetSource3f(sourceID, AL_POSITION, &sourceXDir, &sourceZDir, &sourceYDir);
		
		//sourceXDir = sourceXDir - listenerXPos;
		//sourceYDir = sourceYDir - listenerYPos;
		
		float sourceOrientation = atan(fabs(sourceXDir) / fabs(sourceYDir)) * 180 / M_PI;
		
		if (sourceXDir >= 0)
		{
			// if 1st quadrant
			if (sourceYDir < 0)
				;
			// if 2nd quadrant
			else if (sourceYDir > 0)
				sourceOrientation = 180 - sourceOrientation;
			// else 90
			else
				sourceOrientation = 90;
		}
		else
		{
			// if 4th quadrant
			if (sourceYDir < 0)
				sourceOrientation = 360 - sourceOrientation;
			// else if 3rd quadrant
			else if (sourceYDir > 0)
				sourceOrientation = 180 + sourceOrientation;
			// else 270
			else
				sourceOrientation = 270;
		}

		
		//NSString *shortName = [[record objectForKey:@"fileName"] lastPathComponent];
		//if ([shortName isEqualToString:@"moma.caf"])
		//if ([soundLibrary count] == 1)
		//{
			//NSString *test4 = [NSString stringWithFormat:@"%.14f",sourceOrientation];
			//NSString *test5 = [NSString stringWithFormat:@"%.14f",sourceXDir];
			//NSString *test6 = [NSString stringWithFormat:@"%.14f",sourceYDir];
			//sourceOr.text = test4;
			//sourceXField.text = test5;
			//sourceYField.text = test6;
		//}
		
		// diff = sourceOrientation - newRotation
		// diff has a range of 360 to -360, where closest to 0 is equivalent to closest to +-360
		// diff = |diff|
		// diff has a range of 0 to 360, where closest to 0 is equivalent to closest to 360
		// diff = diff - 180
		// diff has a range of -180 to 180, where closest to 0 is SOFTEST
		// diff = |diff|
		// diff has a range of 0 to 180, where closest to 0 is SOFTEST
		// diff = diff / 180
		// diff has a range of 0 to 1, where closest to 0 is SOFTEST
		// diff = diff - 1
		// diff has a range of -1 to 0, where closest to 0 is loudest
		// diff = |diff|
		// diff has a range of 0 to 1, where closest to 0 is loudest
		
		// get the absolute difference between listener and source orientation normalized between 0 and 1
		float diff = fabs((fabs(fabs(sourceOrientation - newRotation) - 180) / 180) - 1);
		
		
		// call this function to get a gain scalar normalized between 0 and 1
		float gainScale = [self gaussianBellCurve:diff];
		if (gainScale < gainFloor) gainScale = gainFloor;
		
		/**
		if ((diff <= (angleWidthSlider.value / 2)) || (diff >= (360 - (angleWidthSlider.value / 2))))
			gainScale = 1.0;
		else
			gainScale = gainScaleSlider.value;
		**/
		
		//gainScaleSlider.value = gainScale;
		//gainScaleSliderValue.text = [NSString stringWithFormat:@"%.02f",gainScale];
		
		alSourcef(sourceID, AL_GAIN, gainScale);
	}
}



-(float)gaussianBellCurve:(float)difference
{
	float exponent = pow(difference, 2) / (2 * pow(gaussianC, 2));
	float gainScale = pow(2.718281828, exponent * -1);
	return gainScale;
}



-(void)locationManager:(CLLocationManager*)manager didFailWithError:(NSError*)error
{
	if ([error code] == kCLErrorDenied)
		[locationManager stopUpdatingLocation];
	NSLog(@"location manager failed");
}



- (IBAction)toggleTracking
{
	NSLog(@"toggleTracking called");
	
	if (tracking)
	{
		tracking = NO;
		
		[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
		[toggleButton setTitle:@"Start Tracking" forState:UIControlStateNormal];
		[locationManager stopUpdatingLocation];
		[locationManager stopUpdatingHeading];
		
		/**
		 UIAlertView *alert = [[UIAlertView alloc]
		 initWithTitle:@"Statistics" message:@"Win" delegate:self
		 cancelButtonTitle:@"Return" otherButtonTitles:nil];
		 [alert show];
		 [alert release];
		 **/
	}
	else
	{
		tracking = YES;
		
		[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
		[toggleButton setTitle:@"Stop Tracking" forState:UIControlStateNormal];
		[locationManager startUpdatingLocation];
		[locationManager startUpdatingHeading];
	}
}


/**
- (IBAction)setTestValues
{
	
	NSMutableDictionary *record1 = [soundLibrary objectAtIndex:0];
	NSMutableDictionary *record2 = [soundLibrary objectAtIndex:1];
	NSMutableDictionary *record3 = [soundLibrary objectAtIndex:2];
	NSMutableDictionary *record4 = [soundLibrary objectAtIndex:3];
	NSMutableDictionary *record5 = [soundLibrary objectAtIndex:4];
	NSMutableDictionary *record6 = [soundLibrary objectAtIndex:5];
	NSMutableDictionary *record7 = [soundLibrary objectAtIndex:6];
	
	[record1 setObject:[NSNumber numberWithBool:YES] forKey:@"shouldPlay"];
	[record2 setObject:[NSNumber numberWithBool:NO] forKey:@"shouldPlay"];
	[record3 setObject:[NSNumber numberWithBool:NO] forKey:@"shouldPlay"];
	[record4 setObject:[NSNumber numberWithBool:NO] forKey:@"shouldPlay"];
	[record5 setObject:[NSNumber numberWithBool:NO] forKey:@"shouldPlay"];
	[record6 setObject:[NSNumber numberWithBool:NO] forKey:@"shouldPlay"];
	[record7 setObject:[NSNumber numberWithBool:NO] forKey:@"shouldPlay"];
	
}
 **/


- (void)dealloc
{
	NSLog(@"dealloc called");
	
	// destroy the context
	alcDestroyContext(mContext);
	// close the device
	alcCloseDevice(mDevice);
	
	[locationManager release];
	[soundLibrary release];
	[heading release];
	//[fileNames release];
	[super dealloc];
}



- (void)flipsideViewControllerDidFinish:(FlipsideViewController*)controller withCategory:(NSString*)activeCategory
{
	// this is the place to call load sounds with whatever categories are active
	NSLog(@"calling loadSounds from flipsideViewControllerDidFinish");
	categoryLabel.text = activeCategory;
	[self loadSounds:activeCategory];
		
	[self dismissModalViewControllerAnimated:YES];
}


- (IBAction)showInfo:(id)sender
{
	[self cleanUpOpenAL:nil];
	
	FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	controller.delegate = self;
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}


- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}



- (IBAction)updateAngleWidth
{
	angleWidthSliderValue.text = [NSString stringWithFormat:@"%.02f",angleWidthSlider.value];
	gaussianC = angleWidthSlider.value;
}

- (IBAction)updateGainFloor
{
	gainFloorSliderValue.text = [NSString stringWithFormat:@"%.02f",gainFloorSlider.value];
	gainFloor = gainFloorSlider.value;
}

/**
- (IBAction)updateGainScale
{
	gainScaleSliderValue.text = [NSString stringWithFormat:@"%.02f",gainScaleSlider.value];
}
 **/


/**
- (void)frame
{
	
}
 **/

/**
- (unsigned char *)convolve:(unsigned char *)outData withFilter:(unsigned char *)filter forRecord:(NSMutableDictionary*)record
{
	// create a temporary buffer which will hold the convolved data
	unsigned char *temp = malloc(bufferSize + filterSize - 1);
	for (int i = 0; i < bufferSize + filterSize - 1; i++)
	{
		if (i < filterLen)
			temp[i] = currentTail[i];
		else
			temp[i] = 0;
	}
	
	// perform the convolution
	for (int j = 0; j < bufferSize; j++)
	{
		for (int k = 0; k < filterSize; k++)
		{
			temp[j + k] = ((temp[j + k] + ((outData[j] - 128) * filter[k])) * 128) + 128;
		}
	}
	
	// currentTail
	// currentTail is the values between (temp + bufferSize) and (currentTail + filterSize - 1)
	//currentTail =&(temp + bufferSize);
}
 **/

- (void)convolve:(unsigned char *)outData withFilter:(unsigned char*)filter
{
	for (int i = 0; i < bufferSize; i++)
	{
		outData[i] = outData[i] / 2;
	}
}



@end
