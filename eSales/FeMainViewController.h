//
//  FeMainViewController.h
//  eSales
//
//  Created by Nghia Tran on 8/22/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FeMainViewDelegate;

@interface FeMainViewController : UIViewController


// delegate
@property (weak, nonatomic) id<FeMainViewDelegate> delegate;
// user
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *idUserName;

- (IBAction)syncImageTapped:(id)sender;

//
@property (weak, nonatomic) IBOutlet UILabel *statusSaler;


// Action
- (IBAction)loginTapped:(id)sender;

- (IBAction)btnSyncTapped:(id)sender;

@end

@protocol FeMainViewDelegate <NSObject>
@required
-(void) FeMainViewDelegateLogOut:(FeMainViewController *) sender;

@end