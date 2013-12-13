//
//  FeShowNews.h
//  eSales
//
//  Created by Nghia Tran on 9/11/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FeShowNewsDelegate;

@interface FeShowNews : UIView
@property (weak, nonatomic) IBOutlet UITextField *lblTieuDe;
@property (weak, nonatomic) IBOutlet UITextView *lblNoiDung;
@property (weak, nonatomic) id<FeShowNewsDelegate> delegate;
-(void) loadImageForID:(NSString *)ID;
- (IBAction)btnDongTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *avatar1;
@property (weak, nonatomic) IBOutlet UIImageView *avatar2;
@property (weak, nonatomic) IBOutlet UIImageView *avatar3;


@end

@protocol FeShowNewsDelegate <NSObject>

-(void) FeShowNewShouldClose:(id) sender;

@end