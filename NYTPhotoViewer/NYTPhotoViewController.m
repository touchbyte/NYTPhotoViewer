//
//  NYTPhotoViewController.m
//  NYTPhotoViewer
//
//  Created by Brian Capps on 2/11/15.
//
//

#import "NYTPhotoViewController.h"
#import "NYTPhoto.h"
#import "NYTScalingImageView.h"

#ifdef ANIMATED_GIF_SUPPORT
#import <FLAnimatedImage/FLAnimatedImage.h>
#endif

NSString * const NYTPhotoViewControllerPhotoImageUpdatedNotification = @"NYTPhotoViewControllerPhotoImageUpdatedNotification";

@interface NYTPhotoViewController () <UIScrollViewDelegate>

@property (nonatomic) id <NYTPhoto> photo;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;
- (void)setPlayButtonHidden:(BOOL)hidden animated:(BOOL)animated;

@property (nonatomic) NYTScalingImageView *scalingImageView;
@property (nonatomic) UIView *loadingView;
@property (nonatomic) NSNotificationCenter *notificationCenter;
@property (nonatomic) UITapGestureRecognizer *doubleTapGestureRecognizer;
@property (nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic) UIImageView *playButton;

@end

@implementation NYTPhotoViewController

#pragma mark - NSObject

- (void)dealloc {
    _scalingImageView.delegate = nil;
    
    [_notificationCenter removeObserver:self];
}

#pragma mark - UIViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithPhoto:nil loadingView:nil notificationCenter:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];

    if (self) {
        [self commonInitWithPhoto:nil loadingView:nil notificationCenter:nil];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.notificationCenter addObserver:self selector:@selector(photoImageUpdatedWithNotification:) name:NYTPhotoViewControllerPhotoImageUpdatedNotification object:nil];
    
    self.scalingImageView.frame = self.view.bounds;
    [self.view addSubview:self.scalingImageView];
    
    [self.view addSubview:self.loadingView];
    [self.loadingView sizeToFit];
    
    [self.view addGestureRecognizer:self.doubleTapGestureRecognizer];
    [self.view addGestureRecognizer:self.longPressGestureRecognizer];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.scalingImageView.frame = self.view.bounds;
    
    [self.loadingView sizeToFit];
    self.loadingView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

#pragma mark - NYTPhotoViewController

- (instancetype)initWithPhoto:(id <NYTPhoto>)photo loadingView:(UIView *)loadingView notificationCenter:(NSNotificationCenter *)notificationCenter {
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) {
        [self commonInitWithPhoto:photo loadingView:loadingView notificationCenter:notificationCenter];
    }
    
    return self;
}

- (void)commonInitWithPhoto:(id <NYTPhoto>)photo loadingView:(UIView *)loadingView notificationCenter:(NSNotificationCenter *)notificationCenter {
    _photo = photo;
    
    if (photo.imageData) {
        _scalingImageView = [[NYTScalingImageView alloc] initWithImageData:photo.imageData frame:CGRectZero];
    }
    else {
        UIImage *photoImage = photo.image ?: photo.placeholderImage;
        _scalingImageView = [[NYTScalingImageView alloc] initWithImage:photoImage frame:CGRectZero];
        
        if (!photoImage) {
            [self setupLoadingView:loadingView];
        }
    }

	if (!_playButton)
	{
		_playButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"videoPlayBack" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
		_playButton.userInteractionEnabled = YES;
		[self setPlayButtonHidden:YES animated:NO];
		
		UITapGestureRecognizer *playGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playButtonTapped:)];
		[_playButton addGestureRecognizer:playGesture];
		

		NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:_playButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:72];
		NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:_playButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:72];
		NSLayoutConstraint *horizontalConstraint = [NSLayoutConstraint constraintWithItem:self.playButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.scalingImageView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
		NSLayoutConstraint *verticalConstraint = [NSLayoutConstraint constraintWithItem:self.playButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.scalingImageView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
		[_playButton addConstraints:@[widthConstraint,heightConstraint]];
		[_scalingImageView addSubview:_playButton];

		UIButton *yourButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 18)];
		[yourButton setTitle:@"Button" forState:UIControlStateNormal];
		
		
		[_scalingImageView addConstraint:[NSLayoutConstraint constraintWithItem:yourButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_scalingImageView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]]; //Align veritcally center to superView
		
		[_scalingImageView addConstraint:[NSLayoutConstraint constraintWithItem:yourButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_scalingImageView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]]; //Align horizontally center to superView
		
		[_scalingImageView addSubview:yourButton]; //Add button to superView

		
		[self updateMediaTypeSpecificLayers:photo];
		
	}
	
    _scalingImageView.delegate = self;

    _notificationCenter = notificationCenter;
	
    [self setupGestureRecognizers];
}

- (void)updateMediaTypeSpecificLayers:(id <NYTPhoto>)photo
{
	if (photo.mediaType == MTVideo)
	{
		[self setPlayButtonHidden:NO animated:YES];
	}
	else
	{
		[self setPlayButtonHidden:YES animated:YES];
	}
}

- (void)playButtonTapped:(id)sender {
	NSLog(@"play");
}

- (void)setPlayButtonHidden:(BOOL)hidden animated:(BOOL)animated {
	if (hidden == self.playButton.hidden) {
		return;
	}
	
	if (animated) {
		self.playButton.hidden = NO;
		
		self.playButton.alpha = hidden ? 1.0 : 0.0;
		
		[UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionAllowUserInteraction animations:^{
			self.playButton.alpha = hidden ? 0.0 : 1.0;
		} completion:^(BOOL finished) {
			self.playButton.alpha = 1.0;
			self.playButton.hidden = hidden;
		}];
	}
	else {
		self.playButton.hidden = hidden;
	}
}


- (void)setupLoadingView:(UIView *)loadingView {
    self.loadingView = loadingView;
    if (!loadingView) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activityIndicator startAnimating];
        self.loadingView = activityIndicator;
    }
}

- (void)photoImageUpdatedWithNotification:(NSNotification *)notification {
    id <NYTPhoto> photo = notification.object;
    if ([photo conformsToProtocol:@protocol(NYTPhoto)] && [photo isEqual:self.photo]) {
        [self updateImage:photo.image imageData:photo.imageData];
    }
}

- (void)updateImage:(UIImage *)image imageData:(NSData *)imageData {
    if (imageData) {
        [self.scalingImageView updateImageData:imageData];
    }
    else {
        [self.scalingImageView updateImage:image];
    }
    
    if (imageData || image) {
        [self.loadingView removeFromSuperview];
    } else {
        [self.view addSubview:self.loadingView];
    }
}

#pragma mark - Gesture Recognizers

- (void)setupGestureRecognizers {
    self.doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTapWithGestureRecognizer:)];
    self.doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    
    self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressWithGestureRecognizer:)];
}

- (void)didDoubleTapWithGestureRecognizer:(UITapGestureRecognizer *)recognizer {
    CGPoint pointInView = [recognizer locationInView:self.scalingImageView.imageView];
    
    CGFloat newZoomScale = self.scalingImageView.maximumZoomScale;

    if (self.scalingImageView.zoomScale >= self.scalingImageView.maximumZoomScale
        || ABS(self.scalingImageView.zoomScale - self.scalingImageView.maximumZoomScale) <= 0.01) {
        newZoomScale = self.scalingImageView.minimumZoomScale;
    }
    
    CGSize scrollViewSize = self.scalingImageView.bounds.size;
    
    CGFloat width = scrollViewSize.width / newZoomScale;
    CGFloat height = scrollViewSize.height / newZoomScale;
    CGFloat originX = pointInView.x - (width / 2.0);
    CGFloat originY = pointInView.y - (height / 2.0);
    
    CGRect rectToZoomTo = CGRectMake(originX, originY, width, height);
    
    [self.scalingImageView zoomToRect:rectToZoomTo animated:YES];
}

- (void)didLongPressWithGestureRecognizer:(UILongPressGestureRecognizer *)recognizer {
    if ([self.delegate respondsToSelector:@selector(photoViewController:didLongPressWithGestureRecognizer:)]) {
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            [self.delegate photoViewController:self didLongPressWithGestureRecognizer:recognizer];
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.scalingImageView.imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    scrollView.panGestureRecognizer.enabled = YES;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    // There is a bug, especially prevalent on iPhone 6 Plus, that causes zooming to render all other gesture recognizers ineffective.
    // This bug is fixed by disabling the pan gesture recognizer of the scroll view when it is not needed.
    if (scrollView.zoomScale == scrollView.minimumZoomScale) {
        scrollView.panGestureRecognizer.enabled = NO;
    }
}

@end
