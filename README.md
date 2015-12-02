# FYTextView
A self-adapted textView with tags,you can set your tags in the textview。



## A simple TextView with tags
FYTextView is a self-adapted textView with Tags, and you can set tags easily in text view。

FYTextView inherits from UITextView and all the property that applies to UITextView can also be used for FYTextView.
Works on iOS 7+. 

## Usage

All you have to do is import the 'FYTextView' folder in you project,and then create the FYTextView object,FYTextView handles everything for you.

####create text view
```obj-c
FYTextView *testView = [[FYTextView alloc]initWithFrame:CGRectMake(10, 50, self.view.frame.size.width - 20, 50)];
testView.font = [UIFont systemFontOfSize:14.f];
testView.textContainerInset = UIEdgeInsetsMake(3, 5, 3, 5);
testView.hasSpace = YES;
testView.tagBgColor = [UIColor brownColor];
testView.contentInset = UIEdgeInsetsMake(5, 0, 5, 0);
UIImage *tagBgImage = [[UIImage imageNamed:@"bg"]resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6) resizingMode:UIImageResizingModeStretch];
testView.tagBgImage = tagBgImage;
testView.tagColor = [UIColor whiteColor];
testView.autoIncrement = NO;
testView.maxHeight = 80;
[testView setPlaceholder:@"Hahahaha..."];
testView.backgroundColor = [UIColor groupTableViewBackgroundColor];
testView.fyDelegate = self;
[self.view addSubview:testView];
```
####set tags
```obj-c
[testView addTagToCurrentLocation:@"Tag"]
```

## License

Released under the [MIT License](LICENSE).

