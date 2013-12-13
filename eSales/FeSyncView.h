//
//  FeSyncView.h
//  eSales
//
//  Created by Nghia Tran on 9/6/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCheckBoxView.h"
#import "Reachability.h"
@protocol FeSyncViewDelegate;

@interface FeSyncView : UIView
@property (weak, nonatomic) id<FeSyncViewDelegate> delegate;
@property (strong, nonatomic) SSCheckBoxView *checkBoxDanhMuc;
@property (strong, nonatomic) SSCheckBoxView *checkBoxDuLieuBanHang;
@property (strong, nonatomic) Reachability *reach;
@property (weak, nonatomic) IBOutlet UIView *syncView;

- (IBAction)btnDongBoTapped:(id)sender;
- (IBAction)btnThoatTapped:(id)sender;

@end

@protocol FeSyncViewDelegate <NSObject>

-(void) FeSyncViewDelegateDismissView:(FeSyncView *) sender;

@end