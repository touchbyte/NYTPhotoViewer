//
//  NSString+Extensions.h
//  NYTPhotoViewer
//
//  Created by Helmut Schottmüller on 17.07.19.
//  Copyright © 2019 NYTimes. All rights reserved.
//

@import UIKit;


@interface NSString(NSStringExtension)
+ (NSString*) stringWithUUID;
- (NSString*) fileMIMEType;
- (NSString*)fileUTI;
- (BOOL)isImageFile;
- (BOOL)isVideoFile;
- (BOOL)isRawFile;
- (BOOL)isJPEGFile;
- (BOOL)isHEIFFile;
- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
- (NSString *)stripTags:(NSString *)str;
+ (NSString *)stringFromFileSize:(long long)theSize;
+ (NSString*)stringfromDuration:(NSTimeInterval)duration;
+ (NSString *)MD5:(NSString *)str;
- (NSString *)stringByAppendingPathComponents:(NSArray *)components;
- (NSString *)decodeHTMLEntities;
- (NSString *)encodeHTMLEntities;
- (CGSize)sizeWithFont:(UIFont*)font maxSize:(CGSize)maxSize paragraphStyle:(NSLineBreakMode)lineBreakMode;

@end
