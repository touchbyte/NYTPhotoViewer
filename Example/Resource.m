//
//  Resource.m
//  Example
//
//  Created by Helmut Schottmüller on 17.07.19.
//  Copyright © 2019 NYTimes. All rights reserved.
//

#import "Resource.h"
#import "ImageFunctions.h"
#import "NSString+Extensions.h"

@interface Resource ()

@end

@implementation Resource

- (instancetype)initWithURL:(NSURL *)url andResourceType:(Resourcetypes)type
{
	self = [super init];
	
	_url = url;
	_type = type;
	
	return self;
}


- (nullable NSData *)data {
	return nil;
}

- (nonnull NSURL *)url {
	return _url;
}

- (Resourcetypes)resourceType
{
	return _type;
}

- (nonnull UIImage *)imageRepresentation {
	if (_url.path.isVideoFile)
	{
		return [ImageFunctions createThumbnailFromVideo:_url.path maxSize:1920];
	}
	else if (_url.path.isRawFile)
	{
		return [ImageFunctions createResizedUIImageFromURL:_url imageSize:2048];
	}
	else
	{
		return [UIImage imageWithContentsOfFile:_url.path];
	}
}


@end
