//
//  NYTScalingImageView.m
//  NYTPhotoViewer
//
//  Created by Harrison, Andrew on 7/23/13.
//  Copyright (c) 2015 The New York Times Company. All rights reserved.
//

#import "NYTScalingImageView.h"

#import "tgmath.h"

#ifdef ANIMATED_GIF_SUPPORT
#import <FLAnimatedImage/FLAnimatedImage.h>
#endif

@interface NYTScalingImageView ()

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

#ifdef ANIMATED_GIF_SUPPORT
@property (nonatomic) FLAnimatedImageView *imageView;
#else
@property (nonatomic) UIView *imageView;
#endif
@end

@implementation NYTScalingImageView

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithImage:[UIImage new] frame:frame];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];

    if (self) {
        [self commonInitWithImage:nil imageData:nil];
    }

    return self;
}

- (void)didAddSubview:(UIView *)subview {
    [super didAddSubview:subview];
    [self centerScrollViewContents];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateZoomScale];
    [self centerScrollViewContents];
}

#pragma mark - NYTScalingImageView

- (instancetype)initWithImage:(UIImage *)image frame:(CGRect)frame {
    self = [super initWithFrame:frame];

	_isLivePhoto = NO;

	if (self) {
			[self commonInitWithImage:image imageData:nil];
  }
	
  return self;
}

- (instancetype)initWithImageData:(NSData *)imageData frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
	_isLivePhoto = NO;

	if (self) {
        [self commonInitWithImage:nil imageData:imageData];
    }
    
	return self;
}

#ifdef __IPHONE_9_1
- (instancetype)initWithLivePhoto:(PHLivePhoto *)livePhoto frame:(CGRect)frame {
	self = [super initWithFrame:frame];

	_isLivePhoto = YES;

	if (self) {
		[self commonInitWithLivePhoto:livePhoto];
	}
	
	return self;
}

- (void)commonInitWithLivePhoto:(PHLivePhoto *)image {
	[self setupInternalImageViewWithLivePhoto:image];
	[self setupImageScrollView];
	[self updateZoomScale];
}
#endif

- (void)commonInitWithImage:(UIImage *)image imageData:(NSData *)imageData {
    [self setupInternalImageViewWithImage:image imageData:imageData];
    [self setupImageScrollView];
    [self updateZoomScale];
}

#pragma mark - PHLivePhotoViewDelegate

- (void)livePhotoView:(PHLivePhotoView *)livePhotoView willBeginPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle
{
	NSLog(@"begin playback");
}

- (void)livePhotoView:(PHLivePhotoView *)livePhotoView didEndPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle
{
	NSLog(@"end playback");
}


#pragma mark - Setup

- (void)setupInternalImageViewWithLivePhoto:(PHLivePhoto *)image  {
	self.imageView = [[PHLivePhotoView alloc] initWithFrame:self.bounds];
	//_livePhotoView.opaque = YES;
	self.imageView.contentMode = UIViewContentModeScaleAspectFit;
	//_livePhotoView.tag = ZOOM_VIEW_TAG;
	((PHLivePhotoView *)self.imageView).delegate = self;
	UIImageView *livePhotoIconView = [[UIImageView alloc] initWithImage:[PHLivePhotoView livePhotoBadgeImageWithOptions:PHLivePhotoBadgeOptionsOverContent]];

	[self updateLivePhoto:image];
	[self addSubview:self.imageView];
}

- (void)setupInternalImageViewWithImage:(UIImage *)image imageData:(NSData *)imageData {
    UIImage *imageToUse = image ?: [UIImage imageWithData:imageData];

#ifdef ANIMATED_GIF_SUPPORT
    self.imageView = [[FLAnimatedImageView alloc] initWithImage:imageToUse];
#else
    self.imageView = [[UIImageView alloc] initWithImage:imageToUse];
#endif
    [self updateImage:imageToUse imageData:imageData];
    
    [self addSubview:self.imageView];
}

- (void)updateImage:(UIImage *)image {
    [self updateImage:image imageData:nil];
}

- (void)updateImageData:(NSData *)imageData {
    [self updateImage:nil imageData:imageData];
}

- (void)updateLivePhoto:(PHLivePhoto *)image {
	// Remove any transform currently applied by the scroll view zooming.
	self.imageView.transform = CGAffineTransformIdentity;
	((PHLivePhotoView *)self.imageView).livePhoto = image;
	
	self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
	
	self.contentSize = image.size;
	
	[self updateZoomScale];
	[self centerScrollViewContents];
}

- (void)updateImage:(UIImage *)image imageData:(NSData *)imageData {
#ifdef DEBUG
#ifndef ANIMATED_GIF_SUPPORT
    if (imageData != nil) {
        NSLog(@"[NYTPhotoViewer] Warning! You're providing imageData for a photo, but NYTPhotoViewer was compiled without animated GIF support. You should use native UIImages for non-animated photos. See the NYTPhoto protocol documentation for discussion.");
    }
#endif // ANIMATED_GIF_SUPPORT
#endif // DEBUG

    UIImage *imageToUse = image ?: [UIImage imageWithData:imageData];

    // Remove any transform currently applied by the scroll view zooming.
    self.imageView.transform = CGAffineTransformIdentity;
    ((UIImageView *)self.imageView).image = imageToUse;
    
#ifdef ANIMATED_GIF_SUPPORT
    // It's necessarry to first assign the UIImage so calulations for layout go right (see above)
    self.imageView.animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:imageData];
#endif
    
    self.imageView.frame = CGRectMake(0, 0, imageToUse.size.width, imageToUse.size.height);
    
    self.contentSize = imageToUse.size;
    
    [self updateZoomScale];
    [self centerScrollViewContents];
}

- (void)setupImageScrollView {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.bouncesZoom = YES;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
}

- (CGSize)getImageSize
{
#ifdef ANIMATED_GIF_SUPPORT
		if (_isLivePhoto)
		{
			return ((PHLivePhotoView *)self.imageView).livePhoto.size;
		}
		else
		{
			if (((UIImageView *)self.imageView).animatedImage)
			{
				return ((UIImageView *)self.imageView).animatedImage.size;
			}
			else return ((UIImageView *)self.imageView).image.size;
		}
#else
	if (_isLivePhoto)
	{
		return ((PHLivePhotoView *)self.imageView).livePhoto.size;
	}
	else
	{
		return ((UIImageView *)self.imageView).image.size;
	}
#endif
}

- (void)updateZoomScale {
	BOOL imageExists = NO;
#ifdef ANIMATED_GIF_SUPPORT
	if (_isLivePhoto)
	{
		imageExists = ((PHLivePhotoView *)self.imageView).livePhoto != nil;
	}
	else
	{
		imageExists = (((UIImageView *)self.imageView).animatedImage || ((UIImageView *)self.imageView).image);
	}
#else
	if (_isLivePhoto)
	{
		imageExists = ((PHLivePhotoView *)self.imageView).livePhoto != nil;
	}
	else
	{
		imageExists = ((UIImageView *)self.imageView).image != nil;
	}
#endif


    if (imageExists) {
        CGRect scrollViewFrame = self.bounds;
        
        CGFloat scaleWidth = scrollViewFrame.size.width / [self getImageSize].width;
        CGFloat scaleHeight = scrollViewFrame.size.height / [self getImageSize].height;
        CGFloat minScale = MIN(scaleWidth, scaleHeight);
        
        self.minimumZoomScale = minScale;
        self.maximumZoomScale = MAX(minScale, self.maximumZoomScale);
        
        self.zoomScale = self.minimumZoomScale;
        
        // scrollView.panGestureRecognizer.enabled is on by default and enabled by
        // viewWillLayoutSubviews in the container controller so disable it here
        // to prevent an interference with the container controller's pan gesture.
        //
        // This is enabled in scrollViewWillBeginZooming so panning while zoomed-in
        // is unaffected.
        self.panGestureRecognizer.enabled = NO;
    }
}

#pragma mark - Centering

- (void)centerScrollViewContents {
    CGFloat horizontalInset = 0;
    CGFloat verticalInset = 0;
    
    if (self.contentSize.width < CGRectGetWidth(self.bounds)) {
        horizontalInset = (CGRectGetWidth(self.bounds) - self.contentSize.width) * 0.5;
    }
    
    if (self.contentSize.height < CGRectGetHeight(self.bounds)) {
        verticalInset = (CGRectGetHeight(self.bounds) - self.contentSize.height) * 0.5;
    }
    
    if (self.window.screen.scale < 2.0) {
        horizontalInset = __tg_floor(horizontalInset);
        verticalInset = __tg_floor(verticalInset);
    }
    
    // Use `contentInset` to center the contents in the scroll view. Reasoning explained here: http://petersteinberger.com/blog/2013/how-to-center-uiscrollview/
    self.contentInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset);
}

@end
