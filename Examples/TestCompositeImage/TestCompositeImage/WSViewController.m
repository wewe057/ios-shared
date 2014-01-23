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
@property (nonatomic, strong) IBOutlet UIImageView* testImage2;
@property (nonatomic, strong) IBOutlet UIImageView* testImage3;
@end

@implementation WSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage* stretch = [[UIImage imageNamed:@"stretch"] resizableImageWithCapInsets:UIEdgeInsetsMake(0,9,0,9)];
    UIImage* nipple = [UIImage imageNamed:@"nipple"];

    self.testImage.image = [UIImage stretchImage:stretch
                                          toSize:(CGSize){ 320.0f, stretch.size.height }
                                 andOverlayImage:nipple
                                     withOptions:SDImageCompositeOptionsPinSourceToTop |
                                                 SDImageCompositeOptionsCenterXOverlay |
                                                 SDImageCompositeOptionsPinOverlayToBottom];

    self.testImage2.image = [UIImage stretchImage:stretch
                                           toSize:(CGSize){ 320.0f, stretch.size.height }
                                  andOverlayImage:nipple
                                      withOptions:SDImageCompositeOptionsPinSourceToTop |
                                                  SDImageCompositeOptionsPinOverlayToRight |
                                                  SDImageCompositeOptionsPinOverlayToBottom];

    self.testImage3.image = [UIImage stretchImage:stretch
                                           toSize:(CGSize){ 320.0f, stretch.size.height }
                                  andOverlayImage:nipple
                                      withOptions:SDImageCompositeOptionsPinSourceToBottom |
                                                  SDImageCompositeOptionsPinOverlayToLeft |
                                                  SDImageCompositeOptionsPinOverlayToTop];
    
    NSData* imageData = UIImagePNGRepresentation(self.testImage3.image);
    [imageData writeToFile:@"/Users/woolie/Desktop/source-image3.png" atomically:YES];
}

@end
