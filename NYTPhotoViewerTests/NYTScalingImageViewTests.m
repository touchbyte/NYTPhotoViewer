//
//  NYTScalingImageViewTests.m
//  NYTPhotoViewer
//
//  Created by Brian Capps on 2/26/15.
//  Copyright (c) 2015 NYTimes. All rights reserved.
//

@import UIKit;
@import XCTest;

#import <NYTPhotoViewer/NYTScalingImageView.h>
#ifdef ANIMATED_GIF_SUPPORT
#import <FLAnimatedImage/FLAnimatedImage.h>
#endif

@interface NYTScalingImageViewTests : XCTestCase

@property (nonatomic, strong) NSData *imageData;
@property (nonatomic, strong) NSString *gifPath;

@end

@implementation NYTScalingImageViewTests

#pragma mark - Helpers

- (NSString *)gifPath {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _gifPath = [[NSBundle bundleForClass:self.class] pathForResource:@"giphy" ofType:@"gif"];
    });
    return _gifPath;
}

- (NSData *)imageData {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _imageData = [NSData dataWithContentsOfFile:self.gifPath];
    });
    return _imageData;
}

#pragma mark - Tests

- (void)testImageInitializationAcceptsEmptyData {
    XCTAssertNoThrow([[NYTScalingImageView alloc] initWithImage:[UIImage new] frame:CGRectZero]);
}

- (void)testDataInitializationAcceptsEmptyData {
    XCTAssertNoThrow([[NYTScalingImageView alloc] initWithImageData:[NSData new] frame:CGRectZero]);
}

- (void)testImageViewExistsAfterImageInitialization {
    NYTScalingImageView *scalingImageView = [[NYTScalingImageView alloc] initWithImage:[UIImage new] frame:CGRectZero];
    XCTAssertNotNil(scalingImageView.imageView);
}

- (void)testImageViewExistsAfterDataInitialization {
    NYTScalingImageView *scalingImageView = [[NYTScalingImageView alloc] initWithImageData:[NSData new] frame:CGRectZero];
    XCTAssertNotNil(scalingImageView.imageView);
}

- (void)testImageInitializationSetsImage {
    NYTScalingImageView *scalingImageView = [[NYTScalingImageView alloc] initWithImage:[UIImage new] frame:CGRectZero];
    XCTAssertNotNil(scalingImageView.imageView.image);
}

- (void)testDataInitializationSetsImage {
    NYTScalingImageView *scalingImageView = [[NYTScalingImageView alloc] initWithImageData:self.imageData frame:CGRectZero];

#ifdef ANIMATED_GIF_SUPPORT
	XCTAssertEqual(self.imageData, ((FLAnimatedImageView *)scalingImageView.imageView).animatedImage.data);
#endif
}

- (void)testUpdateImageUpdatesImage {
    UIImage *image = [UIImage new];
    NYTScalingImageView *scalingImageView = [[NYTScalingImageView alloc] initWithImage:image frame:CGRectZero];
    [scalingImageView updateImage:image];
    
    XCTAssertEqual(scalingImageView.imageView.image, image);
}

- (void)testUpdateImageDataUpdatesImage {
    NSData *image2 = [NSData dataWithContentsOfFile:self.gifPath];
    
    NYTScalingImageView *scalingImageView = [[NYTScalingImageView alloc] initWithImageData:self.imageData frame:CGRectZero];
    [scalingImageView updateImageData:image2];

#ifdef ANIMATED_GIF_SUPPORT
	XCTAssertEqual(image2, ((FLAnimatedImageView *)scalingImageView.imageView).animatedImage.data);
#endif
}

- (void)testImageViewIsOfCorrectKindAfterInitialization {
    NYTScalingImageView *scalingImageViewer = [[NYTScalingImageView alloc] initWithImageData:self.imageData frame:CGRectZero];

#ifdef ANIMATED_GIF_SUPPORT
	XCTAssertTrue([scalingImageViewer.imageView isKindOfClass:FLAnimatedImageView.class]);
#endif
}

@end
