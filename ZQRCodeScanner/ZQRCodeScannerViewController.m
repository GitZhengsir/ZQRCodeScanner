//
//  ZQRCodeScannerViewController.m
//  ZQRCodeScanner
//
//  Created by 郑宇恒 on 2019/9/6.
//

#import "ZQRCodeScannerViewController.h"

#import "ZQRMaskView.h"

@interface ZQRCodeScannerViewController () <AVCaptureMetadataOutputObjectsDelegate>
{
    CGRect _clearRect;
}

@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoLayer;
@property (nonatomic, strong) ZQRMaskView *maskView;

@property (nonatomic, strong) UIButton *backButton;

@end

@implementation ZQRCodeScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat mainRectWidth = self.view.frame.size.width;
    CGFloat mainRectHeight = self.view.frame.size.height;
    _clearRect = CGRectMake(mainRectWidth/6, mainRectHeight/5*2 - mainRectWidth/3, 2*mainRectWidth/3, 2*mainRectWidth/3);
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.maskView];
    [self.view addSubview:self.backButton];
    
    [self checkAuthorization];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    if (self.session.running == NO) {
        [self.session startRunning];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.session stopRunning];
}

#pragma mark - Private
- (void)checkAuthorization {
    NSString *mediaType = AVMediaTypeVideo;//读取媒体类型
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];//读取设备授权状态
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    if (TARGET_IPHONE_SIMULATOR) {
                        NSLog(@"模拟器不支持相机!");
                    } else {
                        [self openAVCaptureSession];
                    }
                });
            } else {
                
            }
        }];
    }
    if (authStatus == AVAuthorizationStatusAuthorized) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (TARGET_IPHONE_SIMULATOR) {
                NSLog(@"模拟器不支持相机!");
            } else {
                [self openAVCaptureSession];
            }
        });
    }
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        [self askForCamera];
    }
}

- (void)askForCamera {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请在iPhone的“设置-隐私-相机”选项中，允许访问你的相机" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *done = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                [self checkAuthorization];
            }];
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (self.presentingViewController) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    
    [alert addAction:done];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)openAVCaptureSession {
    
    NSError *inputError = nil;
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&inputError];
    if (inputError) {
        NSLog(@"AVCaptureDeviceInput Error:%@", inputError.localizedDescription);
    }
    self.output = [[AVCaptureMetadataOutput alloc] init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    self.session = [[AVCaptureSession alloc] init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    [self.session addInput:self.input];
    [self.session addOutput:self.output];
    
    self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    self.videoLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setInterestingRect];
        self.videoLayer.frame = self.view.bounds;
        [self.view.layer addSublayer:self.videoLayer];
        [self.view bringSubviewToFront:self.maskView];
        [self.view bringSubviewToFront:self.backButton];
        [self.session startRunning];
    });
}

- (void)setInterestingRect {
    CGRect mainRect = self.view.frame;
    CGRect interestRect = CGRectMake(_clearRect.origin.y/mainRect.size.height, _clearRect.origin.x/mainRect.size.width, _clearRect.size.height/mainRect.size.height, _clearRect.size.width/mainRect.size.width);//参照坐标是横屏左上角
    [self.output setRectOfInterest:interestRect];
}


#pragma mark - Delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *object = [metadataObjects lastObject];
        
        [self.session stopRunning];
        [self.navigationController popViewControllerAnimated:YES];
        if (_delegate && [_delegate respondsToSelector:@selector(qrcodeScanner:didScanQRCode:)]) {
            [_delegate qrcodeScanner:self didScanQRCode:object];
        }
    }
}

#pragma mark - Target Action
- (void)pressBackButton {
    if (self.navigationController.topViewController == self) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Getter
- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        BOOL isPhoneX = NO;
        if (@available(iOS 11.0, *)) {
            isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;
        }
        
        CGFloat y = 0;
        if (isPhoneX) {
            y = 40;
        } else {
            y = 30;
        }
        _backButton.frame = CGRectMake(15, y, 40, 40);
        
        [_backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        _backButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        _backButton.layer.cornerRadius = 20.0f;
        
        [_backButton addTarget:self action:@selector(pressBackButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (ZQRMaskView *)maskView {
    if (!_maskView) {
        _maskView = [[ZQRMaskView alloc] initWithFrame:self.view.frame clearRect:_clearRect];
    }
    return _maskView;
}
@end
