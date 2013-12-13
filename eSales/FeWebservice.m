//
//  FeWebservice.m
//  eSales
//
//  Created by Nghia Tran on 9/1/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeWebservice.h"
#import "FeDatabaseManager.h"
#import "FeXMLParseManager.h"
#import "NSData+Base64.h"
#import "NSData+IDZGunzip.h"
#import "Base64.h"

#define kBaseURL @"http://113.161.67.149:8080/SyncServicetest/"

#define kBaseURlTest @"http://14.161.10.215/mobile_smiles_web_service/mobileservices.asmx"

@interface FeWebservice () <NSXMLParserDelegate>
{
    BOOL isFirstTimeLogin;
    dispatch_group_t group;
    CompletionHandler _completionHander;
    
    // Parse XML
    NSString *_qName;
    
    // Check Error
    BOOL isSyncPDAToService_OK;
    BOOL isSyncServiceToPDA_OK;
    NSString *stringURL;
    
    NSMutableArray *arrTableHasError;
    
}
@property (strong, nonatomic) NSString *slsperID;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *branchID;
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) FeXMLParseManager *xmlManager;
@property (strong, nonatomic) NSString *syncAllData;

@end

@implementation FeWebservice
@synthesize slsperID = _slsperID, password = _password, branchID = _branchID, token = _token;
@synthesize xmlManager = _xmlManager,syncAllData = _syncAllData;

+(FeWebservice *) shareInstance
{
    static FeWebservice *instance;    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSURL *baseURL = [NSURL URLWithString:kBaseURL];
        instance = [[FeWebservice alloc] initWithBaseURL:baseURL];
    });
    
    
    
    return instance;
}
-(id) initWithBaseURL:(NSURL *)baseURL
{
    self = [super initWithBaseURL:baseURL];
    if (self)
    {
        [self registerHTTPOperationClass:[AFXMLRequestOperation class]];
        isFirstTimeLogin = NO;
        _xmlManager = [FeXMLParseManager shareInstance];
        _syncAllData = @"1";
    }
    
    return self;
}
-(NSString*) getURLWhenSync
{
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    
    NSMutableDictionary *dictURL = [db getURLSyncFromDatabase];
    int IsSyncWAN = [[dictURL objectForKey:@"IsSyncWAN"] intValue];
    
    NSString *strURL;
    if(IsSyncWAN)
    {
        strURL = [dictURL objectForKey:@"SyncAddressWAN"];
        NSLog(@"URL cuc bo: %@", strURL);
    }
    else
    {
        strURL = [dictURL objectForKey:@"SyncAddress"];
        NSLog(@"URL internet: %@", strURL);
    }
    
    return strURL;
}
-(void) loginWithCompletionHandler:(CompletionHandler)completionHanlder
{
    // Get URL when sync 
    stringURL = [self getURLWhenSync];
    
    _completionHander = [completionHanlder copy];
    
    // Database
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:[user objectForKey:@"Setting"]];
    
    _slsperID = [dict objectForKey:@"SlsperID"];
    _password = [dict objectForKey:@"Password"];
    _branchID = [dict objectForKey:@"BranchID"];
    _token = @"";
    
    // URL
    NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncLG"];
    //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncLG", stringURL]];
    NSLog(@"URL: %@", url);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncLG xmlns=\"http://localhost/PPCSyncService/\" />"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncLG\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser) {
        NSLog(@"OK");
        
        XMLParser.accessibilityHint = @"Login";
        // Parse
        [_xmlManager getStringFromXMLParse:XMLParser funcName:@"Login" tagResult:@"" withCompletionHandler:^(BOOL success, NSString *stringParse) {
            
            // Get Gobal
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            NSDictionary *dict = [user objectForKey:@"HeaderSOAP"];
            _slsperID = [dict objectForKey:@"Var1"];
            _password = [dict objectForKey:@"Var2"];
            _token = [dict objectForKey:@"Var3"];
            _branchID = [dict objectForKey:@"Var4"];
            
            if (!_token)
                _token = @"";
            
            //if (!_branchID)
                //_branchID = @"IFV0001";
            _branchID = @"IFV0001";
            
            completionHanlder(YES);
        }];
        
        
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
        NSLog(@"Fail Login");
        _completionHander(NO);
    }];
    
    // Start
    [operation start];
}
// Sync Service To PDA
-(void) syncAllFuncWithCompletionHandler:(CompletionHandler)completionHanlder
{
    isSyncServiceToPDA_OK = YES;
    
    group = dispatch_group_create();
    
    [self loginWithCompletionHandler:^(BOOL success)
    {
        if (success)
        {

            NSLog(@"Login OK");
            NSLog(@"dict Var = %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"HeaderSOAP"]);
         
            
            dispatch_group_enter(group);
            [self SyncGetIN_Brand];
            
            
            dispatch_group_enter(group);
            [self SyncGetPPC_SalesHistory];
            
            
            dispatch_group_enter(group);
            [self SyncGetPPC_AgingDebt];
            
            
            dispatch_group_enter(group);
            [self SyncGetIN_InventoryCompetitor];
            
            dispatch_group_enter(group);
            [self SyncGetOM_ReasonCode];
            
            
            dispatch_group_enter(group);
            [self SyncGetAR_Territory];
            
            
            dispatch_group_enter(group);
            [self SyncGetAR_CustType];
            
            dispatch_group_enter(group);
            [self SyncGetOM_Knowledge];
            
            dispatch_group_enter(group);
            [self SyncGetOM_IssueType];
            
            dispatch_group_enter(group);
            [self SyncGetOM_TechnicalSupport];
            
            
            FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
            
            if ([db isHasValueWithQuery:@"select * from AR_Doc where AdjAmt > 0"])
            {
                NSLog(@"Has Value AR_DOC");
                dispatch_group_enter(group);
                [self SyncSetAR_Doc];
            }
            else
            {
                NSLog(@"Isn't Has Value AR_DOC");
            }
            
            dispatch_group_enter(group);
            [self SyncGetAR_Doc];
            
            dispatch_group_enter(group);
            [self SyncGetSysCompany];
            
            dispatch_group_enter(group);
            [self SyncGetSI_State];
            
            dispatch_group_enter(group);
            [self SyncGetSI_City];
            
            // OK
            
            dispatch_group_enter(group);
            [self SyncGetSI_District];
            
            dispatch_group_enter(group);
            [self SyncGetSI_Ward];
            
            dispatch_group_enter(group);
            [self SyncGetAR_Channel];
            
            // OK
            dispatch_group_enter(group);
            [self SyncGetAR_CustClass];
            
            dispatch_group_enter(group);
            [self SyncGetAR_Area];
            
            dispatch_group_enter(group);
            [self SyncGetAR_ShopType];
            
            
            dispatch_group_enter(group);
            [self SyncGetAR_Customer];
            
            if ([db isHasValueWithQuery:@"select * from AR_CustomerLocation"])
            {
                NSLog(@"AR Customer Location SET Has Value");
                dispatch_group_enter(group);
                [self SyncAR_CustomerLocation];
            }
            else
            {
                NSLog(@"AR Customer Location SET Has NO Value");
            }
            
            
            dispatch_group_enter(group);
            [self SyncAR_CustomerLocation_GET];
            
            
            dispatch_group_enter(group);
            [self SyncPPC_ARCustomerInfo];
             
            
            dispatch_group_enter(group);
            [self SyncAR_CustomerInfo_Invt];
            
            
            dispatch_group_enter(group);
            [self SyncGetOM_SalesRoute];
            
            dispatch_group_enter(group);
            [self SyncGetOM_SalesRouteDet];
            
            dispatch_group_enter(group);
            [self SyncSI_Tax];
            
            
            dispatch_group_enter(group);
            [self SyncInvtHierarchy];
            
            dispatch_group_enter(group);
            [self SyncInventory];
            
            dispatch_group_enter(group);
            [self SyncReports];
            
            dispatch_group_enter(group);
            [self SyncOM_Discount];
            
            dispatch_group_enter(group);
            [self SyncOM_DiscSeq];
            
            dispatch_group_enter(group);
            [self SyncOM_DiscFreeItem];
            
            dispatch_group_enter(group);
            [self SyncOM_DiscBreak];
            
            //
            dispatch_group_enter(group);
            [self SyncOM_DiscCust];
            
            dispatch_group_enter(group);
            [self SyncOM_DiscCustClass];
            
            
            dispatch_group_enter(group);
            [self SyncOM_DiscDescr];
            
            dispatch_group_enter(group);
            [self SyncOM_DiscItem];
            //
            dispatch_group_enter(group);
            [self SyncOM_DiscItemClass];
            
             dispatch_group_enter(group);
            [self SyncOM_PPAlloc];
            
            dispatch_group_enter(group);
            [self SyncOM_PPBudget];
            
            dispatch_group_enter(group);
            [self SyncOM_Setup];
            
            dispatch_group_enter(group);
            [self SyncOM_PriceClass];
            
            dispatch_group_enter(group);
            [self SyncSuggestOrder];
            
            dispatch_group_enter(group);
            [self SyncSetting];
            
            dispatch_group_enter(group);
            [self SyncGetIN_ItemLoc];
            
            dispatch_group_enter(group);
            [self SyncGetPPC_Distributor];
            
            dispatch_group_enter(group);
            [self SyncGetPPC_SurveyBrand];
            
            dispatch_group_enter(group);
            [self SyncGetAR_Transactionlist];
            
            dispatch_group_enter(group);
            [self SyncGetPPC_INSite];

            dispatch_group_enter(group);
            [self SyncGetPPC_PriceOfCust];
            
            dispatch_group_enter(group);
            [self SyncGetOM_DefineWorks];

            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
                dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //you are now back on the main thread and all the async tasks are done!
                    completionHanlder(isSyncServiceToPDA_OK);
                    
                });
            });
        }
        else
         {
             NSLog(@"Login Fail");
         }
     
    }];
}

/*
SyncGetIN_Brand
SyncGetPPC_SalesHistory
SyncGetPPC_AgingDebt
SyncGetIN_InventoryCompetitor
SyncGetOM_ReasonCode
SyncGetAR_Territory
SyncGetAR_CustType
SyncGetOM_Knowledge
SyncGetOM_IssueType
SyncGetOM_TechnicalSupport
SyncSetAR_Doc
SyncGetSysCompany
SyncGetSI_State
SyncGetSI_City
SyncGetSI_District
SyncGetSI_Ward
SyncGetAR_Channel
SyncGetAR_CustClass
SyncGetAR_Area
SyncGetAR_ShopType
SyncGetAR_Customer
SyncAR_CustomerLocation
SyncPPC_ARCustomerInfo
SyncGetOM_SalesRoute
SyncGetOM_SalesRouteDet
SyncSI_Tax
SyncInvtHierarchy
SyncInventory
SyncReports
SyncOM_Discount
SyncOM_DiscSeq
SyncOM_DiscFreeItem
SyncOM_DiscBreak
SyncOM_DiscCust
SyncOM_DiscCustClass
SyncOM_DiscDescr
SyncOM_DiscItem
SyncOM_DiscItemClass
SyncOM_PPAlloc
SyncOM_PPBudget
SyncOM_Setup
SyncOM_PriceClass
SyncPPC_SuggestOrder
SyncSetting
SyncPPC_Log
 */

-(void) SyncGetIN_ItemLoc
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGIL"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGIL", stringURL]];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGIL xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "</FuncGIL>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGIL\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncGetIN_ItemLoc";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncGetIN_ItemLoc" tagResult:@"FuncGILResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@" String ItemLoc = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"IN_ItemLoc"];
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                            
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"##### ItemLoc Fail ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncGetIN_Brand
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGINB"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGINB", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGINB xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "</FuncGINB>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGINB\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
    {
        XMLParser.accessibilityHint = @"SyncGetIN_Brand";
        [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncGetIN_Brand" tagResult:@"FuncGINBResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
         {
             NSLog(@" String Branch = %@",stringParse);
             
             FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
             [db saveJSONToDatabase:stringParse atTable:@"IN_Brand"];
             
             dispatch_group_leave(group);
         }];

    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
        NSLog(@"##### Branch Fail ***** with Error- %@",error);
        
        dispatch_group_leave(group);
        isSyncServiceToPDA_OK = NO;
    }];
    
    // Start
    [operation start];

}
-(void) SyncGetPPC_SalesHistory
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGPSH"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGPSH", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGPSH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncGPSH>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_branchID,_syncAllData];
    NSLog(@"SOAP SalesHistory = %@",body);
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGPSH\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
        {
            XMLParser.accessibilityHint = @"SyncGetPPC_SalesHistory";
            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncGetPPC_SalesHistory" tagResult:@"FuncGPSHResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
             {
                 NSLog(@"String Sale History = %@",stringParse);
                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                 [db saveJSONToDatabase:stringParse atTable:@"PPC_SalesHistory"];
                 
                 
                 dispatch_group_leave(group);
             }];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
            NSLog(@"Sales Historyl ***** with Error- %@",error);
            
            dispatch_group_leave(group);
            isSyncServiceToPDA_OK = NO;
            
        }];
    
    // Start
    [operation start];
}
-(void) SyncGetPPC_AgingDebt
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGPAD"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGPAD", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGPAD xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncGPAD>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_branchID,_syncAllData];
    NSLog(@"SOAP AgingDebt = %@",body);
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGPAD\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
        {
            XMLParser.accessibilityHint = @"SyncGetPPC_AgingDebt";
            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncGetPPC_AgingDebt" tagResult:@"FuncGPADResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
             {
                 NSLog(@"String Adbit = %@",stringParse);
                 
                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                 [db saveJSONToDatabase:stringParse atTable:@"PPC_AgingDebt"];
                 
                 dispatch_group_leave(group);
             }];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
            NSLog(@"Adbit ***** with Error- %@",error);
            
            dispatch_group_leave(group);
            isSyncServiceToPDA_OK = NO;
        }];
    
    // Start
    [operation start];
}
-(void) SyncGetIN_InventoryCompetitor
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGIC"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGIC", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGIC xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncGIC>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_branchID,_syncAllData];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGIC\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncGetIN_InventoryCompetitor";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncGetIN_InventoryCompetitor" tagResult:@"FuncGICResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String InventoryCompetitor = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"IN_InventoryCompetitor"];
                                                 
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"InventoryCompetitor ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
    
}
-(void) SyncGetOM_ReasonCode
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGEOMRC"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGEOMRC", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGEOMRC xmlns=\"http://localhost/PPCSyncService/\" />"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGEOMRC\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncGetOM_ReasonCode";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncGetOM_ReasonCode" tagResult:@"FuncGEOMRCResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String ReasonCode = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"OM_ReasonCode"];
                                                 
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"ReasonCode ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncGetAR_Territory
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGEARTE"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGEARTE", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGEARTE xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncGEARTE>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_branchID,_syncAllData];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGEARTE\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncGetAR_Territory";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncGetAR_Territory" tagResult:@"FuncGEARTEResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String Territory = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"AR_Territory"];
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"Territory ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncGetAR_CustType
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGACT"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGACT", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGACT xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncGACT>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_syncAllData,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGACT\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncGetAR_CustType";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncGetAR_CustType" tagResult:@"FuncGACTResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String CustType = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"AR_CustType"];
                                                 
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"CustType ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncGetOM_Knowledge
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGETOMK"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGETOMK", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGETOMK xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "</FuncGETOMK>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGETOMK\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncGetOM_Knowledge";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncGetOM_Knowledge" tagResult:@"FuncGETOMKResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String Knowledge = %@",stringParse);
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"OM_Knowledge"];
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"Knowledge ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncGetOM_IssueType
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGOIST"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGOIST", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGOIST xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncGOIST>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_branchID,_syncAllData];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGOIST\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncGetOM_IssueType";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncGetOM_IssueType" tagResult:@"FuncGOISTResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String IssueType = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"OM_IssueType"];
                                                 
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"IssueType ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncGetOM_TechnicalSupport
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGOTCS"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGOTCS", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGOTCS xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncGOTCS>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_branchID,_syncAllData];
    
    NSLog(@"soap SyncGetOM_TechnicalSupport = %@",body);
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGOTCS\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncGetOM_TechnicalSupport";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncGetOM_TechnicalSupport" tagResult:@"FuncGOTCSResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String TechnicalSupport = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"OM_TechnicalSupport"];
                                                 
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"TechnicalSupport ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
    
}
-(void) SyncSetAR_Doc
{
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    NSString *stringjson =  [db stringJSONFROMQuery:@"select * from AR_Doc where AdjAmt > 0"];
    NSString *stringBussinessDate = [db stringBussinessDateFromDatabase];
    
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncSEARDOWR"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncSEARDOWR", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncSEARDOWR xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncSEARDOWR>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,stringjson,_branchID,stringBussinessDate];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncSEARDOWR\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncSetAR_Doc";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncSetAR_Doc" tagResult:@"FuncSEARDOWRResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String SetAR_Doc = %@",stringParse);
                                                 
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"SetAR_Doc ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
     
}
-(void) SyncGetAR_Doc
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGEARDO"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGEARDO", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGEARDO xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncGEARDO>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_syncAllData,_branchID];
    NSLog(@"body AR_Doc = %@",body);
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGEARDO\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncGetAR_Doc";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncGetAR_Doc" tagResult:@"FuncGEARDOResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String GetAR_Doc = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"AR_Doc"];
                                                 
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"GetAR_Doc ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];

}
-(void) SyncGetSysCompany
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGESC"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGESC", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGESC xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "</FuncGESC>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGESC\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncGetSysCompany";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncGetSysCompany" tagResult:@"FuncGESCResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String SysCompany = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"SYS_Company"];
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"SysCompany ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncGetSI_State
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGSS"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGSS", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGSS xmlns=\"http://localhost/PPCSyncService/\" />"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGSS\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncGetSI_State";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncGetSI_State" tagResult:@"FuncGSSResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String State = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"SI_State"];
                                                 
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@" ********* State ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncGetSI_City
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGSCT"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGSCT", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGSCT xmlns=\"http://localhost/PPCSyncService/\" />"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGSCT\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncGetSI_City";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncGetSI_City" tagResult:@"FuncGSCTResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String City = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"SI_City"];
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"City ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncGetSI_District
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGSD"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGSD", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGSD xmlns=\"http://localhost/PPCSyncService/\" />"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGSD\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncGetSI_District";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncGetSI_District" tagResult:@"FuncGSDResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String District = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"SI_District"];
                                                 
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"District ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncGetSI_Ward
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGSW"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGSW", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGSW xmlns=\"http://localhost/PPCSyncService/\" />"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGSW\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncGetSI_Ward";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncGetSI_Ward" tagResult:@"FuncGSWResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String Ward = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"SI_Ward"];
                                                 
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"Ward ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];

}
-(void) SyncGetAR_Channel
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGAC"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGAC", stringURL]];
    NSLog(@"URL: %@", url);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGAC xmlns=\"http://localhost/PPCSyncService/\" />"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGAC\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncGetAR_Channel";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncGetAR_Channel" tagResult:@"FuncGACResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String Channel = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"AR_Channel"];
                                                 
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"Channel ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncGetAR_CustClass
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGACC"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGACC", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGACC xmlns=\"http://localhost/PPCSyncService/\" />"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGACC\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncGetAR_CustClass";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncGetAR_CustClass" tagResult:@"FuncGACCResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String CustClass = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"AR_CustClass"];
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"CustClass ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncGetAR_Area
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGAA"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGAA", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGAA xmlns=\"http://localhost/PPCSyncService/\" />"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGAA\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncGetAR_Area";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncGetAR_Area" tagResult:@"FuncGAAResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String Area = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"AR_Area"];
                                                 
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"Area ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncGetAR_ShopType
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGAST"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGAST", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGAST xmlns=\"http://localhost/PPCSyncService/\" />"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGAST\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncGetAR_ShopType";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncGetAR_ShopType" tagResult:@"FuncGASTResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String ShopType = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"AR_ShopType"];
                                                 
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"ShopType ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncGetAR_Customer
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGEARCU"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGEARCU", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGEARCU xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncGEARCU>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_syncAllData,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGEARCU\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncGetAR_Customer";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncGetAR_Customer" tagResult:@"FuncGEARCUResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String Customer = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"AR_Customer"];

                                                 
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"Customer ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncAR_CustomerLocation
{
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    //NSString *stringJSON = [db stringJSONFROMQuery:@"SELECT * FROM AR_CustomerLocation"];
    
    NSString *stringJSON = [db stringJSONForAR_CustomerLocation_SET];
    NSLog(@"string json SyncAR_CustomerLocation = %@",stringJSON);
    
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncINARCLT"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncINARCLT", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncINARCLT xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "</FuncINARCLT>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,stringJSON];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncINARCLT\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            NSLog(@"SyncAR_CustomerLocation - SET OK");
                                            
                                            dispatch_group_leave(group);
                                            
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"SyncAR_CustomerLocation - SET ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                            isSyncPDAToService_OK = NO;
                                        }];
    
    // Start
    [operation start];

    
}
-(void) SyncAR_CustomerLocation_GET
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGARCLT"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGARCLT", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGARCLT xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "</FuncGARCLT>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,@"IFV0001"];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGARCLT\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncAR_CustomerLocation_GET";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncAR_CustomerLocation_GET" tagResult:@"FuncGARCLTResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String CustomerLocation_GET = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"AR_CustomerLocation"];
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"CustomerLocation_GET ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncPPC_ARCustomerInfo
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGACI"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGACI", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGACI xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncGACI>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_syncAllData,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGACI\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncPPC_ARCustomerInfo";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncPPC_ARCustomerInfo" tagResult:@"FuncGACIResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String ARCustomerInfo = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"PPC_ARCustomerInfo"];
                                                 
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"ARCustomerInfo ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncAR_CustomerInfo_Invt
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGARCII"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGARCII", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGARCII xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "</FuncGARCII>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGARCII\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncAR_CustomerInfo_Invt";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncAR_CustomerInfo_Invt" tagResult:@"FuncGARCIIResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String CustomerInfo_Invt = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"AR_CustomerInfo_Invt"];
                                                 
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"CustomerInfo_Invt ***** with Error- %@",error);
                                        
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];

}
-(void) SyncGetOM_SalesRoute
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGEOMSR"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGEOMSR", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGEOMSR xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncGEOMSR>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_syncAllData,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGEOMSR\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncGetOM_SalesRoute";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncGetOM_SalesRoute" tagResult:@"FuncGEOMSRResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String SalesRoute = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"OM_SalesRoute"];
                                                 
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"SalesRoute ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncGetOM_SalesRouteDet
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGEOMSRD"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGEOMSRD", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGEOMSRD xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncGEOMSRD>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_syncAllData,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGEOMSRD\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncGetOM_SalesRouteDet";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncGetOM_SalesRouteDet" tagResult:@"FuncGEOMSRDResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String SalesRouteDet = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"OM_SalesRouteDet"];
                                                 
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"SalesRouteDet ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncSI_Tax
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGT"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGT", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGT xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "</FuncGT>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_syncAllData];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGT\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncSI_Tax";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncSI_Tax" tagResult:@"FuncGTResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String Tax = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"SI_Tax"];
                                                 
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"Tax ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncInvtHierarchy
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGIH"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGIH", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGIH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "</FuncGIH>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGIH\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncInvtHierarchy";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncInvtHierarchy" tagResult:@"FuncGIHResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String InvtHierarchy = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"SI_Hierarchy"];
                                                 
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"InvtHierarchy ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncInventory
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGI"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGI", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGI xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncGI>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_syncAllData,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGI\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncInventory";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncInventory" tagResult:@"FuncGIResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String Inventory = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"IN_Inventory"];
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"Inventory ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncReports
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGMSR"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGMSR", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGMSR xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "</FuncGMSR>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGMSR\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncReports";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncReports" tagResult:@"FuncGMSRResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String Reports = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"RPT_MonthlySales"];
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"Reports ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncOM_Discount
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGD"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGD", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGD xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncGD>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_syncAllData,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGD\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncOM_Discount";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncOM_Discount" tagResult:@"FuncGDResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String Discount = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"OM_Discount"];
                                                 
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"Discount ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncOM_DiscSeq
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGDS"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGDS", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGDS xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncGDS>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_syncAllData,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGDS\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncOM_DiscSeq";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncOM_DiscSeq" tagResult:@"FuncGDSResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String DiscSeq = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"OM_DiscSeq"];
                                                 
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"DiscSeq ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncOM_DiscFreeItem
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGDF"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGDF", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGDF xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncGDF>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_syncAllData,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGDF\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncOM_DiscFreeItem";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncOM_DiscFreeItem" tagResult:@"FuncGDFResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String DiscFreeItem = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"OM_DiscFreeItem"];
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"DiscFreeItem ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncOM_DiscBreak
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGDB"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGDB", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGDB xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncGDB>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_syncAllData,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGDB\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncOM_DiscBreak";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncOM_DiscBreak" tagResult:@"FuncGDBResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String DiscBreak = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"OM_DiscBreak"];
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"DiscBreak ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncOM_DiscCust
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGDC"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGDC", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGDC xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncGDC>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_syncAllData,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGDC\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncOM_DiscCust";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncOM_DiscCust" tagResult:@"FuncGDCResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String DiscCust = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"OM_DiscCust"];
                                                 
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"DiscCust ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncOM_DiscCustClass
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGDCC"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGDCC", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGDCC xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncGDCC>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_syncAllData,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGDCC\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncOM_DiscCustClass";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncOM_DiscCustClass" tagResult:@"FuncGDCCResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String DiscCustClass = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"OM_DiscCustClass"];
                                                 
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"DiscCustClass ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncOM_DiscDescr
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGDD"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGDD", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGDD xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncGDD>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_syncAllData,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGDD\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncOM_DiscDescr";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncOM_DiscDescr" tagResult:@"FuncGDDResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String DiscDescr = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"OM_DiscDescr"];
                                                 
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"DiscDescr ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncOM_DiscItem
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGDI"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGDI", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGDI xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncGDI>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_syncAllData,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGDI\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncOM_DiscItem";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncOM_DiscItem" tagResult:@"FuncGDIResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String DiscItem = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"OM_DiscItem"];
                                                 
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"DiscItem ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncOM_DiscItemClass
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGDIC"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGDIC", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGDIC xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncGDIC>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_syncAllData,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGDIC\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncOM_DiscItemClass";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncOM_DiscItemClass" tagResult:@"FuncGDICResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String DiscItemClass = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"OM_DiscItemClass"];
                                                 
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"DiscItemClass ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncOM_PPAlloc
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGPPA"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGPPA", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGPPA xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncGPPA>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_syncAllData,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGPPA\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncOM_PPAlloc";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncOM_PPAlloc" tagResult:@"FuncGPPAResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String PPAlloc = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"OM_PPAlloc"];
                                                 
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"PPAlloc ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncOM_PPBudget
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGPPB"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGPPB", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGPPB xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncGPPB>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_syncAllData,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGPPB\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncOM_PPBudget";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncOM_PPBudget" tagResult:@"FuncGPPBResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String PPBudget = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"OM_PPBudget"];
                                                 
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"PPBudget ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncOM_Setup
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGSU"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGSU", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGSU xmlns=\"http://localhost/PPCSyncService/\" />"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGSU\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncOM_Setup";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncOM_Setup" tagResult:@"FuncGSUResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String Setup = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"OM_Setup"];
                                                 
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"Setup ***** with Error- %@",error);
                                        
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;}];
    
    // Start
    [operation start];
}
-(void) SyncOM_PriceClass
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGOMPC"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGOMPC", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGOMPC xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "</FuncGOMPC>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_syncAllData];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGOMPC\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncOM_PriceClass";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncOM_PriceClass" tagResult:@"FuncGOMPCResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String PriceClass = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"OM_PriceClass"];
                                                 
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"PriceClass ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncSuggestOrder
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGSO"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGSO", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGSO xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncGSO>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_syncAllData,_branchID];
    
    NSLog(@"body SuggestOrder = %@",body);
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGSO\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncSuggestOrder";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncSuggestOrder" tagResult:@"FuncGSOResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String SuggestOrder = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"PPC_SuggestOrder"];
                                                 
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"SuggestOrder ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncSetting
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncGST"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGST", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGST xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "</FuncGST>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGST\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncSetting";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncSetting" tagResult:@"FuncGSTResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"String Setting = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"Setting"];
                                                 
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"Setting ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
//*******************************************************
//*******************************************************
//*******************************************************
// Sync from PDA -> Service
-(void) SyncAllFromPDAToServiceWithCompletionHandler:(CompletionHandler)completionHandler
{
    arrTableHasError = [[NSMutableArray alloc] init];
    
    isSyncPDAToService_OK = YES;
    group = dispatch_group_create();
    
    [self loginWithCompletionHandler:^(BOOL success)
     {
         if (success)
         {
             @try {
                 dispatch_group_enter(group);
                 [self SyncSales];
                 
                 dispatch_group_enter(group);
                 [self SyncARCustomerDontBuy];
                 
                 dispatch_group_enter(group);
                 [self SyncPPC_IN_InventoryCompetitor];
                 
                 dispatch_group_enter(group);
                 [self SyncPPC_IN_Inventory];
                 
                 dispatch_group_enter(group);
                 [self SyncAR_SalespersonLocationTrace];
                 
                 dispatch_group_enter(group);
                 [self SyncOutsideChecking];
                 
                 dispatch_group_enter(group);
                 [self SyncPPC_NoticeBoardSubmit];
                 
                 dispatch_group_enter(group);
                 [self SyncPPC_TechnicalSupport];
                 
                 dispatch_group_enter(group);
                 [self SyncNewCustomer];
                 
                 dispatch_group_enter(group);
                 [self SyncOM_ProductReneu];
                 
                 dispatch_group_enter(group);
                 [self SyncAR_CustomerLocation];
                 
                 dispatch_group_enter(group);
                 [self SyncPPC_Task];
                 
                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                 NSMutableArray *arrPhotoName = [db arrNamePhotoFromDatabase];
                 NSLog(@"arrPhotoname = %@",arrPhotoName);
                 
                 for (NSString *namePhoto in arrPhotoName)
                 {
                     [self syncPhotoName:namePhoto];
                 }
                 
                 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^
                                {
                                    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
                                    dispatch_async(dispatch_get_main_queue(), ^
                                                   {
                                                       
                                                       //you are now back on the main thread and all the async tasks are done!
                                                       // Save to NSUSerDefault
                                                       NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                                                       [user setObject:arrTableHasError forKey:@"arrTableHasError"];
                                                       [user synchronize];
                                                       
                                                       completionHandler(isSyncPDAToService_OK);
                                                       
                                                   });
                                });

             }
             @catch (NSException *exception) {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Có lỗi ở xảy ra" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                 [alert show];
             }
             @finally {
                 
             }
             
         }
     }];
}
-(void) SyncSales
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncISW"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncISW", stringURL]];
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    
    /* OM_SalesOrd,OM_SalesOrdDet,OM_OrdDisc,OM_SuggestOrder */
    /*
    NSString *jsonString_1 = [db stringJSonWithRootName:@"OM_SalesOrd" fromQuery:@"select * from OM_SalesOrd"];
    NSString *jsonString_2 = [db stringJSonWithRootName:@"OM_SalesOrdDet" fromQuery:@"select * from OM_SalesOrdDet"];
    NSString *jsonString_4 = [db stringJSonWithRootName:@"OM_SuggestOrder" fromQuery:@"select * from OM_SuggestOrder"];
    NSString *jsonString_3 = [db stringJSonWithRootName:@"OM_OrdDisc" fromQuery:@"select * from OM_OrdDisc"];
    */
    NSString *finalJSON = [db stringJSONForSyncSales];
    
    //NSString *finalJSON = [NSString stringWithFormat:@"{%@,%@,%@,%@}",jsonString_1,jsonString_2,jsonString_3,jsonString_4];
    
    NSLog(@"json string SyncSales_1 = %@",finalJSON);
    
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncISW xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "</FuncISW>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,finalJSON,_slsperID];
    
    NSLog(@"body SyncSales = %@",body);
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncISW\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            NSLog(@"SyncSales OK");
                                            dispatch_group_leave(group);
                                            
                                            dispatch_group_enter(group);
                                            [self SyncSales_1];
                                            
                                            
                                            
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"SyncSales ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncPDAToService_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncSales_1
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncSS"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncSS", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncSS xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "</FuncSS>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_branchID];
    
    NSLog(@"body SyncSales = %@",body);
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncSS\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            NSLog(@"SyncSales_1 OK");
                                            
                                            
                                            
                                            dispatch_group_leave(group);
                                            
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"SyncSales_1 ***** with Error- %@",error);
                                            dispatch_group_leave(group);
                                            isSyncPDAToService_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncAR_SalespersonLocationTrace
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncSLT"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncSLT", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    NSString *jsonString = [db stringJSonWithRootName:@"AR_SalespersonLocationTrace" fromQuery:@"select * from AR_SalespersonLocationTrace"];
    
    NSLog(@"json string SyncAR_SalespersonLocationTrace = %@",jsonString);
    
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncSLT xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "</FuncSLT>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,jsonString];
    
    NSLog(@"body SyncAR_SalespersonLocationTrace = %@",body);
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncSLT\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            NSLog(@"SyncAR_SalespersonLocationTrace OK");
                                            
                                            
                                            dispatch_group_leave(group);
                                            
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"SyncAR_SalespersonLocationTrace ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncPDAToService_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncOutsideChecking
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncSOC"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncSOC", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    NSString *jsonString = [db stringJSonWithRootName:@"OutsideChecking" fromQuery:@"select * from OutsideChecking"];
    
    NSLog(@"json string SyncOutsideChecking = %@",jsonString);
    
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncSOC xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncSOC>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,jsonString,_slsperID,_branchID];
    
    NSLog(@"body SyncOutsideChecking = %@",body);
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncSOC\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            NSLog(@"SyncOutsideChecking OK");
                                            
                                            dispatch_group_leave(group);
                                            
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"SyncOutsideChecking ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncPDAToService_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncNewCustomer
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncSNCID"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncSNCID", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    NSString *newCustID = [db getNewCustIDFromSetting];
    
    NSLog(@"string newCustID = %@",newCustID);
    
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncSNCID xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncSNCID>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_branchID,newCustID];
    
    NSLog(@"body SyncNewCustomer = %@",body);
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncSNCID\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            NSLog(@"SyncNewCustomer OK");
                                            
                                            dispatch_group_enter(group);
                                            [self SyncNewCustomer_1];
                                            
                                            dispatch_group_leave(group);
                                            
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"SyncNewCustomer ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncPDAToService_OK = NO;
                                        }];
    
    // Start
    [operation start];

}
-(void) SyncNewCustomer_1
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncINCINFOR"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncINCINFOR", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    NSString *jsonString = [db stringJSonWithRootName:@"AR_NewCustomerInfor" fromQuery:@"SELECT * FROM AR_NewCustomerInfor"];
    
    NSLog(@"string jsonString SyncNewCustomer_1= %@",jsonString);
    
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncINCINFOR xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncINCINFOR>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,jsonString,_slsperID,_branchID];
    
    NSLog(@"body SyncNewCustomer_1 = %@",body);
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncINCINFOR\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            NSLog(@"SyncNewCustomer_1 OK");
                                            
                                            
                                            dispatch_group_leave(group);
                                            
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"SyncNewCustomer_1 ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncPDAToService_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncPPC_NoticeBoardSubmit
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://192.168.130.48:81/Sync.asmx?op=FuncINPNBS"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncINPNBS", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    NSString *jsonString = [db stringJSONForSyncNoticalBoard];
    
    NSLog(@"json string SyncPPC_NoticeBoardSubmit = %@",jsonString);
    
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncINPNBS xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncINPNBS>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,jsonString,_slsperID,_branchID];
    
    NSLog(@"body SyncPPC_NoticeBoardSubmit = %@",body);
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncINPNBS\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            NSLog(@"SyncPPC_NoticeBoardSubmit OK");
                                            
                                            
                                            dispatch_group_leave(group);
                                            
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"SyncPPC_NoticeBoardSubmit ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncPDAToService_OK = NO;
                                            
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncPPC_TechnicalSupport
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://192.168.130.48:81/Sync.asmx?op=FuncINPTCS"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncINPTCS", stringURL]];
    NSLog(@"URL: %@", url);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    NSString *jsonString = [db stringJSONForSyncTechnicalSupport];
    
    NSLog(@"json string SyncPPC_TechnicalSupport = %@",jsonString);
    
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncINPTCS xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncINPTCS>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,jsonString,_slsperID,_branchID];
    
    NSLog(@"body SyncPPC_TechnicalSupport = %@",body);
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncINPTCS\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            NSLog(@"SyncPPC_TechnicalSupport OK");
                                            
                                            XMLParser.accessibilityHint = @"SyncPPC_TechnicalSupport";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncPPC_TechnicalSupport" tagResult:@"FuncINPTCSResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@"Bool TechnicalSupport = %@",stringParse);
                                                 
                                                 if ([stringParse isEqualToString:@"true"])
                                                 {
                                                     [arrTableHasError addObject:@"PPC_TechnicalSupport"];
                                                 }
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                            
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"SyncPPC_TechnicalSupport ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncPDAToService_OK = NO;
                                            
 
                                            
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncOM_ProductReneu
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncIOMPR"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncIOMPR", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    NSString *jsonString = [db stringJSonWithRootName:@"OM_ProductReneu" fromQuery:@"SELECT * FROM  OM_ProductReneu"];
    
    NSLog(@"json string SyncOM_ProductReneu = %@",jsonString);
    
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncIOMPR xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncIOMPR>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,jsonString,_slsperID,_branchID];
    
    NSLog(@"body SyncPPC_IN_Inventory = %@",body);
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncIOMPR\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            NSLog(@"SyncOM_ProductReneu OK");
                                            
                                            
                                            dispatch_group_leave(group);
                                            
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"SyncOM_ProductReneu ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncPDAToService_OK = NO;
                                        }];
    
    // Start
    [operation start];

}
-(void) SyncPPC_IN_Inventory
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://192.168.130.48:81/Sync.asmx?op=FuncINPIN"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncINPIN", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    NSString *jsonString = [db stringJSonWithRootName:@"PPC_IN_Inventory" fromQuery:@"SELECT * FROM  PPC_IN_Inventory"];
    
    NSLog(@"json string SyncPPC_IN_Inventory = %@",jsonString);
    
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncINPIN xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncINPIN>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,jsonString,_slsperID,_branchID];
    
    NSLog(@"body SyncPPC_IN_Inventory = %@",body);
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncINPIN\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            NSLog(@"SyncPPC_IN_Inventory OK");
                                            
                                            
                                            dispatch_group_leave(group);
                                            
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"SyncPPC_IN_Inventory ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncPDAToService_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncPPC_IN_InventoryCompetitor
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncINPINC"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncINPINC", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    NSString *jsonString = [db stringJSonWithRootName:@"PPC_IN_InventoryCompetitor" fromQuery:@"SELECT * FROM  PPC_IN_InventoryCompetitor"];
    NSLog(@"json string SyncPPC_IN_InventoryCompetitor = %@",jsonString);
    
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncINPINC xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncINPINC>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,jsonString,_slsperID,_branchID];
    
    NSLog(@"body SyncPPC_IN_InventoryCompetitor = %@",body);
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncINPINC\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            NSLog(@"SyncPPC_IN_InventoryCompetitor OK");
                                            
                                            
                                            dispatch_group_leave(group);
                                            
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"SyncPPC_IN_InventoryCompetitor ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncPDAToService_OK = NO;
                                            
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncARCustomerDontBuy
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncACDB"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncACDB", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    NSString *jsonString = [db stringJSonWithRootName:@"AR_CustomerDontBuy" fromQuery:@"SELECT * FROM AR_CustomerDontBuy"];
    NSLog(@"json string SyncARCustomerDontBuy = %@",jsonString);
    
    NSString *visitDate = [db stringMaxDateFromDatabase];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncACDB xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncACDB>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,jsonString,_slsperID,visitDate];
    
    NSLog(@"body SyncARCustomerDontBuy = %@",body);
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncACDB\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            NSLog(@"SyncARCustomerDontBuy OK");
                                                 
                                                 
                                                 dispatch_group_leave(group);
                                            
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"SyncARCustomerDontBuy ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncPDAToService_OK = NO;
                                            
                                        }];
    
    // Start
    [operation start];
}
-(void) syncPhotoName:(NSString *)name
{
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [array objectAtIndex:0];
    NSString *photoPath = [documentPath stringByAppendingString:[NSString stringWithFormat:@"/%@.jpg",name]];
    
    NSLog(@"Photo Path = %@",photoPath);
    NSError *error;
    
    //UIImage *image = [UIImage imageWithContentsOfFile:photoPath];
    
    //NSData *dataPhoto = UIImageJPEGRepresentation(image, 0.7f);
    NSData *dataPhoto = [NSData dataWithContentsOfFile:photoPath options:NSDataReadingMappedAlways error:&error];
    if (error)
    {
        NSLog(@"error DataPhoto");
    }
    
    [Base64 initialize];
    NSString *stringData = [ Base64 encode:dataPhoto];
    NSLog(@"stringBase64 = %@",stringData);
    
    /*
    NSUInteger len = dataPhoto.length;
    uint8_t *bytes = (uint8_t *)[dataPhoto bytes];
    NSMutableString *result = [NSMutableString stringWithCapacity:len * 3];
    //[result appendString:@"["];
    for (NSUInteger i = 0; i < len; i++) {
        if (i) {
            [result appendString:@","];
        }
        [result appendFormat:@"%d", bytes[i]];
    }
    //[result appendString:@"]"];
    */
    //************************
    // URL
    NSURL *url = [NSURL URLWithString:@"http://113.161.67.149:8080/SyncServicetest/Sync.asmx?op=FuncSIMG"];
    //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncAC", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncSIMG xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "</FuncSIMG>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,stringData,name];
    
    NSLog(@"body syncPhotoName: = %@",body);
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncSIMG\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            NSLog(@"syncPhotoName OK");
                                            
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"syncPhotoName ***** with Error- %@",error);
                                            
                                        }];
    
    // Start
    [operation start];

    
    

}

-(void) SyncGetPPC_Distributor
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://192.168.130.48:81/Sync.asmx?op=FuncGEPPCDI"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGEPPCDI", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGEPPCDI xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncGEPPCDI>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_syncAllData,_branchID];
    NSLog(@"BDFuncGEPPCDI: %@", body);
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGEPPCDI\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncPPC_Distributor";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncPPC_Distributor" tagResult:@"FuncGEPPCDIResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@" String Distributor = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"PPC_Distributor"];
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                            
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"##### Distributor Fail ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncGetPPC_SurveyBrand
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://192.168.130.48:81/Sync.asmx?op=FuncGEPPCSB"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGEPPCSB", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGEPPCSB xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncGEPPCSB>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_syncAllData,_branchID];
    NSLog(@"BDFuncGEPPCSB: %@", body);
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGEPPCSB\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncPPC_SurveyBrand";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncPPC_SurveyBrand" tagResult:@"FuncGEPPCSBResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@" String SurveyBrand = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"PPC_SurveyBrand"];
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                            
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"##### SurveyBrand Fail ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncGetAR_Transactionlist
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://192.168.130.48:81/Sync.asmx?op=FuncGEARTL"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGEARTL", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGEARTL xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncGEARTL>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_syncAllData,_branchID];
    NSLog(@"BDFuncGEPPCSB: %@", body);
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGEARTL\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncGetAR_Transactionlist";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncGetAR_Transactionlist" tagResult:@"FuncGEARTLResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@" String Transaction = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"AR_Transaction"];
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                            
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"##### Transaction Fail ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncGetPPC_INSite
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://192.168.130.48:81/Sync.asmx?op=FuncGEPPCIS"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGEPPCIS", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGEPPCIS xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncGEPPCIS>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_syncAllData,_branchID];
    //NSLog(@"FuncGEPPCIS: %@", body);
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGEPPCIS\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncGetPPC_INSite";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncGetPPC_INSite" tagResult:@"FuncGEPPCISResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@" String In_Site = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"In_Site"];
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                            
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"##### In_Site Fail ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncGetPPC_PriceOfCust
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://192.168.130.48:81/Sync.asmx?op=FuncGEPPCIS"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGEPPCPOC", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGEPPCPOC xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncGEPPCPOC>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_syncAllData,_branchID];
    //NSLog(@"FuncGEPPCIS: %@", body);
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGEPPCPOC\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncGetPPC_PriceOfCust";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncGetPPC_PriceOfCust" tagResult:@"FuncGEPPCPOCResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@" String PriceOfCust = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"PPC_PriceOfCust"];
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                            
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"##### PriceOfCust Fail ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}

//Check Connection
-(void) checkConnectionWithURL:(NSString*)strURL AndCompletionHandler:(CompletionHandler)completionHanlder
{    
    _completionHander = [completionHanlder copy];
    
    // Database
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:[user objectForKey:@"Setting"]];
    
    _slsperID = [dict objectForKey:@"SlsperID"];
    _password = [dict objectForKey:@"Password"];
    _branchID = [dict objectForKey:@"BranchID"];
    _token = @"";
    
    // URL
    NSURL *url = [NSURL URLWithString:strURL];
    NSLog(@"URL: %@", url);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncLG xmlns=\"http://localhost/PPCSyncService/\" />"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID];
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncLG\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser) {
        NSLog(@"OK");
        
        XMLParser.accessibilityHint = @"Login";
        // Parse
        [_xmlManager getStringFromXMLParse:XMLParser funcName:@"Login" tagResult:@"FuncLGResult" withCompletionHandler:^(BOOL success, NSString *stringParse) {
            
            NSLog(@" Bool Login = %@",stringParse);
            /*
            // Get Gobal
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            NSDictionary *dict = [user objectForKey:@"HeaderSOAP"];
            _slsperID = [dict objectForKey:@"Var1"];
            _password = [dict objectForKey:@"Var2"];
            _token = [dict objectForKey:@"Var3"];
            _branchID = [dict objectForKey:@"Var4"];
            
            if (!_token)
                _token = @"";
            
            //if (!_branchID)
            //_branchID = @"IFV0001";
            _branchID = @"IFV0001";
            */
            completionHanlder(YES);
        }];
        
        
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
        NSLog(@"Fail Login");
        _completionHander(NO);
    }];
    
    // Start
    [operation start];
}

-(void) SyncGetOM_DefineWorks
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://192.168.130.48:81/Sync.asmx?op=FuncGOMDW"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncGOMDW", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncGOMDW xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "</FuncGOMDW>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,_slsperID,_branchID];

    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncGOMDW\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            XMLParser.accessibilityHint = @"SyncGetOM_DefineWorks";
                                            [_xmlManager getStringFromXMLParse:XMLParser funcName:@"SyncGetOM_DefineWorks" tagResult:@"FuncGOMDWResult" withCompletionHandler:^(BOOL success, NSString *stringParse)
                                             {
                                                 NSLog(@" String OM_DefineWorks = %@",stringParse);
                                                 
                                                 FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                                                 [db saveJSONToDatabase:stringParse atTable:@"OM_DefineWorks"];
                                                 
                                                 dispatch_group_leave(group);
                                             }];
                                            
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"##### OM_DefineWorks Fail ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncServiceToPDA_OK = NO;
                                        }];
    
    // Start
    [operation start];
}
-(void) SyncPPC_Task
{
    // URL
    //NSURL *url = [NSURL URLWithString:@"http://192.168.130.48:81/Sync.asmx?op=FuncSEPPCTASK"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?op=FuncSEPPCTASK", stringURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    NSString *jsonString = [db stringJSonWithRootName:@"PPC_Task" fromQuery:@"SELECT * FROM  PPC_Task"];
    
    NSLog(@"json string SyncPPC_Task = %@",jsonString);
    
    
    // Body
    NSString *body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                      "<soap:Header>"
                      "<clsTCH xmlns=\"http://localhost/PPCSyncService/\">"
                      "<Var1>%@</Var1>"
                      "<Var2>%@</Var2>"
                      "<Var3>%@</Var3>"
                      "<Var4>%@</Var4>"
                      "</clsTCH>"
                      "</soap:Header>"
                      "<soap:Body>"
                      "<FuncSEPPCTASK xmlns=\"http://localhost/PPCSyncService/\">"
                      "<param1>%@</param1>"
                      "<param2>%@</param2>"
                      "<param3>%@</param3>"
                      "</FuncSEPPCTASK>"
                      "</soap:Body>"
                      "</soap:Envelope>",_slsperID,_password,_token,_branchID,jsonString,_slsperID,_branchID];
    
    NSLog(@"body SyncPPC_Task = %@",body);
    
    // Header
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d",body.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"\"http://localhost/PPCSyncService/FuncSEPPCTASK\"" forHTTPHeaderField:@"SOAPAction"];
    
    // Body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XEM afnetworking
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser)
                                        {
                                            NSLog(@"SyncPPC_Task OK");
                                            
                                            
                                            dispatch_group_leave(group);
                                            
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                            NSLog(@"SyncPPC_Task ***** with Error- %@",error);
                                            
                                            dispatch_group_leave(group);
                                            isSyncPDAToService_OK = NO;
                                        }];
    
    // Start
    [operation start];
}


@end
