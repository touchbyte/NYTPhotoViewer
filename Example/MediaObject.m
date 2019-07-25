//
//  MediaObject.m
//  Example
//
//  Created by Helmut Schottmüller on 16.07.19.
//  Copyright © 2019 NYTimes. All rights reserved.
//

#import "MediaObject.h"
#import "ImageFunctions.h"
#import "NSString+Extensions.h"
#import "Resource.h"

@interface MediaObject ()

@property (nonatomic) NSArray<id<NYTMediaResource>> *assets;

@end

@implementation MediaObject

- (instancetype)initWithURL:(NSURL *)url andResourceType:(resourcetypes)type
{
	self = [super init];
	
	
	
	self.assets = [NSArray arrayWithObject:[[Resource alloc] initWithURL:url andResourceType:type]];
	
	return self;
}

- (instancetype)initWithURLArray:(NSArray *)urls
{
	self = [super init];

	self.assets = [NSMutableArray new];
	[urls enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		resourcetypes t = RTPhoto;
		if ([[[((NSURL *)obj) pathExtension] lowercaseString] isEqualToString:@"mov"])
		{
			t = RTVideo;
		}
		else if ([[[((NSURL *)obj) pathExtension] lowercaseString] isEqualToString:@"dng"])
		{
			t = RTRaw;
		}
		[((NSMutableArray *)self.assets) addObject:[[Resource alloc] initWithURL:obj andResourceType:t]];
	}];
	
	return self;
}

- (UIImage *)image
{
	return [((Resource *)self.resources[0]) imageRepresentation];
}

- (NSData *)imageData
{
	return nil;//[NSData dataWithContentsOfFile:((Resource *)self.assets[0]).url.path];
}

- (mediatypes) mediaType
{
	if ([((Resource *)self.assets[0]).url.path isImageFile])
	{
		return MTPhoto;
	}
	else if ([((Resource *)self.assets[0]).url.path isVideoFile])
	{
		return MTVideo;
	}
	else if (self.assets.count == 2)
	{
		return MTMultiAsset;
	}
	else return MTPhoto;
}

- (NSArray<id<NYTMediaResource>> *)resources
{
	return self.assets;
}

@end
