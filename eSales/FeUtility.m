//
//  FeUtility.m
//  eSales
//
//  Created by Nghia Tran on 8/23/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeUtility.h"

@implementation FeUtility
+(UIAlertView *) alertViewWithErrorTitle:(NSString *) title message:(NSString *) message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    return alertView;
}
+(UIImage *) imageFromDocumentFolderWithName:(NSString *)name
{
    // get path to document folder
    
    
    // NSData
    
    return [UIImage imageNamed:@"default_profile"];
}
+(void) saveImageToDocumentFolder:(UIImage *)image withName:(NSString *)name
{
    
}

+(NSString *) formatDateWithDateYMD:(NSDate *)date
{
    // format date
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    // convert date to a string
    NSString *dateString = [dateFormat stringFromDate:date];
    
    return dateString;
}
@end
