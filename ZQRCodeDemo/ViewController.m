//
//  ViewController.m
//  ZQRCodeScanner
//
//  Created by 郑宇恒 on 2019/9/6.
//

#import "ViewController.h"

#import "ZQRCodeScannerViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)scan:(id)sender {
    ZQRCodeScannerViewController *scanner = [[ZQRCodeScannerViewController alloc] init];
    [self.navigationController pushViewController:scanner animated:YES];
}


@end
