//
//  SDPullNavigationBarBackground.h
//  walmart
//
//  Created by Brandon Sneed on 11/06/2013.
//  Copyright (c) 2013 Walmart. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SDPullNavigationBarOverlayProtocol <NSObject>
- (void)drawOverlayRect:(CGRect)rect;
- (void)tapAction:(id)sender;
@end

@interface SDPullNavigationBarBackground : UIView
@property (nonatomic, weak) id<SDPullNavigationBarOverlayProtocol> delegate;
@end
