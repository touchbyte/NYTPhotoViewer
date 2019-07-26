//
//  NYTMediaResource.h
//  NYTPhotoViewer
//
//  Created by Helmut Schottmüller on 16.07.19.
//  Copyright © 2019 NYTimes. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, Resourcetypes) {
	RTPhoto,
	RTVideo,
	RTRaw,
};

/**
 *  The model for the resource of a media object displayed in an `NYTPhotosViewController`.
 *
 */
@protocol NYTMediaResource <NSObject>

@property (nonatomic, assign, readonly) Resourcetypes resourceType;

- (nullable NSData *)data;
- (NSURL *)url;
- (UIImage *)imageRepresentation;

@end

NS_ASSUME_NONNULL_END
