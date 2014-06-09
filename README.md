# NKOColorPickerView

A block based and easy to use Color Picker View for iOS.


## Installation

The best way to integrate NKOColorPickerView in your project is with CocoaPods. You can find more info about this dependency manager [here](http://cocoapods.org). Just add the following line to your **Podfile**.

```
pod 'NKOColorPickerView'
```

## How to get started

NKOColorPickerView can be added to your controller's view using Interface Builder or programmatically with the following code:

```
//Color did change block declaration
NKOColorPickerDidChangeColorBlock colorDidChangeBlock = ^(UIColor *color){
	//Your code handling a color change in the picker view.
};
    
NKOColorPickerView *colorPickerView = [[NKOColorPickerView alloc] initWithFrame:CGRectMake(0, 0, 300, 340) color:[UIColor blueColor] andDidChangeColorBlock:colorDidChangeBlock];
    
//Add color picker to your view
[self.view addSubview:colorPickerView];
```

# Screenshot

### iPhone

![](/Screenshots/screenshot-ios.png) 

# Example Project

[NKOColorPickerView example](https://github.com/FWCarlos/NKOColorPickerView-Example-iOS)

# License

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

