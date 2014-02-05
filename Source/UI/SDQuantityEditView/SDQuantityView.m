//
//  SDQuantityView.m
//
//  Created by ricky cancro on 10/31/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "SDQuantityView.h"

static const CGFloat kCircularButtonWidth = 29.0f;
static const CGFloat kCircularButtonHeight = 29.0f;

@interface SDCircularMinusButton()
@end

@implementation SDCircularMinusButton

+ (instancetype)circularMinusButtonWithStrokeColor:(UIColor *)strokeColor;
{
    SDCircularMinusButton *circularButton = [[SDCircularMinusButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kCircularButtonWidth, kCircularButtonHeight)];
    circularButton.strokeColor = strokeColor;
    [circularButton createButtonStates];
    return circularButton;
}

- (void)setStrokeColor:(UIColor *)strokeColor
{
    if (_strokeColor != strokeColor)
    {
        _strokeColor = strokeColor;
        [self createButtonStates];
    }
}

- (void)setHighlightedColor:(UIColor *)highlightedColor
{
    if (_highlightedColor != highlightedColor)
    {
        _highlightedColor = highlightedColor;
        [self createButtonStates];
    }
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
    SDCircularPlusButton *circularButton = [[SDCircularPlusButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kCircularButtonWidth, kCircularButtonHeight)];
    circularButton.strokeColor = strokeColor;
    [circularButton createButtonStates];
    return circularButton;
}

- (void)setStrokeColor:(UIColor *)strokeColor
{
    if (_strokeColor != strokeColor)
    {
        _strokeColor = strokeColor;
        [self createButtonStates];
    }
}


- (void)setHighlightedColor:(UIColor *)highlightedColor
{
    if (_highlightedColor != highlightedColor)
    {
        _highlightedColor = highlightedColor;
        [self createButtonStates];
    }
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
        UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
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

static const CGFloat kSDQuantityViewBackgroundWidthInset = 14.0f;

@interface SDQuantityView()
@property (nonatomic, assign) BOOL hasSetupConstraints;
@property (nonatomic, strong, readwrite) SDCircularPlusButton *incrementButton;
@property (nonatomic, strong, readwrite) SDCircularMinusButton *decrementButton;
@property (nonatomic, strong, readwrite) UIImageView *rightImageView;
@property (nonatomic, strong, readwrite) UILabel *quantityLabel;
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
 
    _incrementButton = [SDCircularPlusButton circularPlusButtonWithStrokeColor:_fillColor];
    _incrementButton.highlightedColor = [UIColor lightGrayColor];
    
    _decrementButton = [SDCircularMinusButton circularMinusButtonWithStrokeColor:_fillColor];
    _decrementButton.highlightedColor = [UIColor lightGrayColor];
    
    _incrementButton.translatesAutoresizingMaskIntoConstraints = NO;
    _decrementButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:_incrementButton];
    [self addSubview:_decrementButton];
    
    _quantityLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _quantityLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _quantityLabel.textAlignment = NSTextAlignmentCenter;
    [_quantityLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [_quantityLabel setContentCompressionResistancePriority:1000 forAxis:UILayoutConstraintAxisHorizontal];
    [_quantityLabel setFont:[UIFont systemFontOfSize:14]];
    [self addSubview:_quantityLabel];
    
    _rightImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _rightImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [_rightImageView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_rightImageView setContentCompressionResistancePriority:0 forAxis:UILayoutConstraintAxisHorizontal];
    [self addSubview:_rightImageView];
}

- (void)setRightImage:(UIImage *)image
{
    self.rightImageView.image = image;
    self.hasSetupConstraints = NO;
    [self setNeedsUpdateConstraints];
}

- (void)setFillColor:(UIColor *)fillColor
{
    if (_fillColor != fillColor)
    {
        _fillColor = fillColor;
        
        self.incrementButton.strokeColor = fillColor;
        self.decrementButton.strokeColor = fillColor;
    }
}

- (void)updateConstraints
{
    if (self.hasSetupConstraints == NO)
    {
        [self removeConstraints:[self constraints]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_incrementButton(29)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_incrementButton)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_decrementButton(29)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_decrementButton)]];
        
        if (self.rightImageView.image)
        {
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_rightImageView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_rightImageView)]];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_decrementButton(29)][_quantityLabel][_rightImageView][_incrementButton(29)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_decrementButton, _quantityLabel, _rightImageView, _incrementButton)]];
        }
        else
        {
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_decrementButton(29)][_quantityLabel][_incrementButton(29)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_decrementButton, _quantityLabel, _incrementButton)]];
        }
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.quantityLabel attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:1.0f]];
        
        self.hasSetupConstraints = YES;
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
    CGRect bgRect = CGRectInset(self.bounds, kSDQuantityViewBackgroundWidthInset, 0.0f);
    bgRect.origin.y += 0.5f;
    bgRect.size.height -= 1.0f;

    CGPathRef path = CGPathCreateWithRect(bgRect, NULL);
    layer.path = path;
    CGPathRelease(path);
    
    layer.fillColor = self.fillColor.CGColor;
    layer.strokeColor = self.fillColor.CGColor;
}

@end
