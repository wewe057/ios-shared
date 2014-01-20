//
//  SDAnimating.h
//
//  Derived by Steven Woolgar on 01/16/2014.
//  Changes Copyright 2014 SetDirection. All rights reserved.
//

/*
    PKRevealController > PKAnimating.h
    Copyright (c) 2013 zuui.org (Philip Kluz). All rights reserved.
 
    The MIT License (MIT)
 
    Copyright (c) 2013 Philip Kluz
 
    Permission is hereby granted, free of charge, to any person obtaining a copy of
    this software and associated documentation files (the "Software"), to deal in
    the Software without restriction, including without limitation the rights to
    use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
    the Software, and to permit persons to whom the Software is furnished to do so,
    subject to the following conditions:
 
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
 
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
    FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
    COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <Foundation/Foundation.h>
#import "CAAnimation+SDIdentifier.h"

typedef void(^SDAnimationStartBlock)();
typedef void(^SDAnimationCompletionBlock)(BOOL finished);

@protocol SDAnimating <NSObject>

@required

@property (nonatomic, weak, readwrite) CALayer* layer;
@property (nonatomic, assign, readwrite, getter = isAnimating) BOOL animating;
@property (nonatomic, copy, readonly) NSString* key;
@property (nonatomic, copy, readwrite) SDAnimationStartBlock startHandler;
@property (nonatomic, copy, readwrite) SDAnimationCompletionBlock completionHandler;

- (void)startAnimationOnLayer:(CALayer*)layer;
- (void)stopAnimation;

@end
