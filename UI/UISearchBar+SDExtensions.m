//
//  UISearchBar+SDExtensions.m
//  walmart
//
//  Created by Brandon Sneed on 10/27/11.
//  Copyright (c) 2011 Walmart. All rights reserved.
//

#import "UISearchBar+SDExtensions.h"
#import <QuartzCore/QuartzCore.h>

@implementation UISearchBar (SDExtensions)

+ (UIImage *)backgroundImage
{
	static UIImage *image = nil;
	if (image == nil)
		image = [UIImage imageNamed:@"searchBarBackground.png"];
	
	return image;
}

//- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)contenxt
- (void)drawRect:(CGRect)rect
{
	UIImage *image = [UISearchBar backgroundImage];  
	
	for (UIView * subview in self.subviews)
	{
		if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) 
			subview.alpha = 0.0; 
		
		if ([subview isKindOfClass:NSClassFromString(@"UISegmentedControl")])
			subview.alpha = 0.0; 
	}
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context , 0 , image.size.height );
	CGContextScaleCTM(context, 1.0, -1.0 );
	CGContextDrawImage(context , CGRectMake(0 , 0 , rect.size.width , rect.size.height), image.CGImage);
}  

@end
