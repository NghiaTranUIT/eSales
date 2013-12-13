//
//  FeXMLParseManager.h
//  eSales
//
//  Created by Nghia Tran on 9/6/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^XMLCompletionHandler)(BOOL success, NSString *stringParse);

@interface FeXMLParseManager : NSObject <NSXMLParserDelegate>
@property (weak, nonatomic) NSXMLParser *xmlParse;
@property (strong, nonatomic) NSString *funcName;
@property (strong, nonatomic) NSString *tagResult;
@property (strong, nonatomic) NSString *qName;
@property (strong, nonatomic) NSString *stringParse;

+(id) shareInstance;
-(id) init;


// Get String
-(void) getStringFromXMLParse:(NSXMLParser *) xmlParse funcName:(NSString *) funcName tagResult:(NSString *) tagResult withCompletionHandler:(XMLCompletionHandler) xmlCompletionHander;

@end
