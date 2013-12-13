//
//  FeUtility.h
//  eSales
//
//  Created by Nghia Tran on 8/23/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeUtility : NSObject
+(UIAlertView *) alertViewWithErrorTitle:(NSString *) title message:(NSString *) message;
+(UIImage *) imageFromDocumentFolderWithName:(NSString *) name;
+(void) saveImageToDocumentFolder:(UIImage *) image withName:(NSString *) name;
+(NSString *) formatDateWithDateYMD:(NSDate *)date;
@end
