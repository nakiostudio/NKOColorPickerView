//
//  NKOColorPickerView.h
//  ColorPicker
//
//  Created by Carlos Vidal
//  Based on work by Fabián Cañas and Gilly Dekel
//

#import <UIKit/UIKit.h>

typedef void (^NKOColorPickerDidChangeColorBlock)(UIColor *color);

@interface NKOColorPickerView : UIView

@property (nonatomic, strong) NKOColorPickerDidChangeColorBlock didChangeColorBlock;
@property (nonatomic, strong) UIColor *color;

- (id)initWithFrame:(CGRect)frame color:(UIColor*)color andDidChangeColorBlock:(NKOColorPickerDidChangeColorBlock)didChangeColorBlock;

@end

