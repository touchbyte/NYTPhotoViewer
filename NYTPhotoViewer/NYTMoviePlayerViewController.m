//
//  NYTMoviePlayerViewController.m
//  NYTPhotoViewer
//
//  Created by Helmut Schottmüller on 22.07.19.
//  Copyright © 2019 NYTimes. All rights reserved.
//

#import "NYTMoviePlayerViewController.h"

static NSString* const AVPlayerStatusObservationContext = @"AVPlayerStatusObservationContext";

@interface NYTMoviePlayerViewController ()
@property (nonatomic, strong) AVPlayerItem *avPlayerItem;
@property (nonatomic, strong) UIAlertView *alertView;
@end

@implementation NYTMoviePlayerViewController

-(instancetype)initWithAVPlayerItem:(AVPlayerItem*)avPlayerItem
{
	if (self = [super init]) {
		self.avPlayerItem = avPlayerItem;
	}
	return self;
}

-(void)viewDidLoad
{
	[super viewDidLoad];
	self.player = [AVPlayer playerWithPlayerItem:_avPlayerItem];
	self.navigationController.navigationBar.hidden = YES;
	[self.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionPrior context:(__bridge void *)(AVPlayerStatusObservationContext)];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	
	if (context == (__bridge void *)(AVPlayerStatusObservationContext))
	{
		if (object == self.player) {
			if (self.player.status == AVPlayerStatusReadyToPlay) {
				[self.player play];
			} else  if (self.player.status == AVPlayerStatusFailed){
				NSError *error = self.player.error;
				NSString *message = [error localizedDescription];
				self.alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[NSString stringWithFormat:NSLocalizedString(@"Video could not be played", nil),message] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:nil , nil];
				[_alertView show];
			}
		}
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (NSUInteger)customInterfaceOrientations
{
	return UIInterfaceOrientationMaskAll;
}

-(void)dealloc
{
	[self.player removeObserver:self forKeyPath:@"status"];
	_alertView.delegate = nil;
}
@end
