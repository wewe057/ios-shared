//
//  SDWebViewCell.m
//  walmart
//
//  Created by Sam Grover on 2/27/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import "SDWebViewCell.h"

#define VERTICAL_OFFSET_FOR_CELL_VIEWS 10.0f

@implementation SDWebViewCell


#pragma mark -
#pragma mark Properties

@synthesize titleLabel;
@synthesize webView;
@synthesize webViewHeight;


#pragma mark -
#pragma mark Helpers

- (void)basicSetup
{
	// Diable scrolling in the webView
	for (UIView *view in [self.webView subviews]) {
		if ([view isKindOfClass: [UIScrollView class]]) {
			UIScrollView *scrollView = (UIScrollView*)view;
			[scrollView setScrollEnabled:NO];
		}
	}
}


#pragma mark -
#pragma mark Object and Memory

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		[self basicSetup];
	}
	return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc
{
	webView.delegate = nil;
	[webView stopLoading];
    [webView release];
	webView = nil;
    [titleLabel release];
	
	[super dealloc];
}

- (void)awakeFromNib
{
	[self basicSetup];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	if (self.titleLabel.hidden) {
		self.webView.frame = CGRectMake(10.0f, VERTICAL_OFFSET_FOR_CELL_VIEWS, 300.0f, self.webViewHeight);
	} else {
		self.titleLabel.frame = CGRectMake(10.0f, VERTICAL_OFFSET_FOR_CELL_VIEWS, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height);
		[self.webView positionBelowView:self.titleLabel offset:VERTICAL_OFFSET_FOR_CELL_VIEWS];
	}
	
	self.webView.frame = CGRectMake(self.webView.frame.origin.x, self.webView.frame.origin.y, 300.0f, self.webViewHeight);
}

@end
