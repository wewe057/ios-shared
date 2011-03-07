//
//  SDWebViewCell.h
//  walmart
//
//  Created by Sam Grover on 2/27/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SDWebViewCell : UITableViewCell {
	UILabel *titleLabel;
	UIWebView *webView;
	CGFloat webViewHeight;
}

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIWebView *webView;

// It's the responsibility of the VC that manages this cell to set the height after it loads the HTML.
@property (nonatomic, assign) CGFloat webViewHeight;

@end
