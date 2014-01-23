//
//  WSViewController.m
//  TestImage
//
//  Created by Steven Woolgar on 01/22/2014.
//  Copyright (c) 2014 Steven Woolgar. All rights reserved.
//

#import "WSViewController.h"

#import "UIImage+SDExtensions.h"

@interface WSViewController ()
@property (nonatomic, strong) IBOutlet UIImageView* testImage;
@property (nonatomic, strong) IBOutlet UIImageView* sourceImage;
@property (nonatomic, strong) IBOutlet UILabel* matchesLabel;
@end

@implementation WSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage* stretch = [[UIImage imageNamed:@"stretch"] resizableImageWithCapInsets:UIEdgeInsetsMake(0,9,0,9)];
    UIImage* nipple = [UIImage imageNamed:@"nipple"];

    UIImage* compositedImage = [UIImage stretchImage:stretch
                                              toSize:(CGSize){ 320.0f, stretch.size.height }
                                     andOverlayImage:nipple
                                         withOptions:SDImageCompositeOptionsPinSourceToTop |
                                                     SDImageCompositeOptionsCenterXOverlay |
                                                     SDImageCompositeOptionsPinOverlayToBottom];

    self.testImage.image = compositedImage;
    self.sourceImage.image = [UIImage imageNamed:@"source-image"];

    NSData* imageData = UIImagePNGRepresentation(compositedImage);
    NSData* sourceData = UIImagePNGRepresentation(compositedImage);

    if([imageData isEqualToData:sourceData])
    {
        self.matchesLabel.hidden = NO;
    }
}

@end
