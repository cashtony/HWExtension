//
//  HWFileContentBrowserViewController.m
//  HWExtension
//
//  Created by Wang,Houwen on 2019/3/1.
//  Copyright © 2019 Wang,Houwen. All rights reserved.
//

#import "HWFileContentBrowserViewController.h"

@interface HWFileContentBrowserViewController ()

@property (nonatomic, strong) UITextView *textView;

@end

@implementation HWFileContentBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.textView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.textView.frame = self.view.bounds;
}

- (void)setFilePath:(NSString *)filePath {
    if (![_filePath isEqualToString:filePath]) {
        NSString *str = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        if (str) {
            self.textView.text = str;
        } else {
            self.textView.text = [NSData dataWithContentsOfFile:filePath].description;
        }
    }
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.editable = NO;
    }
    return _textView;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
