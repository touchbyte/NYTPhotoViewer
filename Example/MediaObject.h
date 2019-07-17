//
//  MediaObject.h
//  NYTPhotoViewer
//
//  Created by Helmut Schottmüller on 16.07.19.
//  Copyright © 2019 NYTimes. All rights reserved.
//

@import Foundation;

#import <NYTPhotoViewer/NYTPhoto.h>
#import <NYTPhotoViewer/NYTMediaResource.h>

@interface MediaObject : NSObject <NYTPhoto>

// Redeclare all the properties as readwrite for sample/testing purposes.
@property (nonatomic) UIImage *placeholderImage;
@property (nonatomic) NSAttributedString *attributedCaptionTitle;
@property (nonatomic) NSAttributedString *attributedCaptionSummary;
@property (nonatomic) NSAttributedString *attributedCaptionCredit;

- (instancetype)initWithURL:(NSURL *)url;
- (instancetype)initWithURLArray:(NSArray *)urls;
- (UIImage *)image;

@end
