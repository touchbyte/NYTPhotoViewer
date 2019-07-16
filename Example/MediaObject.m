//
//  MediaObject.m
//  Example
//
//  Created by Helmut Schottmüller on 16.07.19.
//  Copyright © 2019 NYTimes. All rights reserved.
//

#import "MediaObject.h"
#import "ImageFunctions.h"

@interface MediaObject ()

@property (nonatomic) NSArray<NSURL *> *assets;

@end

@implementation MediaObject

- (instancetype)initWithURL:(NSURL *)url
{
	self = [super init];
	
	self.assets = [NSArray arrayWithObject:url];
	
	return self;
}

- (instancetype)initWithURLArray:(NSArray *)urls
{
	self = [super init];

	self.assets = [NSArray arrayWithArray:urls];
	
	return self;
}

- (UIImage *)image
{
	return nil;
	//[ImageFunctions createResizedUIImageFromURL:self.assets[0] imageSize:2048];
}

- (NSData *)imageData
{
	return nil;
	//[NSData dataWithContentsOfFile:((NSURL *)self.assets[0]).path];
}

- (NSURL *)dataURL
{
	return self.assets[0];
}

@end
