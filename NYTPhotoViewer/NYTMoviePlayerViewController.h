//
//  NYTMoviePlayerViewController.h
//  NYTPhotoViewer
//
//  Created by Helmut Schottmüller on 22.07.19.
//  Copyright © 2019 NYTimes. All rights reserved.
//

@import UIKit;
@import AVKit;

@interface NYTMoviePlayerViewController : AVPlayerViewController
{
	NSURL *_contentURL;
}

-(instancetype)initWithAVPlayerItem:(AVPlayerItem*)avPlayerItem;

@end
