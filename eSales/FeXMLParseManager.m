//
//  FeXMLParseManager.m
//  eSales
//
//  Created by Nghia Tran on 9/6/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeXMLParseManager.h"
@interface FeXMLParseManager ()
{
    NSString *_slsperID;
    NSString *_password;
    NSString *_token;
    NSString *_branchID;
    
    // Block
    XMLCompletionHandler _xmlBlock;
}

@end;
@implementation FeXMLParseManager
@synthesize xmlParse = _xmlParse;
@synthesize tagResult = _tagResult, funcName = _funcName;
@synthesize qName = _qName, stringParse = _stringParse;

+(id) shareInstance
{
    static FeXMLParseManager *instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FeXMLParseManager alloc] init];
    });
    
    return instance;
}
-(id) init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

-(void) getStringFromXMLParse:(NSXMLParser *) xmlParse funcName:(NSString *) funcName tagResult:(NSString *) tagResult withCompletionHandler:(XMLCompletionHandler) xmlCompletionHander
{
    _xmlBlock = [xmlCompletionHander copy];
    _stringParse = @"";
    
    _funcName = funcName;
    _tagResult = tagResult;
    _xmlParse = xmlParse;
    
    xmlParse.delegate = self;
    [xmlParse setShouldProcessNamespaces:YES];
    [xmlParse parse];
}


-(void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    //NSLog(@"Did Start Element = %@ , qualifier = %@",elementName, qName);
    if ([parser.accessibilityHint isEqualToString:@"Login"])
    {
        if ([qName isEqualToString:@"Var1"])
        {
            _qName = qName;
        }
        if ([qName isEqualToString:@"Var2"])
        {
            _qName = qName;
        }
        if ([qName isEqualToString:@"Var3"])
        {
            _qName = qName;
        }
        if ([qName isEqualToString:@"Var4"])
        {
            _qName = qName;
        }
        
        return;
    }
    
    if ([parser.accessibilityHint isEqualToString:_funcName])
    {
        if ([qName isEqualToString:_tagResult])
        {
            _qName = qName;
        }
    }
    
}
-(void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    //NSLog(@"Found string = %@",string);
    if ([parser.accessibilityHint isEqualToString:@"Login"])
    {
        if ([_qName isEqualToString:@"Var1"]) {
            _slsperID = string;
        }
        if ([_qName isEqualToString:@"Var2"]) {
            _password = string;
        }
        if ([_qName isEqualToString:@"Var3"]) {
            _token = string;
        }
        if ([_qName isEqualToString:@"Var4"]) {
            _branchID = string;
            _qName = @"";
        }
        return;
    }
    
    if ([parser.accessibilityHint isEqualToString:_funcName])
    {
        if ([_qName isEqualToString:_tagResult])
        {
            // Save Data
            //_stringParse = string;
            _stringParse = [_stringParse stringByAppendingString:string];
        }
    }
    
}
-(void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    //NSLog(@"Did End Element = %@ Qualifier = %@",elementName, qName);
    if ([parser.accessibilityHint isEqualToString:@"Login"])
    {

        if ([qName isEqualToString:@"soap:Envelope"])
        {
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            /*
            NSDictionary *headerSOAP = [NSDictionary dictionaryWithObjectsAndKeys:_slsperID,@"Var1",_password,@"Var2",_token,@"Var3",_branchID,@"Var4", nil];
             */
            
            NSDictionary *headerSOAP = [NSDictionary dictionaryWithObjectsAndKeys:_slsperID,@"Var1",_password,@"Var2",@"",@"Var3",@"",@"Var4", nil];
            
            [user setObject:headerSOAP forKey:@"HeaderSOAP"];
            [user synchronize];
            _qName = @"";
            
            _xmlBlock(YES,nil);
        }
        return;
    }
    
    if ([parser.accessibilityHint isEqualToString:_funcName])
    {
        if ([qName isEqualToString:@"soap:Envelope"])
        {
            _qName = @"";
            _xmlBlock(YES,_stringParse);
        }
    }
}

@end
