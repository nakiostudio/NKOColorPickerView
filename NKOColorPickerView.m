/*
 The MIT License (MIT)
 
 Copyright (C) 2014 Carlos Vidal
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
 documentation files (the "Software"), to deal in the Software without restriction, including without
 limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 the Software, and to permit persons to whom the Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial
 portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
 LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
 EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
 AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
 OR OTHER DEALINGS IN THE SOFTWARE LICENSE
 */

//
//  NKOColorPickerView.h
//  ColorPicker
//
//  Created by Carlos Vidal
//  Based on work by Fabián Cañas and Gilly Dekel
//

#import "NKOColorPickerView.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

//NKOBrightnessView
@interface NKOBrightnessView: UIView

@property (nonatomic, strong) UIColor *color;

@end

//UIImage category
@interface UIImage(NKO)

- (UIImage*)nko_tintImageWithColor:(UIColor*)tintColor;

@end

//NKOColorPickerView

CGFloat const NKOPickerViewGradientViewHeight           = 40.f;
CGFloat const NKOPickerViewGradientTopMargin            = 20.f;
CGFloat const NKOPickerViewDefaultMargin                = 10.f;
CGFloat const NKOPickerViewBrightnessIndicatorWidth     = 16.f;
CGFloat const NKOPickerViewBrightnessIndicatorHeight    = 48.f;
CGFloat const NKOPickerViewCrossHairshWidthAndHeight    = 38.f;

@interface NKOColorPickerView()

@property (nonatomic, strong) NKOBrightnessView *gradientView;

@property (nonatomic, strong) UIImageView *brightnessIndicator;
@property (nonatomic, strong) UIImageView *hueSatImage;
@property (nonatomic, strong) UIView *crossHairs;

@property (nonatomic, assign) CGFloat currentBrightness;
@property (nonatomic, assign) CGFloat currentSaturation;
@property (nonatomic, assign) CGFloat currentHue;

@end

@implementation NKOColorPickerView

- (id)initWithFrame:(CGRect)frame color:(UIColor*)color andDidChangeColorBlock:(NKOColorPickerDidChangeColorBlock)didChangeColorBlock {
    
    self = [super init];
    
    if (self != nil){
        self.frame = frame;
        
        self->_color = color;
        self->_didChangeColorBlock = didChangeColorBlock;
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    
    [super willMoveToSuperview:newSuperview];
    
    [self.crossHairs setHidden:NO];
    [self.brightnessIndicator setHidden:NO];
    
    if (self->_color == nil){
        self.color = [self _defaultTintColor];
    }
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.hueSatImage.frame = CGRectMake(NKOPickerViewDefaultMargin,
                                        NKOPickerViewDefaultMargin,
                                        CGRectGetWidth(self.frame) - (NKOPickerViewDefaultMargin*2),
                                        CGRectGetHeight(self.frame) - NKOPickerViewGradientViewHeight - NKOPickerViewDefaultMargin - NKOPickerViewGradientTopMargin);
    
    self.gradientView.frame = CGRectMake(NKOPickerViewDefaultMargin,
                                         CGRectGetHeight(self.frame) - NKOPickerViewGradientViewHeight - NKOPickerViewDefaultMargin,
                                         CGRectGetWidth(self.frame) - (NKOPickerViewDefaultMargin*2),
                                         NKOPickerViewGradientViewHeight);
    
    [self _updateBrightnessPosition];
    [self _updateCrosshairPosition];
}

#pragma mark - Public methods

- (void)setTintColor:(UIColor *)tintColor {
    self.hueSatImage.layer.borderColor = tintColor.CGColor;
    self.gradientView.layer.borderColor = tintColor.CGColor;
    self.brightnessIndicator.image = [[UIImage imageNamed:@"nko_brightness_guide"] nko_tintImageWithColor:tintColor];
}

- (void)setColor:(UIColor *)newColor {
    
    CGFloat hue = 0.f;
    CGFloat saturation = 0.f;
    [newColor getHue:&hue saturation:&saturation brightness:nil alpha:nil];

    self.currentHue = hue;
    self.currentSaturation = saturation;
    [self _setColor:newColor];
    [self _updateGradientColor];
    [self _updateBrightnessPosition];
    [self _updateCrosshairPosition];
}

#pragma mark - Private methods

- (void)_setColor:(UIColor *)newColor {
    
    if (![self->_color isEqual:newColor]){
        CGFloat brightness;
        [newColor getHue:NULL saturation:NULL brightness:&brightness alpha:NULL];
        CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(CGColorGetColorSpace(newColor.CGColor));
        
        if (colorSpaceModel==kCGColorSpaceModelMonochrome) {
            const CGFloat *c = CGColorGetComponents(newColor.CGColor);
            self->_color = [UIColor colorWithHue:0 saturation:0 brightness:c[0] alpha:1.0];
        }
        else{
            self->_color = [newColor copy];
        }
        
        if (self.didChangeColorBlock != nil){
            self.didChangeColorBlock(self.color);
        }
    }
}

- (void)_updateBrightnessPosition {
    
    CGFloat brightness = 0.f;
    [self.color getHue:nil saturation:nil brightness:&brightness alpha:nil];
    
    self.currentBrightness = brightness;
    
    CGPoint brightnessPosition;
    brightnessPosition.x = (1.0-self.currentBrightness)*self.gradientView.frame.size.width + self.gradientView.frame.origin.x;
    brightnessPosition.y = self.gradientView.center.y;
    
    self.brightnessIndicator.center = brightnessPosition;
}

- (void)_updateCrosshairPosition {
    
    CGPoint hueSatPosition;
    
    hueSatPosition.x = (self.currentHue * self.hueSatImage.frame.size.width) + self.hueSatImage.frame.origin.x;
    hueSatPosition.y = (1.0-self.currentSaturation) * self.hueSatImage.frame.size.height + self.hueSatImage.frame.origin.y;
    
    self.crossHairs.center = hueSatPosition;
    [self _updateGradientColor];
}

- (void)_updateGradientColor {
    
    UIColor *gradientColor = [UIColor colorWithHue:self.currentHue
                                        saturation:self.currentSaturation
                                        brightness:1.0
                                             alpha:1.0];
	
    self.crossHairs.layer.backgroundColor = gradientColor.CGColor;
    
	[self.gradientView setColor:gradientColor];
}

- (void)_updateHueSatWithMovement:(CGPoint)position {
    
	self.currentHue = (position.x - self.hueSatImage.frame.origin.x) / self.hueSatImage.frame.size.width;
	self.currentSaturation = 1.0 -  (position.y - self.hueSatImage.frame.origin.y) / self.hueSatImage.frame.size.height;
    
	UIColor *_tcolor = [UIColor colorWithHue:self.currentHue
                                  saturation:self.currentSaturation
                                  brightness:self.currentBrightness
                                       alpha:1.0];
    UIColor *gradientColor = [UIColor colorWithHue:self.currentHue
                                        saturation:self.currentSaturation
                                        brightness:1.0
                                             alpha:1.0];
	
    
    self.crossHairs.layer.backgroundColor = gradientColor.CGColor;
    [self _updateGradientColor];
    
    [self _setColor:_tcolor];
}

- (void)_updateBrightnessWithMovement:(CGPoint)position {
    
	self.currentBrightness = 1.0 - ((position.x - self.gradientView.frame.origin.x)/self.gradientView.frame.size.width) ;
	
	UIColor *_tcolor = [UIColor colorWithHue:self.currentHue
                                  saturation:self.currentSaturation
                                  brightness:self.currentBrightness
                                       alpha:1.0];
    [self _setColor:_tcolor];
}

- (UIColor*)_defaultTintColor {
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    if ([window respondsToSelector:@selector(tintColor)]) {
        return [window tintColor];
    }
    return [UIColor whiteColor];
}

- (UIImage*)_imageWithName:(NSString*)name {
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        NSBundle *libraryBundle = [NSBundle bundleForClass:[self class]];
        UIImage *image = [UIImage imageNamed:name inBundle:libraryBundle compatibleWithTraitCollection:nil];
        
        return image;
    }
    else {
        UIImage *image = [UIImage imageNamed:name];
        
        return image;
    }
}

#pragma mark - Touch Handling methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	for (UITouch *touch in touches){
		[self dispatchTouchEvent:[touch locationInView:self]];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	for (UITouch *touch in touches){
		[self dispatchTouchEvent:[touch locationInView:self]];
	}
}

- (void)dispatchTouchEvent:(CGPoint)position {
	if (CGRectContainsPoint(self.hueSatImage.frame,position)){
        self.crossHairs.center = position;
		[self _updateHueSatWithMovement:position];
	}
    else if (CGRectContainsPoint(self.gradientView.frame, position)) {
        self.brightnessIndicator.center = CGPointMake(position.x, self.gradientView.center.y);
		[self _updateBrightnessWithMovement:position];
	}
}

#pragma mark - Lazy loading

- (NKOBrightnessView*)gradientView {
    
    if (self->_gradientView == nil){
        self->_gradientView = [[NKOBrightnessView alloc] init];
        self->_gradientView.frame = CGRectMake(NKOPickerViewDefaultMargin,
                                               CGRectGetHeight(self.frame) - NKOPickerViewGradientViewHeight - NKOPickerViewDefaultMargin,
                                               CGRectGetWidth(self.frame)-(NKOPickerViewDefaultMargin*2),
                                               NKOPickerViewGradientViewHeight);
        
        self->_gradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
        self->_gradientView.layer.borderWidth = 1.f;
        self->_gradientView.layer.cornerRadius = 6.f;
        self->_gradientView.layer.borderColor = [self _defaultTintColor].CGColor;
        self->_gradientView.layer.masksToBounds = YES;
    }
    
    if (self->_gradientView.superview == nil){
        [self addSubview:self->_gradientView];
    }
    
    return self->_gradientView;
}

- (UIImageView*)hueSatImage {
    
    if (self->_hueSatImage == nil){
        self->_hueSatImage = [[UIImageView alloc] initWithImage:[self _imageWithName:@"nko_colormap.png"]];
        self->_hueSatImage.frame = CGRectMake(NKOPickerViewDefaultMargin,
                                              NKOPickerViewDefaultMargin,
                                              CGRectGetWidth(self.frame) - (NKOPickerViewDefaultMargin*2),
                                              CGRectGetHeight(self.frame) - NKOPickerViewGradientViewHeight - NKOPickerViewDefaultMargin - NKOPickerViewGradientTopMargin);
        
        self->_hueSatImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self->_hueSatImage.layer.borderWidth = 1.f;
        self->_hueSatImage.layer.cornerRadius = 6.f;
        self->_hueSatImage.layer.borderColor = [self _defaultTintColor].CGColor;
        self->_hueSatImage.layer.masksToBounds = YES;
    }
    
    if (self->_hueSatImage.superview == nil){
        [self addSubview:self->_hueSatImage];
    }
    
    return self->_hueSatImage;
}

- (UIView*)crossHairs {
    
    if (self->_crossHairs == nil){
        self->_crossHairs = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)*0.5,
                                                                     CGRectGetHeight(self.frame)*0.5,
                                                                     NKOPickerViewCrossHairshWidthAndHeight,
                                                                     NKOPickerViewCrossHairshWidthAndHeight)];
        
        self->_crossHairs.autoresizingMask = UIViewAutoresizingNone;
        
        UIColor *edgeColor = [UIColor colorWithWhite:0.9 alpha:0.8];
        
        self->_crossHairs.layer.cornerRadius = 19;
        self->_crossHairs.layer.borderColor = edgeColor.CGColor;
        self->_crossHairs.layer.borderWidth = 2;
        self->_crossHairs.layer.shadowColor = [UIColor blackColor].CGColor;
        self->_crossHairs.layer.shadowOffset = CGSizeZero;
        self->_crossHairs.layer.shadowRadius = 1;
        self->_crossHairs.layer.shadowOpacity = 0.5f;
    }
    
    if (self->_crossHairs.superview == nil){
        [self insertSubview:self->_crossHairs aboveSubview:self.hueSatImage];
    }
    
    return self->_crossHairs;
}

- (UIImageView*)brightnessIndicator {
    
    if (self->_brightnessIndicator == nil){
        self->_brightnessIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.gradientView.frame)*0.5f,
                                                                                   CGRectGetMinY(self.gradientView.frame)-4,
                                                                                   NKOPickerViewBrightnessIndicatorWidth,
                                                                                   NKOPickerViewBrightnessIndicatorHeight)];
        
        
        self->_brightnessIndicator.image = [[self _imageWithName:@"nko_brightness_guide"] nko_tintImageWithColor:[self _defaultTintColor]];
        self->_brightnessIndicator.autoresizingMask = UIViewAutoresizingNone;
        self->_brightnessIndicator.backgroundColor = [UIColor clearColor];
    }
    
    if (self->_brightnessIndicator.superview == nil){
        [self insertSubview:self->_brightnessIndicator aboveSubview:self.gradientView];
    }
    
    return self->_brightnessIndicator;
}

@end


// NKOBrightnessView
@interface NKOBrightnessView() {
    CGGradientRef gradient;
}

@end

@implementation NKOBrightnessView

- (void)setColor:(UIColor*)color {

    if (self->_color != color) {
        self->_color = [color copy];
        [self setupGradient];
        
        [self setNeedsDisplay];
    }
}

- (void)setupGradient {
    
	const CGFloat *c = CGColorGetComponents(self.color.CGColor);
    
	CGFloat colors[] = {
		c[0], c[1], c[2], 1.0f,
		0.f, 0.f, 0.f, 1.f,
	};
	
	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
	
    if (gradient != nil){
        CGGradientRelease(gradient);
    }
    
	gradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
	CGColorSpaceRelease(rgb);
}

- (void)drawRect:(CGRect)rect {
    
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGRect clippingRect = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
	
	CGPoint endPoints[] = {
		CGPointMake(0,0),
		CGPointMake(self.frame.size.width,0),
	};
	
	CGContextSaveGState(context);
	CGContextClipToRect(context, clippingRect);
	
	CGContextDrawLinearGradient(context, gradient, endPoints[0], endPoints[1], 0);
	CGContextRestoreGState(context);
}

- (void)dealloc {
    CGGradientRelease(gradient);
}

@end


//UIImage category
@implementation UIImage(NKO)

- (UIImage*)nko_tintImageWithColor:(UIColor*)tintColor {
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    CGContextSaveGState(ctx);
    CGContextClipToMask(ctx, area, self.CGImage);
    [tintColor set];
    CGContextFillRect(ctx, area);
    CGContextRestoreGState(ctx);
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    CGContextDrawImage(ctx, area, self.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
