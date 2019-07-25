//
//  NYTMediaResource.h
//  NYTPhotoViewer
//
//  Created by Helmut Schottmüller on 16.07.19.
//  Copyright © 2019 NYTimes. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

typedef enum resourcetypes {
	RTPhoto, RTVideo, RTRaw
} resourcetypes;

/**
 *  The model for the resource of a media object displayed in an `NYTPhotosViewController`.
 *
 */
@protocol NYTMediaResource <NSObject>

@property (nonatomic, assign, readonly) resourcetypes resourceType;

- (NSData *)data;
- (NSURL *)url;
- (UIImage *)imageRepresentation;

@end

NS_ASSUME_NONNULL_END
