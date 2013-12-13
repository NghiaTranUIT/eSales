//
//  FeWebservice.h
//  eSales
//
//  Created by Nghia Tran on 9/1/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "AFHTTPClient.h"
typedef void (^CompletionHandler)(BOOL success);

@protocol FeWebserviceDelegate;

@interface FeWebservice : AFHTTPClient

// Singleton parterrn
+(FeWebservice *) shareInstance;

-(void) syncAllFuncWithCompletionHandler:(CompletionHandler) completionHanlder;
-(void) loginWithCompletionHandler:(CompletionHandler) completionHanlder;

//Check Connection
-(void) checkConnectionWithURL:(NSString*)url AndCompletionHandler:(CompletionHandler)completionHanlder;

//**********

-(void) SyncGetIN_Brand;
-(void) SyncGetPPC_SalesHistory;
-(void) SyncGetPPC_AgingDebt;
-(void) SyncGetIN_InventoryCompetitor;
-(void) SyncGetOM_ReasonCode;
-(void) SyncGetAR_Territory;
-(void) SyncGetAR_CustType;
-(void) SyncGetOM_Knowledge;
-(void) SyncGetOM_IssueType;
-(void) SyncGetOM_TechnicalSupport;
-(void) SyncSetAR_Doc;
-(void) SyncGetAR_Doc;
-(void) SyncGetSysCompany;
-(void) SyncGetSI_State;
-(void) SyncGetSI_City;
-(void) SyncGetSI_District;
-(void) SyncGetSI_Ward;
-(void) SyncGetAR_Channel;
-(void) SyncGetAR_CustClass;
-(void) SyncGetAR_Area;
-(void) SyncGetAR_ShopType;
-(void) SyncGetAR_Customer;
-(void) SyncAR_CustomerLocation;
-(void) SyncAR_CustomerLocation_GET;
-(void) SyncPPC_ARCustomerInfo;
-(void) SyncAR_CustomerInfo_Invt;
-(void) SyncGetOM_SalesRoute;
-(void) SyncGetOM_SalesRouteDet;
-(void) SyncSI_Tax;
-(void) SyncInvtHierarchy;
-(void) SyncInventory;
-(void) SyncReports;
-(void) SyncOM_Discount;
-(void) SyncOM_DiscSeq;
-(void) SyncOM_DiscFreeItem;
-(void) SyncOM_DiscBreak;
-(void) SyncOM_DiscCust;
-(void) SyncOM_DiscCustClass;
-(void) SyncOM_DiscDescr;
-(void) SyncOM_DiscItem;
-(void) SyncOM_DiscItemClass;
-(void) SyncOM_PPAlloc;
-(void) SyncOM_PPBudget;
-(void) SyncOM_Setup;
-(void) SyncOM_PriceClass;
-(void) SyncSuggestOrder;
-(void) SyncSetting;
-(void) SyncGetPPC_Distributor;
-(void) SyncGetPPC_SurveyBrand;
-(void) SyncGetAR_Transactionlist;
-(void) SyncGetPPC_INSite;
-(void) SyncGetPPC_PriceOfCust;
-(void) SyncGetOM_DefineWorks;
//****************************************
//****************************************
// Sync from PDA -> Service
-(void) SyncAllFromPDAToServiceWithCompletionHandler:(CompletionHandler) completionHandler;
-(void) SyncSales;
-(void) SyncSales_1;
-(void) SyncAR_SalespersonLocationTrace;
-(void) SyncOutsideChecking;
-(void) SyncNewCustomer;
-(void) SyncNewCustomer_1;
-(void) SyncPPC_NoticeBoardSubmit;
-(void) SyncPPC_TechnicalSupport;
-(void) SyncOM_ProductReneu;
-(void) SyncPPC_IN_Inventory;
-(void) SyncPPC_IN_InventoryCompetitor;
-(void) SyncARCustomerDontBuy;
-(void) SyncPPC_Task;
-(void) SyncPPC_TechnicalSupport1;

// Sync Photo
-(void) syncPhotoName:(NSString *) name;
@end

@protocol FeWebserviceDelegate <NSObject>

-(void) FeWebService:(FeWebservice *) sender syncWithTitle:(NSString *) title;
@end