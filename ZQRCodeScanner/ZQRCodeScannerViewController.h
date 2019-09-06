//
//  ZQRCodeScannerViewController.h
//  ZQRCodeScanner
//
//  Created by 郑宇恒 on 2019/9/6.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZQRCodeScannerDelegate <NSObject>

- (void)qrcodeScanner:(UIViewController *)scanner didScanQRCode:(AVMetadataMachineReadableCodeObject *)object;

@end

@interface ZQRCodeScannerViewController : UIViewController

@property (nonatomic, weak) id <ZQRCodeScannerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
