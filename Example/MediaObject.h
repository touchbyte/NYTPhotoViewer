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

@property (nonatomic, nullable) NSArray<id<NYTMediaResource>> *resources;
@property (nonatomic, readonly) Mediatypes mediaType;
@property (nonatomic, nullable) UIImage *image;
@property (nonatomic, nullable) NSData *imageData;
@property (nonatomic, nullable) UIImage *placeholderImage;
@property (nonatomic, nullable) NSAttributedString *attributedCaptionTitle;
@property (nonatomic, nullable) NSAttributedString *attributedCaptionSummary;
@property (nonatomic, nullable) NSAttributedString *attributedCaptionCredit;

/*
// Redeclare all the properties as readwrite for sample/testing purposes.
@property (nonatomic) UIImage *placeholderImage;
@property (nonatomic) NSAttributedString *attributedCaptionTitle;
@property (nonatomic) NSAttributedString *attributedCaptionSummary;
@property (nonatomic) NSAttributedString *attributedCaptionCredit;

- (instancetype)initWithURL:(NSURL *)url andResourceType:(resourcetypes)type;
- (instancetype)initWithURLArray:(NSArray *)urls;
- (UIImage *)image;
*/

@end
