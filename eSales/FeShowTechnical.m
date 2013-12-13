//
//  FeShowTechnical.m
//  eSales
//
//  Created by Nghia Tran on 9/11/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeShowTechnical.h"
#import <QuartzCore/QuartzCore.h>
#import "FeDatabaseManager.h"
#import "UIImageView+AFNetworking.h"
#define kURLPhoto @"http://113.161.67.149:8080/syncservicetest/Sync/Pics/"

@implementation FeShowTechnical
@synthesize lblNoiDung = _lblNoiDung, lblSTT = _lblSTT, delegate = _delegate;
@synthesize avatar1 = _avatar1, avatar2 = _avatar2, avatar3 = _avatar3;

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
-(void) loadImageForDict:(NSDictionary *)dict
{
    NSString *stringPicture1 = [dict objectForKey:@"Picture1"];
    NSString *stringPicture2 = [dict objectForKey:@"Picture2"];
    NSString *stringPicture3 = [dict objectForKey:@"Picture3"];
    
    // Load photo from Doucument
    // Get dir
    NSString *documentsDirectory = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    
    if (stringPicture1 && ![stringPicture1 isEqualToString:@""])
    {
        NSString *pathString_1 = [NSString stringWithFormat:@"%@/%@",documentsDirectory, stringPicture1];
        _avatar1.image = [UIImage imageWithContentsOfFile:pathString_1];
    }
    if (stringPicture2 && ![stringPicture2 isEqualToString:@""])
    {
        NSString *pathString_1 = [NSString stringWithFormat:@"%@/%@",documentsDirectory, stringPicture2];
        _avatar2.image = [UIImage imageWithContentsOfFile:pathString_1];
    }
    if (stringPicture3 && ![stringPicture3 isEqualToString:@""])
    {
        NSString *pathString_1 = [NSString stringWithFormat:@"%@/%@",documentsDirectory, stringPicture3];
        _avatar3.image = [UIImage imageWithContentsOfFile:pathString_1];
    }
    //NSString *pathString_2 = [NSString stringWithFormat:@"%@/%@",documentsDirectory, stringPicture2];
    //NSString *pathString_3 = [NSString stringWithFormat:@"%@/%@",documentsDirectory, stringPicture3];
    
    
    
    
    
}
- (IBAction)btnTapped:(id)sender
{
    [_delegate FeShowTechnicalDelegateShouldClose:self];
}
@end
