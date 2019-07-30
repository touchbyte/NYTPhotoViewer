//
//  NYTPhotoViewController.m
//  NYTPhotoViewer
//
//  Created by Brian Capps on 2/11/15.
//
//

#import "NYTPhotoViewController.h"
#import "NYTPhoto.h"
#import "NYTMediaResource.h"
#import "NYTScalingImageView.h"
#import "NYTMoviePlayerViewController.h"
#import "NYTBadgeLive.h"

#ifdef ANIMATED_GIF_SUPPORT
#import <FLAnimatedImage/FLAnimatedImage.h>
#endif

NSString * const NYTPhotoViewControllerPhotoImageUpdatedNotification = @"NYTPhotoViewControllerPhotoImageUpdatedNotification";

@interface NYTPhotoViewController () <UIScrollViewDelegate>

@property (nonatomic) id <NYTPhoto> photo;
@property (nonatomic, readonly) NYTBadgeLive *livePhotoBadge;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;
- (void)setPlayButtonHidden:(BOOL)hidden animated:(BOOL)animated;

@property (nonatomic) NYTScalingImageView *scalingImageView;
@property (nonatomic) UIView *loadingView;
@property (nonatomic) NSNotificationCenter *notificationCenter;
@property (nonatomic) UITapGestureRecognizer *doubleTapGestureRecognizer;
@property (nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic) UIButton *playButton;

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
	
	[self.view addSubview:_playButton];
	
	self.playButton.translatesAutoresizingMaskIntoConstraints = NO;
	id views = @{@"playButton": self.playButton};
	// playbutton constraints
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[playButton(72)]" options:0 metrics:nil views:views]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[playButton(72)]" options:0 metrics:nil views:views]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.playButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.playButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
	
	[self.view addSubview:_livePhotoBadge];
	self.livePhotoBadge.translatesAutoresizingMaskIntoConstraints = NO;
	id liveViews = @{@"livePhotoBadge": self.livePhotoBadge};
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:[livePhotoBadge(%.f)]", self.livePhotoBadge.bounds.size.width] options:0 metrics:nil views:liveViews]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[livePhotoBadge(%.f)]", self.livePhotoBadge.bounds.size.height] options:0 metrics:nil views:liveViews]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.livePhotoBadge attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:6.0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.livePhotoBadge attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:100.0]];
	
	[self.view addGestureRecognizer:self.doubleTapGestureRecognizer];
	[self.view addGestureRecognizer:self.longPressGestureRecognizer];
}

- (void)setOverlayViewsHidden:(BOOL)hidden animated:(BOOL)animated
{
	if ([self isLivePhoto:_photo])
	{
		[self setLivePhotoBadgeHidden:hidden animated:animated];
	}
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	
	self.scalingImageView.frame = self.view.bounds;
	
	[self.loadingView sizeToFit];
	self.loadingView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	
	/*
	if ([self isLivePhoto:_photo])
	{
		CGFloat leftOffset = (self.view.bounds.size.width - (self.scalingImageView.zoomScale * [self.scalingImageView getImageSize].width))/2.0 + 10;
		CGFloat topOffset = (self.view.bounds.size.height - (self.scalingImageView.zoomScale * [self.scalingImageView getImageSize].height))/2.0 + 10;
		CGFloat topOffsetLive = topOffset;
		
		CGFloat layoutGuide = ((UIViewController*)self.parentViewController).topLayoutGuide.length;
		if (topOffsetLive <layoutGuide) topOffsetLive = layoutGuide;
		self.livePhotoBadge.frame = CGRectMake(leftOffset+15, topOffsetLive+15, self.livePhotoBadge.image.size.width, self.livePhotoBadge.image.size.height);
	}
	 */

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

- (BOOL)isLivePhoto:(id <NYTPhoto>)photo
{
	__block BOOL hasPhoto = false;
	__block BOOL hasVideo = false;
	if (photo.resources.count == 2)
	{
		[photo.resources enumerateObjectsUsingBlock:^(id<NYTMediaResource> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			if (obj.resourceType == RTPhoto)
			{
				hasPhoto = true;
			}
			else if (obj.resourceType == RTVideo)
			{
				hasVideo = true;
			}
		}];
	}
	return (hasPhoto && hasVideo) ? true : false;
}

- (void)commonInitWithPhoto:(id <NYTPhoto>)photo loadingView:(UIView *)loadingView notificationCenter:(NSNotificationCenter *)notificationCenter {
	_photo = photo;
	
	if ([self isLivePhoto:photo])
	{
#ifdef __IPHONE_9_1
		self.scalingImageView = [[NYTScalingImageView alloc] initWithLivePhoto:nil frame:CGRectZero];
		[self setupVideoPlayButton];
		self.scalingImageView.delegate = self;
		self.notificationCenter = notificationCenter;
		[self setupGestureRecognizers];
		
		__typeof(self) __weak weakSelf = self;
		[PHLivePhoto requestLivePhotoWithResourceFileURLs:@[photo.resources[0].url, photo.resources[1].url] placeholderImage:nil targetSize:CGSizeZero contentMode:PHImageContentModeAspectFill resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nonnull info) {
			[weakSelf.scalingImageView updateLivePhoto:livePhoto];
			/*
			CGFloat leftOffset = (weakSelf.view.bounds.size.width - (weakSelf.scalingImageView.zoomScale * [weakSelf.scalingImageView getImageSize].width))/2.0 + 10;
			CGFloat topOffset = (weakSelf.view.bounds.size.height - (weakSelf.scalingImageView.zoomScale * [weakSelf.scalingImageView getImageSize].height))/2.0 + 10;
			CGFloat topOffsetLive = topOffset;
			
			CGFloat layoutGuide = ((UIViewController*)weakSelf.parentViewController).topLayoutGuide.length;
			if (topOffsetLive <layoutGuide) topOffsetLive = layoutGuide;
			weakSelf.livePhotoBadge.frame = CGRectMake(leftOffset+15, topOffsetLive+15, weakSelf.livePhotoBadge.image.size.width, weakSelf.livePhotoBadge.image.size.height);
			 */
		}];
#else
		if (photo.imageData) {
			self.scalingImageView = [[NYTScalingImageView alloc] initWithImage:photo.image frame:CGRectZero];
		}
#endif
	}
	else
	{
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
	}
	
	[self setupVideoPlayButton];
	[self setupLivePhotoBadge];
	_scalingImageView.delegate = self;
	_notificationCenter = notificationCenter;
	[self setupGestureRecognizers];
}

- (void)setupVideoPlayButton
{
	if (!_playButton)
	{
		_playButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 72, 72)];
		[_playButton setBackgroundImage:[UIImage imageNamed:@"videoPlayBack" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
		[_playButton setBackgroundImage:[UIImage imageNamed:@"videoPlayBack_highlighted" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateHighlighted];
		[_playButton addTarget:self action:@selector(playButtonTapped:)
					forControlEvents:UIControlEventTouchUpInside];
		[self setPlayButtonHidden:YES animated:NO];
		
		//UITapGestureRecognizer *playGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playButtonTapped:)];
		//[_playButton addGestureRecognizer:playGesture];
		
		[self updateMediaTypeSpecificLayers:self.photo];
		
	}
}

- (void)setupLivePhotoBadge
{
	if (!_livePhotoBadge)
	{
		_livePhotoBadge = [NYTBadgeLive new];
		//_livePhotoBadge = [[UIImageView alloc] initWithImage:[PHLivePhotoView livePhotoBadgeImageWithOptions:PHLivePhotoBadgeOptionsOverContent]];
		[self setLivePhotoBadgeHidden:YES animated:NO];
		
		[self updateMediaTypeSpecificLayers:self.photo];
	}
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
	if ([self isLivePhoto:photo])
	{
		[self setLivePhotoBadgeHidden:NO animated:NO];
	}
	else
	{
		[self setLivePhotoBadgeHidden:YES animated:NO];
	}
}

- (void)playButtonTapped:(UIButton *)button {
	if (self.photo.resources && [self.photo.resources count] > 0)
	{
		AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:self.photo.resources[0].url];
		dispatch_async(dispatch_get_main_queue(), ^{
			NYTMoviePlayerViewController *playerViewController = [[NYTMoviePlayerViewController alloc] initWithAVPlayerItem:item];
			UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:playerViewController];
			[self presentViewController:navController animated:YES completion:^{
			}];
		});
	}
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

- (void)setLivePhotoBadgeHidden:(BOOL)hidden animated:(BOOL)animated {
	if (hidden == self.livePhotoBadge.hidden) {
		return;
	}
	
	if (animated) {
		self.livePhotoBadge.hidden = NO;
		
		self.livePhotoBadge.alpha = hidden ? 0.5 : 0.0;
		
		[UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionAllowUserInteraction animations:^{
			self.livePhotoBadge.alpha = hidden ? 0.0 : 0.5;
		} completion:^(BOOL finished) {
			self.livePhotoBadge.alpha = 0.5;
			self.livePhotoBadge.hidden = hidden;
		}];
	}
	else {
		self.livePhotoBadge.hidden = hidden;
		if (!hidden) self.livePhotoBadge.alpha = 0.5;
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
