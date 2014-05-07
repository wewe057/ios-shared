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
        UIBezierPath* trolleyPaddleCircDec2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(0.0f, 0.0f, 28.5f, 28.5f)];
        [pressesGray setFill];
        [trolleyPaddleCircDec2Path fill];
        [white setStroke];
        trolleyPaddleCircDec2Path.lineWidth = 1;
        [trolleyPaddleCircDec2Path stroke];
        
        
        //// TrolleyPaddle-Icn-Minus 4 Drawing
        UIBezierPath* trolleyPaddleIcnMinusPath = [UIBezierPath bezierPath];
        [trolleyPaddleIcnMinusPath moveToPoint: CGPointMake(8, 13)];
        [trolleyPaddleIcnMinusPath addLineToPoint: CGPointMake(21, 13)];
        [trolleyPaddleIcnMinusPath addLineToPoint: CGPointMake(21, 16)];
        [trolleyPaddleIcnMinusPath addLineToPoint: CGPointMake(8, 16)];
        [trolleyPaddleIcnMinusPath addLineToPoint: CGPointMake(8, 13)];
        [trolleyPaddleIcnMinusPath closePath];
        [white setFill];
        [trolleyPaddleIcnMinusPath fill];
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
        UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(0.5f, 0.5f, 28.0f, 28.0f)];
        [pressesGray setFill];
        [ovalPath fill];
        [white setStroke];
        ovalPath.lineWidth = 1;
        [ovalPath stroke];
        
        
        //// TrolleyPaddle-Icn-Plus 6 Drawing
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
        [white setFill];
        [trolleyPaddleIcnPlusPath fill];
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
@property (nonatomic, strong) NSLayoutConstraint *labelWidthConstraint;
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
	[_quantityLabel setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_quantityLabel];
    
    _rightImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _rightImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [_rightImageView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_rightImageView setContentCompressionResistancePriority:0 forAxis:UILayoutConstraintAxisHorizontal];
    
    [self setNeedsUpdateConstraints];
}

- (void)setRightImage:(UIImage *)image
{
    if (image && [self.rightImageView superview] == nil)
    {
        [self addSubview:self.rightImageView];
    }
    else if (image == nil && [self.rightImageView superview] != nil)
    {
        [self.rightImageView removeFromSuperview];
    }
    self.rightImageView.image = image;
    self.rightImageView.contentMode = UIViewContentModeScaleAspectFit;
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
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_decrementButton(29)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_decrementButton)]];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_incrementButton(29)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_incrementButton)]];
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:[_quantityLabel]-(2)-[_rightImageView(%tu)]", (NSUInteger)self.rightImageView.image.size.width] options:0 metrics:nil views:NSDictionaryOfVariableBindings(_quantityLabel, _rightImageView)]];
            
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.quantityLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:-self.rightImageView.image.size.width/2.0]];
        }
        else
        {
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_decrementButton(29)][_quantityLabel][_incrementButton(29)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_decrementButton, _quantityLabel, _incrementButton)]];
        }
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.quantityLabel attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:1.0f]];
        
        self.hasSetupConstraints = YES;
    }
    [self updateLabelWidthConstraint];
    [super updateConstraints];
}

- (void) updateLabelWidthConstraint
{
    if (self.labelWidthConstraint != nil)
    {
        [self removeConstraint:self.labelWidthConstraint];
        self.labelWidthConstraint = nil;
    }
    
    if (self.rightImageView.image)
    {
        static const CGFloat kSDQuantityViewLabelMargin = 2.0;
        CGFloat maxLabelWidth = CGRectGetWidth(self.bounds) - (kCircularButtonWidth + 2.0 + self.rightImageView.image.size.width + kCircularButtonWidth + 2 * kSDQuantityViewLabelMargin);
        if ( maxLabelWidth > 1.0 ) {
            self.labelWidthConstraint = [NSLayoutConstraint constraintWithItem:self.quantityLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:maxLabelWidth];
            [self addConstraint:self.labelWidthConstraint];
        }
    }
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

- (void) setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    if (self.rightImageView.image)
        [self setNeedsUpdateConstraints];
}

@end
