//
//  FeDatabaseManager.h
//  eSales
//
//  Created by Nghia Tran on 8/22/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLHelper.h"
#import "SBJson.h"

typedef void (^CompletionHandler)(BOOL success);

@interface FeDatabaseManager : NSObject
+(FeDatabaseManager *) sharedInstance;
-(id) init;
// Login
-(BOOL) loginWithUsername:(NSString *) username password:(NSString *) pass;

// save data
-(NSString *) lastIDForTable:(NSString *) table columnName:(NSString *) column;

// Nee Customer
-(void) saveNewCustomerUsingNSUserDefaultWithCompletionHandler:(CompletionHandler) completionHandler;
// PhanHoi Save
-(void) savePhanHoiUsingNSUserDefaultWithCompletionHandler:(CompletionHandler) completionHandler;
// Ho Tro Ky Thuat
-(void) saveHoTroKyThuatUsingNSUserDefaultWithCompletionHandler:(CompletionHandler) completionHandler;

// NEW custumer
-(NSMutableArray *) arrKenhFromDatabase;
-(NSMutableArray *) arrNhomKHFromDatabase;
-(NSMutableArray *) arrKhuVucFromDatabase;
-(NSMutableArray *) arrLoaiCuaHangFromDatabase;
-(NSMutableArray *) arrLoaiBanHanFromDatabase;
-(NSMutableArray *) arrTPFromDatabaseWithIDKhucVuc:(NSString *) idKhuVuc;
-(NSMutableArray *) arrQuanHuyenFromDatabaseWithIDThanhPho:(NSString *) idThanhPho;

// NEWS
-(NSMutableArray *) arrBangTinFromDatabase;

// Technical
-(NSMutableArray *) arrLoaiYCFromDatabase;
-(NSMutableArray *) arrThongTinKyThuatWithIDLoaiYC:(NSString *) loaiYC;

// Product Inventor
-(NSMutableArray *) arrSanPhamFromDatabase;

/// GPS
-(NSMutableArray *) arrGSPDSKhachHangFromDatabaseAtDate:(NSString *) stringDate;
-(NSString *) stringMaxDateFromDatabase;
-(void) saveGPSForCustomerWithArr:(NSMutableArray *) arrCustomer;

//*********
// SETTING
-(void) saveSettingUsingNSUSerDefaultWithCompletionHandler:(CompletionHandler) completionHandler;
-(NSMutableArray *) arrSaleSetupFromDatabase;
-(void) saveSaleSetupUsingNSUserDefaultWithCompletionHandler:(CompletionHandler) completionHanlder;


// Take Order
-(NSMutableArray *) arrDSKhachHangFromDatabaseAtDate:(NSString *) stringDate;
-(NSMutableArray *) arrALLDSKhachHangFromDatabase;
-(void) saveTakeOrderDictionary:(NSMutableDictionary *) dict WithCompletionHandler:(CompletionHandler) completionHandler;
-(void) saveTakeOrderKHKhongMuaWithDictionary:(NSMutableDictionary *) dict withCompletionHandler:(CompletionHandler) completionHandler;
// Lich Su Ban Hang
-(NSMutableArray *) arrLichSuBanHangFromDatabaseWithCustomerID:(NSString *) custID;
-(NSMutableArray *) arrTuoiNoFromDatabaseWithCustomerID:(NSString *) custID;

// Thong Tin Doi Thu
-(NSMutableArray *) arrBrancdFromDatabase;
-(NSMutableArray *) arrSanPhamDoiThuFromDatabaseWithCustID:(NSString *) custID;

// GhiNhanDonhang
-(NSMutableArray *) arrGhiNhanDonHangFromDatabaseWithCustID:(NSString*)custID AndPriceClassID:(NSString*)priceClassID AndSiteID:(NSString*)siteID;
-(NSMutableArray *) arrLyDoFromDatabase;
-(NSMutableArray *) arrNhaPhanPhoiFromDatabase;
//***************
// Convert table to json
-(NSString *) stringJSONFROMQuery:(NSString *) queryString;
-(NSString *) stringJSonWithRootName:(NSString *) rootName fromQuery:(NSString *) queryString;
-(NSString *) stringJSONForSyncSales;
-(NSString *) stringJSONForSyncTechnicalSupport;
-(NSString *) stringJSONForSyncNoticalBoard;
-(NSString *) stringJSONForAR_CustomerLocation_SET;
-(NSString *) stringBussinessDateFromDatabase;
-(BOOL) isHasValueWithQuery:(NSString *) queryString;

// *****************
// Save to database - Sync
-(void) saveJSONToDatabase:(NSString *) jsonString atTable:(NSString *) table;
-(void) printAllNameDatabase;
-(NSString *) getNewCustIDFromSetting;

// Delete all table
-(void) deleteAllTalbForSyncPDAToService;
-(void) deleteAllTableForLogout;

// Sync Photo
-(NSMutableArray *) arrNamePhotoFromDatabase;

//Get Image
-(NSMutableArray *) arrURLImagePhotoForTechnicalSupportWithID:(NSString *) ID;
-(NSMutableArray *) arrURLImagePhotoForNoticeBoardWithID:(NSString *) ID;
-(NSMutableArray *) arrURLImagePhotoForCustomerID:(NSString *) ID;

// *********************Report**********************
//Day
-(NSString *) soluongKhacHangFromDatabaseAtDate:(NSString *) stringDate;
-(NSString *) soluongDonHangFromDatabase;
-(NSString *) soluongKHBaoPhuFromDatabase;
-(NSString *) tongKhuyenMaiFromDatabase;
-(NSMutableDictionary *) dictTongChietKhauVaDoanhSoFromDatabase;

//Month
-(NSMutableDictionary *) dictBaoCaoThangFromDatabase;

//DS Don Hang
-(NSMutableArray *) arrDSDonHangFromDatabase;
-(void) deleteOM_SaleOrdWithOrderNbr:(NSString *)strOrderNbr;
-(NSMutableArray *) arrAllOM_SalesOrdDetFromDatabaseWithOrderNbr:(NSString *)strOrderNbr;
-(NSMutableDictionary *) arrIN_ItemLocByKeyWithInvtID:(NSString *)invtID SiteID:(NSString *)siteID WhseLoc:(NSString *)whseLoc;
-(void) updateIN_ItemLocWithDict:(NSMutableDictionary *)dict QtyAvail:(int) qtyAvail;
-(void) deleteOM_SalesOrdDetWithOrderNbr:(NSString *)strOrderNbr;

//DS KH Moi
-(NSMutableArray *) arrDSKHMoiFromDatabase;
-(void) deleteAR_NewCustomerInforWithCustID:(NSString *)strCustID;

//TT Phan Hoi
-(NSMutableArray *) arrTTPhanHoiFromDatabase;
-(NSMutableDictionary *) arrNewTechnicalSupportFromDatabaseWithCode:(NSString*)strCode;
-(NSMutableDictionary *) arrNoticeBoardSubmitFromDatabaseWithCode:(NSString*)strCode;
-(NSMutableDictionary *) arrPhanHoiFromDatabaseWithCode:(NSString*)strCode;
-(void) deletePPC_TechnicalSupportWithCode:(NSString *)strCode;
-(void) deletePPC_OM_TechnicalSupport_ImageWithCode:(NSString *)strCode;

-(void) deletePPC_NoticeBoardSubmitWithCode:(NSString *)strCode;
-(void) deletePPC_NoticeBoardSubmitImageWithCode:(NSString *)strCode;
    // Update Ho tro ky thuat
-(void) updateHoTroKyThuatUsingNSUserDefaultWithCompletionHandler:(CompletionHandler) completionHandler;
    // Update Phan Hoi
-(void) updatePhanHoiUsingNSUserDefaultWithCompletionHandler:(CompletionHandler)completionHandler;
// Doi chieu cong no
-(NSMutableArray *) arrDoiChieuCongNoFromDatabaseWithCustomerID:(NSString *)custID;
// SL Ghi Nhan Don Hang
-(NSMutableArray *) arrSLGhiNhanDonHangFromDatabaseWithOrderNbr:(NSString*)orderNbr;
-(void) deleteDonHangCuFromDatabaseWithOrderNbr:(NSString*)orderNbr;
// Update KH Moi
-(void) updateNewCustomerWithDict:(NSMutableDictionary*)dictKHMoi UsingNSUserDefaultWithCompletionHandler:(CompletionHandler)completionHandler;
// Get max Id in Table
-(NSString *) maxIDForTable:(NSString *) table columnName:(NSString *) column;
// Get URL Sync
-(NSMutableDictionary*)getURLSyncFromDatabase;
// Get Query KH
-(NSMutableArray*) arrPPC_ARCustomerInfoFromDatabase;
-(NSMutableArray*) arrCustomerNonTradeFromDatabaseWithCustID:(NSString*)custID;
-(NSMutableArray*) arrCustomerTradeFromDatabaseWithCustID:(NSString*)custID;
-(NSMutableArray*) arrSurveyBrandFromDatabaseWithCustID:(NSString*)custID;
// Price of Site
-(NSMutableArray*) arrSiteFromDatabaseWithInvtID:(NSString*)invtID;
-(NSMutableArray*) arrSiteFromDatabase;
-(CGFloat) priceOfSite:(NSString*)siteID AndInvtID:(NSString*)invtID;
// Task
-(NSMutableArray*) arrOM_DefineWorksFromDatabase;
-(BOOL)checkTaskExistInDatabaseWithCustID:(NSString*)custID AndTaskID:(NSString*)taskID;
-(void) saveTaskDictionary:(NSMutableDictionary *) dict WithCompletionHandler:(CompletionHandler)completionHandler;
-(void) updateTaskWithDict:(NSMutableDictionary*)dict WithCompletionHandler:(CompletionHandler)completionHandler;
-(NSMutableDictionary*)arrTaskExistInDatabaseWithCustID:(NSString*)custID AndTaskID:(NSString*)taskID;

-(NSMutableArray *) arrAllPhotoShouldDownload;
@end
