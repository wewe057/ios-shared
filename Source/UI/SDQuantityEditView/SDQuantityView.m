//
//  ASDATrolleyQuantityView.m
//  asda
//
//  Created by ricky cancro on 10/31/13.
//  Copyright (c) 2013 Asda. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "SDQuantityView.h"

@interface SDCircularMinusButton()
@end

@implementation SDCircularMinusButton

+ (instancetype)circularMinusButtonWithStrokeColor:(UIColor *)strokeColor;
{
    SDCircularMinusButton *circularButton = [[SDCircularMinusButton alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
    circularButton.strokeColor = strokeColor;
    [circularButton createButtonStates];
    return circularButton;
}

- (void)setStrokeColor:(UIColor *)strokeColor
{
    _strokeColor = strokeColor;
    [self createButtonStates];
}

- (void)setHighlightedColor:(UIColor *)highlightedColor
{
    _highlightedColor = highlightedColor;
    [self createButtonStates];
}

- (void)drawButtonNormalWithColor:(UIColor *)strokeColor
{
    //// Color Declarations
    UIColor* white = [UIColor whiteColor];
    
    //// Btn-Dec
    {
        //// TrolleyPaddle-CircDec Drawing
        UIBezierPath* trolleyPaddleCircDecPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(0.5, 0.5, 28, 28)];
        [white setFill];
        [trolleyPaddleCircDecPath fill];
        [strokeColor setStroke];
        trolleyPaddleCircDecPath.lineWidth = 1;
        [trolleyPaddleCircDecPath stroke];
        
        
        //// TrolleyPaddle-Icn-Minus Drawing
        UIBezierPath* trolleyPaddleIcnMinusPath = [UIBezierPath bezierPath];
        [trolleyPaddleIcnMinusPath moveToPoint: CGPointMake(8, 13)];
        [trolleyPaddleIcnMinusPath addLineToPoint: CGPointMake(21, 13)];
        [trolleyPaddleIcnMinusPath addLineToPoint: CGPointMake(21, 16)];
        [trolleyPaddleIcnMinusPath addLineToPoint: CGPointMake(8, 16)];
        [trolleyPaddleIcnMinusPath addLineToPoint: CGPointMake(8, 13)];
        [trolleyPaddleIcnMinusPath closePath];
        [strokeColor setFill];
        [trolleyPaddleIcnMinusPath fill];
    }}

- (void)drawButtonNormal
{
    [self drawButtonNormalWithColor:self.strokeColor];
}

- (void)drawButtonDisabled
{
    [self drawButtonNormalWithColor:[self.strokeColor colorWithAlphaComponent:0.4f]];

}

- (void)drawButtonHighlighted
{
    //// Color Declarations
    UIColor* white = [UIColor whiteColor];
    UIColor* pressesGray = self.highlightedColor;
    
    //// Btn-DecPressed
    {
        //// TrolleyPaddle-CircDec2 Drawing
        UIBezierPath* trolleyPaddleCircDec2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(0, 0, 30, 30)];
        [pressesGray setFill];
        [trolleyPaddleCircDec2Path fill];
        [white setStroke];
        trolleyPaddleCircDec2Path.lineWidth = 1;
        [trolleyPaddleCircDec2Path stroke];
        
        
        //// TrolleyPaddle-Icn-Minus 4 Drawing
        UIBezierPath* trolleyPaddleIcnMinus4Path = [UIBezierPath bezierPath];
        [trolleyPaddleIcnMinus4Path moveToPoint: CGPointMake(9, 14)];
        [trolleyPaddleIcnMinus4Path addLineToPoint: CGPointMake(22, 14)];
        [trolleyPaddleIcnMinus4Path addLineToPoint: CGPointMake(22, 17)];
        [trolleyPaddleIcnMinus4Path addLineToPoint: CGPointMake(9, 17)];
        [trolleyPaddleIcnMinus4Path addLineToPoint: CGPointMake(9, 14)];
        [trolleyPaddleIcnMinus4Path closePath];
        [white setFill];
        [trolleyPaddleIcnMinus4Path fill];
    }
}

@end

@interface SDCircularPlusButton()
@end

@implementation SDCircularPlusButton

+ (instancetype)circularPlusButtonWithStrokeColor:(UIColor *)strokeColor;
{
    SDCircularPlusButton *circularButton = [[SDCircularPlusButton alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
    circularButton.strokeColor = strokeColor;
    [circularButton createButtonStates];
    return circularButton;
}

- (void)setStrokeColor:(UIColor *)strokeColor
{
    _strokeColor = strokeColor;
    [self createButtonStates];
}


- (void)setHighlightedColor:(UIColor *)highlightedColor
{
    _highlightedColor = highlightedColor;
    [self createButtonStates];
}

- (void)drawButtonNormalWithColor:(UIColor *)strokeColor
{
    //// Color Declarations
    UIColor* white = [UIColor whiteColor];
    
    //// Btn-Inc
    {
        //// TrolleyPaddle-CircInc Drawing
        UIBezierPath* trolleyPaddleCircIncPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(0.5, 0.5, 28, 28)];
        [white setFill];
        [trolleyPaddleCircIncPath fill];
        [strokeColor setStroke];
        trolleyPaddleCircIncPath.lineWidth = 1;
        [trolleyPaddleCircIncPath stroke];
        
        
        //// TrolleyPaddle-Icn-Plus Drawing
        UIBezierPath* trolleyPaddleIcnPlusPath = [UIBezierPath bezierPath];
        [trolleyPaddleIcnPlusPath moveToPoint: CGPointMake(7, 13)];
        [trolleyPaddleIcnPlusPath addLineToPoint: CGPointMake(22, 13)];
        [trolleyPaddleIcnPlusPath addLineToPoint: CGPointMake(22, 16)];
        [trolleyPaddleIcnPlusPath addLineToPoint: CGPointMake(7, 16)];
        [trolleyPaddleIcnPlusPath addLineToPoint: CGPointMake(7, 13)];
        [trolleyPaddleIcnPlusPath closePath];
        [trolleyPaddleIcnPlusPath moveToPoint: CGPointMake(16, 7)];
        [trolleyPaddleIcnPlusPath addLineToPoint: CGPointMake(16, 22)];
        [trolleyPaddleIcnPlusPath addLineToPoint: CGPointMake(13, 22)];
        [trolleyPaddleIcnPlusPath addLineToPoint: CGPointMake(13, 7)];
        [trolleyPaddleIcnPlusPath addLineToPoint: CGPointMake(16, 7)];
        [trolleyPaddleIcnPlusPath closePath];
        [strokeColor setFill];
        [trolleyPaddleIcnPlusPath fill];
    }
}

- (void)drawButtonNormal
{
    [self drawButtonNormalWithColor:self.strokeColor];
}

- (void)drawButtonDisabled
{
    [self drawButtonNormalWithColor:[self.strokeColor colorWithAlphaComponent:0.4f]];
}

- (void)drawButtonHighlighted
{
    //// Color Declarations
    UIColor* white = [UIColor whiteColor];
    UIColor* pressesGray = self.highlightedColor;
    
    //// Btn-IncPressed
    {
        //// Oval Drawing
        UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(0, 0, self.width, self.height)];
        [pressesGray setFill];
        [ovalPath fill];
        [white setStroke];
        ovalPath.lineWidth = 1;
        [ovalPath stroke];
        
        
        //// TrolleyPaddle-Icn-Plus 6 Drawing
        UIBezierPath* trolleyPaddleIcnPlus6Path = [UIBezierPath bezierPath];
        [trolleyPaddleIcnPlus6Path moveToPoint: CGPointMake(8, 14)];
        [trolleyPaddleIcnPlus6Path addLineToPoint: CGPointMake(23, 14)];
        [trolleyPaddleIcnPlus6Path addLineToPoint: CGPointMake(23, 17)];
        [trolleyPaddleIcnPlus6Path addLineToPoint: CGPointMake(8, 17)];
        [trolleyPaddleIcnPlus6Path addLineToPoint: CGPointMake(8, 14)];
        [trolleyPaddleIcnPlus6Path closePath];
        [trolleyPaddleIcnPlus6Path moveToPoint: CGPointMake(17, 8)];
        [trolleyPaddleIcnPlus6Path addLineToPoint: CGPointMake(17, 23)];
        [trolleyPaddleIcnPlus6Path addLineToPoint: CGPointMake(14, 23)];
        [trolleyPaddleIcnPlus6Path addLineToPoint: CGPointMake(14, 8)];
        [trolleyPaddleIcnPlus6Path addLineToPoint: CGPointMake(17, 8)];
        [trolleyPaddleIcnPlus6Path closePath];
        [white setFill];
        [trolleyPaddleIcnPlus6Path fill];
    }
}


@end

@interface SDQuantityView()
@property (nonatomic, assign) BOOL setupContrainst;
@property (nonatomic, strong, readwrite) SDCircularPlusButton *incrementButton;
@property (nonatomic, strong, readwrite) SDCircularMinusButton *decrementButton;
@end

@implementation SDQuantityView

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

+ (instancetype)quantityView
{
    SDQuantityView *quantityView = [[SDQuantityView alloc] initWithFrame:CGRectMake(0, 0, 110.0f, 29.0f)];
    [quantityView setup];
    return quantityView;
}

- (void)setup
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
 
    self.incrementButton = [[SDCircularPlusButton alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
    self.incrementButton.strokeColor = self.fillColor;
    self.incrementButton.highlightedColor = [UIColor lightGrayColor];
    
    self.decrementButton = [[SDCircularMinusButton alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
    self.decrementButton.strokeColor = self.fillColor;
    self.decrementButton.highlightedColor = [UIColor lightGrayColor];
    
    self.incrementButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.decrementButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:self.incrementButton];
    [self addSubview:self.decrementButton];
    
    self.quantityLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.quantityLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.quantityLabel setFont:[UIFont systemFontOfSize:14]];
    [self addSubview:self.quantityLabel];
}

- (void)setFillColor:(UIColor *)fillColor
{
    _fillColor = fillColor;
    
    self.incrementButton.strokeColor = fillColor;
    self.decrementButton.strokeColor = fillColor;
}

- (void)updateConstraints
{
    if (self.setupContrainst == NO)
    {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[incrementButton(29)]|" options:0 metrics:nil views:@{@"incrementButton":self.incrementButton}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[decrementButton(29)]|" options:0 metrics:nil views:@{@"decrementButton":self.decrementButton}]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[decrementButton(29)]" options:0 metrics:nil views:@{@"decrementButton":self.decrementButton}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[incrementButton(29)]|" options:0 metrics:nil views:@{@"incrementButton":self.incrementButton}]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.quantityLabel attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:1.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.quantityLabel attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:1.0f]];
        
        self.setupContrainst = YES;
    }
    [super updateConstraints];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setupLayer];
}

- (void)setupLayer
{
    CAShapeLayer *layer = (CAShapeLayer *)self.layer;
    CGRect bgRect = self.bounds;
    bgRect = CGRectInset(self.bounds, 14, 0);
    bgRect.origin.y += 0.5f;
    bgRect.size.height -= 1.0f;
    layer.path = CGPathCreateWithRect(bgRect, nil);
    
    layer.fillColor = self.fillColor.CGColor;
    layer.strokeColor = self.fillColor.CGColor;
}

@end
