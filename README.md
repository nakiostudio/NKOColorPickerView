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
