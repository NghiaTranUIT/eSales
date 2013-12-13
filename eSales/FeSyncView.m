//
//  FeSyncView.m
//  eSales
//
//  Created by Nghia Tran on 9/6/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeSyncView.h"
#import "FeWebservice.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "FeDatabaseManager.h"


@interface FeSyncView ()
{
    
}
-(void) setupDefaultView;

-(void) checkBoxDanhMucChanged:(id) sender;
-(void) checkBoxDuLieuBanHang:(id) sender;
-(void) removeAllCheck;
-(void) checkInternet;
-(void) startSync;
@end

@implementation FeSyncView
@synthesize checkBoxDanhMuc = _checkBoxDanhMuc, checkBoxDuLieuBanHang = _checkBoxDuLieuBanHang;
@synthesize delegate = _delegate,syncView = _syncView;
@synthesize reach;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void) awakeFromNib
{
    [self setupDefaultView];
}
-(void) setupDefaultView
{
    // Init check box
    _checkBoxDanhMuc = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(342, 55, 35, 35) style:kSSCheckBoxViewStyleGreen checked:YES];
    [_checkBoxDanhMuc setStateChangedTarget:self selector:@selector(checkBoxDanhMucChanged:)];
    [_syncView addSubview:_checkBoxDanhMuc];
    
    // Init check box
    _checkBoxDuLieuBanHang = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(342, 101, 35, 35) style:kSSCheckBoxViewStyleGreen checked:NO];
    [_checkBoxDuLieuBanHang setStateChangedTarget:self selector:@selector(checkBoxDuLieuBanHang:)];
    [_syncView addSubview:_checkBoxDuLieuBanHang];
    
    self.layer.cornerRadius = 5;
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4f];
}

- (IBAction)btnDongBoTapped:(id)sender
{
    [self checkInternet];
}
-(void) startSync
{
    if (_checkBoxDanhMuc.checked)
    {
        // delete all data
        FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
        [db deleteAllTableForLogout];
        
        MBProgressHUD *hub = [[MBProgressHUD alloc] initWithView:self];
        hub.labelText = @"Downloading ...";
        
        [self addSubview:hub];
        [hub show:YES];
        FeWebservice *ws = [FeWebservice shareInstance];
        
        [ws syncAllFuncWithCompletionHandler:^(BOOL success) {
            if (success)
            {
                [hub removeFromSuperview];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông báo" message:@"Đồng bộ danh mục thành công" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                
                FeDatabaseManager *db  =[ FeDatabaseManager sharedInstance];
                [db printAllNameDatabase];
            }
            else
            {
                [hub removeFromSuperview];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông báo" message:@"Có lỗi trong quá trình đồng bộ. Mời bạn kiểm tra internet." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];

            }
            
        }];
    }
    else
    {
        MBProgressHUD *hub = [[MBProgressHUD alloc] initWithView:self];
        hub.labelText = @"Uploading ...";
        
        [self addSubview:hub];
        [hub show:YES];
        FeWebservice *ws = [FeWebservice shareInstance];
        
        [ws SyncAllFromPDAToServiceWithCompletionHandler:^(BOOL success) {
            if (success)
            {
                [hub removeFromSuperview];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông báo" message:@"Đồng bộ từ PDA -> Service thành công" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                
                
                FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                [db deleteAllTalbForSyncPDAToService];
            }
            else
            {
                [hub removeFromSuperview];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông báo" message:@"Có lỗi trong quá trình đồng bộ. Mời bạn kiểm tra internet." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];

            }
        }];
    }
}
- (IBAction)btnThoatTapped:(id)sender
{
    [reach stopNotifier];
    
    [_delegate FeSyncViewDelegateDismissView:self];
}
-(void) checkBoxDanhMucChanged:(id)sender
{
    _checkBoxDanhMuc.checked = YES;
    _checkBoxDuLieuBanHang.checked = NO;
}
-(void) checkBoxDuLieuBanHang:(id)sender
{
    _checkBoxDuLieuBanHang.checked = YES;
    _checkBoxDanhMuc.checked = NO;
}
-(void) removeAllCheck
{
    _checkBoxDanhMuc.checked = NO;
    _checkBoxDuLieuBanHang.checked = NO;
}
-(void) checkInternet
{
    reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Set the blocks
    reach.reachableBlock = ^(Reachability*reach)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startSync];
        });
    };
    
    reach.unreachableBlock = ^(Reachability*reach)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"No internet");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Thông Báo" message:@"Không có internet" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        });
        
    };
    
    
    // Start the notifier, which will cause the reachability object to retain itself!
    [reach startNotifier];

}
@end
