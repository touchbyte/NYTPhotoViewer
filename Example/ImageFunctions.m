//
//  ImageFunctions.m
//  Example
//
//  Created by Helmut Schottmüller on 16.07.19.
//  Copyright © 2019 NYTimes. All rights reserved.
//

#import "ImageFunctions.h"


@implementation ImageFunctions


+(UIImage*)createResizedUIImageFromURL:(NSURL*)url imageSize:(NSUInteger)imageSize
{
	CGImageSourceRef  imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)url, nil);
	if (imageSource == NULL) return nil;
	NSDictionary* thumbOpts = @{(id)kCGImageSourceCreateThumbnailWithTransform:(id)kCFBooleanTrue,
															(id)kCGImageSourceCreateThumbnailFromImageAlways: (id)kCFBooleanTrue,
															(id)kCGImageSourceThumbnailMaxPixelSize: [NSNumber numberWithUnsignedInteger:imageSize]};
	CGImageRef resizedImage = CGImageSourceCreateThumbnailAtIndex(imageSource,0,(__bridge_retained CFDictionaryRef)thumbOpts);
	UIImage *image = [UIImage imageWithCGImage:resizedImage];
	CGImageRelease(resizedImage);
	if (imageSource!=nil) {
		CFRelease(imageSource);
	}
	return image;
}

+ (NSString*) createResizedImageFromFile:(NSString*)file imageSize:(NSUInteger)imageSize forceJPEG:(BOOL)forceJPEG rotate:(BOOL)rotate createTempFile:(BOOL)createTempFile
{
	
	CGImageRef        thumbnailImage = NULL;
	CGImageSourceRef  imageSource;
	CGImageDestinationRef imageDestination;
	BOOL isPNG = NO;
	
	
	CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,(__bridge CFStringRef)[file pathExtension], NULL);
	if (UTTypeConformsTo(UTI,(CFStringRef) @"public.png")) {
		isPNG = YES;
	}
	
	//resize raws
	if (UTTypeConformsTo(UTI,(CFStringRef) @"public.camera-raw-image")) {  //extract JPEF From Raw
		isPNG = NO;
		
	}
	
	if (forceJPEG == YES)
	{
		isPNG = NO;
	}
	
	CFRelease(UTI);
	
	imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:file], nil);
	if (imageSource != NULL) {
		NSMutableDictionary *metadata =  [(__bridge_transfer NSDictionary*)CGImageSourceCopyPropertiesAtIndex(imageSource,0,NULL) mutableCopy];
		
		
		NSDictionary* thumbOpts = nil;
		if (imageSize == 0 || imageSize == -1) {   //extract emebedded JPEG in RAWs
			thumbOpts = @{(id)kCGImageSourceCreateThumbnailWithTransform: @(rotate),
										(id)kCGImageSourceCreateThumbnailFromImageAlways: (id)kCFBooleanTrue};
			
		} else {        //normal processing
			thumbOpts = @{(id)kCGImageSourceCreateThumbnailWithTransform: @(rotate),
										(id)kCGImageSourceCreateThumbnailFromImageAlways: (id)kCFBooleanTrue,
										(id)kCGImageSourceThumbnailMaxPixelSize: [NSNumber numberWithUnsignedInteger:imageSize]};
		}
		
		if (rotate) {
			NSLog(@"Perform image rotation");
			if ([metadata objectForKey:(id)kCGImagePropertyOrientation]) {
				[metadata setObject:@1 forKey:(id)kCGImagePropertyOrientation];
			}
			if ([metadata objectForKey:(id)kCGImagePropertyTIFFDictionary]) {
				[[metadata objectForKey:(id)kCGImagePropertyTIFFDictionary] setObject:@1 forKey:(id)kCGImagePropertyOrientation];
			}
		}
		thumbnailImage = CGImageSourceCreateThumbnailAtIndex(imageSource,0,(__bridge_retained CFDictionaryRef)thumbOpts);
		CFRelease(imageSource);
		
		
		NSString *newFileName;
		NSString *finalFileName;
		
		if (isPNG) {
			if (createTempFile) {
				newFileName = [NSString stringWithFormat:@"%@",[file stringByDeletingPathExtension]];
				finalFileName = [NSString stringWithFormat:@"%@.PNG",[file stringByDeletingPathExtension]];
			} else {
				newFileName = [NSString stringWithFormat:@"%@.PNG",[file stringByDeletingPathExtension]];
			}
			imageDestination = CGImageDestinationCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:newFileName], kUTTypePNG, 1, NULL);
		} else {
			if (createTempFile) {
				newFileName = [NSString stringWithFormat:@"%@",[file stringByDeletingPathExtension]];
				finalFileName = [NSString stringWithFormat:@"%@.JPG",[file stringByDeletingPathExtension]];
			} else {
				newFileName = [NSString stringWithFormat:@"%@.JPG",[file stringByDeletingPathExtension]];
			}
			imageDestination = CGImageDestinationCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:newFileName], kUTTypeJPEG, 1, NULL);
		}
		
		[metadata setObject:@(YES) forKey:(__bridge id)kCGImageDestinationEmbedThumbnail];
		
		CGImageDestinationAddImage(imageDestination, thumbnailImage,(__bridge_retained CFDictionaryRef) metadata);
		CGImageDestinationFinalize(imageDestination);
		
		CFRelease(imageDestination);
		CGImageRelease(thumbnailImage);
		
		if (createTempFile) {
			[[NSFileManager defaultManager] removeItemAtPath:file error:nil];
			[[NSFileManager defaultManager] moveItemAtPath:newFileName toPath:finalFileName error:nil];
		}
		
		return newFileName;
	} else {
		return nil;  //invalid image file
	}
}

+ (NSString*) createResizedImageFromFile:(NSString*)file imageSize:(NSUInteger)imageSize
{
	return [ImageFunctions createResizedImageFromFile:file imageSize:imageSize forceJPEG:NO rotate:NO createTempFile:NO];
}

+(UIImage*)createThumbnailFromVideo:(NSString *)videoPath maxSize:(NSUInteger)maxSize {
	NSURL *url = [NSURL fileURLWithPath:videoPath];
	AVAsset *asset = [AVAsset assetWithURL:url];
	AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
	imageGenerator.appliesPreferredTrackTransform = YES;
	imageGenerator.maximumSize = CGSizeMake(maxSize, maxSize);
	CMTime time = CMTimeMakeWithSeconds(0.0, 600);
	CMTime actualTime;
	NSError *error;
	CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:&actualTime error:&error];
	if (error != nil) {
		NSLog(@"Video thumb generation error %@",error);
	}
	UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	return thumbnail;
}

+(NSDictionary*)imageMetadataForPath:(NSString*)imagePath
{
	CGImageSourceRef source = CGImageSourceCreateWithURL( (CFURLRef) [NSURL fileURLWithPath:imagePath], NULL);
	if (source != NULL) {
		NSDictionary* metadata = (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source,0,NULL));
		CFRelease(source);
		return metadata;
	} else {
		return nil;
	}
}

@end

