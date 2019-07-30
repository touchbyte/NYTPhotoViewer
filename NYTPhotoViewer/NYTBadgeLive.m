//
//  NYTBadgeLive.m
//  NYTPhotoViewer
//
//  Created by Helmut Schottmüller on 30.07.19.
//  Copyright © 2019 NYTimes. All rights reserved.
//

#import "NYTBadgeLive.h"

@interface NYTBadgeLive ()
{
	UIImageView *livePhotoBadge;
	UITextView *livePhotoText;
}
@end

@implementation NYTBadgeLive

- (instancetype)init
{
	return [self initWithFrame:CGRectMake(0, 0, 58, 26)];
}

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	[self initComponents];
	return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	[self initComponents];
	return self;
}

- (void)initComponents
{
	UIImage *badgeImage = [UIImage imageNamed:@"liveBadge" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
	livePhotoBadge = [[UIImageView alloc] initWithImage:badgeImage];
	livePhotoBadge.tintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
	livePhotoBadge.frame = CGRectMake(4, 4, 18, 18);
	[self addSubview:livePhotoBadge];
	livePhotoText = [[UITextView alloc] initWithFrame:CGRectMake(23, 0, 35, 26)];
	livePhotoText.text = @"LIVE";
	livePhotoText.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
	livePhotoText.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
	livePhotoText.backgroundColor = [UIColor clearColor];
	float topCorrect = (livePhotoText.bounds.size.height - livePhotoText.contentSize.height * livePhotoText.zoomScale) / 2.0;
	livePhotoText.contentInset = UIEdgeInsetsMake(-2, livePhotoText.contentInset.left, livePhotoText.contentInset.bottom, livePhotoText.contentInset.right);
	[self addSubview:livePhotoText];
	
	self.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:1.0];
	self.layer.cornerRadius = 5;
	self.layer.masksToBounds = true;

	self.alpha = 0.5;
}

@end
