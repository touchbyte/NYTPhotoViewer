//
//  ImageFunctions.h
//  NYTPhotoViewer
//
//  Created by Helmut Schottmüller on 16.07.19.
//  Copyright © 2019 NYTimes. All rights reserved.
//

@import Foundation;
@import ImageIO;
@import UIKit;
@import AssetsLibrary;
@import AVFoundation;
@import CoreServices;
@import MobileCoreServices;

@interface ImageFunctions : NSObject {
	
}

+ (NSString*) createResizedImageFromFile:(NSString*)file imageSize:(NSUInteger)imageSize forceJPEG:(BOOL)forceJPEG rotate:(BOOL)rotate createTempFile:(BOOL)createTempFile;
+ (NSString*) createResizedImageFromFile:(NSString*)file imageSize:(NSUInteger)imageSize;
+ (UIImage*) createResizedUIImageFromURL:(NSURL*)url imageSize:(NSUInteger)imageSize;
+ (UIImage*)createThumbnailFromVideo:(NSString *)videoPath maxSize:(NSUInteger)maxSize;
+ (NSDictionary*)imageMetadataForPath:(NSString*)imagePath;

@end
