//
//  FeShowNews.m
//  eSales
//
//  Created by Nghia Tran on 9/11/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeShowNews.h"
#import <QuartzCore/QuartzCore.h>
#import "FeDatabaseManager.h"
#import "UIImageView+AFNetworking.h"

@implementation FeShowNews
@synthesize lblNoiDung = _lblNoiDung, lblTieuDe = _lblTieuDe;
@synthesize delegate = _delegate, avatar1 = _avatar1, avatar2 = _avatar2, avatar3 = _avatar3;

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
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    bg.frame = self.frame;
    bg.contentMode = UIViewContentModeScaleAspectFill;
    [self insertSubview:bg atIndex:0];
    
    _lblNoiDung.layer.borderColor = [UIColor blackColor].CGColor;
    _lblNoiDung.layer.borderWidth = 1;
}

- (IBAction)btnDongTapped:(id)sender
{
    [_delegate FeShowNewShouldClose:self];
}

-(void) loadImageForID:(NSString *)ID
{
    // Get image Sync
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    NSMutableArray *arr = [db arrURLImagePhotoForTechnicalSupportWithID:ID];
    
    for (NSInteger i = 0; i < arr.count; i++)
    {
        if (i == 0)
        {
            [_avatar1 setImageWithURL:[arr objectAtIndex:i] placeholderImage:[UIImage imageNamed:@"default_profile"]];
        }
        if (i == 1)
        {
            [_avatar2 setImageWithURL:[arr objectAtIndex:i] placeholderImage:[UIImage imageNamed:@"default_profile"]];
        }
        if (i == 2)
        {
            [_avatar3 setImageWithURL:[arr objectAtIndex:i] placeholderImage:[UIImage imageNamed:@"default_profile"]];
        }
        
    }
}

@end
