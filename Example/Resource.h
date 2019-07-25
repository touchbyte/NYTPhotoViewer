//
//  Resource.h
//  NYTPhotoViewer
//
//  Created by Helmut Schottmüller on 17.07.19.
//  Copyright © 2019 NYTimes. All rights reserved.
//

@import Foundation;

#import <NYTPhotoViewer/NYTMediaResource.h>

@interface Resource : NSObject <NYTMediaResource> {
	NSURL *_url;
	resourcetypes _type;
}

- (instancetype)initWithURL:(NSURL *)url andResourceType:(resourcetypes)type;

@end
