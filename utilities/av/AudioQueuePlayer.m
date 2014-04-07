//
//  AudioQueuePlayer.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 05. 22.
//
//  last update: 2014.04.07.
//

#pragma GCC diagnostic ignored "-Wmissing-prototypes"

#import "AudioQueuePlayer.h"

#import <mach/mach_time.h>

#import "Logging.h"
#import "AVUtil.h"


@implementation AudioQueuePlayer

@synthesize numPacketsToRead;
@synthesize audioFile;
@synthesize packetDescs;
@synthesize currentPacket;
@synthesize queue;
@synthesize isRunning;
@synthesize startTime;
@synthesize delegate;

#pragma mark -
#pragma mark audio queue's callback functions and etc.

void outputCallback(void* userData, AudioQueueRef inAudioQueue, AudioQueueBufferRef inBuffer)
{
	AudioQueuePlayer* wrapper = (AudioQueuePlayer*)userData;
	UInt32 numBytesReadFromFile;
	UInt32 numPackets = wrapper.numPacketsToRead;
	
//	DebugLog(@"currentPacket = %d", wrapper.currentPacket);
	
	OSStatus result = AudioFileReadPackets(wrapper.audioFile, false, &numBytesReadFromFile, wrapper.packetDescs, wrapper.currentPacket, &numPackets, inBuffer->mAudioData);
	if(result != noErr)
		DebugLog(@"AudioFileReadPackets failed");
	
	if(numPackets > 0)
	{
		inBuffer->mAudioDataByteSize = numBytesReadFromFile;

		@synchronized(wrapper)
		{
			if(wrapper.currentPacket == 0 && wrapper.startTime)	//if it's first buffer, and has desired start time
			{
				AudioTimeStamp actualStartTime;
				result = AudioQueueEnqueueBufferWithParameters(wrapper.queue, inBuffer, (wrapper.packetDescs ? numPackets : 0), wrapper.packetDescs,
															   0,
															   0,
															   0,
															   NULL,
															   wrapper.startTime,
															   &actualStartTime);
				if(result != noErr)
					DebugLog(@"AudioQueueEnqueueBufferWithParameters failed");
			}
			else
			{
				result = AudioQueueEnqueueBuffer(wrapper.queue, inBuffer, (wrapper.packetDescs ? numPackets : 0), wrapper.packetDescs);
				if(result != noErr)
					DebugLog(@"AudioQueueEnqueueBuffer failed");
			}

			wrapper.currentPacket += numPackets;
		}
	}
	else
	{
		[wrapper stop:NO];
	}
}

void propertyCallback(void* inUserData, AudioQueueRef inAQ, AudioQueuePropertyID inID)
{
	if(inID == kAudioQueueProperty_IsRunning)
	{
		UInt32 propertyIsRunning;
		UInt32 propertySize = sizeof(propertyIsRunning);
		OSStatus result = AudioQueueGetProperty(inAQ, inID, &propertyIsRunning, &propertySize);
		if(result != noErr)
		{
			DebugLog(@"AudioQueueGetProperty failed: %d", (int)result);
		}
		
		AudioQueuePlayer* wrapper = (AudioQueuePlayer*)inUserData;
		@synchronized(wrapper)
		{
			wrapper.isRunning = (propertyIsRunning != 0);	//0 means 'stopped'
			if(wrapper.isRunning)
			{
				DebugLog(@"AudioQueue is running");
				
				[wrapper.delegate audioQueuePlayer:wrapper 
												 did:AudioQueuePlayerStartedPlaying];
			}
			else
			{
				DebugLog(@"AudioQueue is not running");

				[wrapper stop:YES];
				wrapper.currentPacket = 0;	//go back to start point
				
				[wrapper.delegate audioQueuePlayer:wrapper 
												 did:AudioQueuePlayerStoppedPlaying];
			}
		}
	}
}

void calcBufferSize(AudioStreamBasicDescription desc, UInt32 maxPacketSize, Float64 seconds, UInt32* outBufferSize, UInt32* outNumPacketsToRead)
{
	static const int maxBufferSize = 0x20000;	//128kb
	static const int minBufferSize = 0x4000;	//16kb
	
	if(desc.mFramesPerPacket != 0)
	{
		Float64 numPacketsForTime = desc.mSampleRate / desc.mFramesPerPacket * seconds;
		*outBufferSize = numPacketsForTime * maxPacketSize;
	}
	else
	{
		*outBufferSize = MAX(maxBufferSize, maxPacketSize);
	}
	
	if(*outBufferSize > maxBufferSize && *outBufferSize > maxPacketSize)
	{
		*outBufferSize = maxBufferSize;
	}
	else
	{
		if(*outBufferSize < minBufferSize)
		{
			*outBufferSize = minBufferSize;
		}
	}

	*outNumPacketsToRead = *outBufferSize / maxPacketSize;

	DebugLog(@"bufferByteSize = %u, numPacketsToRead = %u", (unsigned int)*outBufferSize, (unsigned int)*outNumPacketsToRead);
}

#pragma mark -
#pragma mark initializers

- (id)initWithURL:(NSURL*)url 
	 samplingRate:(float)multiplier
{
	if((self = [super init]))
	{
		_url = [url retain];
		
		//open audio file
		OSStatus result = AudioFileOpenURL((CFURLRef)url, kAudioFileReadPermission, 0, &audioFile);
		if(result != noErr)
			DebugLog(@"AudioFileOpenURL failed: %d", (int)result);
		
		//get given audio file's data format
		UInt32 dataFormatSize = sizeof(dataFormat);
		result = AudioFileGetProperty(audioFile, kAudioFilePropertyDataFormat, &dataFormatSize, &dataFormat);
		if(result != noErr)
			DebugLog(@"AudioFileGetProperty failed: %d", (int)result);
		
		//alter sampling rate
		if(multiplier > 0.0f && multiplier != 1.0f)
		{
			DebugLog(@"sampling rate changed from: %f to: %f", dataFormat.mSampleRate, dataFormat.mSampleRate * multiplier);
			dataFormat.mSampleRate *= multiplier;
		}
		
		//new audio queue for output
		result = AudioQueueNewOutput(&dataFormat, outputCallback, self, CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &queue);
		if(result != noErr)
			DebugLog(@"AudioQueueNewOutput failed: %d", (int)result);
		
		UInt32 maxPacketSize;
		UInt32 propertySize = sizeof(maxPacketSize);
		
		//get upper bound of packet size
		result = AudioFileGetProperty(audioFile, kAudioFilePropertyPacketSizeUpperBound, &propertySize, &maxPacketSize);
		if(result != noErr)
			DebugLog(@"AudioFileGetProperty failed: %d", (int)result);
		
		//calculate optimal buffer size
		calcBufferSize(dataFormat, maxPacketSize, BUFFER_DURATION, &bufferByteSize, &numPacketsToRead);
		
		//check if it's VBR or not
		BOOL isVBR = (dataFormat.mBytesPerPacket == 0 || dataFormat.mFramesPerPacket == 0);
		if(isVBR)
		{
			DebugLog(@"given audio file is in VBR format");
			packetDescs = (AudioStreamPacketDescription*)malloc(numPacketsToRead * sizeof(AudioStreamPacketDescription));
		}
		else
		{
			packetDescs = NULL;
		}
		
		//apply magic cookie
		UInt32 cookieSize = sizeof(UInt32);
		result = AudioFileGetProperty(audioFile, kAudioFilePropertyMagicCookieData, &cookieSize, NULL);
		if(result == noErr && cookieSize)
		{
			char* magicCookie = (char*)malloc(cookieSize);
			result = AudioFileGetProperty(audioFile, kAudioFilePropertyMagicCookieData, &cookieSize, magicCookie);
			if(result != noErr)
				DebugLog(@"AudioFileGetProperty failed: %d", (int)result);
			
			result = AudioQueueSetProperty(queue, kAudioQueueProperty_MagicCookie, magicCookie, cookieSize);
			if(result != noErr)
				DebugLog(@"AudioQueueSetProperty failed: %d", (int)result);
			
			free(magicCookie);
		}

		//allocate buffers
		for(int i=0; i<NUMBER_OF_BUFFERS; i++)
		{
			result = AudioQueueAllocateBuffer(queue, bufferByteSize, (AudioQueueBufferRef*)&buffers[i]);
			if(result != noErr)
				DebugLog(@"AudioQueueAllocateBuffer failed: %d", (int)result);
		}
		
		//add a property change listener
		result = AudioQueueAddPropertyListener(queue, kAudioQueueProperty_IsRunning, propertyCallback, self);
		if(result != noErr)
			DebugLog(@"AudioQueueAddPropertyListener failed: %d", (int)result);

		currentPacket = 0;

		isRunning = NO;
		startTime = NULL;
		
		delegate = nil;
	}
	return self;
}

- (id)initWithFilepath:(NSString*)filepath
		  samplingRate:(float)multiplier
{
	return [self initWithURL:[NSURL fileURLWithPath:filepath] 
				samplingRate:multiplier];
}

- (id)initWithURL:(NSURL*)url
{
	return [self initWithURL:url 
				samplingRate:1.0f];
}

- (id)initWithFilepath:(NSString*)filepath
{
	return [self initWithURL:[NSURL fileURLWithPath:filepath] 
				samplingRate:1.0f];
}


#pragma mark -
#pragma mark functions for manipulating audio queue

+ (AudioTimeStamp)timestampAfterSeconds:(float)seconds
{
	AudioTimeStamp timestamp;
	
	mach_timebase_info_data_t tinfo;
	kern_return_t kerror = mach_timebase_info(&tinfo);
	if (kerror != KERN_SUCCESS)
		DebugLog(@"mach_timebase_info failed: %d", kerror);
	
	double hTime2nsFactor = (double)tinfo.numer / tinfo.denom;
	uint64_t delayTicks = (uint64_t)(seconds * 1000000000 / hTime2nsFactor);
	
	timestamp.mHostTime = mach_absolute_time() + delayTicks;
	timestamp.mFlags = kAudioTimeStampHostTimeValid;
	
	return timestamp;
}

- (void)setStartTime:(AudioTimeStamp*)timestamp
{
	startTime = timestamp;
}

- (NSTimeInterval)duration
{
	return [AVUtil estimatedDurationOfAudioFileurl:_url];
}

- (Float64)currentTime
{
	AudioTimeStamp timestamp;
	AudioQueueTimelineRef timeline;

	OSStatus result;
	
	result = AudioQueueCreateTimeline(queue, &timeline);
	if(result != noErr)
		DebugLog(@"AudioQueueCreateTimeline failed: %d", (int)result);
	else
	{
		Boolean discontinuity;

		result = AudioQueueGetCurrentTime(queue, timeline, &timestamp, &discontinuity);
		if(result != noErr)
			DebugLog(@"AudioQueueGetCurrentTime failed: %d", (int)result);
		
		result = AudioQueueDisposeTimeline(queue, timeline);
		if(result != noErr)
			DebugLog(@"AudioQueueDisposeTimeine failed: %d", (int)result);
	}
	
	return timestamp.mSampleTime / dataFormat.mSampleRate;
}

- (float)volume
{
	float volume = -1.0f;
	OSStatus result = AudioQueueGetParameter(queue, kAudioQueueParam_Volume, &volume);
	if(result != noErr)
		DebugLog(@"AudioQueueGetParameter failed: %d", (int)result);
	
	return volume;
}

- (void)setVolume:(float)volume
{
	OSStatus result = AudioQueueSetParameter(queue, kAudioQueueParam_Volume, volume);
	if(result != noErr)
		DebugLog(@"AudioQueueSetParameter failed: %d", (int)result);
}

- (void)play
{
	[self play:NO];
}

- (void)play:(BOOL)isResume
{
	[self play:isResume 
		  from:NULL];
}

- (void)play:(BOOL)isResume 
		from:(AudioTimeStamp*)timestamp
{
	@synchronized(self)
	{
		if(isRunning)
		{
			DebugLog(@"already running");
			return;
		}
		
		DebugLog(@"start playing");
		
		if(!isResume)
			currentPacket = 0;
		
		//call output callback
		for(int i=0; i<NUMBER_OF_BUFFERS; i++)
			outputCallback(self, queue, (AudioQueueBufferRef)buffers[i]);
		
		//start audio queue
		OSStatus result = AudioQueueStart(queue, timestamp);
		if(result != noErr)
			DebugLog(@"AudioQueueStart failed: %d", (int)result);
	}
}

- (void)seekTo:(Float64)seconds
{
	@synchronized(self)
	{		
		if(isRunning)
			[self stop:YES];
		
		currentPacket = dataFormat.mSampleRate / dataFormat.mFramesPerPacket * seconds;
		DebugLog(@"seeking to: %f seconds (packet: %lld)", seconds, currentPacket);
		
		[self play:YES];
	}
}

- (void)stop:(BOOL)immediate
{
	@synchronized(self)
	{
		if(immediate)
			DebugLog(@"stop playing immediately");
		else
			DebugLog(@"stop playing");
		
		//stop audio queue
		OSStatus result = AudioQueueStop(queue, immediate);
		if(result != noErr)
			DebugLog(@"AudioQueueStop failed: %d", (int)result);
	}
}

#pragma mark -
#pragma mark etc.

- (void)dealloc
{
	OSStatus result;
	
	result = AudioQueueDispose(queue, YES);
	if(result != noErr)
		DebugLog(@"AudioQueueDispose failed: %d", (int)result);
	
	result = AudioFileClose(audioFile);
	if(result != noErr)
		DebugLog(@"AudioFileClose failed: %d", (int)result);
	
	if(packetDescs)
		free(packetDescs);

	[_url release];
	
	[super dealloc];
}

@end
