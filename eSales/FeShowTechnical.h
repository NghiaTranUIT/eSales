//
//  FeShowTechnical.h
//  eSales
//
//  Created by Nghia Tran on 9/11/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FeShowTechnicalDelegate;
@interface FeShowTechnical : UIView

@property (weak, nonatomic) IBOutlet UITextField *lblSTT;
@property (weak, nonatomic) IBOutlet UITextView *lblNoiDung;
@property (weak, nonatomic) id<FeShowTechnicalDelegate> delegate;
- (IBAction)btnTapped:(id)sender;
-(void) loadImageForDict:(NSDictionary *)dict;

@property (weak, nonatomic) IBOutlet UIImageView *avatar1;
@property (weak, nonatomic) IBOutlet UIImageView *avatar2;
@property (weak, nonatomic) IBOutlet UIImageView *avatar3;

@end



@protocol FeShowTechnicalDelegate <NSObject>

-(void) FeShowTechnicalDelegateShouldClose:(id) sender;

@end