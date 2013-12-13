//
//  FeDatabaseManager.m
//  eSales
//
//  Created by Nghia Tran on 8/22/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeDatabaseManager.h"
#import <sqlite3.h>
#import "AFImageRequestOperation.h"
#define kURLPhoto @"http://113.161.67.149:8080/syncservicetest/Sync/Pics/"

@interface FeDatabaseManager()
{
    sqlite3 *db;
    NSString *databasePath;
    
    NSMutableArray *arrTable;
}

-(void) checkDatabase;

//**************



@end

@implementation FeDatabaseManager
+(FeDatabaseManager *) sharedInstance
{
    static FeDatabaseManager *instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FeDatabaseManager alloc] init];
    });
    
    return instance;
}
-(id) init
{
    self = [super init];
    if (self)
    {
        //NSString *pathDatabase = [[NSBundle mainBundle] pathForResource:@"Mobile" ofType:@"db3"];
        
        [self checkDatabase];
        
        if (sqlite3_open([databasePath UTF8String], &db) != SQLITE_OK)
        {
            //NSLog(@"Error with database");
        }
        
        arrTable = [[NSMutableArray alloc] init];
    }
    return self;
}
-(void) saveSettingUsingNSUSerDefaultWithCompletionHandler:(CompletionHandler)completionHandler
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:[user objectForKey:@"Setting"]];
    NSString *SlsperID = [dict objectForKey:@"SlsperID"];
    NSString *Password = [dict objectForKey:@"Password"];
    NSString *SyncAddress = [dict objectForKey:@"SyncAddress"];
    NSString *SyncAddressWAN = [dict objectForKey:@"SyncAddressWAN"];
    
    NSNumber *IsSyncWAN = [dict objectForKey:@"IsSyncWAN"];
    NSNumber *IsSyncAllData = [dict objectForKey:@"IsSyncAllData"];
    NSNumber *IsStepSales = [dict objectForKey:@"IsStepSales"];
    NSNumber *IsChkOldData = [dict objectForKey:@"IsChkOldData"];
    
    NSString *BranchID = [dict objectForKey:@"BranchID"];
    
    
    sqlite3_stmt *stmt1;
    NSString *query1 = @"UPDATE Setting SET SlsperID = ? , Password = ? , SyncAddress = ? , SyncAddressWAN = ? , IsSyncWAN = ? , IsSyncAllData = ? , isStepSales = ? , IsChkOldData = ? , BranchID = ? WHERE SetupID = 'eBiz' ";
    
    if (sqlite3_prepare_v2(db, [query1 UTF8String], -1, &stmt1, nil) == SQLITE_OK)
    {
        sqlite3_bind_text(stmt1, 1, SlsperID.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt1, 2, Password.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt1, 3, SyncAddress.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt1, 4, SyncAddressWAN.UTF8String, -1, NULL);
        
        /*
        sqlite3_bind_int(stmt1, 5, IsSyncWAN.intValue);
        sqlite3_bind_int(stmt1, 6, IsSyncAllData.intValue);
        sqlite3_bind_int(stmt1, 8, IsStepSales.intValue);
        sqlite3_bind_int(stmt1, 11, IsChkOldData.intValue);
        
        sqlite3_bind_text(stmt1, 18, BranchID.UTF8String, -1, NULL);
        //sqlite3_bind_int(stmt1, 18, BranchID.intValue);
     */
        sqlite3_bind_int(stmt1, 5, IsSyncWAN.intValue);
        sqlite3_bind_int(stmt1, 6, IsSyncAllData.intValue);
        sqlite3_bind_int(stmt1, 7, IsStepSales.intValue);
        sqlite3_bind_int(stmt1, 8, IsChkOldData.intValue);
        
        sqlite3_bind_text(stmt1, 9, BranchID.UTF8String, -1, NULL);
        //sqlite3_bind_int(stmt1, 18, BranchID.intValue);
    }
    if (sqlite3_step(stmt1) == SQLITE_DONE)
    {
        //NSAssert(0, @"Error updating table.");
        //NSLog(@"Save avatar OK");
    }
    sqlite3_finalize(stmt1);
    
    completionHandler(YES);
    
}
-(BOOL) loginWithUsername:(NSString *)username password:(NSString *)pass
{
    BOOL success = NO;
    NSMutableDictionary *dict;
    
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM Setting WHERE SlsperID = '%@' AND Password = '%@'",username, pass];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            success = YES;
            char *SetupID = (char *) sqlite3_column_text(statement, 0);
            char *SlsperID = (char *) sqlite3_column_text(statement, 1);
            char *Password = (char *) sqlite3_column_text(statement, 2);
            char *SyncAddress = (char *) sqlite3_column_text(statement, 3);
            char *SyncAddressWAN = (char *) sqlite3_column_text(statement, 4);
            char *BusinessDate = (char *) sqlite3_column_text(statement, 12);
            char *DeliveryMan = (char *) sqlite3_column_text(statement, 19);
            char *CpnyName = (char *) sqlite3_column_text(statement, 16);
            char *BranchID = (char *) sqlite3_column_text(statement, 18);
            
            // BOOL
            int isSyncWAN = (int) sqlite3_column_int(statement, 5);
            int isSyncAllData = (int) sqlite3_column_int(statement, 6);
            int idDisplayMap = (int) sqlite3_column_int(statement, 7);
            int isStepSales = (int) sqlite3_column_int(statement, 8);
            int isCICO = (int) sqlite3_column_int(statement, 9);            
            int isChkOldData = (int) sqlite3_column_int(statement, 11);
            
            dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSString stringWithUTF8String:SetupID],@"SetupID",[NSString stringWithUTF8String:SlsperID],@"SlsperID",[NSString stringWithUTF8String:Password],@"Password",[NSString stringWithUTF8String:SyncAddress],@"SyncAddress",[NSString stringWithUTF8String:SyncAddressWAN],@"SyncAddressWAN",
                [NSString stringWithUTF8String:BusinessDate],@"BusinessDate",
                [NSString
                 stringWithUTF8String:DeliveryMan],@"SiteDefault",
                [NSString
                 stringWithUTF8String:CpnyName],@"CpnyName",
                [NSString stringWithUTF8String:BranchID],@"BranchID", nil];
            
            [dict setObject:[NSNumber numberWithInt:isSyncWAN] forKey:@"IsSyncWAN"];
            [dict setObject:[NSNumber numberWithInt:isSyncAllData] forKey:@"IsSyncAllData"];
            [dict setObject:[NSNumber numberWithInt:idDisplayMap] forKey:@"IdDisplayMap"];
            [dict setObject:[NSNumber numberWithInt:isStepSales] forKey:@"IsStepSales"];
            [dict setObject:[NSNumber numberWithInt:isCICO] forKey:@"IsCICO"];
            [dict setObject:[NSNumber numberWithInt:isChkOldData] forKey:@"IsChkOldData"];
            
        }
    }
    sqlite3_finalize(statement);
    
    // Save
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dict];
    
    // Save data
    NSError *err;
    NSString *docsDir;
    NSArray *dirPaths;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    
    NSString *Path = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"TempLogin.data"]];
    [data writeToFile:Path options:NSDataWritingAtomic error:&err];
    
    [user setObject:data forKey:@"Setting"];
    [user synchronize];
    
    return success;
}

-(void) checkDatabase
{
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [array objectAtIndex:0];
    databasePath = [documentPath stringByAppendingPathComponent:@"Mobile.db3"];
    NSLog(@"Path: %@", databasePath);
    
    BOOL isExist = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    isExist = [fileManager fileExistsAtPath:databasePath];
    
    if (!isExist)
    {
        NSString *bundlePath = [[[NSBundle mainBundle] resourcePath ] stringByAppendingPathComponent:@"Mobile.db3"];
        NSError *error;
        [fileManager copyItemAtPath:bundlePath toPath:databasePath error:&error];
        
        if (error)
        {
            //NSLog(@"Error when copy path From %@ to %@",bundlePath,databasePath);
        }
        else
        {
            //NSLog(@"Copy database OK");
        }
    }
else
{
    //NSLog(@"database is exsisting");
}
    
}
-(void) updateNewCustomerWithDict:(NSMutableDictionary*)dictKHMoi UsingNSUserDefaultWithCompletionHandler:(CompletionHandler)completionHandler
{
    // Saler Man
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *setting = [NSKeyedUnarchiver unarchiveObjectWithData:[user objectForKey:@"Setting"]];
    
    
    NSString *slsperID = [setting valueForKey:@"SlsperID"];
    NSString *brandID = [setting valueForKey:@"BranchID"];
    NSString *CustID = [dictKHMoi objectForKey:@"CustID"];
    NSString *imgFileName = [dictKHMoi objectForKey:@"ImageFileName"];
    // User default
    
    
    // NString Col
    NSString *str2 = [user valueForKey:@"2_tenCuaHang"];
    NSString *str3 = [user valueForKey:@"2_tenKH"];
    NSString *str4 = [user valueForKey:@"2_dienThoai"];
    NSString *str5 = @""; // Mobile
    NSString *str6 = [user valueForKey:@"2_fax"];
    NSString *str7 = [user valueForKey:@"2_email"];
    NSString *str8 = [user valueForKey:@"2_diaChiDayDu"];
    NSString *str9 = @"";
    NSString *str10 = @""; // adred 3
    
    NSDictionary *dictTinh = [user valueForKey:@"2_dictTP"];
    NSString *str11 = [dictTinh valueForKey:@"State"];
    NSString *str12 = [dictTinh valueForKey:@"State"];
    
    NSDictionary *dictQuan = [user valueForKey:@"2_dictQuanHuyen"];
    NSString *str13 = [dictQuan valueForKey:@"District"];
    
    NSString *str14 = @"";
    //NSString *str14 = [user valueForKey:@"2_phuongXa"];
    
    NSDictionary *dictKenh = [user valueForKey:@"2_dictKenh"];
    NSString *str15 = [dictKenh valueForKey:@"Code"];
    
    NSDictionary *dictNhomKH = [user valueForKey:@"2_dictNhomKH"];
    NSString *str16 = [dictNhomKH valueForKey:@"ClassId"];
    
    NSDictionary *dictKhuVuc = [user valueForKey:@"2_dictKhuVuc"];
    NSString *str17 = [dictKhuVuc valueForKey:@"Area"]; // Area
    NSString *str18 = [dictKhuVuc valueForKey:@"Area"]; // Terrious
    
    NSDictionary *dictLoaiCH = [user valueForKey:@"2_dictLoaiCuaHang"];
    NSString *str19 = [dictLoaiCH valueForKey:@"Code"]; // Loai CH
    
    NSDictionary *dictLoaiBH = [user valueForKey:@"2_dictLoaiBanHang"];
    NSString *str20 = [dictLoaiBH valueForKey:@"Code"];
    
    NSString *str21 = [user valueForKey:@"1_lat"];
    NSString *str22 = [user valueForKey:@"1_lng"]; // lng
    
    //NSString *str23 = [NSString stringWithFormat:@"photoCustomer_%@",CustID]; // file avatar name
    NSString *str23 = imgFileName;
    
    NSString *str24 = [user valueForKey:@"3_tenCongTy"];
    NSString *str25 = [user valueForKey:@"3_diaChi"];
    NSString *str26 = [user valueForKey:@"3_ngayThanhLap"];
    NSString *str27 = [user valueForKey:@"3_nguoiDaiDien"]; // Owe
    
    NSString *str28 = [user valueForKey:@"3_taiKhoanNH"];
    
    
    NSString *str29 = [user valueForKey:@"4_tenKH1"];
    NSString *str30 = [user valueForKey:@"4_diaChi1"];
    NSString *str31 = [user valueForKey:@"4_dienThoai1"];
    NSString *str32 = [user valueForKey:@"4_email1"];
    NSString *str33 = [user valueForKey:@"4_ngaySinh1"];
    
    NSString *str34 = [user valueForKey:@"4_tenKH2"];
    NSString *str35 = [user valueForKey:@"4_diaChi2"];
    NSString *str36 = [user valueForKey:@"4_dienThoai2"];
    NSString *str37 = [user valueForKey:@"4_email2"];
    NSString *str38 = [user valueForKey:@"4_ngaySinh2"];
    
    NSString *str39 = [user valueForKey:@"4_tenKH3"];
    NSString *str40 = [user valueForKey:@"4_diaChi3"];
    NSString *str41 = [user valueForKey:@"4_dienThoai3"];
    NSString *str42 = [user valueForKey:@"4_email3"];
    NSString *str43 = [user valueForKey:@"4_ngaySinh3"];
    
    NSString *str44 = @"0";
    NSString *str45 = @"0";
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *str46 = [format stringFromDate:[NSDate date]];
    NSString *str47 = [format stringFromDate:[NSDate date]];
    
    // ***************************
    // Update Avatar
    NSString *ava_str1 = CustID;
    NSString *ava_str2 = @"Document";
    NSString *ava_str3 = str23;
    NSString *ava_str4 = [format stringFromDate:[NSDate date]];
    NSString *ava_str5 = @"";
    NSString *ava_str6 = str21;
    NSString *ava_str7 = str22;
    NSString *ava_str8 = [format stringFromDate:[NSDate date]];
    
    sqlite3_stmt *stmt1;
    NSString *query1 = @"UPDATE AR_NewCustomer_Picture SET ImageRelatePath = ? , ImageFileName = ?, ImageDate = ?, ImageHashString = ?, Lat = ?, Lng = ?, UpdateTime = ? WHERE CustID = ? ";
    
    if (sqlite3_prepare_v2(db, [query1 UTF8String], -1, &stmt1, nil) == SQLITE_OK)
    {
        sqlite3_bind_text(stmt1, 1, ava_str2.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt1, 2, ava_str3.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt1, 3, ava_str4.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt1, 4, ava_str5.UTF8String, -1, NULL);
        sqlite3_bind_double(stmt1, 5, ava_str6.doubleValue);
        sqlite3_bind_double(stmt1, 6, ava_str7.doubleValue);
        sqlite3_bind_text(stmt1, 7, ava_str8.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt1, 8, ava_str1.UTF8String, -1, NULL);
    }
    if (sqlite3_step(stmt1) == SQLITE_DONE)
    {
        //NSAssert(0, @"Error updating table.");
        //NSLog(@"Save avatar OK");
    }
    ////NSLog(@"Save Avatar Done");
    
    // Save Data to Document
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *pathDocument = [paths objectAtIndex:0];
    NSData *dataAvatar = [user objectForKey:@"1_avatarCustomer"];
    NSString *pathAvatar = [pathDocument stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",ava_str3]];
    NSError *error;
    [dataAvatar writeToFile:pathAvatar options:NSDataWritingAtomic error:&error];
    
    sqlite3_finalize(stmt1);
    
    // Update KH
    NSString *query2 = @"UPDATE AR_NewCustomerInfor SET OutletName = ?, ContactName = ?, Phone = ?, Mobile = ?, Fax = ?, Email = ?, Addr1 = ?, Addr2 = ?, Addr3 = ?, State = ?, City = ? , District = ? , Ward = ? , Channel = ?, ClassId = ?, Area = ?, Territory= ?, ShopType= ?, TradeType= ?, Lat = ?, Lng= ?, ImageFileName= ?, CpnyName= ?, AddrCpny= ?, DateCpny= ?, Owner=? , BankAccount= ?, ContactName1= ?, Addr11= ?, Phone1= ?, Email1= ?, DOB1= ?, ContactName2= ?, Addr21= ?, Phone2= ?, Email2= ?, DOB2= ?, ContactName3= ?, Addr31= ?, Phone3= ?, Email3= ?, DOB3= ?, Status= ?, IsActive= ?, Crtd_Datetime= ?, LUpd_Datetime= ? WHERE CustID = ?";
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(db, [query2 UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        
        sqlite3_bind_text(stmt, 1, str2.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 2, str3.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 3, str4.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 4, str5.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 5, str6.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 6, str7.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 7, str8.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 8, str9.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 9, str10.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 10, str11.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 11, str12.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 12, str13.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 13, str14.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 14, str15.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 15, str16.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 16, str17.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 17, str18.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 18, str19.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 19, str20.UTF8String, -1, NULL);
        sqlite3_bind_double(stmt, 20, str21.doubleValue);
        //sqlite3_bind_text(stmt, 21, str6.UTF8String, -1, NULL);
        sqlite3_bind_double(stmt, 21, str22.doubleValue);
        //sqlite3_bind_text(stmt, 22, [field.text UTF8String], -1, NULL);
        
        sqlite3_bind_text(stmt, 22, str23.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 23, str24.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 24, str25.UTF8String, -1, NULL);
        
        //if ([str26 isEqualToString:@""])
        //sqlite3_bind_null(stmt, 26);
        //else
        sqlite3_bind_text(stmt, 25, str26.UTF8String, -1, NULL);
        //sqlite3_bind_text(stmt, 26, [field.text UTF8String], -1, NULL);
        
        sqlite3_bind_text(stmt, 26, str27.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 27, str28.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 28, str29.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 29, str30.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 30, str31.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 31, str32.UTF8String, -1, NULL);
        
        //if ([str33 isEqualToString:@""])
        //sqlite3_bind_null(stmt, 33);
        //else
        sqlite3_bind_text(stmt, 32, str33.UTF8String, -1, NULL);
        //sqlite3_bind_text(stmt, 33, CustID.UTF8String, -1, NULL);
        
        sqlite3_bind_text(stmt, 33, str34.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 34, str35.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 35, str36.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 36, str37.UTF8String, -1, NULL);
        
        //if ([str38 isEqualToString:@""])
        //sqlite3_bind_null(stmt, 38);
        //else
        sqlite3_bind_text(stmt, 37, str38.UTF8String, -1, NULL);
        //sqlite3_bind_text(stmt, 38, [field.text UTF8String], -1, NULL);
        
        sqlite3_bind_text(stmt, 38, str39.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 39, str40.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 40, str41.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 41, str42.UTF8String, -1, NULL);
        
        //if ([str43 isEqualToString:@""])
        //sqlite3_bind_null(stmt, 43);
        //else
        sqlite3_bind_text(stmt, 42, str43.UTF8String, -1, NULL);
        //sqlite3_bind_text(stmt, 43, CustID.UTF8String, -1, NULL);
        
        sqlite3_bind_text(stmt, 43, str44.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 44, str45.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 45, str46.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 46, str47.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 47, CustID.UTF8String, -1, NULL);
        
    }
    if (sqlite3_step(stmt) != SQLITE_DONE)
    {
        NSAssert(0, @"Error updating table.");
    }
    NSLog(@"Save Done");
    
    sqlite3_finalize(stmt);
    
    // Update Dis
    NSString *dis1 = slsperID;
    NSString *dis2 = brandID;
    NSString *dis3 = CustID;
    NSString *dis4 = [format stringFromDate:[NSDate date]];
    NSString *dis5 = [user valueForKey:@"6_Dis1"];
    NSString *dis6 = [user valueForKey:@"6_Dis2"];
    NSString *dis7 = [user valueForKey:@"6_Dis3"];
    NSString *dis8 = [user valueForKey:@"6_Dis4"];
    NSString *dis9 = [user valueForKey:@"6_Dis5"];
    NSString *query3 = @"UPDATE PPC_AR_Distributors SET CrtDate =? , Distributor1 =? , Distributor2 =? , Distributor3 =? , Distributor4 =? , Distributor5 =? WHERE SlsperID =? AND BranchID =? AND CustID= ?";
    
    
    sqlite3_stmt *stmt3;
    
    
    if (sqlite3_prepare_v2(db, [query3 UTF8String], -1, &stmt3, nil) == SQLITE_OK)
    {
        sqlite3_bind_text(stmt3, 1, dis4.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt3, 2, dis5.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt3, 3, dis6.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt3, 4, dis7.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt3, 5, dis8.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt3, 6, dis9.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt3, 7, dis1.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt3, 8, dis2.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt3, 9, dis3.UTF8String, -1, NULL);
    }
    if (sqlite3_step(stmt3) != SQLITE_DONE)
    {
        NSAssert(0, @"Error updating table.");
    }
    //NSLog(@"Save Avatar Done");
    sqlite3_finalize(stmt3);
    
    
    completionHandler(YES);
    
}
-(void) saveNewCustomerUsingNSUserDefaultWithCompletionHandler:(CompletionHandler)completionHandler
{
    
    // Saler Man
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *setting = [NSKeyedUnarchiver unarchiveObjectWithData:[user objectForKey:@"Setting"]];
    
    
    NSString *slsperID = [setting valueForKey:@"SlsperID"];
    NSString *brandID = [setting valueForKey:@"BranchID"];
    
    /*
     // 1
     
     "1_lat",
     "1_avatarCustomer",
     "1_lng",
     
     // 2
     
     "2_dictTP",
     "2_dictKhuVuc",
     "2_tenCuaHang",
     "2_dictQuanHuyen",
     "2_diaChiDayDu",
     "2_dictNhomKH",
     "2_dictLoaiBanHang",
     "2_phuongXa",
     "2_email",
     "2_dienThoai",
     "2_dictKenh",
     "2_fax",
     "2_dictLoaiCuaHang",
     "2_tenKH",
     
     // 3
     
     "3_ngayThanhLap",
     "3_nguoiDaiDien",
     "3_dienThoaiDD",
     "3_diaChi",
     "3_tenCongTy",
     "3_taiKhoanNH",
     "3_dienThoai",
     
     // 4
     
     "4_email1",
     "4_ngaySinh1",
    "4_email2",
    "4_dienThoai2",
     "4_ngaySinh2",
     "4_diaChi1",
     "4_diaChi2",
     "4_tenKH1",
     "4_diaChi3",
     "4_tenKH2",
     "4_ngaySinh3",
     "4_tenKH3",
     "4_dienThoai3",
     "4_email13",
     "4_dienThoai1",
     
     // 5
     
     "5_arrSanPhamSelected",
    
    
    */
        // Save in backgouroud
    NSString *query = @"INSERT INTO AR_NewCustomerInfor VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    NSString *CustID = [self lastIDForTable:@"AR_NewCustomerInfor" columnName:@"CustID"];
    
    //NSLog(@"query = %@",query);
    //NSLog(@"Cust ID = %@",CustID);
    
    // User default
    
    
    // NString Col
    NSString *str2 = [user valueForKey:@"2_tenCuaHang"];
    NSString *str3 = [user valueForKey:@"2_tenKH"];
    NSString *str4 = [user valueForKey:@"2_dienThoai"];
    NSString *str5 = @""; // Mobile
    NSString *str6 = [user valueForKey:@"2_fax"];
    NSString *str7 = [user valueForKey:@"2_email"];
    NSString *str8 = [user valueForKey:@"2_diaChiDayDu"];
    NSString *str9 = @"";
    NSString *str10 = @""; // adred 3
    
    NSDictionary *dictTinh = [user valueForKey:@"2_dictTP"];
    NSString *str11 = [dictTinh valueForKey:@"State"];
    NSString *str12 = [dictTinh valueForKey:@"State"];
    
    NSDictionary *dictQuan = [user valueForKey:@"2_dictQuanHuyen"];
    NSString *str13 = [dictQuan valueForKey:@"District"];
    
    NSString *str14 = @"";
    //NSString *str14 = [user valueForKey:@"2_phuongXa"];
    
    NSDictionary *dictKenh = [user valueForKey:@"2_dictKenh"];
    NSString *str15 = [dictKenh valueForKey:@"Code"];
    
    NSDictionary *dictNhomKH = [user valueForKey:@"2_dictNhomKH"];
    NSString *str16 = [dictNhomKH valueForKey:@"ClassId"];
    
    NSDictionary *dictKhuVuc = [user valueForKey:@"2_dictKhuVuc"];
    NSString *str17 = [dictKhuVuc valueForKey:@"Area"]; // Area
    NSString *str18 = [dictKhuVuc valueForKey:@"Area"]; // Terrious
    
    NSDictionary *dictLoaiCH = [user valueForKey:@"2_dictLoaiCuaHang"];
    NSString *str19 = [dictLoaiCH valueForKey:@"Code"]; // Loai CH
    
    NSDictionary *dictLoaiBH = [user valueForKey:@"2_dictLoaiBanHang"];
    NSString *str20 = [dictLoaiBH valueForKey:@"Code"];
    
    NSString *str21 = [user valueForKey:@"1_lat"];
    NSString *str22 = [user valueForKey:@"1_lng"]; // lng
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy_MM_dd_HH_mm_ss"];
    NSString *str23 = [NSString stringWithFormat:@"NC_%@",[format stringFromDate:[NSDate date]]]; // file avatar name
    
    
    NSString *str24 = [user valueForKey:@"3_tenCongTy"];
    NSString *str25 = [user valueForKey:@"3_diaChi"];
    NSString *str26 = [user valueForKey:@"3_ngayThanhLap"];
    NSString *str27 = [user valueForKey:@"3_nguoiDaiDien"]; // Owe
    
    NSString *str28 = [user valueForKey:@"3_taiKhoanNH"];
    
    
    NSString *str29 = [user valueForKey:@"4_tenKH1"];
    NSString *str30 = [user valueForKey:@"4_diaChi1"];
    NSString *str31 = [user valueForKey:@"4_dienThoai1"];
    NSString *str32 = [user valueForKey:@"4_email1"];
    NSString *str33 = [user valueForKey:@"4_ngaySinh1"];
    
    NSString *str34 = [user valueForKey:@"4_tenKH2"];
    NSString *str35 = [user valueForKey:@"4_diaChi2"];
    NSString *str36 = [user valueForKey:@"4_dienThoai2"];
    NSString *str37 = [user valueForKey:@"4_email2"];
    NSString *str38 = [user valueForKey:@"4_ngaySinh2"];
    
    NSString *str39 = [user valueForKey:@"4_tenKH3"];
    NSString *str40 = [user valueForKey:@"4_diaChi3"];
    NSString *str41 = [user valueForKey:@"4_dienThoai3"];
    NSString *str42 = [user valueForKey:@"4_email3"];
    NSString *str43 = [user valueForKey:@"4_ngaySinh3"];
    
    NSString *str44 = @"0";
    NSString *str45 = @"0";
    
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *str46 = [format stringFromDate:[NSDate date]];
    NSString *str47 = [format stringFromDate:[NSDate date]];
    
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        sqlite3_bind_text(stmt, 1, CustID.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 2, str2.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 3, str3.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 4, str4.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 5, str5.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 6, str6.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 7, str7.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 8, str8.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 9, str9.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 10, str10.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 11, str11.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 12, str12.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 13, str13.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 14, str14.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 15, str15.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 16, str16.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 17, str17.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 18, str18.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 19, str19.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 20, str20.UTF8String, -1, NULL);
        sqlite3_bind_double(stmt, 21, str21.doubleValue);
        //sqlite3_bind_text(stmt, 21, str6.UTF8String, -1, NULL);
        sqlite3_bind_double(stmt, 22, str22.doubleValue);
        //sqlite3_bind_text(stmt, 22, [field.text UTF8String], -1, NULL);
        
        sqlite3_bind_text(stmt, 23, str23.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 24, str24.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 25, str25.UTF8String, -1, NULL);
        
        //if ([str26 isEqualToString:@""])
            //sqlite3_bind_null(stmt, 26);
        //else
            sqlite3_bind_text(stmt, 26, str26.UTF8String, -1, NULL);
        //sqlite3_bind_text(stmt, 26, [field.text UTF8String], -1, NULL);
        
        sqlite3_bind_text(stmt, 27, str27.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 28, str28.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 29, str29.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 30, str30.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 31, str31.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 32, str32.UTF8String, -1, NULL);
        
        //if ([str33 isEqualToString:@""])
            //sqlite3_bind_null(stmt, 33);
        //else
            sqlite3_bind_text(stmt, 33, str33.UTF8String, -1, NULL);
        //sqlite3_bind_text(stmt, 33, CustID.UTF8String, -1, NULL);
        
        sqlite3_bind_text(stmt, 34, str34.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 35, str35.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 36, str36.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 37, str37.UTF8String, -1, NULL);
        
        //if ([str38 isEqualToString:@""])
            //sqlite3_bind_null(stmt, 38);
        //else
            sqlite3_bind_text(stmt, 38, str38.UTF8String, -1, NULL);
        //sqlite3_bind_text(stmt, 38, [field.text UTF8String], -1, NULL);
        
        sqlite3_bind_text(stmt, 39, str39.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 40, str40.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 41, str41.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 42, str42.UTF8String, -1, NULL);
        
        //if ([str43 isEqualToString:@""])
            //sqlite3_bind_null(stmt, 43);
        //else
            sqlite3_bind_text(stmt, 43, str43.UTF8String, -1, NULL);
        //sqlite3_bind_text(stmt, 43, CustID.UTF8String, -1, NULL);
        
        sqlite3_bind_text(stmt, 44, str44.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 45, str45.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 46, str46.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 47, str47.UTF8String, -1, NULL);
        
    }
    if (sqlite3_step(stmt) != SQLITE_DONE)
    {
        NSAssert(0, @"Error updating table.");
    }
    //NSLog(@"Save Done");
    
    sqlite3_finalize(stmt);
    
    // ***************************
    // Save Avatar
    NSString *ava_str1 = CustID;
    NSString *ava_str2 = @"Document";
    NSString *ava_str3 = str23;
    NSString *ava_str4 = [format stringFromDate:[NSDate date]];
    NSString *ava_str5 = @"";
    NSString *ava_str6 = str21;
    NSString *ava_str7 = str22;
    NSString *ava_str8 = [format stringFromDate:[NSDate date]];
    
    sqlite3_stmt *stmt1;
    NSString *query1 = @"INSERT INTO AR_NewCustomer_Picture VALUES(?,?,?,?,?,?,?,?)";
    
    if (sqlite3_prepare_v2(db, [query1 UTF8String], -1, &stmt1, nil) == SQLITE_OK)
    {
        sqlite3_bind_text(stmt1, 1, ava_str1.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt1, 2, ava_str2.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt1, 3, ava_str3.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt1, 4, ava_str4.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt1, 5, ava_str5.UTF8String, -1, NULL);
        sqlite3_bind_double(stmt1, 6, ava_str6.doubleValue);
        sqlite3_bind_double(stmt1, 7, ava_str7.doubleValue);
        sqlite3_bind_text(stmt1, 8, ava_str8.UTF8String, -1, NULL);
    }
    if (sqlite3_step(stmt1) == SQLITE_DONE)
    {
        //NSAssert(0, @"Error updating table.");
        //NSLog(@"Save avatar OK");
    }
    ////NSLog(@"Save Avatar Done");
    
    // Save Data to Document
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *pathDocument = [paths objectAtIndex:0];
    NSData *dataAvatar = [user objectForKey:@"1_avatarCustomer"];
    NSString *pathAvatar = [pathDocument stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",ava_str3]];
    NSError *error;
    [dataAvatar writeToFile:pathAvatar options:NSDataWritingAtomic error:&error];
    
    sqlite3_finalize(stmt1);
    
    
    // ***************************
    // Save SP Hay Ban
    NSMutableArray *SPSelected = [user valueForKey:@"5_arrSanPhamSelected"];
    NSString *query2 = @"INSERT INTO PPC_PDAIN_InventoryNewCust VALUES(?,?,?,?,?,?,?,?,?,?,?)";
    for (NSMutableDictionary *dict in SPSelected)
    {
        NSString *SP1 = slsperID;
        NSString *SP2 = brandID;
        NSString *SP3 = [format stringFromDate:[NSDate date]];
        NSString *SP4 = CustID;
        NSString *SP5 = [self lastIDForTable:@"PPC_PDAIN_InventoryNewCust" columnName:@"Code"];
        
        NSString *SP7 = [dict objectForKey:@"desrc"];
        NSString *SP8 = [dict objectForKey:@"stkUnit"];
        NSString *SP9 = [dict objectForKey:@"soLuong"];
        NSString *SP10 = [dict objectForKey:@"stkBasePrc"];
        NSString *SP11 = [dict objectForKey:@"ghiChu"];
        NSString *SP6 = [NSString stringWithFormat:@"%f",SP10.floatValue * SP9.integerValue];
        
        // Save SP HayBan
        sqlite3_stmt *stmt2;
        
        
        if (sqlite3_prepare_v2(db, [query2 UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, SP1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, SP2.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 3, SP3.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 4, SP4.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 5, SP5.UTF8String, -1, NULL);
            sqlite3_bind_double(stmt2, 6, SP6.doubleValue); // Thanh Tien
            
            sqlite3_bind_text(stmt2, 7, SP7.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 8, SP8.UTF8String, -1, NULL);
            sqlite3_bind_double(stmt2, 9, SP9.doubleValue);
            sqlite3_bind_double(stmt2, 10, SP10.doubleValue);
            sqlite3_bind_text(stmt2, 11, SP11.UTF8String, -1, NULL);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSAssert(0, @"Error updating table.");
        }
        //NSLog(@"Save Avatar Done");
        sqlite3_finalize(stmt2);
    }
    
    //****************
    // Save Dis
    NSString *dis1 = slsperID;
    NSString *dis2 = brandID;
    NSString *dis3 = CustID;
    NSString *dis4 = [format stringFromDate:[NSDate date]];
    NSString *dis5 = [user valueForKey:@"6_Dis1"];
    NSString *dis6 = [user valueForKey:@"6_Dis2"];
    NSString *dis7 = [user valueForKey:@"6_Dis3"];
    NSString *dis8 = [user valueForKey:@"6_Dis4"];
    NSString *dis9 = [user valueForKey:@"6_Dis5"];
    NSString *query3 = @"INSERT INTO PPC_AR_Distributors VALUES(?,?,?,?,?,?,?,?,?)";
    
    
    sqlite3_stmt *stmt3;
    
    
    if (sqlite3_prepare_v2(db, [query3 UTF8String], -1, &stmt3, nil) == SQLITE_OK)
    {
        sqlite3_bind_text(stmt3, 1, dis1.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt3, 2, dis2.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt3, 3, dis3.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt3, 4, dis4.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt3, 5, dis5.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt3, 6, dis6.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt3, 7, dis7.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt3, 8, dis8.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt3, 9, dis9.UTF8String, -1, NULL);
    }
    if (sqlite3_step(stmt3) != SQLITE_DONE)
    {
        NSAssert(0, @"Error updating table.");
    }
    //NSLog(@"Save Avatar Done");
    sqlite3_finalize(stmt3);
    
    completionHandler(YES);
    
}
-(NSString *) lastIDForTable:(NSString *) table columnName:(NSString *) column
{
    NSString *currentID;
    
    // get current ID
    NSMutableArray *arrID = [[NSMutableArray alloc] init];
    NSString *query = [NSString stringWithFormat:@"SELECT %@ FROM %@",column, table ];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *ID = (char *) sqlite3_column_text(statement, 0);
        
            [arrID addObject:[NSString stringWithUTF8String:ID]];
        }
    }
    sqlite3_finalize(statement);
    
    // check if has = row - New table -no data
    if (arrID.count == 0)
        return @"0";
    
    // Current ID
    currentID = [arrID lastObject];
    NSInteger currentIndex;
    @try {
        currentIndex = [currentID integerValue];
    }
    @catch (NSException *exception)
    {
        currentIndex = 0;
    }
    
    return [NSString stringWithFormat:@"%d",currentIndex + 1];
}
-(void) savePhanHoiUsingNSUserDefaultWithCompletionHandler:(CompletionHandler)completionHandler
{
    NSUserDefaults *user = [ NSUserDefaults standardUserDefaults];
    
    NSString *str1 = [user valueForKey:@"PH_Code"]; // Code
    NSString *str2 = [user valueForKey:@"PH_RequestType"];
    NSString *str3 = [user valueForKey:@"PH_RequestHeader"];
    NSString *str4 = [user valueForKey:@"PH_RequestContent"];
    NSString *str5 = [user valueForKey:@"PH_RequestDate"];
    NSString *str6 = [user valueForKey:@"PH_Status"];
    
    sqlite3_stmt *stmt2;
    NSString *query = @"INSERT INTO PPC_NoticeBoardSubmit VALUES(?,?,?,?,?,?)";
    
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
    {
        sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt2, 4, str4.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt2, 5, str5.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt2, 6, str6.UTF8String, -1, NULL);
    }
    if (sqlite3_step(stmt2) != SQLITE_DONE)
    {
        NSAssert(0, @"Error updating table.");
    }
    //NSLog(@"Save Avatar Done");
    sqlite3_finalize(stmt2);
    
    // Save Pic 1
    NSData *pic1 = [user valueForKey:@"PH_Pic1"];
    NSData *pic2 = [user valueForKey:@"PH_Pic2"];
    NSData *pic3 = [user valueForKey:@"PH_Pic3"];
    
    if (pic1)
    {
        NSString *str_pic_1 = [self lastIDForTable:@"PPC_OM_NoticeBoardSubmit_Image" columnName:@"NoteID"];
        NSString *str_pic_2 = str1;
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy_MM_dd_HH_mm_ss"];
        
        
        // Fix name photo
        NSString *str_pic_3 = [NSString stringWithFormat:@"NB_%@_1",[format stringFromDate:[NSDate date]]];

        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *str_pic_4 = [format stringFromDate:[NSDate date]];
        
        // Save Database
        sqlite3_stmt *stm;
        NSString *queryPic = @"INSERT INTO PPC_OM_NoticeBoardSubmit_Image VALUES(?,?,?,?)";
        if (sqlite3_prepare_v2(db, [queryPic UTF8String], -1, &stm, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stm, 1, str_pic_1.UTF8String, -1, NULL);
            sqlite3_bind_text(stm, 2, str_pic_2.UTF8String, -1, NULL);
            sqlite3_bind_text(stm, 3, str_pic_3.UTF8String, -1, NULL);
            sqlite3_bind_text(stm, 4, str_pic_4.UTF8String, -1, NULL);

        }
        if (sqlite3_step(stm) != SQLITE_DONE)
        {
            NSAssert(0, @"Error updating table.");
        }
        //NSLog(@"Save Avatar Done");
        sqlite3_finalize(stm);
        
        // Save document
        // Save Data to Document
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *pathDocument = [paths objectAtIndex:0];

        NSString *pathAvatar = [pathDocument stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",str_pic_3]];
        NSError *error;
        [pic1 writeToFile:pathAvatar options:NSDataWritingAtomic error:&error];
        
    }
    if (pic2)
    {
        NSString *str_pic_1 = [self lastIDForTable:@"PPC_OM_NoticeBoardSubmit_Image" columnName:@"NoteID"];
        NSString *str_pic_2 = str1;
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy_MM_dd_HH_mm_ss"];
        
        
        // Fix name photo
        NSString *str_pic_3 = [NSString stringWithFormat:@"NB_%@_2",[format stringFromDate:[NSDate date]]];
        
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

        NSString *str_pic_4 = [format stringFromDate:[NSDate date]];
        
        // Save
        sqlite3_stmt *stm;
        NSString *queryPic = @"INSERT INTO PPC_OM_NoticeBoardSubmit_Image VALUES(?,?,?,?)";
        if (sqlite3_prepare_v2(db, [queryPic UTF8String], -1, &stm, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stm, 1, str_pic_1.UTF8String, -1, NULL);
            sqlite3_bind_text(stm, 2, str_pic_2.UTF8String, -1, NULL);
            sqlite3_bind_text(stm, 3, str_pic_3.UTF8String, -1, NULL);
            sqlite3_bind_text(stm, 4, str_pic_4.UTF8String, -1, NULL);
            
        }
        if (sqlite3_step(stm) != SQLITE_DONE)
        {
            NSAssert(0, @"Error updating table.");
        }
        //NSLog(@"Save Avatar Done");
        sqlite3_finalize(stm);
        
        // Save document
        // Save Data to Document
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *pathDocument = [paths objectAtIndex:0];
        
        NSString *pathAvatar = [pathDocument stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",str_pic_3]];
        NSError *error;
        [pic2 writeToFile:pathAvatar options:NSDataWritingAtomic error:&error];

        
    }
    if (pic3)
    {
        NSString *str_pic_1 = [self lastIDForTable:@"PPC_OM_NoticeBoardSubmit_Image" columnName:@"NoteID"];
        NSString *str_pic_2 = str1;
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy_MM_dd_HH_mm_ss"];
        
        
        // Fix name photo
        NSString *str_pic_3 = [NSString stringWithFormat:@"NB_%@_1",[format stringFromDate:[NSDate date]]];
        
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

        NSString *str_pic_4 = [format stringFromDate:[NSDate date]];
        
        // Save
        sqlite3_stmt *stm;
        NSString *queryPic = @"INSERT INTO PPC_OM_NoticeBoardSubmit_Image VALUES(?,?,?,?)";
        if (sqlite3_prepare_v2(db, [queryPic UTF8String], -1, &stm, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stm, 1, str_pic_1.UTF8String, -1, NULL);
            sqlite3_bind_text(stm, 2, str_pic_2.UTF8String, -1, NULL);
            sqlite3_bind_text(stm, 3, str_pic_3.UTF8String, -1, NULL);
            sqlite3_bind_text(stm, 4, str_pic_4.UTF8String, -1, NULL);
            
        }
        if (sqlite3_step(stm) != SQLITE_DONE)
        {
            NSAssert(0, @"Error updating table.");
        }
        //NSLog(@"Save Avatar Done");
        sqlite3_finalize(stm);
        
        // Save document
        // Save Data to Document
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *pathDocument = [paths objectAtIndex:0];
        
        NSString *pathAvatar = [pathDocument stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",str_pic_3]];
        NSError *error;
        [pic3 writeToFile:pathAvatar options:NSDataWritingAtomic error:&error];

    }
    
    completionHandler(YES);
}

-(void) saveHoTroKyThuatUsingNSUserDefaultWithCompletionHandler:(CompletionHandler)completionHandler
{
    NSUserDefaults *user = [ NSUserDefaults standardUserDefaults];
    
    NSString *str1 = [user valueForKey:@"HT_Code"]; // Code
    NSString *str2 = [user valueForKey:@"HT_RequestType"];
    NSString *str3 = [user valueForKey:@"HT_RequestHeader"];
    NSString *str4 = [user valueForKey:@"HT_RequestContent"];
    NSString *str5 = [user valueForKey:@"HT_RequestDate"];
    NSString *str6 = [user valueForKey:@"HT_Status"];
    
    sqlite3_stmt *stmt2;
    NSString *query = @"INSERT INTO PPC_TechnicalSupport VALUES(?,?,?,?,?,?)";
    
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
    {
        sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt2, 4, str4.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt2, 5, str5.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt2, 6, str6.UTF8String, -1, NULL);
    }
    if (sqlite3_step(stmt2) != SQLITE_DONE)
    {
        NSAssert(0, @"Error updating table.");
    }
    //NSLog(@"Save Avatar Done");
    sqlite3_finalize(stmt2);
    
    // Save Pic 1
    NSData *pic1 = [user valueForKey:@"HT_Pic1"];
    NSData *pic2 = [user valueForKey:@"HT_Pic2"];
    NSData *pic3 = [user valueForKey:@"HT_Pic3"];
    
    if (pic1)
    {
        NSString *str_pic_1 = [self lastIDForTable:@"PPC_OM_TechnicalSupport_Image" columnName:@"NoteID"];
        NSString *str_pic_2 = str1;
        
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy_MM_dd_HH_mm_ss"];
        
        
        // Fix name photo
        NSString *str_pic_3 = [NSString stringWithFormat:@"TS_%@_1",[format stringFromDate:[NSDate date]]];
        
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

        
        
        NSString *str_pic_4 = [format stringFromDate:[NSDate date]];
        
        // Save Database
        sqlite3_stmt *stm;
        NSString *queryPic = @"INSERT INTO PPC_OM_TechnicalSupport_Image VALUES(?,?,?,?)";
        if (sqlite3_prepare_v2(db, [queryPic UTF8String], -1, &stm, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stm, 1, str_pic_1.UTF8String, -1, NULL);
            sqlite3_bind_text(stm, 2, str_pic_2.UTF8String, -1, NULL);
            sqlite3_bind_text(stm, 3, str_pic_3.UTF8String, -1, NULL);
            sqlite3_bind_text(stm, 4, str_pic_4.UTF8String, -1, NULL);
            
        }
        if (sqlite3_step(stm) != SQLITE_DONE)
        {
            NSAssert(0, @"Error updating table.");
        }
        //NSLog(@"Save Avatar Done");
        sqlite3_finalize(stm);
        
        // Save document
        // Save Data to Document
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *pathDocument = [paths objectAtIndex:0];
        
        NSString *pathAvatar = [pathDocument stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",str_pic_3]];
        NSError *error;
        [pic1 writeToFile:pathAvatar options:NSDataWritingAtomic error:&error];

        
    }
    if (pic2)
    {
        NSString *str_pic_1 = [self lastIDForTable:@"PPC_OM_TechnicalSupport_Image" columnName:@"NoteID"];
        NSString *str_pic_2 = str1;
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy_MM_dd_HH_mm_ss"];
        
        
        // Fix name photo
        NSString *str_pic_3 = [NSString stringWithFormat:@"TS_%@_2",[format stringFromDate:[NSDate date]]];
        
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

        NSString *str_pic_4 = [format stringFromDate:[NSDate date]];
        
        // Save
        sqlite3_stmt *stm;
        NSString *queryPic = @"INSERT INTO PPC_OM_TechnicalSupport_Image VALUES(?,?,?,?)";
        if (sqlite3_prepare_v2(db, [queryPic UTF8String], -1, &stm, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stm, 1, str_pic_1.UTF8String, -1, NULL);
            sqlite3_bind_text(stm, 2, str_pic_2.UTF8String, -1, NULL);
            sqlite3_bind_text(stm, 3, str_pic_3.UTF8String, -1, NULL);
            sqlite3_bind_text(stm, 4, str_pic_4.UTF8String, -1, NULL);
            
        }
        if (sqlite3_step(stm) != SQLITE_DONE)
        {
            NSAssert(0, @"Error updating table.");
        }
        //NSLog(@"Save Avatar Done");
        sqlite3_finalize(stm);
        
        // Save document
        // Save Data to Document
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *pathDocument = [paths objectAtIndex:0];
        
        NSString *pathAvatar = [pathDocument stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",str_pic_3]];
        NSError *error;
        [pic2 writeToFile:pathAvatar options:NSDataWritingAtomic error:&error];

        
    }
    if (pic3)
    {
        NSString *str_pic_1 = [self lastIDForTable:@"PPC_OM_TechnicalSupport_Image" columnName:@"NoteID"];
        NSString *str_pic_2 = str1;
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy_MM_dd_HH_mm_ss"];
        
        
        // Fix name photo
        NSString *str_pic_3 = [NSString stringWithFormat:@"TS_%@_3",[format stringFromDate:[NSDate date]]];
        
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *str_pic_4 = [format stringFromDate:[NSDate date]];
        
        // Save
        sqlite3_stmt *stm;
        NSString *queryPic = @"INSERT INTO PPC_OM_TechnicalSupport_Image VALUES(?,?,?,?)";
        if (sqlite3_prepare_v2(db, [queryPic UTF8String], -1, &stm, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stm, 1, str_pic_1.UTF8String, -1, NULL);
            sqlite3_bind_text(stm, 2, str_pic_2.UTF8String, -1, NULL);
            sqlite3_bind_text(stm, 3, str_pic_3.UTF8String, -1, NULL);
            sqlite3_bind_text(stm, 4, str_pic_4.UTF8String, -1, NULL);
            
        }
        if (sqlite3_step(stm) != SQLITE_DONE)
        {
            NSAssert(0, @"Error updating table.");
        }
        //NSLog(@"Save Avatar Done");
        sqlite3_finalize(stm);
        
        // Save document
        // Save Data to Document
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *pathDocument = [paths objectAtIndex:0];
        
        NSString *pathAvatar = [pathDocument stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",str_pic_3]];
        NSError *error;
        [pic3 writeToFile:pathAvatar options:NSDataWritingAtomic error:&error];

    }
    
    completionHandler(YES);

}







//********************************************
-(NSMutableArray *) arrKenhFromDatabase
{
    NSMutableArray *arrKenh = [[NSMutableArray alloc] init];
    
    NSString *query = @"SELECT * FROM AR_Channel";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *idChannel = (char *) sqlite3_column_text(statement, 0);
            char *channel = (char *) sqlite3_column_text(statement, 1);
            
            NSDictionary *row = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:idChannel],@"Code",[NSString stringWithUTF8String:channel],@"Descr", nil];
            
            [arrKenh addObject:row];
        }
    }

    return arrKenh;
}
-(NSMutableArray *) arrNhomKHFromDatabase
{
    NSMutableArray *arrNhomKH = [[NSMutableArray alloc] init];
    
    NSString *query = @"SELECT * FROM AR_CustClass";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *idChannel = (char *) sqlite3_column_text(statement, 0);
            char *channel = (char *) sqlite3_column_text(statement, 2);
            
            if (!idChannel)
                continue;
            
            NSDictionary *row = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:idChannel],@"ClassId",[NSString stringWithUTF8String:channel],@"Descr", nil];
            
            [arrNhomKH addObject:row];
        }
    }
    return arrNhomKH;
}
-(NSMutableArray *) arrKhuVucFromDatabase
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    NSString *query = @"SELECT * FROM AR_Area";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *idKhuVuc = (char *) sqlite3_column_text(statement, 0);
            char *khuVuc = (char *) sqlite3_column_text(statement, 1);
            
            NSDictionary *row = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:idKhuVuc],@"Area",[NSString stringWithUTF8String:khuVuc],@"Descr", nil];
            
            [arr addObject:row];
        }
    }
    return arr;
}
-(NSMutableArray *) arrLoaiCuaHangFromDatabase
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    NSString *query = @"SELECT * FROM AR_ShopType";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *idKhuVuc = (char *) sqlite3_column_text(statement, 0);
            char *khuVuc = (char *) sqlite3_column_text(statement, 1);
            
            
            NSDictionary *row = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:idKhuVuc],@"Code",[NSString stringWithUTF8String:khuVuc],@"Descr", nil];
            
            [arr addObject:row];
        }
    }
    return arr;
}
-(NSMutableArray *) arrLoaiBanHanFromDatabase
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    NSString *query = @"SELECT * FROM AR_CustType";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *idKhuVuc = (char *) sqlite3_column_text(statement, 0);
            char *khuVuc = (char *) sqlite3_column_text(statement, 1);
            
            NSDictionary *row = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:idKhuVuc],@"Code",[NSString stringWithUTF8String:khuVuc],@"Descr", nil];
            
            [arr addObject:row];
        }
    }
    return arr;
}
-(NSMutableArray *) arrTPFromDatabaseWithIDKhucVuc:(NSString *)idKhuVuc
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    NSString *query =  [NSString stringWithFormat:@"SELECT * FROM SI_State WHERE Territory = '%@'",idKhuVuc ];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *idTP = (char *) sqlite3_column_text(statement, 1);
            char *TP = (char *) sqlite3_column_text(statement, 2);
            
            NSDictionary *row = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:idTP],@"State",[NSString stringWithUTF8String:TP],@"Descr", nil];
            
            [arr addObject:row];
        }
    }
    return arr;
}
-(NSMutableArray *) arrQuanHuyenFromDatabaseWithIDThanhPho:(NSString *)idThanhPho
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    NSString *query =  [NSString stringWithFormat:@"SELECT * FROM SI_District WHERE State = '%@'",idThanhPho ];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *idTP = (char *) sqlite3_column_text(statement, 1);
            char *TP = (char *) sqlite3_column_text(statement, 2);
            
            NSDictionary *row = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:idTP],@"District",[NSString stringWithUTF8String:TP],@"Name", nil];
            
            [arr addObject:row];
        }
    }
    return arr;
}
-(NSMutableArray *) arrBangTinFromDatabase
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    NSString *query =  [NSString stringWithFormat:@"SELECT * FROM OM_Knowledge" ];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *idBangTin = (char *) sqlite3_column_text(statement, 0);
            char *desrc = (char *) sqlite3_column_text(statement, 1);
            char *content = (char *) sqlite3_column_text(statement, 2);
            
            
            NSDictionary *row = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:idBangTin],@"KnowledgeID",[NSString stringWithUTF8String:desrc],@"Descr",[NSString stringWithUTF8String:content],@"Content", nil];
            
            [arr addObject:row];
        }
    }
    return arr;
}
-(NSMutableArray *) arrLoaiYCFromDatabase
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    NSString *query =  [NSString stringWithFormat:@"SELECT * FROM OM_IssueType" ];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *code = (char *) sqlite3_column_text(statement, 0);
            char *desrc = (char *) sqlite3_column_text(statement, 1);

            
            
            NSDictionary *row = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:code],@"Code",[NSString stringWithUTF8String:desrc],@"Descr", nil];
            
            [arr addObject:row];
        }
    }
    return arr;
}
-(NSMutableArray *) arrThongTinKyThuatWithIDLoaiYC:(NSString *)loaiYC
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    NSString *query =  [NSString stringWithFormat:@"SELECT * FROM OM_TechnicalSupport WHERE IssueType = '%@'",loaiYC ];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *code = (char *) sqlite3_column_text(statement, 0);
            char *IssueHeader = (char *) sqlite3_column_text(statement, 1);
            char *IssueContent = (char *) sqlite3_column_text(statement, 4);
            
            char *picture1 =(char *) sqlite3_column_text(statement, 5);
            char *picture2 =(char *) sqlite3_column_text(statement, 6);
            char *picture3 =(char *) sqlite3_column_text(statement, 7);
            
            NSDictionary *row = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:code],@"Code",[NSString stringWithUTF8String:IssueHeader],@"IssueHeader",[NSString stringWithUTF8String:IssueContent],@"IssueContent",
                                 [NSString stringWithUTF8String:picture1],@"Picture1",
                                 [NSString stringWithUTF8String:picture2],@"Picture2",
                                 [NSString stringWithUTF8String:picture3],@"Picture3", nil];
            
            [arr addObject:row];
        }
    }
    return arr;
}
-(NSMutableArray *) arrSanPhamFromDatabase
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    NSString *query =  [NSString stringWithFormat:@"SELECT * FROM IN_Inventory" ];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *invtID = (char *) sqlite3_column_text(statement, 1);
            char *desrc = (char *) sqlite3_column_text(statement, 2);
            char *stkUnit = (char *) sqlite3_column_text(statement, 3);
            char *stkBasePrc = (char *) sqlite3_column_text(statement, 8);
            
            NSMutableDictionary *row = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:invtID],@"invtID",[NSString stringWithUTF8String:desrc],@"desrc",[NSString stringWithUTF8String:stkUnit],@"stkUnit",[NSString stringWithUTF8String:stkBasePrc],@"stkBasePrc",@"0",@"soLuong",@"",@"ghiChu",@"0",@"color",nil];
            
            [arr addObject:row];
        }
    }
    return arr;
}
-(NSMutableArray *) arrGSPDSKhachHangFromDatabaseAtDate:(NSString *) stringDate
{
    /*
    SELECT OM_SalesRouteDet.CustID, OM_SalesRouteDet.SalesRouteID, OM_SalesRouteDet.VisitDate, OM_SalesRouteDet.VisitSort, OM_SalesRouteDet.OrigVisitSort, PPC_ARCustomerInfo.CustName, PPC_ARCustomerInfo.ContactName, PPC_ARCustomerInfo.Addr1, AR_CustomerLocation.BranchID, AR_CustomerLocation.Lng, AR_CustomerLocation.Lat    FROM OM_SalesRouteDet, PPC_ARCustomerInfo, AR_CustomerLocation WHERE OM_SalesRouteDet.CustID = PPC_ARCustomerInfo.CustID AND OM_SalesRouteDet.CustID = AR_CustomerLocation.CustID AND DateTime('2013-08-17 00:00:00') = VisitDate
    */
    
    // Test
    /*
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd 00:00:00"];
    NSDate *past = [format dateFromString:@"2013-08-28 00:00:00"];
    
    stringDate = [format stringFromDate:past];
    */
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    //NSString *query =  [NSString stringWithFormat:@"SELECT OM_SalesRouteDet.CustID, OM_SalesRouteDet.SalesRouteID, OM_SalesRouteDet.VisitDate, OM_SalesRouteDet.VisitSort, OM_SalesRouteDet.OrigVisitSort, PPC_ARCustomerInfo.CustName, PPC_ARCustomerInfo.ContactName, PPC_ARCustomerInfo.Addr1, AR_CustomerLocation.BranchID, AR_CustomerLocation.Lng, AR_CustomerLocation.Lat    FROM OM_SalesRouteDet, PPC_ARCustomerInfo, AR_CustomerLocation WHERE OM_SalesRouteDet.CustID = PPC_ARCustomerInfo.CustID AND OM_SalesRouteDet.CustID = AR_CustomerLocation.CustID AND DateTime('%@') = VisitDate",stringDate ];
    
    NSString *query = @"SELECT OM_SalesRouteDet.CustID, OM_SalesRouteDet.SalesRouteID, OM_SalesRouteDet.VisitDate, OM_SalesRouteDet.VisitSort, OM_SalesRouteDet.OrigVisitSort, PPC_ARCustomerInfo.CustName, PPC_ARCustomerInfo.ContactName, PPC_ARCustomerInfo.Addr1, AR_CustomerLocation.BranchID, AR_CustomerLocation.Lng, AR_CustomerLocation.Lat    FROM OM_SalesRouteDet, PPC_ARCustomerInfo, AR_CustomerLocation WHERE OM_SalesRouteDet.CustID = PPC_ARCustomerInfo.CustID AND OM_SalesRouteDet.CustID = AR_CustomerLocation.CustID AND DateTime('";
    query = [query stringByAppendingString:[NSString stringWithFormat:@"%@')",stringDate]];

    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *CustID = (char *) sqlite3_column_text(statement, 0);
            char *SalesRouteID = (char *) sqlite3_column_text(statement, 1);
            char *VisitDate = (char *) sqlite3_column_text(statement, 2);
            
            
            int VisitSort = (int) sqlite3_column_int(statement, 3);
            int OrigVisitSort = (int) sqlite3_column_int(statement, 4);
            
            char *CustName = (char *) sqlite3_column_text(statement, 5);
            char *ContactName = (char *) sqlite3_column_text(statement, 6);
            
            char *Addr1 = (char *) sqlite3_column_text(statement, 7);
            char *BranchID = (char *) sqlite3_column_text(statement, 8);
            
            double lng = (double) sqlite3_column_double(statement, 9);
            double lat = (double) sqlite3_column_double(statement, 10);
            
            
            
            NSMutableDictionary *row = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:CustID],@"CustID",
                                        [NSString stringWithUTF8String:SalesRouteID],@"SalesRouteID",
                                        [NSString stringWithUTF8String:VisitDate],@"VisitDate",
                                        [NSNumber numberWithInt:VisitSort],@"VisitSort",
                                        [NSNumber numberWithInt:OrigVisitSort],@"OrigVisitSort",
                                        [NSString stringWithUTF8String:CustName],@"CustName",
                                        [NSString stringWithUTF8String:ContactName],@"ContactName",

                                        [NSString stringWithUTF8String:Addr1],@"Addr1",
                                        [NSString stringWithUTF8String:BranchID],@"BranchID",
                                        [NSNumber numberWithDouble:lng],@"lng",
                                        [NSNumber numberWithDouble:lat],@"lat",nil];
            
            [arr addObject:row];
        }
    }
    sqlite3_finalize(statement);
    
    NSMutableArray *arr_1 = [[NSMutableArray alloc] init];
    
    NSString *query_1 =  @"SELECT * FROM PPC_ARCustomerInfo";
    
    
    sqlite3_stmt *statement_1;
    if (sqlite3_prepare_v2(db, [query_1 UTF8String], -1, &statement_1, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement_1) == SQLITE_ROW)
        {
            char *CustID = (char *) sqlite3_column_text(statement_1, 0);
            char *CustName = (char *) sqlite3_column_text(statement_1, 1);
            char *ContactName = (char *) sqlite3_column_text(statement_1, 2);
            
            char *Addr1 = (char *) sqlite3_column_text(statement_1, 7);
            
            double lng = 0;
            double lat = 0;
            
            
            
            NSMutableDictionary *row = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:CustID],@"CustID",
                                        [NSString stringWithUTF8String:CustName],@"CustName",
                                        [NSString stringWithUTF8String:ContactName],@"ContactName",
                                        
                                        [NSString stringWithUTF8String:Addr1],@"Addr1",
                                        @"",@"BranchID",
                                        [NSNumber numberWithDouble:lng],@"lng",
                                        [NSNumber numberWithDouble:lat],@"lat",nil];
            
            [arr_1 addObject:row];
        }
    }
    sqlite3_finalize(statement_1);

    for (NSMutableDictionary *dict_1 in arr_1)
    {
        BOOL isHas = NO;
        NSString *custID_1 = [dict_1 objectForKey:@"CustID"];
        for (NSMutableDictionary *dict in arr)
        {
            NSString *custID = [dict objectForKey:@"CustID"];
            if ([custID isEqualToString:custID_1])
                isHas = YES;
            
        }
        
        if (!isHas)
        {
            [arr addObject:dict_1];
        }
        
        
    }
    
    
    return arr;
    

}
-(NSString *) stringMaxDateFromDatabase
{
    NSString *returnString;
    /*
    NSString *query =  @"SELECT  MAX(DateTime(VisitDate))   FROM OM_SalesRouteDet ";
    
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *stringMaxDate = (char *) sqlite3_column_text(statement, 0);
            
            returnString = [NSString stringWithUTF8String:stringMaxDate];
            
        }
    }
    sqlite3_finalize(statement);
    
    */
    
    NSString *query =  @"SELECT  BusinessDate FROM Setting ";
    
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *stringMaxDate = (char *) sqlite3_column_text(statement, 0);
            
            returnString = [NSString stringWithUTF8String:stringMaxDate];
            
        }
    }
    sqlite3_finalize(statement);
    
    returnString = [returnString stringByAppendingString:@" 00:00:00"];
    returnString = [returnString stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    
    return returnString;

}
-(NSMutableArray *) arrSaleSetupFromDatabase
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    NSString *query =  [NSString stringWithFormat:@"SELECT * FROM SalesSetup"];
                        
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            
            char *SetupID = (char *) sqlite3_column_text(statement, 0);
            NSString *stringSetupID = [NSString stringWithUTF8String:SetupID];
            
            if ([stringSetupID isEqualToString:@"chkPlaPre_frmSetting"])
            {
                int status = (int) sqlite3_column_int(statement, 2);
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:stringSetupID,@"SetupID",[NSNumber numberWithInt:status],@"Status", nil];
                [arr addObject:dict];
            }
            
            if ([stringSetupID isEqualToString:@"chkSalHis_chkPlaPre_frmSetting"])
            {
                int status = (int) sqlite3_column_int(statement, 2);
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:stringSetupID,@"SetupID",[NSNumber numberWithInt:status],@"Status", nil];
                [arr addObject:dict];
            }
            
            if ([stringSetupID isEqualToString:@"chkOutlChk_frmSetting"])
            {
                int status = (int) sqlite3_column_int(statement, 2);
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:stringSetupID,@"SetupID",[NSNumber numberWithInt:status],@"Status", nil];
                [arr addObject:dict];
            }
            
            if ([stringSetupID isEqualToString:@"chkOutsChk_chkOutlChk_frmSetting"])
            {
                int status = (int) sqlite3_column_int(statement, 2);
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:stringSetupID,@"SetupID",[NSNumber numberWithInt:status],@"Status", nil];
                [arr addObject:dict];
            }
            
            if ([stringSetupID isEqualToString:@"chkTakOrd_frmSetting"])
            {
                int status = (int) sqlite3_column_int(statement, 2);
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:stringSetupID,@"SetupID",[NSNumber numberWithInt:status],@"Status", nil];
                [arr addObject:dict];
            }
            
            if ([stringSetupID isEqualToString:@"chkMarketInformation_frmSetting"])
            {
                int status = (int) sqlite3_column_int(statement, 2);
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:stringSetupID,@"SetupID",[NSNumber numberWithInt:status],@"Status", nil];
                [arr addObject:dict];
            }
        
        }
    }
    sqlite3_finalize(statement);
    
    return arr;

}
-(void) saveSaleSetupUsingNSUserDefaultWithCompletionHandler:(CompletionHandler)completionHanlder
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dict = [user objectForKey:@"SalesSetup"];
    
    NSNumber *num1 = [dict objectForKey:@"chkPlaPre_frmSetting"];
    NSNumber *num1_1 = [dict objectForKey:@"chkSalHis_chkPlaPre_frmSetting"];
    NSNumber *num2 = [dict objectForKey:@"chkOutlChk_frmSetting"];
    NSNumber *num2_2 = [dict objectForKey:@"chkOutsChk_chkOutlChk_frmSetting"];
    NSNumber *num3 = [dict objectForKey:@"chkMarketInformation_frmSetting"];
    NSNumber *num4 = [dict objectForKey:@"chkTakOrd_frmSetting"];
    
    
    // Save
    sqlite3_stmt *stmt1;
    for (NSInteger i = 0; i < 6; i++)
    {
        switch (i) {
            case 0:
            {
                NSString *query1 = @"UPDATE SalesSetup SET Status = ? WHERE SetupID = ?";
                NSString *ID = @"chkPlaPre_frmSetting";
                
                if (sqlite3_prepare_v2(db, [query1 UTF8String], -1, &stmt1, nil) == SQLITE_OK)
                {
                    sqlite3_bind_int(stmt1, 1, num1.intValue);
                    sqlite3_bind_text(stmt1, 2, ID.UTF8String, -1, NULL);
                }
                if (sqlite3_step(stmt1) == SQLITE_DONE)
                {
                    //NSLog(@"Save avatar OK");
                }
                break;
            }
            case 1:
            {
                NSString *query1 = @"UPDATE SalesSetup SET Status = ? WHERE SetupID = ?";
                NSString *ID = @"chkSalHis_chkPlaPre_frmSetting";
                
                if (sqlite3_prepare_v2(db, [query1 UTF8String], -1, &stmt1, nil) == SQLITE_OK)
                {
                    sqlite3_bind_int(stmt1, 1, num1_1.intValue);
                    sqlite3_bind_text(stmt1, 2, ID.UTF8String, -1, NULL);
                }
                if (sqlite3_step(stmt1) == SQLITE_DONE)
                {
                    //NSLog(@"Save avatar OK");
                }
                break;
            }
            case 2:
            {
                NSString *query1 = @"UPDATE SalesSetup SET Status = ? WHERE SetupID = ?";
                NSString *ID = @"chkOutlChk_frmSetting";
                
                if (sqlite3_prepare_v2(db, [query1 UTF8String], -1, &stmt1, nil) == SQLITE_OK)
                {
                    sqlite3_bind_int(stmt1, 1, num2.intValue);
                    sqlite3_bind_text(stmt1, 2, ID.UTF8String, -1, NULL);
                }
                if (sqlite3_step(stmt1) == SQLITE_DONE)
                {
                    //NSLog(@"Save avatar OK");
                }
                break;
                break;
            }
            case 3:
            {
                NSString *query1 = @"UPDATE SalesSetup SET Status = ? WHERE SetupID = ?";
                NSString *ID = @"chkOutsChk_chkOutlChk_frmSetting";
                
                if (sqlite3_prepare_v2(db, [query1 UTF8String], -1, &stmt1, nil) == SQLITE_OK)
                {
                    sqlite3_bind_int(stmt1, 1, num2_2.intValue);
                    sqlite3_bind_text(stmt1, 2, ID.UTF8String, -1, NULL);
                }
                if (sqlite3_step(stmt1) == SQLITE_DONE)
                {
                    //NSLog(@"Save avatar OK");
                }
                break;
                break;
            }
            case 4:
            {
                NSString *query1 = @"UPDATE SalesSetup SET Status = ? WHERE SetupID = ?";
                NSString *ID = @"chkMarketInformation_frmSetting";
                
                if (sqlite3_prepare_v2(db, [query1 UTF8String], -1, &stmt1, nil) == SQLITE_OK)
                {
                    sqlite3_bind_int(stmt1, 1, num3.intValue);
                    sqlite3_bind_text(stmt1, 2, ID.UTF8String, -1, NULL);
                }
                if (sqlite3_step(stmt1) == SQLITE_DONE)
                {
                    //NSLog(@"Save avatar OK");
                }
                break;
                break;
            }
            case 5:
            {
                NSString *query1 = @"UPDATE SalesSetup SET Status = ? WHERE SetupID = ?";
                NSString *ID = @"chkTakOrd_frmSetting";
                
                if (sqlite3_prepare_v2(db, [query1 UTF8String], -1, &stmt1, nil) == SQLITE_OK)
                {
                    sqlite3_bind_int(stmt1, 1, num4.intValue);
                    sqlite3_bind_text(stmt1, 2, ID.UTF8String, -1, NULL);
                }
                if (sqlite3_step(stmt1) == SQLITE_DONE)
                {
                    //NSLog(@"Save avatar OK");
                }
                break;
                break;
            }
                
            default:
                break;
        }
    }
    
    sqlite3_finalize(stmt1);
    
    completionHanlder(YES);


}
-(NSMutableArray *) arrDSKhachHangFromDatabaseAtDate:(NSString *)stringDate
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    /*
    NSString *query =  [NSString stringWithFormat:@"SELECT OM_SalesRouteDet.CustID, OM_SalesRouteDet.SalesRouteID, OM_SalesRouteDet.VisitDate, OM_SalesRouteDet.VisitSort, OM_SalesRouteDet.OrigVisitSort, PPC_ARCustomerInfo.CustName, PPC_ARCustomerInfo.ContactName, PPC_ARCustomerInfo.Addr1, AR_CustomerLocation.BranchID, AR_CustomerLocation.Lng, AR_CustomerLocation.Lat    FROM OM_SalesRouteDet, PPC_ARCustomerInfo, AR_CustomerLocation WHERE OM_SalesRouteDet.CustID = PPC_ARCustomerInfo.CustID AND OM_SalesRouteDet.CustID = AR_CustomerLocation.CustID AND DateTime('%@') = VisitDate",stringDate ];
    */
    //NSString *query =  [NSString stringWithFormat:@"SELECT * FROM AR_Customer, OM_SalesRouteDet where AR_Customer.custID = OM_SalesRouteDet.custID and VisitDate = DateTime('%@')",stringDate];
    
    NSString *query = @"SELECT * FROM AR_Customer, OM_SalesRouteDet , PPC_ARCustomerInfo where AR_Customer.custID = OM_SalesRouteDet.custID and AR_Customer.custID = PPC_ARCustomerInfo.custID and strftime('%d-%m-%Y', VisitDate)  = strftime('%d-%m-%Y', '";
    query = [query stringByAppendingString:[NSString stringWithFormat:@"%@')",stringDate]];
    
    NSLog(@"query ArrDSKH = %@",query);
    
    //NSString *query =  [NSString stringWithFormat:@"SELECT * FROM AR_Customer, OM_SalesRouteDet where AR_Customer.custID = OM_SalesRouteDet.custID and strftime('%d-%m-%Y', VisitDate)  = strftime('%d-%m-%Y', '%@')",stringDate];
    
    NSLog(@"query = %@",query);
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *CustID = (char *) sqlite3_column_text(statement, 0);
            char *PriceClassID = (char *) sqlite3_column_text(statement, 3);
            char *SalesRouteID = (char *) sqlite3_column_text(statement, 12);
            char *VisitDate = (char *) sqlite3_column_text(statement, 13);
            
            
            int VisitSort = (int) sqlite3_column_int(statement, 15);
            int OrigVisitSort = (int) sqlite3_column_int(statement, 16);
            
            char *CustName = (char *) sqlite3_column_text(statement, 1);
            char *ContactName = (char *) sqlite3_column_text(statement, 1);
            
            char *Addr1 = (char *) sqlite3_column_text(statement, 2);
            char *BranchID = (char *) sqlite3_column_text(statement, 2);
            
            //double lng = (double) sqlite3_column_double(statement, 9);
            //double lat = (double) sqlite3_column_double(statement, 10);
            
            // detail
            char *Phone = (char *) sqlite3_column_text(statement, 20);
            
            char *Mobile = (char *) sqlite3_column_text(statement, 21);
            char *Fax = (char *) sqlite3_column_text(statement, 22);
            char *Email = (char *) sqlite3_column_text(statement, 23);
            
            char *StateName = (char *) sqlite3_column_text(statement, 28);
            char *CityName = (char *) sqlite3_column_text(statement, 30);
            char *DistrictName = (char *) sqlite3_column_text(statement, 32);
            char *WardName = (char *) sqlite3_column_text(statement, 34);
            
            char *ChannelName = (char *) sqlite3_column_text(statement, 36);
            char *ClassIDName = (char *) sqlite3_column_text(statement, 38);
            char *AreaName = (char *) sqlite3_column_text(statement, 40);
            char *TerritoryName = (char *) sqlite3_column_text(statement, 42);
            
            char *ShopTypeName = (char *) sqlite3_column_text(statement, 44);
            char *TradeTypeName = (char *) sqlite3_column_text(statement, 46);
            char *PhotoCode = (char *) sqlite3_column_text(statement, 47);
            
            
            NSMutableDictionary *row = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:CustID],@"CustID",
                                        [NSString stringWithUTF8String:PriceClassID],@"PriceClassID",
                                        [NSString stringWithUTF8String:SalesRouteID],@"SalesRouteID",
                                        [NSString stringWithUTF8String:VisitDate],@"VisitDate",
                                        [NSNumber numberWithInt:VisitSort],@"VisitSort",
                                        [NSNumber numberWithInt:OrigVisitSort],@"OrigVisitSort",
                                        [NSString stringWithUTF8String:CustName],@"CustName",
                                        [NSString stringWithUTF8String:ContactName],@"ContactName",
                                        [NSString stringWithUTF8String:Addr1],@"Addr1",
                                        @"",@"BranchID",
                                        
                                        //detail
                                        [NSString stringWithUTF8String:Phone],@"Phone",
                                        [NSString stringWithUTF8String:Mobile],@"Mobile",
                                        [NSString stringWithUTF8String:Fax],@"Fax",
                                        [NSString stringWithUTF8String:Email],@"Email",
                                        [NSString stringWithUTF8String:StateName],@"StateName",
                                        [NSString stringWithUTF8String:CityName],@"CityName",
                                        [NSString stringWithUTF8String:DistrictName],@"DistrictName",
                                        [NSString stringWithUTF8String:WardName],@"WardName",
                                        [NSString stringWithUTF8String:ChannelName],@"ChannelName",
                                        [NSString stringWithUTF8String:ClassIDName],@"ClassIDName",
                                        [NSString stringWithUTF8String:AreaName],@"AreaName",
                                        [NSString stringWithUTF8String:TerritoryName],@"TerritoryName",
                                        [NSString stringWithUTF8String:ShopTypeName],@"ShopTypeName",
                                        [NSString stringWithUTF8String:TradeTypeName],@"TradeTypeName",
                                        [NSString stringWithUTF8String:PhotoCode],@"PhotoCode",
                                        nil];
            
            [arr addObject:row];
        }
    }
    sqlite3_finalize(statement);
    
    return arr;
}
-(NSMutableArray *) arrALLDSKhachHangFromDatabase
{
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    NSString *query =  [NSString stringWithFormat:@"SELECT * FROM PPC_ARCustomerInfo"];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *CustID = (char *) sqlite3_column_text(statement, 0);
            char *CustName = (char *) sqlite3_column_text(statement, 1);
            char *ContactName = (char *) sqlite3_column_text(statement, 2);
            char *Phone = (char *) sqlite3_column_text(statement, 3);
            
            char *Mobile = (char *) sqlite3_column_text(statement, 4);
            char *Fax = (char *) sqlite3_column_text(statement, 5);
            char *Email = (char *) sqlite3_column_text(statement, 6);
            char *Addr1 = (char *) sqlite3_column_text(statement, 7);
            
            char *StateName = (char *) sqlite3_column_text(statement, 11);
            char *CityName = (char *) sqlite3_column_text(statement, 13);
            char *DistrictName = (char *) sqlite3_column_text(statement, 15);
            char *WardName = (char *) sqlite3_column_text(statement, 17);
            
            char *ChannelName = (char *) sqlite3_column_text(statement, 19);
            char *ClassIDName = (char *) sqlite3_column_text(statement, 21);
            char *AreaName = (char *) sqlite3_column_text(statement, 23);
            char *TerritoryName = (char *) sqlite3_column_text(statement, 25);
            
            char *ShopTypeName = (char *) sqlite3_column_text(statement, 27);
            char *TradeTypeName = (char *) sqlite3_column_text(statement, 29);
            char *PhotoCode = (char *) sqlite3_column_text(statement, 30);
            char *PriceClasID = (char *) sqlite3_column_text(statement, 31);
            
            NSMutableDictionary *row = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:CustID],@"CustID",
                                        [NSString stringWithUTF8String:CustName],@"CustName",
                                        [NSString stringWithUTF8String:ContactName],@"ContactName",
                                        [NSString stringWithUTF8String:Phone],@"Phone",
                                        [NSString stringWithUTF8String:Mobile],@"Mobile",
                                        [NSString stringWithUTF8String:Fax],@"Fax",
                                        [NSString stringWithUTF8String:Email],@"Email",
                                        [NSString stringWithUTF8String:Addr1],@"Addr1",
                                        [NSString stringWithUTF8String:StateName],@"StateName",
                                        [NSString stringWithUTF8String:CityName],@"CityName",
                                        [NSString stringWithUTF8String:DistrictName],@"DistrictName",
                                        [NSString stringWithUTF8String:WardName],@"WardName",
                                        [NSString stringWithUTF8String:ChannelName],@"ChannelName",
                                        [NSString stringWithUTF8String:ClassIDName],@"ClassIDName",
                                        [NSString stringWithUTF8String:AreaName],@"AreaName",
                                        [NSString stringWithUTF8String:TerritoryName],@"TerritoryName",
                                        [NSString stringWithUTF8String:ShopTypeName],@"ShopTypeName",
                                        [NSString stringWithUTF8String:TradeTypeName],@"TradeTypeName",
                                        [NSString stringWithUTF8String:PhotoCode],@"PhotoCode",
                                        [NSString stringWithUTF8String:PriceClasID],@"PriceClassID",
                                        @"0",@"Color",
                                        nil];
            
            [arr addObject:row];
        }
    }
    sqlite3_finalize(statement);
    
    // New customer
    NSString *query_1 =  [NSString stringWithFormat:@"SELECT * FROM AR_NewCustomerInfor"];
    
    sqlite3_stmt *statement_1;
    if (sqlite3_prepare_v2(db, [query_1 UTF8String], -1, &statement_1, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement_1) == SQLITE_ROW)
        {
            char *CustID = (char *) sqlite3_column_text(statement_1, 0);
            char *CustName = (char *) sqlite3_column_text(statement_1, 1);
            char *ContactName = (char *) sqlite3_column_text(statement_1, 2);
            char *Phone = (char *) sqlite3_column_text(statement_1, 3);
            
            char *Mobile = (char *) sqlite3_column_text(statement_1, 4);
            char *Fax = (char *) sqlite3_column_text(statement_1, 5);
            char *Email = (char *) sqlite3_column_text(statement_1, 6);
            char *Addr1 = (char *) sqlite3_column_text(statement_1, 7);
            
            char *StateName = (char *) sqlite3_column_text(statement_1, 10);
            char *CityName = (char *) sqlite3_column_text(statement_1, 11);
            char *DistrictName = (char *) sqlite3_column_text(statement_1, 12);
            char *WardName = (char *) sqlite3_column_text(statement_1, 13);
            
            char *ChannelName = (char *) sqlite3_column_text(statement_1, 14);
            char *ClassIDName = (char *) sqlite3_column_text(statement_1, 15);
            char *AreaName = (char *) sqlite3_column_text(statement_1, 16);
            char *TerritoryName = (char *) sqlite3_column_text(statement_1, 17);
            
            char *ShopTypeName = (char *) sqlite3_column_text(statement_1, 18);
            char *TradeTypeName = (char *) sqlite3_column_text(statement_1, 19);
            char *PhotoCode = (char *) sqlite3_column_text(statement_1, 22);
            
            NSMutableDictionary *row = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:CustID],@"CustID",
                                        [NSString stringWithUTF8String:CustName],@"CustName",
                                        [NSString stringWithUTF8String:ContactName],@"ContactName",
                                        [NSString stringWithUTF8String:Phone],@"Phone",
                                        [NSString stringWithUTF8String:Mobile],@"Mobile",
                                        [NSString stringWithUTF8String:Fax],@"Fax",
                                        [NSString stringWithUTF8String:Email],@"Email",
                                        [NSString stringWithUTF8String:Addr1],@"Addr1",
                                        [NSString stringWithUTF8String:StateName],@"StateName",
                                        [NSString stringWithUTF8String:CityName],@"CityName",
                                        [NSString stringWithUTF8String:DistrictName],@"DistrictName",
                                        [NSString stringWithUTF8String:WardName],@"WardName",
                                        [NSString stringWithUTF8String:ChannelName],@"ChannelName",
                                        [NSString stringWithUTF8String:ClassIDName],@"ClassIDName",
                                        [NSString stringWithUTF8String:AreaName],@"AreaName",
                                        [NSString stringWithUTF8String:TerritoryName],@"TerritoryName",
                                        [NSString stringWithUTF8String:ShopTypeName],@"ShopTypeName",
                                        [NSString stringWithUTF8String:TradeTypeName],@"TradeTypeName",
                                        [NSString stringWithUTF8String:PhotoCode],@"PhotoCode",
                                        @"0",@"Color",
                                        nil];
            
            [arr addObject:row];
        }
    }
    sqlite3_finalize(statement_1);
    
    
    // set color
    for (NSMutableDictionary *dict in arr)
    {
        NSString *custID = [dict objectForKey:@"CustID"];
        
        NSString *query_1 = [NSString stringWithFormat:@"SELECT * FROM OM_SalesOrd WHERE CustID = '%@'",custID];
        NSLog(@"query = %@",query_1);
        // check
        BOOL isExists = NO;
        sqlite3_stmt *statement_3;
        if (sqlite3_prepare_v2(db, [query_1 UTF8String], -1, &statement_3, nil) == SQLITE_OK)
        {
            while (sqlite3_step(statement_3) == SQLITE_ROW)
            {
                isExists = YES;
            }
        }
        sqlite3_finalize(statement_3);
        
        if (isExists)
        {
            NSLog(@"set color for custID = %@",custID);
            [dict setObject:@"1" forKey:@"Color"];
        }
        else
        {
            [dict setObject:@"0" forKey:@"Color"];
        }
    }
    return arr;
     
}
-(NSMutableArray *) arrLichSuBanHangFromDatabaseWithCustomerID:(NSString *)custID
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    NSString *query =  [NSString stringWithFormat:@"SELECT * FROM PPC_SalesHistory WHERE CustID = '%@'",custID];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *CustID = (char *) sqlite3_column_text(statement, 0);
            char *InvtID = (char *) sqlite3_column_text(statement, 1);
            char *Descr = (char *) sqlite3_column_text(statement, 2);
            
            double qty = (double) sqlite3_column_double(statement, 3);
            double amo = (double) sqlite3_column_double(statement, 4);
            
            
            
            NSMutableDictionary *row = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:CustID],@"CustID",
                                        [NSString stringWithUTF8String:InvtID],@"InvtID",
                                        [NSString stringWithUTF8String:Descr],@"Descr",
                                        [NSNumber numberWithDouble:qty],@"Qty",
                                        [NSNumber numberWithDouble:amo],@"Amo",nil];
            
            [arr addObject:row];
        }
    }
    sqlite3_finalize(statement);
    
    return arr;
}
-(NSMutableArray *) arrTuoiNoFromDatabaseWithCustomerID:(NSString *)custID
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    NSString *query =  [NSString stringWithFormat:@"SELECT * FROM PPC_AgingDebt WHERE CustID = '%@'",custID];
    NSLog(@"Query PPC_AgingDebt = %@",query);
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *CustID = (char *) sqlite3_column_text(statement, 8);
            char *OrderNumber = (char *) sqlite3_column_text(statement, 0);
            double DocBal = (double) sqlite3_column_double(statement, 1);
            
            double CreditLimit = (double) sqlite3_column_double(statement, 2);
            double DueYet = (double) sqlite3_column_double(statement, 3);
            double Due7 = (double) sqlite3_column_double(statement, 4);
            double Due15 = (double) sqlite3_column_double(statement, 5);
            double DueOver15 = (double) sqlite3_column_double(statement, 6);

            
            
            
            NSMutableDictionary *row = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:CustID],@"CustID",
                                        [NSString stringWithUTF8String:OrderNumber],@"OrderNumber",
                                        [NSNumber numberWithDouble:DocBal],@"DocBal",
                                        [NSNumber numberWithDouble:CreditLimit],@"CreditLimit",
                                        [NSNumber numberWithDouble:DueYet],@"DueYet",
                                        [NSNumber numberWithDouble:Due7],@"Due7",
                                        [NSNumber numberWithDouble:Due15],@"Due15",
                                        [NSNumber numberWithDouble:DueOver15],@"DueOver15",nil];
            
            [arr addObject:row];
        }
    }
    sqlite3_finalize(statement);
    
    return arr;
}
-(NSMutableArray *) arrBrancdFromDatabase
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    NSString *query =  [NSString stringWithFormat:@"SELECT * FROM IN_Brand"];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *Code = (char *) sqlite3_column_text(statement, 0);
            char *Descr = (char *) sqlite3_column_text(statement, 1);

            
            
            
            
            NSMutableDictionary *row = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:Code],@"Code",
                                        [NSString stringWithUTF8String:Descr],@"Descr",
                                        @"0",@"color",
                                        @"0",@"GiaBan",
                                        @"0",@"SLTB",
                                        @"0",@"TonKho",
                                        @"",@"GhiChu",nil];
            
            [arr addObject:row];
        }
    }
    sqlite3_finalize(statement);
    
    return arr;
}
-(NSMutableArray *) arrSanPhamDoiThuFromDatabaseWithCustID:(NSString *)custID
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    NSString *query =  [NSString stringWithFormat:@"Select InvtID,BrandIFV,Descr,StkUnit,StkQty,StkBasePrc From PPC_IN_InventoryCompetitor where CustID Like '%@' Union Select InvtID,BrandIFV,Descr,StkUnit,StkQty,StkBasePrc From IN_InventoryCompetitor Where InvtID not in ( Select InvtID From PPC_IN_InventoryCompetitor where CustID Like '%@' ) Order by InvtID",custID,custID];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *InvtID = (char *) sqlite3_column_text(statement, 0);
            char *BrandIFV = (char *) sqlite3_column_text(statement, 1);
            char *Descr = (char *) sqlite3_column_text(statement, 2);
            char *StkUnit = (char *) sqlite3_column_text(statement, 3);
            double StkQty = (double ) sqlite3_column_double(statement, 4);
            double StkBasePrc = (double ) sqlite3_column_double(statement, 5);
            
            
            
            
            
            NSMutableDictionary *row = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:InvtID],@"InvtID",
                                        [NSString stringWithUTF8String:BrandIFV],@"BrandIFV",
                                        [NSString stringWithUTF8String:Descr],@"Descr",
                                        [NSString stringWithUTF8String:StkUnit],@"StkUnit",
                                        [NSNumber numberWithDouble:StkQty],@"StkQty",
                                        [NSString stringWithFormat:@"%.2f",StkBasePrc],@"StkBasePrc",
                                        @"0",@"SLTB",
                                        @"",@"GhiChu",
                                        @"0",@"color",nil];
            
            [arr addObject:row];
        }
    }
    sqlite3_finalize(statement);
    
    return arr;
}
-(NSMutableArray *) arrGhiNhanDonHangFromDatabaseWithCustID:(NSString*)custID AndPriceClassID:(NSString*)priceClassID AndSiteID:(NSString*)siteID
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    NSString *query =  [NSString stringWithFormat:@"SELECT * FROM IN_Inventory" ];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *invtID = (char *) sqlite3_column_text(statement, 1);
            char *desrc = (char *) sqlite3_column_text(statement, 2);
            char *stkUnit = (char *) sqlite3_column_text(statement, 3);
            char *stkBasePrc = (char *) sqlite3_column_text(statement, 8); // ko lay gia cho nay, vì xet uu tien
            char *taxCat = (char *) sqlite3_column_text(statement, 5);
            
            NSMutableDictionary *row = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:invtID],@"invtID",[NSString stringWithUTF8String:desrc],@"desrc",[NSString stringWithUTF8String:stkUnit],@"stkUnit",@"0",@"stkBasePrc",@"0",@"soLuong",@" ",@"ghiChu",@"0",@"color",
                                        @"0",@"SL",
                                        @"0",@"SLKM",
                                        @"0",@"MaCTKM",
                                        @"0",@"QtyVail",
                                        @"0",@"OrigQtyVail",
                                        @"0",@"TongTien",
                                        [NSString stringWithUTF8String:taxCat],@"TaxCat",nil];
            
            [arr addObject:row];
        }
    }
    sqlite3_finalize(statement);
    
    // Add Luong Ton Kho
    NSMutableArray *arrTonKho = [[NSMutableArray alloc] init];
    
    NSString *queryTonKho =  [NSString stringWithFormat:@"SELECT * FROM IN_ItemLoc" ];
    
    sqlite3_stmt *statementTonKho;
    if (sqlite3_prepare_v2(db, [queryTonKho UTF8String], -1, &statementTonKho, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statementTonKho) == SQLITE_ROW)
        {
            char *invtID = (char *) sqlite3_column_text(statementTonKho, 0);
            double QtyVail = (double) sqlite3_column_double(statementTonKho, 3);
            double OrigQtyVail = (double) sqlite3_column_double(statementTonKho, 4);

            
            NSMutableDictionary *row = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:invtID],@"invtID",
                                        [NSString stringWithFormat:@"%.0f",QtyVail],@"QtyVail",
                                        [NSString stringWithFormat:@"%.0f",OrigQtyVail],@"OrigQtyVail",nil];
            [arrTonKho addObject:row];
        }
    }

    

    for (NSDictionary *dict in arr)
    {
        
        for (NSDictionary *dictTonKho in arrTonKho)
        {
            NSString *invtID = [dict objectForKey:@"invtID"];
            NSString *invtIDTonKho = [dictTonKho objectForKey:@"invtID"];
            
            if ([invtID isEqualToString:invtIDTonKho])
            {
                [dict setValue:[dictTonKho objectForKey:@"QtyVail"] forKey:@"QtyVail"];
                [dict setValue:[dictTonKho objectForKey:@"OrigQtyVail"] forKey:@"OrigQtyVail"];
            }
        }
    }
    sqlite3_finalize(statementTonKho);
    
    // Gia theo 3 uu tien
    
    // Uu tien 3
    NSMutableArray *arrPriceOfCust3 = [[NSMutableArray alloc] init];
    NSString *queryPriceOfCust3 = @"SELECT SiteID, InvtID, DiscPrice FROM PPC_PriceOfCust WHERE  CustID = '' GROUP BY InvtID";
    
    sqlite3_stmt *statementPriceOfCust3;
    if (sqlite3_prepare_v2(db, [queryPriceOfCust3 UTF8String], -1, &statementPriceOfCust3, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statementPriceOfCust3) == SQLITE_ROW)
        {
            char *SiteID = (char *) sqlite3_column_text(statementPriceOfCust3, 0);
            char *InvtID = (char *) sqlite3_column_text(statementPriceOfCust3, 1);
            double DiscPrice = (double) sqlite3_column_double(statementPriceOfCust3, 2);
                        
            NSMutableDictionary *row = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                [NSString stringWithUTF8String:SiteID],@"SiteID",
                [NSString stringWithUTF8String:InvtID],@"InvtID",
                [NSString stringWithFormat:@"%.0f",DiscPrice],@"DiscPrice",nil];
            
            [arrPriceOfCust3 addObject:row];
        }
    }
    
    for (NSDictionary *dict in arr)
    {
        
        for (NSDictionary *dictPriceOfCust in arrPriceOfCust3)
        {
            NSString *invtID = [dict objectForKey:@"invtID"];
            NSString *invtIDPriceOfCust = [dictPriceOfCust objectForKey:@"InvtID"];
            
            if ([invtID isEqualToString:invtIDPriceOfCust])
            {
                NSLog(@"InvtID3: %@", invtID);
                NSLog(@"GiaCu: %@", [dict objectForKey:@"stkBasePrc"]);
                NSLog(@"GiaMoi: %@", [dictPriceOfCust objectForKey:@"DiscPrice"]);
                
                
                [dict setValue:[dictPriceOfCust objectForKey:@"DiscPrice"] forKey:@"stkBasePrc"];
                [dict setValue:[dictPriceOfCust objectForKey:@"SiteID"] forKey:@"SiteID"];
                
            }
        }
    }
    sqlite3_finalize(statementPriceOfCust3);
    
    // Uu tien 1
    BOOL UuTien1 = NO;//
    NSMutableArray *arrPriceOfCust1 = [[NSMutableArray alloc] init];
    NSString *queryPriceOfCust1 = [NSString stringWithFormat:@"SELECT SiteID, InvtID, DiscPrice FROM PPC_PriceOfCust WHERE CustID = '%@' AND SiteID ='%@'", custID, siteID];
    
    sqlite3_stmt *statementPriceOfCust1;
    if (sqlite3_prepare_v2(db, [queryPriceOfCust1 UTF8String], -1, &statementPriceOfCust1, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statementPriceOfCust1) == SQLITE_ROW)
        {
            char *SiteID = (char *) sqlite3_column_text(statementPriceOfCust1, 0);
            char *InvtID = (char *) sqlite3_column_text(statementPriceOfCust1, 1);
            double DiscPrice = (double) sqlite3_column_double(statementPriceOfCust1, 2);
            
            NSMutableDictionary *row = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [NSString stringWithUTF8String:SiteID],@"SiteID",
                                        [NSString stringWithUTF8String:InvtID],@"InvtID",
                                        [NSString stringWithFormat:@"%.0f",DiscPrice],@"DiscPrice",nil];
            
            [arrPriceOfCust1 addObject:row];
            UuTien1 = YES;
        }
    }
    
    for (NSDictionary *dict in arr)
    {
        
        for (NSDictionary *dictPriceOfCust in arrPriceOfCust1)
        {
            NSString *invtID = [dict objectForKey:@"invtID"];
            NSString *invtIDPriceOfCust = [dictPriceOfCust objectForKey:@"InvtID"];
            
            if ([invtID isEqualToString:invtIDPriceOfCust])
            {
                NSLog(@"InvtID1: %@", invtID);
                NSLog(@"GiaCu: %@", [dict objectForKey:@"stkBasePrc"]);
                NSLog(@"GiaMoi: %@", [dictPriceOfCust objectForKey:@"DiscPrice"]);
                
                
                [dict setValue:[dictPriceOfCust objectForKey:@"DiscPrice"] forKey:@"stkBasePrc"];
                [dict setValue:[dictPriceOfCust objectForKey:@"SiteID"] forKey:@"SiteID"];
                
            }
        }
    }
    sqlite3_finalize(statementPriceOfCust1);
    
    // Uu tien 2
    if(!UuTien1)
    {
        NSMutableArray *arrPriceOfCust2 = [[NSMutableArray alloc] init];
        NSString *queryPriceOfCust2 = [NSString stringWithFormat:@"SELECT SiteID, InvtID, DiscPrice FROM PPC_PriceOfCust WHERE CustID = '%@' AND SiteID ='%@'", priceClassID, siteID];
        
        sqlite3_stmt *statementPriceOfCust2;
        if (sqlite3_prepare_v2(db, [queryPriceOfCust2 UTF8String], -1, &statementPriceOfCust2, nil) == SQLITE_OK)
        {
            while (sqlite3_step(statementPriceOfCust2) == SQLITE_ROW)
            {
                char *SiteID = (char *) sqlite3_column_text(statementPriceOfCust2, 0);
                char *InvtID = (char *) sqlite3_column_text(statementPriceOfCust2, 1);
                double DiscPrice = (double) sqlite3_column_double(statementPriceOfCust2, 2);
                
                NSMutableDictionary *row = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [NSString stringWithUTF8String:SiteID],@"SiteID",
                                            [NSString stringWithUTF8String:InvtID],@"InvtID",
                                            [NSString stringWithFormat:@"%.0f",DiscPrice],@"DiscPrice",nil];
                
                [arrPriceOfCust2 addObject:row];
            }
        }
        
        for (NSDictionary *dict in arr)
        {
            
            for (NSDictionary *dictPriceOfCust in arrPriceOfCust2)
            {
                NSString *invtID = [dict objectForKey:@"invtID"];
                NSString *invtIDPriceOfCust = [dictPriceOfCust objectForKey:@"InvtID"];
                
                if ([invtID isEqualToString:invtIDPriceOfCust])
                {
                    NSLog(@"InvtID2: %@", invtID);
                    NSLog(@"GiaCu: %@", [dict objectForKey:@"stkBasePrc"]);
                    NSLog(@"GiaMoi: %@", [dictPriceOfCust objectForKey:@"DiscPrice"]);
                    
                    
                    [dict setValue:[dictPriceOfCust objectForKey:@"DiscPrice"] forKey:@"stkBasePrc"];
                    [dict setValue:[dictPriceOfCust objectForKey:@"SiteID"] forKey:@"SiteID"];
                    
                }
            }
        }
        sqlite3_finalize(statementPriceOfCust2);
    }
    
    return arr;
}
-(NSMutableArray *) arrLyDoFromDatabase
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    NSString *query =  [NSString stringWithFormat:@"SELECT * FROM OM_ReasonCode"];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *Code = (char *) sqlite3_column_text(statement, 0);
            char *Descr = (char *) sqlite3_column_text(statement, 1);

            NSMutableDictionary *row = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:Code],@"Code",
                                        [NSString stringWithUTF8String:Descr],@"Descr",nil];
            
            [arr addObject:row];
        }
    }
    sqlite3_finalize(statement);
    
    return arr;
}
-(NSString *) stringJSONFROMQuery:(NSString *)queryString
{
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [array objectAtIndex:0];
    databasePath = [documentPath stringByAppendingPathComponent:@"Mobile.db3"];
    
    SQLHelper *helper = [[SQLHelper alloc] initWithContentsOfFile:databasePath];
    NSArray *arr = [helper executeQuery:queryString];
    
    // Add root table
    NSDictionary *rootDict = [NSDictionary dictionaryWithObjectsAndKeys:arr,@"Table", nil];
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSString *jsonString = [writer stringWithObject:rootDict];
    
    NSLog(@"string JSON = %@",jsonString);
    
    if (!jsonString)
        return @"";
    
    
    return jsonString;
}
-(NSString *) stringJSonWithRootName:(NSString *)rootName fromQuery:(NSString *)queryString
{
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [array objectAtIndex:0];
    databasePath = [documentPath stringByAppendingPathComponent:@"Mobile.db3"];
    
    SQLHelper *helper = [[SQLHelper alloc] initWithContentsOfFile:databasePath];
    NSArray *arr = [helper executeQuery:queryString];
    
    // Add root table
    NSDictionary *rootDict = [NSDictionary dictionaryWithObjectsAndKeys:arr,rootName, nil];
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSString *jsonString = [writer stringWithObject:rootDict];
    
    NSLog(@"string JSON = %@",jsonString);
    
    if (!jsonString)
        return @"";
    
    
    return jsonString;
}
-(NSString *) stringJSONForSyncSales
{
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [array objectAtIndex:0];
    databasePath = [documentPath stringByAppendingPathComponent:@"Mobile.db3"];
    
    SQLHelper *helper = [[SQLHelper alloc] initWithContentsOfFile:databasePath];
    
    NSMutableArray *arr_1 = [helper executeQuery:@"select * from OM_SalesOrd"];
    NSMutableArray *arr_2 = [helper executeQuery:@"select * from OM_SalesOrdDet"];
    
    for (NSMutableDictionary *editDic in arr_2)
    {
        if ([editDic objectForKey:@"FreeItem"])
        {
            [editDic setObject:@"0" forKey:@"FreeItem"];
        }
        
        [editDic setObject:[NSNumber numberWithFloat:0] forKey:@"QtyBO"];
        
        
    }
    
    NSArray *arr_3 = [helper executeQuery:@"select * from OM_SuggestOrder"];
    NSArray *arr_4 = [helper executeQuery:@"select * from OM_OrdDisc"];
    
    NSDictionary *rootDict = [NSDictionary dictionaryWithObjectsAndKeys:arr_1,@"OM_SalesOrd",arr_2,@"OM_SalesOrdDet",arr_3,@"OM_SuggestOrder",arr_4,@"OM_OrdDisc", nil];
    //NSDictionary *rootDict = [NSDictionary dictionaryWithObjectsAndKeys:arr_1,@"OM_SalesOrd",arr_2,@"OM_SalesOrdDet", nil];
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSString *jsonString = [writer stringWithObject:rootDict];
    
    NSLog(@"string JSON = %@",jsonString);
    if (!jsonString)
        return @"";
    
    
    return jsonString;
    
}
-(NSString *) stringJSONForSyncTechnicalSupport
{
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [array objectAtIndex:0];
    databasePath = [documentPath stringByAppendingPathComponent:@"Mobile.db3"];
    
    SQLHelper *helper = [[SQLHelper alloc] initWithContentsOfFile:databasePath];
    
    NSArray *arr_1 = [helper executeQuery:@"select * from PPC_TechnicalSupport"];
    NSArray *arr_2 = [helper executeQuery:@"select * from PPC_OM_TechnicalSupport_Image"];
    
    NSDictionary *rootDict = [NSDictionary dictionaryWithObjectsAndKeys:arr_1,@"PPC_TechnicalSupport",arr_2,@"PPC_OM_TechnicalSupport_Image", nil];
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSString *jsonString = [writer stringWithObject:rootDict];
    
    NSLog(@"string JSON = %@",jsonString);
    if (!jsonString)
        return @"";
    
    
    return jsonString;
}
-(NSString *) stringJSONForSyncNoticalBoard
{
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [array objectAtIndex:0];
    databasePath = [documentPath stringByAppendingPathComponent:@"Mobile.db3"];
    
    SQLHelper *helper = [[SQLHelper alloc] initWithContentsOfFile:databasePath];
    
    NSArray *arr_1 = [helper executeQuery:@"select * from PPC_NoticeBoardSubmit"];
    NSArray *arr_2 = [helper executeQuery:@"select * from PPC_OM_NoticeBoardSubmit_Image"];
    
    NSDictionary *rootDict = [NSDictionary dictionaryWithObjectsAndKeys:arr_1,@"PPC_NoticeBoardSubmit",arr_2,@"PPC_OM_NoticeBoardSubmit_Image", nil];
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSString *jsonString = [writer stringWithObject:rootDict];
    
    NSLog(@"string JSON = %@",jsonString);
    if (!jsonString)
        return @"";
    
    
    return jsonString;
}
-(NSString *) stringJSONForAR_CustomerLocation_SET
{
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [array objectAtIndex:0];
    databasePath = [documentPath stringByAppendingPathComponent:@"Mobile.db3"];
    
    SQLHelper *helper = [[SQLHelper alloc] initWithContentsOfFile:databasePath];
    
    NSArray *arr_1 = [helper executeQuery:@"select * from AR_CustomerLocation"];
    
    NSDictionary *rootDict = [NSDictionary dictionaryWithObjectsAndKeys:arr_1,@"AR_CustomerLocation", nil];
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSString *jsonString = [writer stringWithObject:rootDict];
    
    NSLog(@"string JSON = %@",jsonString);
    if (!jsonString)
        return @"";
    
    
    return jsonString;
}
-(NSString *) stringBussinessDateFromDatabase
{
    NSString *stringReturn;
    
    NSString *query =  [NSString stringWithFormat:@"SELECT * FROM Setting"];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *BussinessDate = (char *) sqlite3_column_text(statement, 12);
            stringReturn = [NSString stringWithUTF8String:BussinessDate];
            
        }
    }
    sqlite3_finalize(statement);
    
    return stringReturn;
}
-(BOOL) isHasValueWithQuery:(NSString *)queryString
{
    BOOL isHasValues = NO;
    
    NSString *query =  queryString;
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            isHasValues = YES;
            
        }
    }
    sqlite3_finalize(statement);
    
    return isHasValues;

}
-(void)saveJSONToDatabase:(NSString *)jsonString atTable:(NSString *)table
{
    NSData *dataJSON = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *rootTable = [NSJSONSerialization JSONObjectWithData:dataJSON options:NSJSONReadingMutableContainers error:&error];
    
    if (error)
    {
        NSLog(@"error With JSON String At table = %@",table);
    }
    else
    {
        NSLog(@"^^^ Json at table %@ = %@",table,rootTable);
    }
    NSLog(@"Table Name: %@", table);
    // CHeck table is OK
    BOOL isHasTable = NO;
    NSString *query =  [NSString stringWithFormat:@"SELECT name FROM sqlite_master WHERE type='table' AND name='%@'",table];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            isHasTable = YES;
        }
    }
    sqlite3_finalize(statement);
    
    if (!isHasTable)
        NSLog(@"Error Name Table = %@",table);
    
    
    [arrTable addObject:table];
    
    if (isHasTable)
    {
        /*
        "PPC_SalesHistory",
        "OM_ReasonCode",
        "PPC_AgingDebt",
        "AR_Territory",
        "AR_CustType",
        "OM_TechnicalSupport",
        "OM_Knowledge",
        "IN_InventoryCompetitor",
        "SI_Tax",
        "OM_DiscSeq",
        "AR_Doc",
        "OM_DiscItem",
        "OM_IssueType",
        "SYS_Company",
        "SI_State",
        "SI_Ward",
        "SI_City",
        "OM_Setup",
        "AR_Channel",
        "SI_District",
        "AR_CustomerLocation",
        "AR_ShopType",
        "RPT_MonthlySales",
        "OM_SalesRouteDet",
        "OM_DiscDescr",
        "OM_DiscCust",
        Setting,
        "OM_PriceClass",
        "AR_Customer",
        "AR_Area",
        "OM_SalesRoute",
        "SI_Hierarchy",
        "OM_DiscBreak",
        "OM_DiscCustClass",
        "OM_PPBudget",
        "PPC_SuggestOrder",
        "AR_CustClass",
        "PPC_ARCustomerInfo",
        "OM_DiscFreeItem",
        "OM_PPAlloc"
        */
        if ([table isEqualToString:@"PPC_SalesHistory"])
        {
            [self PPC_SalesHistory_WithJSON:rootTable tableName:table];
        }
        if ([table isEqualToString:@"OM_ReasonCode"])
        {
            [self OM_ReasonCode_WithJSON:rootTable tableName:table];
        }
        if ([table isEqualToString:@"PPC_AgingDebt"])
        {
            [self PPC_AgingDebt_WithJSON:rootTable tableName:table];
        }
        
        if ([table isEqualToString:@"AR_Territory"])        {
            [self AR_Territory_WithJSON:rootTable tableName:table];
        }
        if ([table isEqualToString:@"AR_CustType"])        {
            [self AR_CustType_WithJSON:rootTable tableName:table];
        }
        if ([table isEqualToString:@"OM_TechnicalSupport"])        {
            [self OM_TechnicalSupport_WithJSON:rootTable tableName:table];
        }
        if ([table isEqualToString:@"OM_Knowledge"])        {
            [self OM_Knowledge_WithJSON:rootTable tableName:table];
        }

        if ([table isEqualToString:@"IN_InventoryCompetitor"])        {
            [self IN_InventoryCompetitor_WithJSON:rootTable tableName:table];
        }
        if ([table isEqualToString:@"SI_Tax"])        {
            [self SI_Tax_WithJSON:rootTable tableName:table];
        }
        if ([table isEqualToString:@"OM_DiscSeq"])        {
            [self OM_DiscSeq_WithJSON:rootTable tableName:table];
        }

        if ([table isEqualToString:@"AR_Doc"])        {
            [self AR_Doc_WithJSON:rootTable tableName:table];
        }

        if ([table isEqualToString:@"OM_DiscItem"])        {
            [self OM_DiscItem_WithJSON:rootTable tableName:table];
        }
        
        if ([table isEqualToString:@"OM_IssueType"])        {
            [self OM_IssueType_WithJSON:rootTable tableName:table];
        }

        if ([table isEqualToString:@"SYS_Company"])        {
            [self SYS_Company_WithJSON:rootTable tableName:table];
        }

        if ([table isEqualToString:@"SI_State"])        {
            [self SI_State_WithJSON:rootTable tableName:table];
        }

        if ([table isEqualToString:@"SI_Ward"])        {
            [self SI_Ward_WithJSON:rootTable tableName:table];
        }

        if ([table isEqualToString:@"SI_City"])        {
            [self SI_City_WithJSON:rootTable tableName:table];
        }

        if ([table isEqualToString:@"OM_Setup"])        {
            [self OM_Setup_WithJSON:rootTable tableName:table];
        }

        if ([table isEqualToString:@"AR_Channel"])        {
            [self AR_Channel_WithJSON:rootTable tableName:table];
        }

        if ([table isEqualToString:@"SI_District"])        {
            [self SI_District_WithJSON:rootTable tableName:table];
        }

        if ([table isEqualToString:@"AR_CustomerLocation"])        {
            [self AR_CustomerLocation_WithJSON:rootTable tableName:table];
        }

        if ([table isEqualToString:@"AR_ShopType"])        {
            [self AR_ShopType_WithJSON:rootTable tableName:table];
        }

        if ([table isEqualToString:@"RPT_MonthlySales"])        {
            [self RPT_MonthlySales_WithJSON:rootTable tableName:table];
        }

        if ([table isEqualToString:@"OM_SalesRouteDet"])        {
            [self OM_SalesRouteDet_WithJSON:rootTable tableName:table];
        }

        if ([table isEqualToString:@"OM_DiscDescr"])        {
            [self OM_DiscDescr_WithJSON:rootTable tableName:table];
        }

        if ([table isEqualToString:@"OM_DiscCust"])        {
            [self OM_DiscCust_WithJSON:rootTable tableName:table];
        }

        if ([table isEqualToString:@"Setting"])        {
            [self Setting_WithJSON:rootTable tableName:table];
        }

        if ([table isEqualToString:@"OM_PriceClass"])        {
            [self OM_PriceClass_WithJSON:rootTable tableName:table];
        }

        if ([table isEqualToString:@"AR_Customer"])        {
            [self AR_Customer_WithJSON:rootTable tableName:table];
        }

        if ([table isEqualToString:@"AR_Area"])        {
            [self AR_Area_WithJSON:rootTable tableName:table];
        }

        if ([table isEqualToString:@"OM_SalesRoute"])        {
            [self OM_SalesRoute_WithJSON:rootTable tableName:table];
        }

        if ([table isEqualToString:@"SI_Hierarchy"])        {
            [self SI_Hierarchy_WithJSON:rootTable tableName:table];
        }

        if ([table isEqualToString:@"OM_DiscBreak"])        {
            [self OM_DiscBreak_WithJSON:rootTable tableName:table];
        }

        if ([table isEqualToString:@"OM_DiscCustClass"])        {
            
        }[self OM_DiscCustClass_WithJSON:rootTable tableName:table];

        if ([table isEqualToString:@"OM_PPBudget"])        {
            [self OM_PPBudget_WithJSON:rootTable tableName:table];
        }
        if ([table isEqualToString:@"PPC_SuggestOrder"])        {
            [self PPC_SuggestOrder_WithJSON:rootTable tableName:table];
        }

        if ([table isEqualToString:@"AR_CustClass"])        {
            [self AR_CustClass_WithJSON:rootTable tableName:table];
        }

        if ([table isEqualToString:@"PPC_ARCustomerInfo"])        {
            [self PPC_ARCustomerInfo_WithJSON:rootTable tableName:table];
        }

        if ([table isEqualToString:@"OM_DiscFreeItem"])        {
            [self OM_DiscFreeItem_WithJSON:rootTable tableName:table];
        }

        if ([table isEqualToString:@"OM_PPAlloc"])        {
            [self OM_PPAlloc__WithJSON:rootTable tableName:table];
        }
        
        
        // Add More
        if ([table isEqualToString:@"IN_Brand"])        {
            [self IN_Brand_WithJSON:rootTable tableName:table];
        }
        
        if ([table isEqualToString:@"IN_Inventory"])        {
            [self IN_Inventory_WithJSON:rootTable tableName:table];
        }
        
        if ([table isEqualToString:@"OM_Discount"])        {
            [self OM_Discount_WithJSON:rootTable tableName:table];
        }
        if ([table isEqualToString:@"OM_DiscItemClass"])        {
            [self OM_DiscItemClass_WithJSON:rootTable tableName:table];
        }
        
        if ([table isEqualToString:@"AR_CustomerInfo_Invt"])        {
            [self AR_CustomerInfo_Invt_WithJSON:rootTable tableName:table];
        }
        
        if ([table isEqualToString:@"IN_ItemLoc"])        {
            [self IN_ItemLoc_WithJSON:rootTable tableName:table];
        }
        
        if ([table isEqualToString:@"PPC_Distributor"])        {
            [self PPC_Distributor_WithJSON:rootTable tableName:table];
        }
        
        if ([table isEqualToString:@"PPC_SurveyBrand"])        {
            [self PPC_SurveyBrand_WithJSON:rootTable tableName:table];
        }
        
        if ([table isEqualToString:@"AR_Transaction"])        {
            [self AR_Transaction_WithJSON:rootTable tableName:table];
        }
        
        if ([table isEqualToString:@"In_Site"])        {
            [self In_Site_WithJSON:rootTable tableName:table];
        }
        
        if ([table isEqualToString:@"PPC_PriceOfCust"])        {
            [self PPC_PriceOfCust_WithJSON:rootTable tableName:table];
        }
        
        if ([table isEqualToString:@"OM_DefineWorks"])        {
            [self OM_DefineWorks_WithJSON:rootTable tableName:table];
        }

    }
}
-(void) OM_DefineWorks_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"TaskID"];
        NSString *str2 = [dict valueForKey:@"Name"];
        NSString *str3 = [dict valueForKey:@"Shooting"];
        NSString *str4 = [dict valueForKey:@"Required"];
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO OM_DefineWorks VALUES(?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt2, 3, str3.intValue);
            sqlite3_bind_int(stmt2, 4, str4.intValue);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
    
}
-(void) IN_ItemLoc_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    /*
     InvtID = "FG888000005-001";
     OrigQtyAvail = 100000;
     QtyAvail = 100000;
     SiteID = IFVHCM;
     WhseLoc = "";
     */
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"InvtID"]; // Code
        NSString *str2 = [dict valueForKey:@"SiteID"];
        NSString *str3 = [dict valueForKey:@"WhseLoc"]; // Code
        NSString *str4 = [dict valueForKey:@"QtyAvail"];
        NSString *str5 = [dict valueForKey:@"OrigQtyAvail"];
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO IN_ItemLoc VALUES(?,?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
            
            sqlite3_bind_double(stmt2, 4, str4.floatValue);
            sqlite3_bind_double(stmt2, 5, str5.floatValue);
            
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }

}
-(void) PPC_PriceOfCust_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"CustID"];
        NSString *str2 = [dict valueForKey:@"InvtID"];
        NSString *str3 = [dict valueForKey:@"SiteID"];
        NSString *str4 = [dict valueForKey:@"DiscPrice"];
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO PPC_PriceOfCust VALUES(?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
            sqlite3_bind_double(stmt2, 4, str4.doubleValue);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
    
}
-(void) In_Site_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"InvtID"];
        NSString *str2 = [dict valueForKey:@"SiteId"];
        NSString *str3 = [dict valueForKey:@"Name"];
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO In_Site VALUES(?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
    
}
-(void) AR_Transaction_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"CustID"];
        NSString *str2 = [dict valueForKey:@"RefNbr"];
        NSString *str3 = [dict valueForKey:@"InvNbr"];
        NSString *str4 = [self stringDateFromJSONString:[dict valueForKey:@"Date"]];
        NSString *str5 = [dict valueForKey:@"Descr"];
        NSString *str6 = [dict valueForKey:@"Debit"];
        NSString *str7 = [dict valueForKey:@"Credit"];
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO AR_Transaction VALUES(?,?,?,?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 4, str4.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 5, str5.UTF8String, -1, NULL);
            sqlite3_bind_double(stmt2, 6, str6.doubleValue);
            sqlite3_bind_double(stmt2, 7, str7.doubleValue);
            
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
    
}

-(void) PPC_SurveyBrand_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"CustID"];
        NSString *str2 = [dict valueForKey:@"Brand"];
        NSString *str3 = [dict valueForKey:@"ThucTe"];
        NSString *str4 = [dict valueForKey:@"ChiTieu"];
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO PPC_SurveyBrand VALUES(?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_double(stmt2, 3, str3.doubleValue);
            sqlite3_bind_double(stmt2, 4, str4.doubleValue);
            
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
    
}
-(void) PPC_Distributor_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{

    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"Distributor"];
        NSString *str2 = [dict valueForKey:@"CustID"];
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO PPC_Distributor VALUES(?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
    
}
-(void) printAllNameDatabase
{
    NSLog(@"arr Table = %@",arrTable);
}
-(NSString *) stringDateFromJSONString:(NSString *) string
{
    static NSRegularExpression *dateRegEx = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateRegEx = [[NSRegularExpression alloc] initWithPattern:@"^\\/date\\((-?\\d++)(?:([+-])(\\d{2})(\\d{2}))?\\)\\/$" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    NSTextCheckingResult *regexResult = [dateRegEx firstMatchInString:string options:0 range:NSMakeRange(0, [string length])];
    
    if (regexResult) {
        // milliseconds
        NSTimeInterval seconds = [[string substringWithRange:[regexResult rangeAtIndex:1]] doubleValue] / 1000.0;
        // timezone offset
        if ([regexResult rangeAtIndex:2].location != NSNotFound) {
            NSString *sign = [string substringWithRange:[regexResult rangeAtIndex:2]];
            // hours
            seconds += [[NSString stringWithFormat:@"%@%@", sign, [string substringWithRange:[regexResult rangeAtIndex:3]]] doubleValue] * 60.0 * 60.0;
            // minutes
            seconds += [[NSString stringWithFormat:@"%@%@", sign, [string substringWithRange:[regexResult rangeAtIndex:4]]] doubleValue] * 60.0;
        }
        
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
        
        return [format stringFromDate:date];
    }
    return nil;
}

// *********************************************************************************************************
// *********************************************************************************************************
// *********************************************************************************************************
// *********************************************************************************************************
// Save all data
// new
-(void) AR_CustomerInfo_Invt_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    /*
     AveMtd = 1000;
     BranchID = IFV0001;
     Code = 02;
     CtrDate = "/Date(1377190800000+0700)/";
     CustID = FG0249;
     Descr = "888 Orange";
     Note = "";
     SlsperID = 022;
     StkBasePrc = 12000;
     StkQty = 0;
     StkUnit = "";
     */
    
    
    
}
-(void) IN_Brand_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    /*
     Code = 01;
     Descr = "888 (Export)";
     */
    
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"Code"]; // Code
        NSString *str2 = [dict valueForKey:@"Descr"];
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO IN_Brand VALUES(?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }

    
}
-(void) IN_Inventory_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    /*
     Brand = "";
     ClassID = DOM;
     CnvFact = 1;
     Color = B;
     Descr = "Bot mi 888 orange (05kg)                          ";
     InvtID = "FG888000005-001";
     IsDel = 0;
     LastPurchaseDate = "/Date(1373389200000+0700)/";
     LossRate00 = 0;
     NodeID = "";
     NodeLevel = 3;
     ParentRecordID = 0;
     Picture = "";
     PriceClassID = "<null>";
     ProKnowledge = "";
     SiteID = IFVHCM;
     SortOrder = 0;
     StkBasePrc = 12000;
     StkUnit = KG;
     StkWt = 0;
     Stt = "";
     TaxCat = VAT05;
     WhseLoc = "";
     */
    
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"Stt"]; // Code
        NSString *str2 = [dict valueForKey:@"InvtID"];
        NSString *str3 = [dict valueForKey:@"Descr"]; // Code
        NSString *str4 = [dict valueForKey:@"StkUnit"];
        NSString *str5 = [dict valueForKey:@"CnvFact"]; // Code
        NSString *str6 = [dict valueForKey:@"TaxCat"];
        NSString *str7 = [dict valueForKey:@"ClassID"];
        NSString *str8 = [dict valueForKey:@"PriceClassID"]; // Code
        NSLog(@"str 8 = %@",str8);
        NSString *str9 = [dict valueForKey:@"StkBasePrc"];
        NSString *str10 = [dict valueForKey:@"SiteID"]; // Code
        NSString *str11 = [dict valueForKey:@"WhseLoc"];
        NSString *str12 = [self stringDateFromJSONString:[dict valueForKey:@"LastPurchaseDate"]]; // Code
        NSString *str13 = [dict valueForKey:@"NodeID"];
        NSString *str14 = [dict valueForKey:@"NodeLevel"]; // Code
        NSString *str15 = [dict valueForKey:@"ParentRecordID"];
        NSString *str16 = [dict valueForKey:@"SortOrder"]; // Code
        NSString *str17 = [dict valueForKey:@"Color"];
        NSString *str18 = [dict valueForKey:@"StkWt"];
        NSString *str19 = [dict valueForKey:@"Brand"];
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO IN_Inventory VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 4, str4.UTF8String, -1, NULL);
            
            sqlite3_bind_double(stmt2, 5, str5.doubleValue);
            
            sqlite3_bind_text(stmt2, 6, str6.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 7, str7.UTF8String, -1, NULL);
            //sqlite3_bind_text(stmt2, 8, str8.UTF8String, -1, NULL);
            // NULL
            if ([str8  isKindOfClass:[NSNull class]])
                sqlite3_bind_null(stmt2, 8);
            else
                sqlite3_bind_text(stmt2, 8, str8.UTF8String, -1, NULL);
            
            
            sqlite3_bind_double(stmt2, 9, str9.doubleValue);
            
            sqlite3_bind_text(stmt2, 10, str10.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 11, str11.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 12, str12.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 13, str13.UTF8String, -1, NULL);
            
            sqlite3_bind_int(stmt2, 14, str14.intValue);
            sqlite3_bind_int(stmt2, 15, str15.intValue);
            sqlite3_bind_int(stmt2, 16, str16.intValue);
            
            sqlite3_bind_text(stmt2, 17, str17.UTF8String, -1, NULL);
            sqlite3_bind_double(stmt2, 18, str18.doubleValue);
            sqlite3_bind_text(stmt2, 19, str19.UTF8String, -1, NULL);
            
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
}
-(void) OM_Discount_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"DiscID"]; // Code
        NSString *str2 = [dict valueForKey:@"Descr"];
        NSString *str3 = [dict valueForKey:@"DiscClass"]; // Code
        NSString *str4 = [dict valueForKey:@"DiscType"];
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO OM_Discount VALUES(?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 4, str4.UTF8String, -1, NULL);
            
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
    }
}
-(void) OM_DiscItemClass_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"DiscID"]; // Code
        NSString *str2 = [dict valueForKey:@"DiscSeq"];
        NSString *str3 = [dict valueForKey:@"ClassID"]; // Code
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO OM_DiscItemClass VALUES(?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
            
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
}
}
// Old

-(void) PPC_SalesHistory_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    /*
    Amt = 90000000;
    BranchID = IFV0001;
    CustID = FG0003;
    Descr = "Bot mi 888 export - 25Kg (Paper Bag)                        ";
    InvtID = "FG888000025-002";
    Qty = 5600;
     */
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"CustID"]; // Code
        str1 = [str1 stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *str2 = [dict valueForKey:@"InvtID"];
        NSString *str3 = [dict valueForKey:@"Descr"];
        NSString *str4 = [dict valueForKey:@"Qty"];
        NSString *str5 = [dict valueForKey:@"Amt"];
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO PPC_SalesHistory VALUES(?,?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
            sqlite3_bind_double(stmt2, 4, str4.floatValue);
            sqlite3_bind_double(stmt2, 5, str5.floatValue);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
    
}
-(void) OM_ReasonCode_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    /*
     
     Code = RC01;
     Descr = "\U0110\U1ed5i h\U00e0ng gi\U1eefa NPP v\U1edbi NPP";
     */
    
    
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"Code"]; // Code
        NSString *str2 = [dict valueForKey:@"Descr"];
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO OM_ReasonCode VALUES(?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }

    
}
-(void) PPC_AgingDebt_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    /*
     BranchID = IFV0001;
     CreditLimit = 0;
     CustID = FG0003;
     DocBal = 500000;
     DocDate = "/Date(1375376400000+0700)/";
     Due15 = 250000;
     Due7 = 250000;
     DueOver15 = 0;
     DueYet = 7;
     OrderNbr = SO0001;
     */
    
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"OrderNbr"]; // Code
        NSString *str2 = [dict valueForKey:@"DocBal"];
        NSString *str3 = [dict valueForKey:@"CreditLimit"]; // Code
        NSString *str4 = [dict valueForKey:@"DueYet"]; // Code
        NSString *str5 = [dict valueForKey:@"Due7"];
        NSString *str6 = [dict valueForKey:@"Due15"]; // Code
        NSString *str7 = [dict valueForKey:@"DueOver15"];
        NSString *str8 = [self stringDateFromJSONString:[dict valueForKey:@"DocDate"]]; // Code
        NSString *str9 = [dict valueForKey:@"CustID"];
        str9 = [str9 stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO PPC_AgingDebt VALUES(?,?,?,?,?,?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_double(stmt2, 2, str2.floatValue);
            sqlite3_bind_double(stmt2, 3, str3.floatValue);
            sqlite3_bind_double(stmt2, 4, str4.floatValue);
            sqlite3_bind_double(stmt2, 5, str5.floatValue);
            sqlite3_bind_double(stmt2, 6, str6.floatValue);
            sqlite3_bind_double(stmt2, 7, str7.floatValue);
            sqlite3_bind_text(stmt2, 8, str8.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 9, str9.UTF8String, -1, NULL);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }

}
-(void) AR_Territory_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    /*
     Descr = North;
     Territory = Z11;
     
     */
    
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"Territory"]; // Code
        NSString *str2 = [dict valueForKey:@"Descr"];

        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO AR_Territory VALUES(?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
}
-(void) AR_CustType_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    /*
     Code = T;
     Descr = Trade;
     */
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"Code"]; // Code
        NSString *str2 = [dict valueForKey:@"Descr"];
        
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO AR_CustType VALUES(?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
}
-(void) OM_TechnicalSupport_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [NSString stringWithFormat:@"%@",[dict valueForKey:@"Code"]]; // Code
        NSString *str2 = [dict valueForKey:@"IssueHeader"];
        NSString *str3 = [dict valueForKey:@"IssueType"]; // Code
        NSString *str4 = [dict valueForKey:@"IssueTypeName"]; // Code
        NSString *str5 = [dict valueForKey:@"IssueContent"];
        NSString *str6 = [dict valueForKey:@"Picture1"];
        NSString *str7 = [dict valueForKey:@"Picture2"];
        NSString *str8 = [dict valueForKey:@"Picture2"];
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO OM_TechnicalSupport VALUES(?,?,?,?,?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 4, str4.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 5, str5.UTF8String, -1, NULL);
            
            sqlite3_bind_text(stmt2, 6, str6.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 7, str7.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 8, str8.UTF8String, -1, NULL);

        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
        NSString *stringPicture1 = str6;
        NSString * stringPicture2 = str7;
        NSString *stringPicture3 = str8;
        
        if (stringPicture1 && ![stringPicture1 isEqualToString:@""])
        {
            // Picture 1
            NSString *photourl = [NSString stringWithFormat:@"%@%@",kURLPhoto,stringPicture1];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:photourl]];
            
            AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request success:^(UIImage *image)
            {
                NSLog(@"download file  %@",stringPicture1);
                
                // Get dir
                NSString *documentsDirectory = nil;
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                documentsDirectory = [paths objectAtIndex:0];
                
                NSString *pathString = [NSString stringWithFormat:@"%@/%@",documentsDirectory, stringPicture1];
                
                // Save Image
                NSData *imageData = UIImagePNGRepresentation(image);
                NSError *err;
                [imageData writeToFile:pathString options:NSDataWritingAtomic error:&err];
                
                if (err)
                    NSLog(@"Error download");
                 
            }];
            [operation start];
        }
        if (stringPicture2 && ![stringPicture2 isEqualToString:@""])
        {
            // Picture 1
            NSString *photourl = [NSString stringWithFormat:@"%@%@",kURLPhoto,stringPicture2];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:photourl]];
            
            AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request success:^(UIImage *image)
                                                  {
                                                      NSLog(@"download file  %@",stringPicture2);
                                                      
                                                      // Get dir
                                                      NSString *documentsDirectory = nil;
                                                      NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                                                      documentsDirectory = [paths objectAtIndex:0];
                                                      
                                                      NSString *pathString = [NSString stringWithFormat:@"%@/%@",documentsDirectory, stringPicture2];
                                                      
                                                      // Save Image
                                                      NSData *imageData = UIImageJPEGRepresentation(image, 0.7f);
                                                      [imageData writeToFile:pathString atomically:YES];
                                                      
                                                  }];
            [operation start];
        }
        if (stringPicture3 && ![stringPicture3 isEqualToString:@""])
        {
            // Picture 1
            NSString *photourl = [NSString stringWithFormat:@"%@%@",kURLPhoto,stringPicture1];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:photourl]];
            
            AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request success:^(UIImage *image)
                                                  {
                                                      NSLog(@"download file  %@",stringPicture3);
                                                      
                                                      // Get dir
                                                      NSString *documentsDirectory = nil;
                                                      NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                                                      documentsDirectory = [paths objectAtIndex:0];
                                                      
                                                      NSString *pathString = [NSString stringWithFormat:@"%@/%@",documentsDirectory, stringPicture3];
                                                      
                                                      // Save Image
                                                      NSData *imageData = UIImageJPEGRepresentation(image, 0.7f);
                                                      [imageData writeToFile:pathString atomically:YES];
                                                      
                                                  }];
            [operation start];
        }
        
        
        /*
        AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request
                                                                                  imageProcessingBlock:nil
                                                                                             cacheName:nil
                                                                                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
         
                                                                                                   // Get dir
                                                                                                   NSString *documentsDirectory = nil;
                                                                                                   NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                                                                                                   documentsDirectory = [paths objectAtIndex:0];
                                                                                                   NSString *pathString = [NSString stringWithFormat:@"%@/%@",documentsDirectory, guideName];
                                                                                                   
                                                                                                   // Save Image
                                                                                                   NSData *imageData = UIImageJPEGRepresentation(image, 90);
                                                                                                   [imageData writeToFile:pathString atomically:YES];
                                                                                                   
                                                                                               } 
                                                                                               failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                                                   NSLog(@"%@", [error localizedDescription]);
                                                                                               }];
        */
        
        
    }

    
}
-(void) OM_Knowledge_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    /*
     
     Content = "Hang moi ";
     Descr = "Mat Hang Moi";
     EndDate = "/Date(1375245120000+0700)/";
     KnowledgeID = 0001;
     StartDate = "/Date(1375245120000+0700)/";
     */
    
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"KnowledgeID"]; // Code
        NSString *str2 = [dict valueForKey:@"Descr"];
        NSString *str3 = [dict valueForKey:@"Content"]; // Code
        NSString *str4 = [self stringDateFromJSONString:[dict valueForKey:@"StartDate"]]; // Code
        NSString *str5 = [self stringDateFromJSONString:[dict valueForKey:@"EndDate"]]; 
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO OM_Knowledge VALUES(?,?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 4, str4.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 5, str5.UTF8String, -1, NULL);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }

}
-(void) IN_InventoryCompetitor_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    /*
     
     BrandIFV = "";
     CompanyID = "";
     CompanyName = "";
     Descr = Lotus;
     InvtID = BA0001;
     StkBasePrc = 0;
     StkQty = 0;
     StkUnit = KG;
     */
    
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"InvtID"]; // Code
        NSString *str2 = [dict valueForKey:@"BrandIFV"];
        NSString *str3 = [dict valueForKey:@"Descr"]; // Code
        NSString *str4 = [dict valueForKey:@"StkUnit"]; // Code
        NSString *str5 = [dict valueForKey:@"StkQty"]; 
        NSString *str6 = [dict valueForKey:@"StkBasePrc"]; // Code
        NSString *str7 = [dict valueForKey:@"CompanyID"];
        NSString *str8 = [dict valueForKey:@"CompanyName"]; // Code


        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO IN_InventoryCompetitor VALUES(?,?,?,?,?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 4, str4.UTF8String, -1, NULL);
            
            sqlite3_bind_double(stmt2, 5, str5.floatValue);
            sqlite3_bind_double(stmt2, 6, str6.floatValue);
            
            sqlite3_bind_text(stmt2, 7, str7.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 8, str8.UTF8String, -1, NULL);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
}
-(void) SI_Tax_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    /*
     CatExcept00 = VAT05;
     CatExcept01 = " ";
     CatExcept02 = " ";
     CatExcept03 = " ";
     CatExcept04 = " ";
     CatExcept05 = " ";
     CatFlg = N;
     IsDel = 0;
     PrcTaxIncl = 0;
     TaxID = IVAT05;
     TaxRate = 5;]
     */
    
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"TaxID"]; // Code
        NSString *str2 = [dict valueForKey:@"TaxRate"];
        NSString *str3 = [dict valueForKey:@"PrcTaxIncl"]; // Code
        NSString *str4 = [dict valueForKey:@"CatFlg"]; // Code
        NSString *str5 = [dict valueForKey:@"CatExcept00"];
        NSString *str6 = [dict valueForKey:@"CatExcept01"]; // Code
        NSString *str7 = [dict valueForKey:@"CatExcept02"];
        NSString *str8 = [dict valueForKey:@"CatExcept03"]; // Code
        NSString *str9 = [dict valueForKey:@"CatExcept04"];
        NSString *str10 = [dict valueForKey:@"CatExcept05"];
        
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO SI_Tax VALUES(?,?,?,?,?,?,?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_double(stmt2, 2, str2.floatValue);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 4, str4.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 5, str5.UTF8String, -1, NULL);
            
            sqlite3_bind_text(stmt2, 6, str6.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 7, str7.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 8, str8.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 9, str9.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 10, str10.UTF8String, -1, NULL);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }

     
     
}
-(void) OM_DiscSeq_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"DiscID"]; // Code
        NSString *str2 = [dict valueForKey:@"DiscSeq"];
        NSString *str3 = [dict valueForKey:@"Active"]; // Code
        NSString *str4 = [dict valueForKey:@"BreakBy"]; // Code
        NSString *str5 = [dict valueForKey:@"BudgetID"];
        NSString *str6 = [dict valueForKey:@"Descr"]; // Code
        NSString *str7 = [dict valueForKey:@"DiscClass"];
        NSString *str8 = [dict valueForKey:@"DiscFor"]; // Code
        NSString *str9 = [self stringDateFromJSONString:[dict valueForKey:@"EndDate"]];
        
        NSString *str10 = [dict valueForKey:@"FreeItemBudgetID"];
        NSString *str11 = [dict valueForKey:@"FreeItemID"];
        NSString *str12 = [dict valueForKey:@"FreeItemUOM"]; // Code
        NSString *str13 = [dict valueForKey:@"FreeItemRate"];
        NSString *str14 = [dict valueForKey:@"FreeItemSiteID"]; // Code
        NSString *str15 = [dict valueForKey:@"FreeItemWhseLoc"]; // Code
        NSString *str16 = [dict valueForKey:@"Promo"];
        NSString *str17 = [self stringDateFromJSONString:[dict valueForKey:@"StartDate"]]; // Code
        NSString *str18 = [dict valueForKey:@"ProAplForItem"];
        NSString *str19 = [dict valueForKey:@"AutoFreeItem"]; // Code
        NSString *str20 = [dict valueForKey:@"AllowEditDisc"];
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO OM_DiscSeq VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            
            sqlite3_bind_int(stmt2, 3, str3.intValue);
            
            sqlite3_bind_text(stmt2, 4, str4.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 5, str5.UTF8String, -1, NULL);
            
            sqlite3_bind_text(stmt2, 6, str6.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 7, str7.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 8, str8.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 9, str9.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 10, str10.UTF8String, -1, NULL);
            
            sqlite3_bind_text(stmt2, 11, str11.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 12, str12.UTF8String, -1, NULL);
            
            sqlite3_bind_double(stmt2, 13, str13.floatValue);
            
            sqlite3_bind_text(stmt2, 14, str14.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 15, str15.UTF8String, -1, NULL);
            
            sqlite3_bind_int(stmt2, 16, str16.intValue);
            
            sqlite3_bind_text(stmt2, 17, str17.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 18, str18.UTF8String, -1, NULL);
            
            sqlite3_bind_int(stmt2, 19, str19.intValue);
            sqlite3_bind_int(stmt2, 20, str20.intValue);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
}
-(void) AR_Doc_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"BatNbr"]; // Code
        NSString *str2 = [dict valueForKey:@"RefNbr"];
        NSString *str3 = [dict valueForKey:@"OrdNbr"]; // Code
        NSString *str4 = [dict valueForKey:@"DocBal"]; // Code
        NSString *str5 = [dict valueForKey:@"AdjAmt"];
        NSString *str6 = [dict valueForKey:@"OrigDocAmt"]; // Code
        NSString *str7 = [dict valueForKey:@"CustID"];
        NSString *str8 = [dict valueForKey:@"InvcNbr"]; // Code
        NSString *str9 = [dict valueForKey:@"SlsperID"]; 
        
        NSString *str10 = [self stringDateFromJSONString:[dict valueForKey:@"DocDate"]];
        
        NSString *str11 = [dict valueForKey:@"SyncStatus"];
        NSString *str12 = [self stringDateFromJSONString:[dict valueForKey:@"Crtd_DateTime"]];
        NSString *str13 = [self stringDateFromJSONString:[dict valueForKey:@"LUpd_DateTime"]];
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO AR_Doc VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
            
            sqlite3_bind_double(stmt2, 4, str4.floatValue);
            sqlite3_bind_double(stmt2, 5, str5.floatValue);
            sqlite3_bind_double(stmt2, 6, str6.floatValue);
            
            sqlite3_bind_text(stmt2, 7, str7.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 8, str8.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 9, str9.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 10, str10.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt2, 11, str11.intValue);
            
            sqlite3_bind_text(stmt2, 12, str12.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 13, str13.UTF8String, -1, NULL);
            
            
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
}
-(void) OM_DiscItem_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"DiscID"]; // Code
        NSString *str2 = [dict valueForKey:@"DiscSeq"];
        NSString *str3 = [dict valueForKey:@"InvtID"]; // Code
        NSString *str4 = [dict valueForKey:@"Active"]; // Code
        NSString *str5 = [dict valueForKey:@"BundleAmt"];
        NSString *str6 = [dict valueForKey:@"BundleNbr"]; // Code
        NSString *str7 = [dict valueForKey:@"BundleOrItem"];
        NSString *str8 = [dict valueForKey:@"BundleQty"];
        NSString *str9 = [dict valueForKey:@"DiscType"]; // Code
        NSString *str10 = [dict valueForKey:@"UnitDesc"];

        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO OM_DiscItem VALUES(?,?,?,?,?,?,?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
            
            sqlite3_bind_int(stmt2, 4, str4.intValue);
            sqlite3_bind_double(stmt2, 5, str5.floatValue);
            sqlite3_bind_int(stmt2, 6, str6.intValue);
            
            sqlite3_bind_text(stmt2, 7, str7.UTF8String, -1, NULL);
            sqlite3_bind_double(stmt2, 8, str8.floatValue);
            sqlite3_bind_text(stmt2, 9, str9.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 10, str10.UTF8String, -1, NULL);
            
            
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
}
-(void) OM_IssueType_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    /*
     Code = 01;
     Descr = "X\U1eed L\U00fd K\U1ef9 Thu\U1eadt";

     */
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"Code"]; // Code
        NSString *str2 = [dict valueForKey:@"Descr"];
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO OM_IssueType VALUES(?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }

    
}
-(void) SYS_Company_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"CpnyID"]; // Code
        NSString *str2 = [dict valueForKey:@"CpnyName"];
        NSString *str3 = [dict valueForKey:@"Territory"]; // Code
        NSString *str4 = [dict valueForKey:@"Address"];
        NSString *str5 = [dict valueForKey:@"Tel"]; // Code
        NSString *str6 = [dict valueForKey:@"Fax"];
        NSString *str7 = [dict valueForKey:@"ClassID"]; // Code
        NSString *str8 = [dict valueForKey:@"Descr"];
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO SYS_Company VALUES(?,?,?,?,?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 4, str4.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 5, str5.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 6, str6.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 7, str7.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 8, str8.UTF8String, -1, NULL);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
}
-(void) SI_State_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    /*
     Country = VN;
     Descr = "TP H\U00e0 N\U1ed9i";
     State = 01;
     Territory = Z11;
     */
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"Country"]; // Code
        NSString *str2 = [dict valueForKey:@"State"];
        NSString *str3 = [dict valueForKey:@"Descr"]; // Code
        NSString *str4 = [dict valueForKey:@"Territory"];
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO SI_State VALUES(?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 4, str4.UTF8String, -1, NULL);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
    
}
-(void) SI_Ward_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"State"]; // Code
        NSString *str2 = [dict valueForKey:@"District"];
        NSString *str3 = [dict valueForKey:@"Ward"]; // Code
        NSString *str4 = [dict valueForKey:@"Descr"];
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO SI_Ward VALUES(?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 4, str4.UTF8String, -1, NULL);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
}
-(void) SI_City_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    /*
     City = HN;
     Name = "TP H\U00e0 N\U1ed9i";
     State = 01;
     */
    
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"State"]; // Code
        NSString *str2 = [dict valueForKey:@"City"];
        NSString *str3 = [dict valueForKey:@"Name"]; // Code
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO SI_City VALUES(?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
}
-(void) OM_Setup_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    /*
     DetDiscG1App = 0;
     DetDiscG1C1 = "";
     DetDiscG1C2 = "";
     DetDiscG2App = 0;
     DetDiscG2C1 = "";
     DetDiscG2C2 = "";
     DetDiscG3App = 0;
     DetDiscG3C1 = "";
     DetDiscG3C2 = "";
     DetDiscG4App = 0;
     DetDiscG4C1 = "";
     DetDiscG4C2 = "";
     DetDiscG5App = 0;
     DetDiscG5C1 = "";
     DetDiscG5C2 = "";
     DetDiscG6App = 0;
     DetDiscG6C1 = "";
     DetDiscG6C2 = "";
     DocDiscG1App = 0;
     DocDiscG1C1 = "";
     DocDiscG1C2 = "";
     DocDiscG2App = 0;
     DocDiscG2C1 = "";
     DocDiscG2C2 = "";
     DocDiscG3App = 0;
     DocDiscG3C1 = "";
     DocDiscG3C2 = "";
     DocDiscG4App = 0;
     DocDiscG4C1 = "";
     DocDiscG4C2 = "";
     DocDiscG5App = 0;
     DocDiscG5C1 = "";
     DocDiscG5C2 = "";
     DocDiscG6App = 0;
     DocDiscG6C1 = "";
     DocDiscG6C2 = "";
     
     GroupDiscG10App = 0;
     GroupDiscG10C1 = "";
     GroupDiscG10C2 = "";
     GroupDiscG11App = 0;
     GroupDiscG11C1 = "";
     GroupDiscG11C2 = "";
     GroupDiscG12App = 0;
     GroupDiscG12C1 = "";
     GroupDiscG12C2 = "";
     GroupDiscG1App = 0;
     GroupDiscG1C1 = "";
     GroupDiscG1C2 = "";
     GroupDiscG2App = 0;
     GroupDiscG2C1 = "";
     GroupDiscG2C2 = "";
     GroupDiscG3App = 0;
     GroupDiscG3C1 = "";
     GroupDiscG3C2 = "";
     GroupDiscG4App = 0;
     GroupDiscG4C1 = "";
     GroupDiscG4C2 = "";
     GroupDiscG5App = 0;
     GroupDiscG5C1 = "";
     GroupDiscG5C2 = "";
     GroupDiscG6App = 0;
     GroupDiscG6C1 = "";
     GroupDiscG6C2 = "";
     GroupDiscG7App = 0;
     GroupDiscG7C1 = "";
     GroupDiscG7C2 = "";
     GroupDiscG8App = 0;
     GroupDiscG8C1 = "";
     GroupDiscG8C2 = "";
     GroupDiscG9App = 0;
     GroupDiscG9C1 = "";
     GroupDiscG9C2 = "";
     ProrateDisc = 0;
     SetupID = OM;
     */
    
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"SetupID"]; // Code
        NSString *str2 = [dict valueForKey:@"DetDiscG1App"];
        NSString *str3 = [dict valueForKey:@"DetDiscG1C1"]; // Code
        NSString *str4 = [dict valueForKey:@"DetDiscG1C2"]; // Code
        NSString *str5 = [dict valueForKey:@"DetDiscG2App"];
        NSString *str6 = [dict valueForKey:@"DetDiscG2C1"]; // Code
        NSString *str7 = [dict valueForKey:@"DetDiscG2C2"]; // Code
        NSString *str8 = [dict valueForKey:@"DetDiscG3App"];
        NSString *str9 = [dict valueForKey:@"DetDiscG3C1"]; // Code
        NSString *str10 = [dict valueForKey:@"DetDiscG3C2"];
        
        NSString *str11 = [dict valueForKey:@"DetDiscG4App"]; // Code
        NSString *str12 = [dict valueForKey:@"DetDiscG4C1"];
        NSString *str13 = [dict valueForKey:@"DetDiscG4C2"]; // Code
        NSString *str14 = [dict valueForKey:@"DetDiscG5App"]; // Code
        NSString *str15 = [dict valueForKey:@"DetDiscG5C1"];
        NSString *str16 = [dict valueForKey:@"DetDiscG5C2"]; // Code
        NSString *str17 = [dict valueForKey:@"DetDiscG6App"]; // Code
        NSString *str18 = [dict valueForKey:@"DetDiscG6C1"];
        NSString *str19 = [dict valueForKey:@"DetDiscG6C2"]; // Code
        
        NSString *str20 = [dict valueForKey:@"DocDiscG1App"];
        
        NSString *str21 = [dict valueForKey:@"DocDiscG1C1"]; // Code
        NSString *str22 = [dict valueForKey:@"DocDiscG1C2"];
        NSString *str23 = [dict valueForKey:@"DocDiscG2App"]; // Code
        NSString *str24 = [dict valueForKey:@"DocDiscG2C1"]; // Code
        NSString *str25 = [dict valueForKey:@"DocDiscG2C2"];
        NSString *str26 = [dict valueForKey:@"DocDiscG3App"]; // Code
        NSString *str27 = [dict valueForKey:@"DocDiscG3C1"]; // Code
        NSString *str28 = [dict valueForKey:@"DocDiscG3C2"];
        NSString *str29 = [dict valueForKey:@"DocDiscG4App"]; // Code
        NSString *str30 = [dict valueForKey:@"DocDiscG4C1"];
        
        NSString *str31 = [dict valueForKey:@"DocDiscG4C2"]; // Code
        NSString *str32 = [dict valueForKey:@"DocDiscG5App"];
        NSString *str33 = [dict valueForKey:@"DocDiscG5C1"]; // Code
        NSString *str34 = [dict valueForKey:@"DocDiscG5C2"]; // Code
        NSString *str35 = [dict valueForKey:@"DocDiscG6App"];
        NSString *str36 = [dict valueForKey:@"DocDiscG6C1"]; // Code
        NSString *str37 = [dict valueForKey:@"DocDiscG6C2"]; // Code
        
        
        NSString *str38 = [dict valueForKey:@"GroupDiscG10App"];
        NSString *str39 = [dict valueForKey:@"GroupDiscG10C1"]; // Code
        NSString *str40 = [dict valueForKey:@"GroupDiscG10C2"];
        
        NSString *str41 = [dict valueForKey:@"GroupDiscG11App"]; // Code
        NSString *str42 = [dict valueForKey:@"GroupDiscG11C1"];
        NSString *str43 = [dict valueForKey:@"GroupDiscG11C2"]; // Code
        NSString *str44 = [dict valueForKey:@"GroupDiscG12App"]; // Code
        NSString *str45 = [dict valueForKey:@"GroupDiscG12C1"];
        NSString *str46 = [dict valueForKey:@"GroupDiscG12C2"]; // Code
        NSString *str47 = [dict valueForKey:@"GroupDiscG1App"]; // Code
        NSString *str48 = [dict valueForKey:@"GroupDiscG1C1"];
        NSString *str49 = [dict valueForKey:@"GroupDiscG1C2"]; // Code
        NSString *str50 = [dict valueForKey:@"GroupDiscG2App"];
        
        NSString *str51 = [dict valueForKey:@"GroupDiscG2C1"]; // Code
        NSString *str52 = [dict valueForKey:@"GroupDiscG2C2"];
        NSString *str53 = [dict valueForKey:@"GroupDiscG3App"]; // Code
        NSString *str54 = [dict valueForKey:@"GroupDiscG3C1"]; // Code
        NSString *str55 = [dict valueForKey:@"GroupDiscG3C2"];
        NSString *str56 = [dict valueForKey:@"GroupDiscG4App"]; // Code
        NSString *str57 = [dict valueForKey:@"GroupDiscG4C1"]; // Code
        NSString *str58 = [dict valueForKey:@"GroupDiscG4C2"];
        NSString *str59 = [dict valueForKey:@"GroupDiscG5App"]; // Code
        NSString *str60 = [dict valueForKey:@"GroupDiscG5C1"];
        
        NSString *str61 = [dict valueForKey:@"GroupDiscG5C2"]; // Code
        NSString *str62 = [dict valueForKey:@"GroupDiscG6App"];
        NSString *str63 = [dict valueForKey:@"GroupDiscG6C1"]; // Code
        NSString *str64 = [dict valueForKey:@"GroupDiscG6C2"]; // Code
        NSString *str65 = [dict valueForKey:@"GroupDiscG7App"];
        NSString *str66 = [dict valueForKey:@"GroupDiscG7C1"]; // Code
        NSString *str67 = [dict valueForKey:@"GroupDiscG7C2"]; // Code
        NSString *str68 = [dict valueForKey:@"GroupDiscG8App"];
        NSString *str69 = [dict valueForKey:@"GroupDiscG8C1"]; // Code
        NSString *str70 = [dict valueForKey:@"GroupDiscG8C2"];
        
        NSString *str71 = [dict valueForKey:@"GroupDiscG9App"]; // Code
        NSString *str72 = [dict valueForKey:@"GroupDiscG9C1"];
        NSString *str73 = [dict valueForKey:@"GroupDiscG9C2"]; // Code
        NSString *str74 = [dict valueForKey:@"ProrateDisc"];
        
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO OM_Setup VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            
            sqlite3_bind_int(stmt2, 2, str2.intValue);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 4, str4.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt2, 5, str5.intValue);
            sqlite3_bind_text(stmt2, 6, str6.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 7, str7.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt2, 8, str8.intValue);
            sqlite3_bind_text(stmt2, 9, str9.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 10, str10.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt2, 11, str11.intValue);
            sqlite3_bind_text(stmt2, 12, str12.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 13, str13.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt2, 14, str14.intValue);
            sqlite3_bind_text(stmt2, 15, str15.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 16, str16.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt2, 17, str17.intValue);
            sqlite3_bind_text(stmt2, 18, str18.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 19, str19.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt2, 20, str20.intValue);
            sqlite3_bind_text(stmt2, 21, str21.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 22, str22.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt2, 23, str23.intValue);
            sqlite3_bind_text(stmt2, 24, str24.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 25, str25.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt2, 26, str26.intValue);
            sqlite3_bind_text(stmt2, 27, str27.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 28, str28.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt2, 29, str29.intValue);
            sqlite3_bind_text(stmt2, 30, str30.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 31, str31.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt2, 32, str32.intValue);
            sqlite3_bind_text(stmt2, 33, str33.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 34, str34.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt2, 35, str35.intValue);
            sqlite3_bind_text(stmt2, 36, str36.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 37, str37.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt2, 38, str38.intValue);
            sqlite3_bind_text(stmt2, 39, str39.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 40, str40.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt2, 41, str41.intValue);
            sqlite3_bind_text(stmt2, 42, str42.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 43, str43.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt2, 44, str44.intValue);
            sqlite3_bind_text(stmt2, 45, str45.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 46, str46.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt2, 47, str47.intValue);
            sqlite3_bind_text(stmt2, 48, str48.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 49, str49.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt2, 50, str50.intValue);
            sqlite3_bind_text(stmt2, 51, str51.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 52, str52.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt2, 53, str53.intValue);
            sqlite3_bind_text(stmt2, 54, str54.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 55, str55.UTF8String, -1, NULL);
            
            sqlite3_bind_int(stmt2, 56, str56.intValue);
            sqlite3_bind_text(stmt2, 57, str57.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 58, str58.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt2, 59, str59.intValue);
            sqlite3_bind_text(stmt2, 60, str60.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 61, str61.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt2, 62, str62.intValue);
            sqlite3_bind_text(stmt2, 63, str63.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 64, str64.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt2, 65, str65.intValue);
            sqlite3_bind_text(stmt2, 66, str66.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 67, str67.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt2, 68, str68.intValue);
            sqlite3_bind_text(stmt2, 69, str69.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 70, str70.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt2, 71, str71.intValue);
            sqlite3_bind_text(stmt2, 72, str72.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 73, str73.UTF8String, -1, NULL);
            
            sqlite3_bind_int(stmt2, 74, str74.intValue);

            
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
}
-(void) AR_Channel_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    /*
     Code = EXP;
     Descr = Export;
     */
    
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"Code"]; // Code
        NSString *str2 = [dict valueForKey:@"Descr"];
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO AR_Channel VALUES(?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
    
}
-(void) SI_District_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    /*
     
     District = 0101;
     Name = "Qu\U1eadn Ba \U0110\U00ecnh";
     State = 01;
     */
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"State"]; // Code
        NSString *str2 = [dict valueForKey:@"District"];
        NSString *str3 = [dict valueForKey:@"Name"];
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO SI_District VALUES(?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
    
}
-(void) AR_CustomerLocation_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"CustID"]; // Code
        NSString *str2 = [dict valueForKey:@"BranchID"];
        NSString *str3 = [dict valueForKey:@"Lat"];
        NSString *str4 = [dict valueForKey:@"Lng"];
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO AR_CustomerLocation VALUES(?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_double(stmt2, 3, str3.floatValue);
            sqlite3_bind_double(stmt2, 4, str4.floatValue);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
}
-(void) AR_ShopType_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    /*
     Code = 01;
     Descr = FeedMill;
     */
    
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"Code"]; // Code
        NSString *str2 = [dict valueForKey:@"Descr"];
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO AR_ShopType VALUES(?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
}
-(void) RPT_MonthlySales_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    /*
     CallNum = 0;
     DiscAmt = 0;
     MustCustVisit = 0;
     OrdAmt = 0;
     OrderNum = 0;
     Quantity = 0;
     SKUNum = 0;
     TargetQuantity = 0;
     */
    
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"CallNum"]; // Code
        NSString *str2 = [dict valueForKey:@"OrderNum"];
        NSString *str3 = [dict valueForKey:@"SKUNum"]; // Code
        NSString *str4 = [dict valueForKey:@"OrderNum"];
        NSString *str5 = [dict valueForKey:@"DiscAmt"]; // Code
        NSString *str6 = [dict valueForKey:@"TargetQuantity"];
        NSString *str7 = [dict valueForKey:@"Quantity"]; // Code
        NSString *str8 = [dict valueForKey:@"MustCustVisit"];
        
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO RPT_MonthlySales VALUES(?,?,?,?,?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_double(stmt2, 1, str1.floatValue);
            sqlite3_bind_double(stmt2, 2, str2.floatValue);
            sqlite3_bind_double(stmt2, 3, str3.floatValue);
            sqlite3_bind_double(stmt2, 4, str4.floatValue);
            sqlite3_bind_double(stmt2, 5, str5.floatValue);
            sqlite3_bind_double(stmt2, 6, str6.floatValue);
            sqlite3_bind_double(stmt2, 7, str7.floatValue);
            sqlite3_bind_double(stmt2, 8, str8.floatValue);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
}
-(void) OM_SalesRouteDet_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"SalesRouteID"]; // Code
        NSString *str2 = [self stringDateFromJSONString:[dict valueForKey:@"VisitDate"]];
        NSString *str3 = [dict valueForKey:@"CustID"]; // Code
        NSString *str4 = [dict valueForKey:@"VisitSort"];
        NSString *str5 = [dict valueForKey:@"OrigVisitSort"]; // Cod
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO OM_SalesRouteDet VALUES(?,?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt2, 4, str4.intValue);
            sqlite3_bind_int(stmt2, 5, str5.intValue);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
}
-(void) OM_DiscDescr_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"DiscCode"]; // Code
        NSString *str2 = [dict valueForKey:@"Descr"]; 
        NSString *str3 = [dict valueForKey:@"SiteID"]; // Code
        NSString *str4 = [dict valueForKey:@"WhseLoc"];
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO OM_DiscDescr VALUES(?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 4, str4.UTF8String, -1, NULL);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
}
-(void) OM_DiscCust_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"DiscID"]; // Code
        NSString *str2 = [dict valueForKey:@"DiscSeq"];
        NSString *str3 = [dict valueForKey:@"CustID"]; // Code
        
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO OM_DiscCust VALUES(?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
}
-(void) Setting_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
 
    /*
     table =     (
     {
     BusinessDate = "2013/09/19";
     CpnyName = "Hua Kim Duc";
     MMSync = 0;
     NewCustID = 0000;
     StorePicReq = 0;
     SysDate = "2013-09-19 07:42:21";
     SysDown = 0;
     }
     );
     }
     
     */
    NSArray *arr = [rootTable objectForKey:@"Table"];
    NSDictionary *dict = [arr lastObject];
    
    NSString *businnessDay = [dict valueForKey:@"BusinessDate"]; // Code
    NSString *CpnyName = [dict valueForKey:@"CpnyName"];
    NSString *NewCustID = [dict valueForKey:@"NewCustID"]; // Code
    NSString *StorePicReq = [dict valueForKey:@"StorePicReq"]; // Code
    NSString *DeliveryMan = [dict valueForKey:@"DeliveryMan"];
    //NSString *SysDate = [dict valueForKey:@"SysDate"];
    //NSString *SysDown = [dict valueForKey:@"SysDown"]; // Code
    
    
    sqlite3_stmt *stmt2;
    NSString *query = @"UPDATE Setting SET BusinessDate = ? , CpnyName = ? , NewCustID = ? , StorePicReq = ? , DeliveryMan = ? WHERE SetupID = 'eBiz'";
    
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
    {
        sqlite3_bind_text(stmt2, 1, businnessDay.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt2, 2, CpnyName.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt2, 3, NewCustID.UTF8String, -1, NULL);
        sqlite3_bind_int(stmt2, 4, StorePicReq.intValue);
        sqlite3_bind_text(stmt2, 5, DeliveryMan.UTF8String, -1, NULL);
    }
    if (sqlite3_step(stmt2) != SQLITE_DONE)
    {
        NSLog(@"Error Saving at table %@",tableName);
        NSLog(@"error: %s\n",sqlite3_errmsg(db));
    }
    sqlite3_finalize(stmt2);
    
    
}
-(void) OM_PriceClass_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    /*
     Descr = Default;
     IsDel = 0;
     PriceClassID = MD;
     PriceClassType = C;
     */
    
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"PriceClassID"]; // Code
        NSString *str2 = [dict valueForKey:@"PriceClassType"];
        NSString *str3 = [dict valueForKey:@"Descr"]; // Code
        
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO OM_PriceClass VALUES(?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }

}
-(void) AR_Customer_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"CustID"]; // Code
        NSString *str2 = [dict valueForKey:@"CustName"];
        NSString *str3 = [dict valueForKey:@"Address"]; // Code
        NSString *str4 = [dict valueForKey:@"PriceClassID"]; // Code
        NSString *str5 = [dict valueForKey:@"TaxID00"];
        NSString *str6 = [dict valueForKey:@"TaxID01"]; // Code
        
        NSString *str7 = [dict valueForKey:@"TaxID02"]; // Code
        NSString *str8 = [dict valueForKey:@"TaxID03"];
        NSString *str9 = [dict valueForKey:@"ClassID"]; // Code
        NSString *str10 = [dict valueForKey:@"CrLmt"]; // Code
        NSString *str11 = [dict valueForKey:@"CustNameSearch"];
        NSString *str12 = [dict valueForKey:@"AddressSearch"]; // Code
        
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO AR_Customer VALUES(?,?,?,?,?,?,?,?,?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 4, str4.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 5, str5.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 6, str6.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 7, str7.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 8, str8.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 9, str9.UTF8String, -1, NULL);
            
            sqlite3_bind_double(stmt2, 10, str10.floatValue);
            sqlite3_bind_text(stmt2, 11, str11.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 12, str12.UTF8String, -1, NULL);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }

}
-(void) AR_Area_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    /*
     Area = Z11;
     Descr = North;
     
     */
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"Area"]; // Code
        NSString *str2 = [dict valueForKey:@"Descr"];
            
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO AR_Area VALUES(?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
}
-(void) OM_SalesRoute_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"SalesRouteID"]; // Code
        NSString *str2 = [dict valueForKey:@"Descr"];
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO OM_SalesRoute VALUES(?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
}
-(void) SI_Hierarchy_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    /*
     Descr = "IFV Product";
     NodeID = 00;
     NodeLevel = 2;
     ParentRecordID = 2;
     RecordID = 3;
     Type = I;
     */
    
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"NodeID"]; // Code
        NSString *str2 = [dict valueForKey:@"NodeLevel"];
        NSString *str3 = [dict valueForKey:@"Type"]; // Code
        NSString *str4 = [dict valueForKey:@"ParentRecordID"]; // Code
        NSString *str5 = [dict valueForKey:@"Descr"];
        NSString *str6 = [dict valueForKey:@"RecordID"]; // Code
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO SI_Hierarchy VALUES(?,?,?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt2, 2, str2.intValue);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt2, 4, str4.intValue);
            sqlite3_bind_text(stmt2, 5, str5.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt2, 6, str6.intValue);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
    
    
}
-(void) OM_DiscBreak_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"DiscID"]; // Code
        NSString *str2 = [dict valueForKey:@"DiscSeq"];
        NSString *str3 = [dict valueForKey:@"LineRef"]; // Code
        NSString *str4 = [dict valueForKey:@"BreakAmt"]; // Code
        NSString *str5 = [dict valueForKey:@"BreakQty"];
        NSString *str6 = [dict valueForKey:@"DiscAmt"]; // Code
        NSString *str7 = [dict valueForKey:@"UOM"]; // Code
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO OM_DiscBreak VALUES(?,?,?,?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
            
            sqlite3_bind_double(stmt2, 4, str4.doubleValue);
            sqlite3_bind_double(stmt2, 5, str5.doubleValue);
            sqlite3_bind_double(stmt2, 6, str6.doubleValue);
            
            sqlite3_bind_text(stmt2, 7, str7.UTF8String, -1, NULL);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
}
-(void) OM_DiscCustClass_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"DiscID"]; // Code
        NSString *str2 = [dict valueForKey:@"DiscSeq"];
        NSString *str3 = [dict valueForKey:@"ClassID"];
        
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO OM_DiscCustClass VALUES(?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
}
-(void) OM_PPBudget_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"BudgetID"]; // Code
        NSString *str2 = [dict valueForKey:@"Active"];
        NSString *str3 = [dict valueForKey:@"ApplyTo"];
        NSString *str4 = [dict valueForKey:@"Descr"]; // Code
        NSString *str5 = [dict valueForKey:@"FreeItemID"];
        NSString *str6 = [self stringDateFromJSONString:[dict valueForKey:@"RvsdDate"]];
        NSString *str7 = [dict valueForKey:@"QtyAmtAlloc"]; // Code
        NSString *str8 = [dict valueForKey:@"QtyAmtFree"];
        NSString *str9 = [dict valueForKey:@"QtyAmtTotal"];
        NSString *str10 = [dict valueForKey:@"UnitDesc"];
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO OM_PPBudget VALUES(?,?,?,?,?,?,?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt2, 2, str2.intValue);
            
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 4, str4.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 5, str5.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 6, str6.UTF8String, -1, NULL);
            
            sqlite3_bind_double(stmt2, 7, str7.doubleValue);
            sqlite3_bind_double(stmt2, 8, str8.doubleValue);
            sqlite3_bind_double(stmt2, 9, str9.doubleValue);
            
            sqlite3_bind_text(stmt2, 10, str10.UTF8String, -1, NULL);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
}
-(void) PPC_SuggestOrder_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"CustID"]; // Code
        NSString *str2 = [dict valueForKey:@"InvtID"];
        NSString *str3 = [dict valueForKey:@"LineQty"];
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO PPC_SuggestOrder VALUES(?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt2, 2, str2.intValue);
            sqlite3_bind_double(stmt2, 3, str3.doubleValue);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
}
-(void) AR_CustClass_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"ClassId"]; // Code
        NSString *str2 = [dict valueForKey:@"Channel"];
        NSString *str3 = [dict valueForKey:@"Descr"];
        NSString *str4 = [dict valueForKey:@"PriceClass"];
        
        
        NSLog(@"insert into AR_CustCass Values(%@,%@,%@,%@)",str1,str2,str3,str4);
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO AR_CustClass VALUES(?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 4, str4.UTF8String, -1, NULL);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
}
-(void) PPC_ARCustomerInfo_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    /*
     Addr1 = "69 Huynh Thuc Khang, TP Hue, tinh Thua Thien Hue";
     Addr11 = "";
     Addr2 = "";
     Addr21 = "";
     Addr3 = "";
     Addr31 = "";
     AddrCpny = "";
     Area = "";
     AreaName = "";
     BankAccount = "";
     Channel = GM;
     ChannelName = GM;
     City = HCM;
     CityName = "TP H\U1ed3 Ch\U00ed Minh";
     ClassId = 01;
     ClassIdName = Distribution;
     ContactName = "Tin Phuong";
     ContactName1 = "";
     ContactName2 = "";
     ContactName3 = "";
     CpnyName = "";
     CustID = FG0029;
     CustName = "Tin Phuong";
     DOB1 = "/Date(-2209014000000+0700)/";
     DOB2 = "/Date(-2209014000000+0700)/";
     DOB3 = "/Date(-2209014000000+0700)/";
     DateCpny = "/Date(-2209014000000+0700)/";
     District = "";
     DistrictName = "";
     Email = "";
     Email1 = "";
     Email2 = "";
     Email3 = "";
     Fax = "";
     Lat = 0;
     Lng = 0;
     Mobile = "";
     Owner = "";
     Phone = "";
     Phone1 = "";
     Phone2 = "";
     Phone3 = "";
     PhotoCode = "";
     ShopType = 02;
     ShopTypeName = Distributor;
     State = "";
     StateName = "";
     Territory = F;
     TerritoryName = "";
     TradeType = T;
     TradeTypeName = Trade;
     Ward = "";
     WardName = "";
     */
    
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"CustID"]; // Code
        NSString *str2 = [dict valueForKey:@"CustName"];
        NSString *str3 = [dict valueForKey:@"ContactName"];
        NSString *str4 = [dict valueForKey:@"Phone"];
        NSString *str5 = [dict valueForKey:@"Mobile"]; // Code
        NSString *str6 = [dict valueForKey:@"Fax"];
        NSString *str7 = [dict valueForKey:@"Email"];
        NSString *str8 = [dict valueForKey:@"Addr1"];
        NSString *str9 = [dict valueForKey:@"Addr2"]; // Code
        NSString *str10 = [dict valueForKey:@"Addr3"];
        NSString *str11 = [dict valueForKey:@"State"];
        NSString *str12 = [dict valueForKey:@"StateName"];
        NSString *str13 = [dict valueForKey:@"City"]; // Code
        NSString *str14 = [dict valueForKey:@"CityName"];
        NSString *str15 = [dict valueForKey:@"District"];
        NSString *str16 = [dict valueForKey:@"DistrictName"];
        NSString *str17 = [dict valueForKey:@"Ward"]; // Code
        NSString *str18 = [dict valueForKey:@"WardName"];
        NSString *str19 = [dict valueForKey:@"Channel"];
        NSString *str20 = [dict valueForKey:@"ChannelName"];
        NSString *str21 = [dict valueForKey:@"ClassId"]; // Code
        NSString *str22 = [dict valueForKey:@"ClassIdName"];
        if ([str22 isKindOfClass:[NSNull class
                                  ]])
            str22 = @"";
        
        NSString *str23 = [dict valueForKey:@"Area"];
        NSString *str24 = [dict valueForKey:@"AreaName"];
        
        NSString *str25 = [dict valueForKey:@"Territory"]; // Code
        NSString *str26 = [dict valueForKey:@"TerritoryName"];
        NSString *str27 = [dict valueForKey:@"ShopType"];
        NSString *str28 = [dict valueForKey:@"ShopTypeName"];
        NSString *str29 = [dict valueForKey:@"TradeType"]; // Code
        NSString *str30 = [dict valueForKey:@"TradeTypeName"];
        NSString *str31 = [dict valueForKey:@"PhotoCode"];
        NSString *str32 = [dict valueForKey:@"PriceClassID"];//PriceClassID
        

        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO PPC_ARCustomerInfo VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 4, str4.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 5, str5.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 6, str6.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 7, str7.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 8, str8.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 9, str9.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 10, str10.UTF8String, -1, NULL);
            
            sqlite3_bind_text(stmt2, 11, str11.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 12, str12.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 13, str13.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 14, str14.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 15, str15.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 16, str16.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 17, str17.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 18, str18.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 19, str19.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 20, str20.UTF8String, -1, NULL);
            
            sqlite3_bind_text(stmt2, 21, str21.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 22, str22.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 23, str23.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 24, str24.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 25, str25.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 26, str26.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 27, str27.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 28, str28.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 29, str29.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 30, str30.UTF8String, -1, NULL);
            
            sqlite3_bind_text(stmt2, 31, str31.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 32, str32.UTF8String, -1, NULL);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
        
        // Download Photo Customer to Document
        
        NSString *stringPhotoCode = str31;
        
        if (stringPhotoCode && ![stringPhotoCode isEqualToString:@""])
        {
            // Picture 1
            NSString *photourl = [NSString stringWithFormat:@"%@%@",kURLPhoto,stringPhotoCode];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:photourl]];
            
            AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request success:^(UIImage *image)
                                                  {
                                                      NSLog(@"download file  %@",stringPhotoCode);
                                                      
                                                      // Get dir
                                                      NSString *documentsDirectory = nil;
                                                      NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                                                      documentsDirectory = [paths objectAtIndex:0];
                                                      
                                                      NSString *pathString = [NSString stringWithFormat:@"%@/%@",documentsDirectory, stringPhotoCode];
                                                      
                                                      // Save Image
                                                      NSData *imageData = UIImagePNGRepresentation(image);
                                                      NSError *err;
                                                      [imageData writeToFile:pathString options:NSDataWritingAtomic error:&err];
                                                      
                                                      if (err)
                                                          NSLog(@"Error download");
                                                      
                                                  }];
            [operation start];
        }

    }
}
-(void) OM_DiscFreeItem_WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"DiscID"]; // Code
        NSString *str2 = [dict valueForKey:@"DiscSeq"];
        NSString *str3 = [dict valueForKey:@"LineRef"];
        NSString *str4 = [dict valueForKey:@"FreeItemBudgetID"]; // Code
        NSString *str5 = [dict valueForKey:@"FreeItemID"];
        NSString *str6 = [dict valueForKey:@"FreeItemQty"];
        NSString *str7 = [dict valueForKey:@"FreeItemUOM"]; // Code
        NSString *str8 = [dict valueForKey:@"FreeItemRate"];
        NSString *str9 = [dict valueForKey:@"FreeItemSiteID"];
        NSString *str10 = [dict valueForKey:@"FreeItemWhseLoc"];
        NSString *str11 = [dict valueForKey:@"BreakBy"]; // Code
        NSString *str12 = [dict valueForKey:@"DiscFor"];
        NSString *str13 = [dict valueForKey:@"BudgetID"];
        NSString *str14 = [dict valueForKey:@"Descr"];
        
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO OM_DiscFreeItem VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 4, str4.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 5, str5.UTF8String, -1, NULL);
            
            sqlite3_bind_double(stmt2, 6, str6.doubleValue);
            sqlite3_bind_text(stmt2, 7, str7.UTF8String, -1, NULL);
            sqlite3_bind_double(stmt2, 8, str8.doubleValue);
            
            sqlite3_bind_text(stmt2, 9, str9.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 10, str10.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 11, str11.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 12, str12.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 13, str13.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 14, str14.UTF8String, -1, NULL);
            
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
}
-(void) OM_PPAlloc__WithJSON:(NSDictionary *) rootTable tableName:(NSString *) tableName
{
    NSArray *arr = [rootTable objectForKey:@"Table"];
    for (NSDictionary *dict in arr)
    {
        NSString *str1 = [dict valueForKey:@"BudgetID"]; // Code
        NSString *str2 = [dict valueForKey:@"ApplyTo"];
        NSString *str3 = [dict valueForKey:@"FreeItemID"];
        NSString *str4 = [dict valueForKey:@"QtyAmtAlloc"]; // Code
        NSString *str5 = [dict valueForKey:@"QtyAmtAvail"];
        NSString *str6 = [dict valueForKey:@"QtyAmtSpent"];
        
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO OM_PPAlloc VALUES(?,?,?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
            
            sqlite3_bind_double(stmt2, 4, str4.doubleValue);
            sqlite3_bind_double(stmt2, 5, str5.doubleValue);
            sqlite3_bind_double(stmt2, 6, str6.doubleValue);
            
            
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table %@",tableName);
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
        
    }
}
-(NSString *) getNewCustIDFromSetting
{
    NSString *newCustID;
    
    NSString *query =  @"select NewCustID from Setting";
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *CustID = (char *) sqlite3_column_text(statement, 0);

            newCustID = [NSString stringWithUTF8String:CustID];
            
        }
    }
    sqlite3_finalize(statement);
    
    return newCustID;

}
-(NSMutableArray *) arrNhaPhanPhoiFromDatabase
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    NSString *query =  [NSString stringWithFormat:@"SELECT * FROM SYS_Company"];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *CpnyID = (char *) sqlite3_column_text(statement, 0);
            char *CpnyName = (char *) sqlite3_column_text(statement, 1);
            char *Territory = (char *) sqlite3_column_text(statement, 2);
            
            NSMutableDictionary *row = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:CpnyID],@"CpnyID",
                                        [NSString stringWithUTF8String:CpnyName],@"CpnyName",
                                        [NSString stringWithUTF8String:Territory],@"Territory"
                                        , nil];
            
            [arr addObject:row];
        }
    }
    sqlite3_finalize(statement);
    
    return arr;
}

-(void) saveTakeOrderDictionary:(NSMutableDictionary *)dict WithCompletionHandler:(CompletionHandler)completionHandler
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSDictionary *activeCust = [user objectForKey:@"ActiveCustomer"];
    NSString *custID;
    NSString *classID = [activeCust objectForKey:@"ClassIDName"];
    
    
    if(![[user objectForKey:@"CustIDUpdate"] isEqualToString:@""])// update DH
    {
        custID = [user objectForKey:@"CustIDUpdate"];
    }else // them moi DH
    {
        custID = [activeCust objectForKey:@"CustID"];
    }
    
    /*
     [dict setObject:_feThongTinDoiThu.arrBrandSelected forKey:@"ThongTinDoiThu"];
     [dict setObject:_feThongTinDoiThu.mainViewSanPhamDoiThu.arrSanPhamDoiThuSelected forKey:@"SanPhamDoiThu"];
     [dict setObject:_feGhiNhanSP.arrSanPhamSelected forKey:@"GhiNhanSanPham"];
     [dict setObject:_feThongTinDoiThu.txbSLTB.text forKey:@"SLTB"];
     [dict setObject:_feThongTinDoiThu.txbDSTB.text forKey:@"DSTB"];
     [dict setObject:_lblCKCtu.text forKey:@"CKCTu"];
     [dict setObject:_lblTongCong forKey:@"TongCong"];
     [dict setObject:_lblTongSL forKey:@"TongSL"];
     */
    
    NSMutableArray *arrThongTinDoiThu = [dict objectForKey:@"ThongTinDoiThu"];
    /*
     Code = 07;
     Descr = "Bakers Choice 3";
     GhiChu = 0;
     GiaBan = 1;
     SLTB = 0;
     TonKho = 0;
     color = 1;
     */
    
    NSMutableArray *arrSanPhamDoiThu = [dict objectForKey:@"SanPhamDoiThu"];

    NSMutableDictionary *nhaPhanPhoi = [dict objectForKey:@"NhaPhanPhoi"];
    /*
     BrandIFV = "";
     Descr = Lotus;
     GhiChu = 0;
     InvtID = BA0001;
     SLTB = 2;
     StkBasePrc = "0.00";
     StkQty = 0;
     StkUnit = KG;
     color = 1;
     */
    NSMutableArray *arrGhiNhanSanPham = [dict objectForKey:@"GhiNhanSanPham"];
    /*
     MaCTKM = 0;
     OrigQtyVail = 100008;
     QtyVail = 99976;
     SL = 32;
     SLKM = 0;
     TaxCat = VAT05;
     TongTien = "384000.00";
     color = 1;
     desrc = "Bot mi 999 - 25 kg -TT - 03                       ";
     ghiChu = " ";
     invtID = "FG999000025-001";
     soLuong = 0;
     stkBasePrc = "12000.0";
     stkUnit = KG;
     */
    CGFloat tienThue = 0;
    NSString *loaiThue;
    
    for (NSDictionary *dict in arrGhiNhanSanPham)
    {
        loaiThue = [dict objectForKey:@"TaxCat"];
        NSString *stringLoaiThue = [dict objectForKey:@"TaxCat"];
        NSString *stringGiaTien = [dict objectForKey:@"stkBasePrc"];
        
        if ([stringLoaiThue isEqualToString:@"VAT05"])
        {
            tienThue += stringGiaTien.floatValue * 0.05;
        }
        else if ([stringLoaiThue isEqualToString:@"VAT10"])
        {
            tienThue += stringGiaTien.floatValue * 0.1;
        }
        else if ([stringLoaiThue isEqualToString:@"VAT00"])
        {
            tienThue += 0;
        }
            
    }
    
    for (NSMutableDictionary *dict  in arrThongTinDoiThu)
    {
        NSString *str1 = custID;
        NSString *str2 = [dict valueForKey:@"Code"];
        NSString *str3 = [dict valueForKey:@"TonKho"];
        NSString *str4 = [dict valueForKey:@"Descr"]; // Code
        NSString *str5 = @"";
        NSString *str6 = [dict valueForKey:@"SLTB"];
        NSString *str7 = [dict valueForKey:@"GiaBan"]; // Code
        NSString *str8 = [dict valueForKey:@"GhiChu"];
        
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd"];
        NSString *str9 = [format stringFromDate:[NSDate date]];
        NSString *str10 = @"H";
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO PPC_IN_Inventory VALUES(?,?,?,?,?,?,?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_double(stmt2, 3, str3.floatValue);
            sqlite3_bind_text(stmt2, 4, str4.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 5, str5.UTF8String, -1, NULL);
            
            sqlite3_bind_double(stmt2, 6, str6.doubleValue);
            sqlite3_bind_double(stmt2, 7, str7.doubleValue);
            
            sqlite3_bind_text(stmt2, 8, str8.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 9, str9.UTF8String, -1, NULL);
            
            sqlite3_bind_text(stmt2, 10, str10.UTF8String, -1, NULL);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table PPC_IN_Inventory");
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
    }
    
    for (NSMutableDictionary *dict in arrSanPhamDoiThu)
    {
        /*
         BrandIFV = "";
         Descr = Lotus;
         GhiChu = 0;
         InvtID = BA0001;
         SLTB = 2;
         StkBasePrc = "0.00";
         StkQty = 0;
         StkUnit = KG;
         color = 1;
         */
        
        NSString *str1 = custID;
        NSString *str2 = [dict valueForKey:@"InvtID"];
        NSString *str3 = [dict valueForKey:@"BrandIFV"];
        NSString *str4 = [dict valueForKey:@"Descr"]; // Code
        NSString *str5 = [dict valueForKey:@"StkUnit"];
        NSString *str6 = [dict valueForKey:@"SLTB"];
        NSString *str7 = [dict valueForKey:@"StkBasePrc"]; // Code
        NSString *str8 = [nhaPhanPhoi objectForKey:@"CpnyID"];
        NSString *str9 = [nhaPhanPhoi objectForKey:@"CpnyName"];
        NSString *str10 = [dict valueForKey:@"GhiChu"];
        
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *str11 = [format stringFromDate:[NSDate date]];
        
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO PPC_IN_InventoryCompetitor VALUES(?,?,?,?,?,?,?,?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 4, str4.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 5, str5.UTF8String, -1, NULL);
            
            sqlite3_bind_double(stmt2, 6, str6.doubleValue);
            sqlite3_bind_double(stmt2, 7, str7.doubleValue);
            
            sqlite3_bind_text(stmt2, 8, str8.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 9, str9.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 10, str10.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 11, str11.UTF8String, -1, NULL);
            
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table PPC_IN_Inventory");
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);

    }
    
    // Save SLTB ,  DSTB
    for (NSInteger i =0; i < 1; i++)
    {
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSData *data = [ user objectForKey:@"Setting"];
        NSMutableDictionary *dictSetting = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        NSString *str1 = [dictSetting objectForKey:@"SlsperID"];
        NSString *str2 = [dictSetting objectForKey:@"BranchID"];
        
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *str3 = [format stringFromDate:[NSDate date]];
        
        NSString *str4 = custID; // Code
        NSString *str5 = [dict objectForKey:@"SLTB"];
        NSString *str6 = [dict valueForKey:@"DSTB"];
    
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO OM_ProductReneu VALUES(?,?,?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 4, str4.UTF8String, -1, NULL);
            
            sqlite3_bind_double(stmt2, 5, str5.doubleValue);
            
            sqlite3_bind_double(stmt2, 6, str6.doubleValue);
            
            
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table OM_ProductReneu");
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);

    }
    
    
    // Save order
    //NSString *currentOrderNbr = [self lastIDForTable:@"OM_SalesOrd" columnName:@"OrderNbr"];
    NSString *currentOrderNbr;
    
    if(![[user objectForKey:@"OrderNbrUpdate"] isEqualToString:@""])// update DH
    {
        currentOrderNbr = [user objectForKey:@"OrderNbrUpdate"];
    }else // them moi DH
    {
        currentOrderNbr = [self maxIDForTable:@"OM_SalesOrd" columnName:@"OrderNbr"];
        NSLog(@"Order Nbr: %@", currentOrderNbr);
    }
    
    //currentOrderNbr = @"0001";
    
    for (NSInteger i = 0; i<1; i++)
    {
        //OrderNbr
        NSString *str1 = currentOrderNbr;
        //BudgetID1
        NSString *str2 = @"";
        //BudgetID2
        NSString *str3 = @"";
        //CustID
        NSString *str4 = custID;
        // LineAmt
        NSString *str5 = [dict objectForKey:@"TongGTTH"];
        //LineDiscAmt
        NSString *str6 = @"0";
        //OrdAmt
        NSString *str7 = [dict objectForKey:@"TongCong"];
        //OrdDiscAmt
        NSString *str8 = @"0";
        //OrderDate
        NSString *str9 = [self stringMaxDateFromDatabase];
        //OrdQty
        NSString *str10 = [dict objectForKey:@"TongSL"]; // Code
        // Tank Qty 
        NSString *str11 = @"0";
        
        // TaxAmtTot00 Tien Thue
        NSString *str12 = [NSString stringWithFormat:@"%.2f",tienThue];
        
        // TaxID00 Ma Loai Thue
        //NSString *str13 = loaiThue;
        NSString *str13 = @"";
        
        //TxblAmtTot00
        // Tien truoc thue
        NSString *str14 = [dict objectForKey:@"tongCongKoThue"];
        //VolDiscAmt
        NSString *str15 = [dict objectForKey:@"CKCTu"];
        // VolDiscPct
        CGFloat percent = str15.floatValue / str5.floatValue;
        NSString *str16 = [NSString stringWithFormat:@"%.2f",percent];
        //OrdStatus
        NSString *str17 = @"0";
        
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        // Crtd_DateTime
        NSString *str18 = [format stringFromDate:[NSDate date]];
        // LUpd_DatTime
        NSString *str19 = [format stringFromDate:[NSDate date]];
        //PriceClassID
        NSString *str20 = @"";
        // ClassID
        NSString *str21 = @" ";
        // CpnyID
        NSString *str22 = [nhaPhanPhoi objectForKey:@"CpnyID"];
        //NSString *str22 = @"";
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO OM_SalesOrd VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 4, str4.UTF8String, -1, NULL);
            
            sqlite3_bind_double(stmt2, 5, str5.doubleValue);
            sqlite3_bind_double(stmt2, 6, str6.doubleValue);
            sqlite3_bind_double(stmt2, 7, str7.doubleValue);
            sqlite3_bind_double(stmt2, 8, str8.doubleValue);
            sqlite3_bind_text(stmt2, 9, str9.UTF8String, -1, NULL);
            sqlite3_bind_double(stmt2, 10, str10.doubleValue);
            
            sqlite3_bind_double(stmt2, 11, str11.doubleValue);
            sqlite3_bind_double(stmt2, 12, str12.doubleValue);
            sqlite3_bind_text(stmt2, 13, str13.UTF8String, -1, NULL);
            
            sqlite3_bind_double(stmt2, 14, str14.doubleValue);
            sqlite3_bind_double(stmt2, 15, str15.doubleValue);
            sqlite3_bind_double(stmt2, 16, str16.doubleValue);
            sqlite3_bind_int(stmt2, 17, str17.intValue);
            
            sqlite3_bind_text(stmt2, 18, str18.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 19, str19.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 20, str20.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 21, str21.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 22, str22.UTF8String, -1, NULL);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table OM_SalesOrd");
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
    }
    
    // Save detail Order
    /*
     MaCTKM = 0;
     OrigQtyVail = 100008;
     QtyVail = 99976;
     SL = 32;
     SLKM = 0;
     TaxCat = VAT05;
     TongTien = "384000.00";
     color = 1;
     desrc = "Bot mi 999 - 25 kg -TT - 03                       ";
     ghiChu = " ";
     invtID = "FG999000025-001";
     soLuong = 0;
     stkBasePrc = "12000.0";
     stkUnit = KG;
     */
    for (NSInteger i = 0 ; i < arrGhiNhanSanPham.count; i++)
    {
        NSDictionary *curretnDict = [arrGhiNhanSanPham objectAtIndex:i];
        
        // OrdNbr
        NSString *str1 = currentOrderNbr;
        // LineRef
        NSString *str2 = [NSString stringWithFormat:@"%d",i];
        // BudgetID1
        NSString *str3 = @"";
        //BudgetID2
        NSString *str4 = @"";
        //DiscAmt
        NSString *str5 = [dict objectForKey:@"CKCTu"];
        //DiscAmt1
        NSString *str6 = @"0";
        //DiscAmt2
        NSString *str7 = @"0";
        //DiscCode1
        NSString *str8 = @"";
        //DescCode2
        NSString *str9 = @"";
        //DiscID1
        NSString *str10 = @"0"; // Code
        //DiscID2
        NSString *str11 = @"0";
        // % CK
        NSString *tempTongGTTH = [dict objectForKey:@"TongGTTH"];
        CGFloat phanTramCK = str5.floatValue / tempTongGTTH.floatValue;
        //DiscPc
        NSString *str12 = [NSString stringWithFormat:@"%.2f",phanTramCK];
        //DiscPc1
        NSString *str13 = @"0";
        //DiscPc2
        NSString *str14 = @"0";
        //DiscSeq1
        NSString *str15 = @"";
        //DiscSeq2
        NSString *str16 = @"";
        //FreeItem
        NSString *str17 = @"0";
        //GroupDiscAmt1
        NSString *str18 = @"0";
        //GroupDiscAmt2
        NSString *str19 = @"0";
        //GroupDiscID1
        NSString *str20 = @"";
        //GroupDiscID2
        NSString *str21 = @"";
        //GroupDiscPct1
        NSString *str22 = @"0";
        // GroupDiscPct2
        NSString *str23 = @"0";
        // GroupDiscSeq1
        NSString *str24 = @"";
        // GroupDiscSeq2
        NSString *str25 = @"";
        //InvtID
        NSString *str26 = [curretnDict objectForKey:@"invtID"];
        // ItemPriceClass
        NSString *str27 = @"";
        //LineAmt
        NSString *str28 = [curretnDict objectForKey:@"TongTien"];
        // LineQty
        NSString *str29 = [curretnDict objectForKey:@"SL"];
        // FreeQty
        NSString *str30 = @"0";
        // OrdQty
        NSString *str31 = @"0";
        //SiteID
        NSString *str32 = [curretnDict objectForKey:@"SiteID"]; // Code
        // SiteIDFree
        NSString *str33 = @"";//[curretnDict objectForKey:@"invtID"];
        // SlsPrice
        NSString *str34 = [curretnDict objectForKey:@"stkBasePrc"];
        // SlsUnit
        NSString *str35 = [curretnDict objectForKey:@"stkUnit"];
        
        NSString *taxCat = [curretnDict objectForKey:@"TaxCat"];
        CGFloat tax = 0;
        if ([taxCat isEqualToString:@"VAT05"])
            tax = 0.05f;
        else if ([taxCat isEqualToString:@"VAT10"])
            tax = 0.1f;
        else
            tax = 0;
        NSString *stringTongTienKoTax = [curretnDict objectForKey:@"TongTien"];
        
        //TaxAmt00
        NSString *str36 = [NSString stringWithFormat:@"%.2f",tax * stringTongTienKoTax.floatValue];
        //TaxCat
        NSString *str37 = [curretnDict objectForKey:@"TaxCat"];
        
        // TaxID00
        NSString *str38 = @"";
        //TxblAmt00
        NSString *str39 = [NSString stringWithFormat:@"%.2f",tax * stringTongTienKoTax.floatValue];
        //UnitMultDiv
        NSString *str40 = @"M";
        //UnitRate
        NSString *str41 = @"1";
        // WhseLoc
        NSString *str42 = @"0";
        // WhseLocFree
        NSString *str43 = @"0";
        //DocDiscAmt
        NSString *str44 = @"0";
        //status
        NSString *str45 = @"0";
        //Backorder
        NSString *str46 = @"0";
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO OM_SalesOrdDet VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 4, str4.UTF8String, -1, NULL);
            
            sqlite3_bind_double(stmt2, 5, str5.doubleValue);
            sqlite3_bind_double(stmt2, 6, str6.doubleValue);
            sqlite3_bind_double(stmt2, 7, str7.doubleValue);
            
            sqlite3_bind_text(stmt2, 8, str8.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 9, str9.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 10, str10.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 11, str11.UTF8String, -1, NULL);
            
            sqlite3_bind_double(stmt2, 12, str12.doubleValue);
            sqlite3_bind_double(stmt2, 13, str13.doubleValue);
            sqlite3_bind_double(stmt2, 14, str14.doubleValue);
            
            sqlite3_bind_text(stmt2, 15, str15.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 16, str16.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt2, 17, str17.intValue);
            sqlite3_bind_double(stmt2, 18, str18.doubleValue);
            sqlite3_bind_double(stmt2, 19, str19.doubleValue);
            
            

            sqlite3_bind_text(stmt2, 20, str20.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 21, str21.UTF8String, -1, NULL);
            sqlite3_bind_double(stmt2, 22, str22.doubleValue);
            sqlite3_bind_double(stmt2, 23, str23.doubleValue);
            sqlite3_bind_text(stmt2, 24, str24.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 25, str25.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 26, str26.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 27, str27.UTF8String, -1, NULL);
            
            sqlite3_bind_double(stmt2, 28, str28.doubleValue);
            sqlite3_bind_double(stmt2, 29, str29.doubleValue);
            sqlite3_bind_double(stmt2, 30, str30.doubleValue);
            sqlite3_bind_double(stmt2, 31, str31.doubleValue);
            
            sqlite3_bind_text(stmt2, 32, str32.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 33, str33.UTF8String, -1, NULL);
            sqlite3_bind_double(stmt2, 34, str34.doubleValue);
            sqlite3_bind_text(stmt2, 35, str35.UTF8String, -1, NULL);
            
            sqlite3_bind_double(stmt2, 36, str36.doubleValue);
            sqlite3_bind_text(stmt2, 37, str37.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 38, str38.UTF8String, -1, NULL);
            sqlite3_bind_double(stmt2, 39, str39.doubleValue);
            
            sqlite3_bind_text(stmt2, 40, str40.UTF8String, -1, NULL);
            sqlite3_bind_double(stmt2, 41, str41.doubleValue);
            sqlite3_bind_text(stmt2, 42, str42.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 43, str43.UTF8String, -1, NULL);
            
            sqlite3_bind_double(stmt2, 44, str44.doubleValue);
            sqlite3_bind_int(stmt2, 45, str45.intValue);
            sqlite3_bind_double(stmt2, 46, str46.doubleValue);
            
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table OM_SalesOrdDet");
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
    
    }
    
    // Save Photo to OutSideChecking
    for (NSInteger i = 0; i < 1; i++)
    {
        /*
         NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:_txbGhiChu.text,@"Note",@"1","NoteID",UIImageJPEGRepresentation(_avatar.image, 0.8f),@"dataImage", nil];
         
         [user setObject:dict forKey:@"OutsideChecking"];
         [user setObject:[NSString stringWithFormat:@"%d",isHasPhoto] forKey:@"OutsideChecking_Available"];
         */
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSString *available = [user objectForKey:@"OutsideChecking_Available"];
        if ([available isEqualToString:@"0"])
            break;
        
        NSDictionary *dict = [user objectForKey:@"OutsideChecking"];
        
        NSString *str1 = custID;
        NSString *str2 = @"1";
        NSString *str3 = [dict objectForKey:@"Note"];
        
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy_MM_dd_HH_mm_ss"];
        
        // name Photo
        NSString *str4 = [NSString stringWithFormat:@"OC_%@",[format stringFromDate:[NSDate date]]];
        
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *str5 = [format stringFromDate:[NSDate date]];

        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO OutsideChecking VALUES(?,?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt2, 2, str2.intValue);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 4, str4.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 5, str5.UTF8String, -1, NULL);
            
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table OM_SalesOrd");
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
            // Reset
            [user setObject:@"0" forKey:@"OutsideChecking_Available"];
            
            // Save image
            NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentPath = [array objectAtIndex:0];
            
            NSString *photoPath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",str4]];
            
            // write
            NSData *dataPhoto = [dict objectForKey:@"dataImage"];
            
            NSError *err;
            [dataPhoto writeToFile:photoPath options:NSDataWritingAtomic error:&err];
        
        if (err)
            NSLog(@"error = %@",err);
        
            NSLog(@"Save photo to %@",photoPath);
        sqlite3_finalize(stmt2);
    }
    
    
    completionHandler(YES);
}
-(void) saveTakeOrderKHKhongMuaWithDictionary:(NSMutableDictionary *) dict withCompletionHandler:(CompletionHandler)completionHandler
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSDictionary *activeCust = [user objectForKey:@"ActiveCustomer"];
    NSString *custID;
    
    if(![[user objectForKey:@"CustIDUpdate"] isEqualToString:@""])// update DH
    {
        custID = [user objectForKey:@"CustIDUpdate"];
    }else // them moi DH
    {
        custID = [activeCust objectForKey:@"CustID"];
    }
    
    //NSMutableArray *arrSanPhamSelected = [dict objectForKey:@"GhiNhanSP"];
    NSDictionary *lyDo = [dict objectForKey:@"LyDo"];
    
    NSString *str1 = custID;
    NSString *str2 = @"1";
    NSString *str3 = [lyDo objectForKey:@"Code"];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd 00:00:00"];
    NSString *str4 = [format stringFromDate:[NSDate date]];

    
    sqlite3_stmt *stmt2;
    NSString *query = @"INSERT INTO AR_CustomerDontBuy VALUES(?,?,?,?)";
    
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
    {
        sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
        sqlite3_bind_int(stmt2, 2, str2.intValue);
        sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt2, 4, str4.UTF8String, -1, NULL);
    }
    if (sqlite3_step(stmt2) != SQLITE_DONE)
    {
        NSLog(@"Error Saving at table AR_CustomerDontBuy");
        NSLog(@"error: %s\n",sqlite3_errmsg(db));
    }
    sqlite3_finalize(stmt2);
    
    
    
    // Save Photo to OutSideChecking
    for (NSInteger i = 0; i < 1; i++)
    {
        /*
         NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:_txbGhiChu.text,@"Note",@"1","NoteID",UIImageJPEGRepresentation(_avatar.image, 0.8f),@"dataImage", nil];
         
         [user setObject:dict forKey:@"OutsideChecking"];
         [user setObject:[NSString stringWithFormat:@"%d",isHasPhoto] forKey:@"OutsideChecking_Available"];
         */
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSString *available = [user objectForKey:@"OutsideChecking_Available"];
        if ([available isEqualToString:@"0"])
            break;
        
        NSDictionary *dict = [user objectForKey:@"OutsideChecking"];
        
        NSString *str1 = custID;
        NSString *str2 = @"1";
        NSString *str3 = [dict objectForKey:@"Note"];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy_MM_dd_HH_mm_ss"];
        
        // name Photo
        NSString *str4 = [NSString stringWithFormat:@"OC_%@",[format stringFromDate:[NSDate date]]];
        
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *str5 = [format stringFromDate:[NSDate date]];
        
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO OutsideChecking VALUES(?,?,?,?,?)";
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt2, 2, str2.intValue);
            sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 4, str4.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt2, 5, str5.UTF8String, -1, NULL);
            
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table OM_SalesOrd");
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        // Reset
        [user setObject:@"0" forKey:@"OutsideChecking_Available"];
        
        // Save image
        NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = [array objectAtIndex:0];
        
        NSString *photoPath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",str4]];
        
        // write
        NSData *dataPhoto = [dict objectForKey:@"dataImage"];
        
        NSError *err;
        [dataPhoto writeToFile:photoPath options:NSDataWritingAtomic error:&err];
        
        if (err)
            NSLog(@"error = %@",err);
        
        NSLog(@"Save photo to %@",photoPath);
        
        sqlite3_finalize(stmt2);
    }

    
    completionHandler(YES);
    
}
-(void) deleteAllTalbForSyncPDAToService
{
    NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:@"OM_SalesOrd",@"OM_SalesOrdDet",@"OM_OrdDisc",@"OM_SuggestOrder",@"AR_SalespersonLocationTrace",@"PPC_NoticeBoardSubmit", @"PPC_OM_NoticeBoardSubmit_Image",@"PPC_TechnicalSupport",@"PPC_OM_TechnicalSupport_Image",@"OM_ProductReneu",@"PPC_IN_Inventory",@"PPC_IN_InventoryCompetitor",@"AR_CustomerDontBuy",@"AR_NewCustomerInfor",@"PPC_Task",@"OutsideChecking", nil];
    
    //NSString *query = @"DELETE FROM OM_SalesOrd,OM_SalesOrdDet,OM_OrdDisc,OM_SuggestOrder, AR_SalespersonLocationTrace,PPC_NoticeBoardSubmit , PPC_TechnicalSupport, PPC_OM_TechnicalSupport_Image, OM_ProductReneu, PPC_IN_Inventory, PPC_IN_InventoryCompetitor, AR_CustomerDontBuy ";
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arrTableHasError = [user objectForKey:@"arrTableHasError"];
    
    
    
    for (NSString *stringTable in arr)
    {
        BOOL isHasError = NO;
        for (NSString *nameTable in arrTableHasError)
        {
            if ([stringTable isEqualToString:nameTable])
            {
                isHasError = YES;
                break;
            }
        }
        
        if (!isHasError)
        {
        
            sqlite3_stmt *stmt2 = NULL;
            NSString *query = [NSString stringWithFormat:@"DELETE FROM %@",stringTable];
            
            char *errMsg = nil;
            if(sqlite3_exec(db, query.UTF8String, NULL, NULL, &errMsg)==SQLITE_OK)
            {
                NSLog(@"Deleted table %@",stringTable);
            }
            sqlite3_finalize(stmt2);
        }
        else
        {
            
        }

    }
    
    
}
-(void) deleteAllTableForLogout
{
    
    NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:@"OM_ReasonCode",
                           @"AR_NewCustomerInfor",
                                @"IN_Brand",
                                @"PPC_AgingDebt",
                                @"AR_Territory",
                                @"PPC_SalesHistory",
                                @"SI_Ward",
                                @"AR_CustType",
                                @"AR_Channel",
                                @"SI_State",
                                @"AR_Customer",
                                @"AR_Area",
                                @"OM_Knowledge",
                                @"OM_SalesRouteDet",
                                @"OM_Setup",
                                @"RPT_MonthlySales",
                                @"OM_Discount",
                                @"IN_ItemLoc",
                                @"OM_DiscCustClass",
                                @"SI_District",
                                @"OM_PPAlloc",
                                @"OM_PPBudget",
                                @"SI_City",
                                @"AR_Doc",
                                @"OM_IssueType",
                                @"OM_TechnicalSupport",
                                @"OM_DiscCust",
                                @"AR_CustomerInfo_Invt",
                                @"AR_ShopType",
                                @"IN_InventoryCompetitor",
                                @"AR_CustomerLocation",
                                @"OM_DiscSeq",
                                @"SI_Tax",
                                @"AR_CustClass",
                                @"SI_Hierarchy",
                                @"OM_DiscItemClass",
                                @"SYS_Company",
                                @"OM_DiscBreak",
                                @"OM_SalesRoute",
                                @"OM_DiscDescr",
                                @"PPC_SuggestOrder",
                                @"PPC_ARCustomerInfo",
                                @"OM_DiscFreeItem",
                                @"OM_PriceClass",
                                @"IN_Inventory",
                                @"OM_DiscItem",
                           @"OM_DefineWorks",
                           @"PPC_PriceOfCust",
                           @"In_Site",
                           @"AR_Transaction",
                           @"PPC_Distributor",
                           @"PPC_SurveyBrand",
                           @"OutsideChecking",
                           @"OM_SalesOrd",
                           @"OM_SalesOrdDet",
                           @"PPC_OM_NoticeBoardSubmit_Image",
                           @"PPC_OM_TechnicalSupport_Image",nil];
    
    for (NSString *nameTable in arr)
    {
        sqlite3_stmt *stmt2 = NULL;
        
        NSString *query = [NSString stringWithFormat:@"DELETE FROM %@",nameTable];
        /*
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table DELETE ALL");
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        else
            NSLog(@"%@",query);
        */
        char *errMsg = nil;
        if(sqlite3_exec(db, query.UTF8String, NULL, NULL, &errMsg)==SQLITE_OK)
        {
            NSLog(@"Deleted table %@",nameTable);
        }
        sqlite3_finalize(stmt2);

    }
}
-(void) saveGPSForCustomerWithArr:(NSMutableArray *)arrCustomer
{
    NSLog(@"save GPS change with = %@",arrCustomer);
    /*
     {
     Addr1 = ttgg6;
     BranchID = "";
     ContactName = DDD;
     CustID = GM00005;
     CustName = AAS;
     lat = "106.698039";
     lng = "106.698039";
     }
*/
    for (NSMutableDictionary *dict in arrCustomer)
    {
        sqlite3_stmt *stmt2;
        NSString *query = @"INSERT INTO AR_CustomerLocation VALUES(?,?,?,?)";
        
        NSString *str1 = [dict objectForKey:@"CustID"];
        NSString *str2 = [dict objectForKey:@"BranchID"];
        NSNumber *str3 = [dict objectForKey:@"lat"];
        NSNumber *str4 = [dict objectForKey:@"lng"];
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt2, 2, str2.intValue);
            sqlite3_bind_double(stmt2, 3, str3.floatValue);
            sqlite3_bind_double(stmt2, 4, str4.floatValue);
        }
        if (sqlite3_step(stmt2) != SQLITE_DONE)
        {
            NSLog(@"Error Saving at table AR_CustomerLocation");
            NSLog(@"error: %s\n",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt2);
    }
    
    
    
}
-(NSMutableArray *) arrNamePhotoFromDatabase
{
    NSMutableArray *arrNamePhoto = [[NSMutableArray alloc] init];
    
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [array objectAtIndex:0];
    databasePath = [documentPath stringByAppendingPathComponent:@"Mobile.db3"];
    
    // OutsideChecking
    SQLHelper *helper = [[SQLHelper alloc] initWithContentsOfFile:databasePath];
    NSArray *arr = [helper executeQuery:@"SELECT * FROM OutSideChecking"];
    
    for (NSDictionary *dict in arr)
    {
        [arrNamePhoto addObject:[dict objectForKey:@"ImageFileName"]];
    }
    
    // TechnicalSupport
    arr = [helper executeQuery:@"SELECT * FROM PPC_OM_TechnicalSupport_Image"];
    
    for (NSDictionary *dict in arr)
    {
        [arrNamePhoto addObject:[dict objectForKey:@"ImageFileName"]];
    }
    
    // NoticeBoard
    arr = [helper executeQuery:@"SELECT * FROM PPC_OM_NoticeBoardSubmit_Image"];
    
    for (NSDictionary *dict in arr)
    {
        [arrNamePhoto addObject:[dict objectForKey:@"ImageFileName"]];
    }
    
    
    // New Customer Info
    arr = [helper executeQuery:@"SELECT * FROM AR_NewCustomer_Picture"];
    
    for (NSDictionary *dict in arr)
    {
        [arrNamePhoto addObject:[dict objectForKey:@"ImageFileName"]];
    }
    return arrNamePhoto;
}
-(NSMutableArray *) arrAllPhotoShouldDownload
{
    
}
-(NSMutableArray *) arrURLImagePhotoForCustomerID:(NSString *)ID
{
    
}
-(NSMutableArray *) arrURLImagePhotoForTechnicalSupportWithID:(NSString *)ID
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    NSString *query =  [NSString stringWithFormat:@"SELECT ImageFileName FROM PPC_OM_TechnicalSupport_Image WHERE Code = '%@'",ID];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *imageFileName = (char *) sqlite3_column_text(statement, 0);
            
            [arr addObject:[NSString stringWithUTF8String:imageFileName]];
        }
    }
    sqlite3_finalize(statement);
    
    return arr;
}
-(NSMutableArray *) arrURLImagePhotoForNoticeBoardWithID:(NSString *)ID
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    NSString *query =  [NSString stringWithFormat:@"SELECT ImageFileName FROM PPC_OM_NoticeBoardSubmit_Image WHERE Code = '%@'",ID];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *imageFileName = (char *) sqlite3_column_text(statement, 0);
            
            [arr addObject:[NSString stringWithUTF8String:imageFileName]];
        }
    }
    sqlite3_finalize(statement);
    
    return arr;

}

//Report
// Day
-(NSString *) soluongKhacHangFromDatabaseAtDate:(NSString *) stringDate
{
    NSString *returnSLKH;
    
    NSString *query =[NSString stringWithFormat:@"SELECT count(distinct a.CustID) as CountCustomer FROM OM_SalesRouteDet a INNER JOIN AR_Customer b on a.CustID = b.CustID WHERE VisitDate Like '%@%@'", stringDate, @"%"];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            int slKH =sqlite3_column_int(statement, 0);
            
            returnSLKH = [NSString stringWithFormat:@"%d", slKH];
        }
    }
    sqlite3_finalize(statement);
    
    return returnSLKH;
}

-(NSString *) soluongDonHangFromDatabase
{
    NSString *returnSLDH;
    
    NSString *query = @"select Count(OrderNbr) as OrderNum from OM_SalesOrd";
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            int slDH =sqlite3_column_int(statement, 0);
            
            returnSLDH = [NSString stringWithFormat:@"%d", slDH];
        }
    }
    sqlite3_finalize(statement);
    
    return returnSLDH;
}

-(NSString *) soluongKHBaoPhuFromDatabase
{
    NSString *returnSLKHBP;
    
    NSString *query = @"select Count(distinct v.CustID) as CallNum from OM_PJP_Visited v inner join  OM_SalesRouteDet d on v.[VisitDate] = d.VisitDate and v.CustID = d.CustID inner join Setting s on v.VisitDate = s.BusinessDate";
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            int slKHBP =sqlite3_column_int(statement, 0);
            
            returnSLKHBP = [NSString stringWithFormat:@"%d", slKHBP];
        }
    }
    sqlite3_finalize(statement);
    
    return returnSLKHBP;
}

-(NSString *) tongKhuyenMaiFromDatabase
{
    NSString *returnTongKM;
    
    NSString *query = @"select (Sum(DiscAmt) + Sum(DiscAmt1) + Sum(DiscAmt2) +Sum(DocDiscAmt)) as OrdAmt from OM_SalesOrd a inner join OM_SalesOrdDet b on a.OrderNbr=b.OrderNbr";
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            int tongKM =sqlite3_column_int(statement, 0);
            
            returnTongKM = [NSString stringWithFormat:@"%d", tongKM];
        }
    }
    sqlite3_finalize(statement);
    
    return returnTongKM;
}

-(NSMutableDictionary *) dictTongChietKhauVaDoanhSoFromDatabase
{
    NSMutableDictionary *dictCKDS = [[NSMutableDictionary alloc] init];
    
    NSString *query = @"select Sum(OrdAmt) as OrdAmt, Sum(LineDiscAmt + VolDiscAmt) as OrdDiscAmt from OM_SalesOrd";
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            int tongCK =sqlite3_column_int(statement, 0);
            [dictCKDS setValue:[NSNumber numberWithInt:tongCK] forKey:@"doanhSo"];
            
            int ds =sqlite3_column_int(statement, 1);
            [dictCKDS setValue:[NSNumber numberWithInt:ds] forKey:@"tongCK"];
            
        }
    }
    sqlite3_finalize(statement);
    
    return dictCKDS;
}

//Month
-(NSMutableDictionary *) dictBaoCaoThangFromDatabase
{
    NSMutableDictionary *dictBCThang = [[NSMutableDictionary alloc] init];
    
    NSString *query = @"SELECT CallNum, OrderNum, SKUNum, OrdAmt, DiscAmt , TargetQuantity , Quantity , MustCustVisit FROM RPT_MONTHLYSALES";
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            int tongKHDaThamVieng = sqlite3_column_int(statement, 0);
            [dictBCThang setValue:[NSNumber numberWithInt:tongKHDaThamVieng] forKey:@"tongKHDaThamVieng"];
            
            int orderNum = sqlite3_column_int(statement, 1);
            [dictBCThang setValue:[NSNumber numberWithInt:orderNum] forKey:@"orderNum"];
            
            int skuNum = sqlite3_column_int(statement, 2);
            [dictBCThang setValue:[NSNumber numberWithInt:skuNum] forKey:@"skuNum"];
            
            int chitieuDS = sqlite3_column_int(statement, 3);
            [dictBCThang setValue:[NSNumber numberWithInt:chitieuDS] forKey:@"chitieuDS"];
            
            int doanhso = sqlite3_column_int(statement, 4);
            [dictBCThang setValue:[NSNumber numberWithInt:doanhso] forKey:@"doanhso"];
            
            int targetQuantity = sqlite3_column_int(statement, 5);
            [dictBCThang setValue:[NSNumber numberWithInt:targetQuantity] forKey:@"targetQuantity"];
            
            int quantity = sqlite3_column_int(statement, 6);
            [dictBCThang setValue:[NSNumber numberWithInt:quantity] forKey:@"quantity"];
            
            int tongKHPhaiViengTham = sqlite3_column_int(statement, 7);
            [dictBCThang setValue:[NSNumber numberWithInt:tongKHPhaiViengTham] forKey:@"tongKHPhaiViengTham"];
        }
    }
    sqlite3_finalize(statement);
    
    return dictBCThang;
}
//DS Don Hang
-(NSMutableArray *) arrDSDonHangFromDatabase
{
    NSMutableArray *arrDSDonHang = [[NSMutableArray alloc] init];
    
    NSString *query = @"select a.CustName,o.CustID, TankQty, OrderNbr, cast(OrdAmt as TEXT) as OrdAmt ,o.OrdQty, ifnull(b.TradeType,'') as TradeType from OM_SalesOrd o inner join AR_Customer a on o.CustID = a.CustID inner join PPC_ARCustomerInfo b on a.CustID = b.CustID union all select a.OutletName as CustName,o.CustID, TankQty, OrderNbr, cast(OrdAmt as TEXT) as OrdAmt ,o.OrdQty,a.TradeType from OM_SalesOrd o inner join AR_NewCustomerInfor a on o.CustID = a.CustID";
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableDictionary *dictDSDonHang = [[NSMutableDictionary alloc] init];
            
            NSString *tenKH =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 0)];
            [dictDSDonHang setValue:tenKH forKey:@"tenKH"];
            
            NSString *maKH =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 1)];
            [dictDSDonHang setValue:maKH forKey:@"maKH"];
            
            NSString *tankQty =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 2)];
            [dictDSDonHang setValue:tankQty forKey:@"tankQty"];
            
            NSString *dhSo =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 3)];
            [dictDSDonHang setValue:dhSo forKey:@"dhSo"];
            
            NSString *tongTien =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 4)];
            [dictDSDonHang setValue:tongTien forKey:@"tongTien"];
            
            NSString *tongSL =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 5)];
            [dictDSDonHang setValue:tongSL forKey:@"tongSL"];
            
            NSString *tradeType =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 6)];
            [dictDSDonHang setValue:tradeType forKey:@"tradeType"];
            
            [arrDSDonHang addObject:dictDSDonHang];
        }
    }
    sqlite3_finalize(statement);
    
    return arrDSDonHang;
}

-(void) deleteOM_SaleOrdWithOrderNbr:(NSString *)strOrderNbr
{
    NSString *deleteStatement = [NSString stringWithFormat:
                                 @"DELETE FROM OM_SALESORD WHERE OrderNbr Like '%@'",
                                 strOrderNbr];
    const char *sql= [deleteStatement UTF8String];
    sqlite3_stmt *deleteStmt;
    //NSLog(@"query: %@",deleteStatement);
    
    if(sqlite3_prepare_v2(db, sql, -1, &deleteStmt, NULL) != SQLITE_OK)
    {
        NSAssert1(0, @"Error while creating delete statement. %s", sqlite3_errmsg(db));
    }
    
    //when binding parameters, index starts from 1 and not zero
    sqlite3_bind_text(deleteStmt, 1, [strOrderNbr UTF8String], -1, SQLITE_TRANSIENT);
    
    if(SQLITE_DONE !=sqlite3_step(deleteStmt))
        NSAssert1(0, @"Error while editing. %s", sqlite3_errmsg(db));
}

-(NSMutableArray *) arrAllOM_SalesOrdDetFromDatabaseWithOrderNbr:(NSString *)strOrderNbr
{
    NSMutableArray *arrOM_SalesOrdDet = [[NSMutableArray alloc] init];
    
    NSString *query = [NSString stringWithFormat:@"SELECT  OrderNbr, BackOrder, LineRef, BudgetID1, BudgetID2, DiscAmt, DiscAmt1, DiscAmt2, DiscCode1, DiscCode2, DiscID1, DiscID2, DiscPct, DiscPct1, DiscPct2, DiscSeq1, DiscSeq2, FreeItem, GroupDiscAmt1, GroupDiscAmt2, GroupDiscID1, GroupDiscID2, GroupDiscPct1, GroupDiscPct2, GroupDiscSeq1, GroupDiscSeq2, InvtID, ItemPriceClass, LineAmt, LineQty, FreeQty, OrdQty, SiteID, SiteIDFree, SlsPrice, SlsUnit, TaxAmt00, TaxCat, TaxID00, TxblAmt00, UnitMultDiv, UnitRate, WhseLoc, WhseLocFree, DocDiscAmt, Status FROM OM_SALESORDDET WHERE OrderNbr Like %@ ORDER BY OrderNbr", strOrderNbr];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableDictionary *dictOM_SalesOrdDet = [[NSMutableDictionary alloc] init];
            
            NSString *OrderNbr =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 0)];
            [dictOM_SalesOrdDet setValue:OrderNbr forKey:@"OrderNbr"];
            
            NSString *BackOrder =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 1)];
            [dictOM_SalesOrdDet setValue:BackOrder forKey:@"BackOrder"];
            
            NSString *LineRef =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 2)];
            [dictOM_SalesOrdDet setValue:LineRef forKey:@"LineRef"];
            
            NSString *BudgetID1 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 3)];
            [dictOM_SalesOrdDet setValue:BudgetID1 forKey:@"BudgetID1"];
            
            NSString *BudgetID2 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 4)];
            [dictOM_SalesOrdDet setValue:BudgetID2 forKey:@"BudgetID2"];
            
            NSString *DiscAmt =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 5)];
            [dictOM_SalesOrdDet setValue:DiscAmt forKey:@"DiscAmt"];
            
            NSString *DiscAmt1 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 6)];
            [dictOM_SalesOrdDet setValue:DiscAmt1 forKey:@"DiscAmt1"];
            
            NSString *DiscAmt2 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 7)];
            [dictOM_SalesOrdDet setValue:DiscAmt2 forKey:@"DiscAmt2"];
            
            NSString *DiscCode1 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 8)];
            [dictOM_SalesOrdDet setValue:DiscCode1 forKey:@"DiscCode1"];
            
            NSString *DiscCode2 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 9)];
            [dictOM_SalesOrdDet setValue:DiscCode2 forKey:@"DiscCode2"];
            
            NSString *DiscID1 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 10)];
            [dictOM_SalesOrdDet setValue:DiscID1 forKey:@"DiscID1"];
            
            NSString *DiscID2 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 11)];
            [dictOM_SalesOrdDet setValue:DiscID2 forKey:@"DiscID2"];
            
            NSString *DiscPct =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 12)];
            [dictOM_SalesOrdDet setValue:DiscPct forKey:@"DiscPct"];
            
            NSString *DiscPct1 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 13)];
            [dictOM_SalesOrdDet setValue:DiscPct1 forKey:@"DiscPct1"];
            
            NSString *DiscPct2 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 14)];
            [dictOM_SalesOrdDet setValue:DiscPct2 forKey:@"DiscPct2"];
            
            NSString *DiscSeq1 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 15)];
            [dictOM_SalesOrdDet setValue:DiscSeq1 forKey:@"DiscSeq1"];
            
            NSString *DiscSeq2 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 16)];
            [dictOM_SalesOrdDet setValue:DiscSeq2 forKey:@"DiscSeq2"];
            
            NSString *FreeItem =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 17)];
            [dictOM_SalesOrdDet setValue:FreeItem forKey:@"FreeItem"];
            
            NSString *GroupDiscAmt1 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 18)];
            [dictOM_SalesOrdDet setValue:GroupDiscAmt1 forKey:@"GroupDiscAmt1"];
            
            NSString *GroupDiscAmt2 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 19)];
            [dictOM_SalesOrdDet setValue:GroupDiscAmt2 forKey:@"GroupDiscAmt2"];
            
            NSString *GroupDiscID1 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 20)];
            [dictOM_SalesOrdDet setValue:GroupDiscID1 forKey:@"GroupDiscID1"];
            
            NSString *GroupDiscID2 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 21)];
            [dictOM_SalesOrdDet setValue:GroupDiscID2 forKey:@"GroupDiscID2"];
            
            NSString *GroupDiscPct1 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 22)];
            [dictOM_SalesOrdDet setValue:GroupDiscPct1 forKey:@"GroupDiscPct1"];
            
            NSString *GroupDiscPct2 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 23)];
            [dictOM_SalesOrdDet setValue:GroupDiscPct2 forKey:@"GroupDiscPct2"];
            
            NSString *GroupDiscSeq1 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 24)];
            [dictOM_SalesOrdDet setValue:GroupDiscSeq1 forKey:@"GroupDiscSeq1"];
            
            NSString *GroupDiscSeq2 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 25)];
            [dictOM_SalesOrdDet setValue:GroupDiscSeq2 forKey:@"GroupDiscSeq2"];
            
            NSString *InvtID =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 26)];
            [dictOM_SalesOrdDet setValue:InvtID forKey:@"InvtID"];
            
            NSString *ItemPriceClass =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 27)];
            [dictOM_SalesOrdDet setValue:ItemPriceClass forKey:@"ItemPriceClass"];
            
            NSString *LineAmt =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 28)];
            [dictOM_SalesOrdDet setValue:LineAmt forKey:@"LineAmt"];
            
            //NSString *LineQty =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 29)];
            int LineQty=sqlite3_column_int(statement, 29);
            [dictOM_SalesOrdDet setValue:[NSNumber numberWithInt:LineQty] forKey:@"LineQty"];
            
            NSString *FreeQty =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 30)];
            [dictOM_SalesOrdDet setValue:FreeQty forKey:@"FreeQty"];
            
            NSString *OrdQty =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 31)];
            [dictOM_SalesOrdDet setValue:OrdQty forKey:@"OrdQty"];
            
            NSString *SiteID =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 32)];
            [dictOM_SalesOrdDet setValue:SiteID forKey:@"SiteID"];
            
            NSString *SiteIDFree =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 33)];
            [dictOM_SalesOrdDet setValue:SiteIDFree forKey:@"SiteIDFree"];
            
            NSString *SlsPrice =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 34)];
            [dictOM_SalesOrdDet setValue:SlsPrice forKey:@"SlsPrice"];
            
            NSString *SlsUnit =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 35)];
            [dictOM_SalesOrdDet setValue:SlsUnit forKey:@"SlsUnit"];
            
            NSString *TaxAmt00 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 36)];
            [dictOM_SalesOrdDet setValue:TaxAmt00 forKey:@"TaxAmt00"];
            
            NSString *TaxCat =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 37)];
            [dictOM_SalesOrdDet setValue:TaxCat forKey:@"TaxCat"];
            
            NSString *TaxID00 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 38)];
            [dictOM_SalesOrdDet setValue:TaxID00 forKey:@"TaxID00"];
            
            NSString *TxblAmt00 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 39)];
            [dictOM_SalesOrdDet setValue:TxblAmt00 forKey:@"TxblAmt00"];
            
            NSString *UnitMultDiv =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 40)];
            [dictOM_SalesOrdDet setValue:UnitMultDiv forKey:@"UnitMultDiv"];
            
            NSString *UnitRate =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 41)];
            [dictOM_SalesOrdDet setValue:UnitRate forKey:@"UnitRate"];
            
            
            NSString *WhseLoc =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 42)];
            [dictOM_SalesOrdDet setValue:WhseLoc forKey:@"WhseLoc"];
            
            NSString *WhseLocFree =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 43)];
            [dictOM_SalesOrdDet setValue:WhseLocFree forKey:@"WhseLocFree"];
            
            NSString *DocDiscAmt =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 44)];
            [dictOM_SalesOrdDet setValue:DocDiscAmt forKey:@"DocDiscAmt"];
            
            NSString *Status =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 45)];
            [dictOM_SalesOrdDet setValue:Status forKey:@"Status"];
            
            [arrOM_SalesOrdDet addObject:dictOM_SalesOrdDet];
        }
    }
    sqlite3_finalize(statement);
    
    return arrOM_SalesOrdDet;
}

-(NSMutableDictionary *) arrIN_ItemLocByKeyWithInvtID:(NSString *)invtID SiteID:(NSString *)siteID WhseLoc:(NSString *)whseLoc
{
    NSMutableDictionary *dictIN_ItemLoc = [[NSMutableDictionary alloc] init];
    
    NSString *query =[NSString stringWithFormat: @"SELECT InvtID, SiteID, WhseLoc, QtyAvail, OrigQtyAvail FROM IN_ITEMLOC WHERE InvtID = '%@' AND SiteID = '%@' AND WhseLoc = '%@'", invtID, siteID, whseLoc];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSString *InvtID =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 0)];
            [dictIN_ItemLoc setValue:InvtID forKey:@"InvtID"];
            
            NSString *SiteID =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 1)];
            [dictIN_ItemLoc setValue:SiteID forKey:@"SiteID"];
            
            NSString *WhseLoc =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 2)];
            [dictIN_ItemLoc setValue:WhseLoc forKey:@"WhseLoc"];
            
            //NSString *QtyAvail =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 3)];
            int QtyAvail=sqlite3_column_int(statement, 3);
            [dictIN_ItemLoc setValue:[NSNumber numberWithInt:QtyAvail] forKey:@"QtyAvail"];
            
            NSString *OrigQtyAvail =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 4)];
            [dictIN_ItemLoc setValue:OrigQtyAvail forKey:@"OrigQtyAvail"];
            
        }
    }
    sqlite3_finalize(statement);
    return dictIN_ItemLoc;
}

-(void) updateIN_ItemLocWithDict:(NSMutableDictionary *)dict QtyAvail:(int) qtyAvail
{
    // update so luong vao kho
    //int QtyAvail = [[dict objectForKey:@"QtyAvail" ] intValue] + lineQty;
    
    NSString *updateStatement = [NSString stringWithFormat:
                                 @"UPDATE IN_ITEMLOC SET QtyAvail = %d  WHERE InvtID = '%@' AND SiteID = '%@'", qtyAvail,
                                 [dict objectForKey:@"InvtID" ], [dict objectForKey:@"SiteID"]];
    
    const char *sql= [updateStatement UTF8String];
    sqlite3_stmt *updateStmt;
    
    if(sqlite3_prepare_v2(db, sql, -1, &updateStmt,NULL) != SQLITE_OK)
    {
        NSAssert1(0, @"Error while creating delete statement. %s", sqlite3_errmsg(db));
    }
    //when binding parameters, index starts from 1 and not zero
    
    sqlite3_bind_int(updateStmt, 1, qtyAvail);
    
    sqlite3_bind_text(updateStmt, 2, [[dict objectForKey:@"InvtID"] UTF8String], -1, SQLITE_TRANSIENT);
    
    sqlite3_bind_text(updateStmt, 3, [[dict objectForKey:@"SiteID"] UTF8String], -1, SQLITE_TRANSIENT);
    
    if(SQLITE_DONE !=sqlite3_step(updateStmt))
        NSAssert1(0, @"Error while editing. %s", sqlite3_errmsg(db));
}

-(void) deleteOM_SalesOrdDetWithOrderNbr:(NSString *)strOrderNbr
{
    NSString *deleteStatement = [NSString stringWithFormat:
                                 @"DELETE FROM OM_SALESORDDET WHERE OrderNbr Like '%@'",
                                 strOrderNbr];
    const char *sql= [deleteStatement UTF8String];
    sqlite3_stmt *deleteStmt;
    //NSLog(@"query: %@",deleteStatement);
    
    if(sqlite3_prepare_v2(db, sql, -1, &deleteStmt, NULL) != SQLITE_OK)
    {
        NSAssert1(0, @"Error while creating delete statement. %s", sqlite3_errmsg(db));
    }
    
    //when binding parameters, index starts from 1 and not zero
    sqlite3_bind_text(deleteStmt, 1, [strOrderNbr UTF8String], -1, SQLITE_TRANSIENT);
    
    if(SQLITE_DONE !=sqlite3_step(deleteStmt))
        NSAssert1(0, @"Error while editing. %s", sqlite3_errmsg(db));
}

//DS KH Moi
-(NSMutableArray *) arrDSKHMoiFromDatabase
{
    NSMutableArray *arrDSKHMoi = [[NSMutableArray alloc] init];
    
    NSString *query = @"SELECT  CustID, OutletName, ContactName, Phone, Mobile, Fax, Email, Addr1, Addr2, Addr3, State, City, District, Ward, Channel, ClassId, Area, ShopType, TradeType, IFNULL(b.Descr,'') as TradeName, CAST(Lat as Text) as Lat, CAST(Lng as Text) as Lng, ImageFileName, Status, IsActive, Crtd_Datetime, LUpd_Datetime, CpnyName, AddrCpny, DateCpny, Owner, BankAccount, ContactName1, Addr11, Phone1, Email1, DOB1, ContactName2, Addr21, Phone2, Email2, DOB2, ContactName3, Addr31, Phone3, Email3, DOB3 FROM AR_NEWCUSTOMERINFOR a left join AR_CustType b on a.TradeType=b.Code ORDER BY CustID";
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableDictionary *dictDSKHMoi = [[NSMutableDictionary alloc] init];
            
            NSString *CustID =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 0)];
            [dictDSKHMoi setValue:CustID forKey:@"CustID"];
            
            NSString *OutletName =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 1)];
            [dictDSKHMoi setValue:OutletName forKey:@"OutletName"];
            
            NSString *ContactName =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 2)];
            [dictDSKHMoi setValue:ContactName forKey:@"ContactName"];
            
            NSString *Phone =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 3)];
            [dictDSKHMoi setValue:Phone forKey:@"Phone"];
            
            NSString *Mobile =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 4)];
            [dictDSKHMoi setValue:Mobile forKey:@"Mobile"];
            
            NSString *Fax =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 5)];
            [dictDSKHMoi setValue:Fax forKey:@"Fax"];
            
            NSString *Email =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 6)];
            [dictDSKHMoi setValue:Email forKey:@"Email"];
            
            NSString *Addr1 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 7)];
            [dictDSKHMoi setValue:Addr1 forKey:@"Addr1"];
            
            NSString *Addr2 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 8)];
            [dictDSKHMoi setValue:Addr2 forKey:@"Addr2"];
            
            NSString *Addr3 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 9)];
            [dictDSKHMoi setValue:Addr3 forKey:@"Addr3"];
            
            NSString *State =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 10)];
            [dictDSKHMoi setValue:State forKey:@"State"];
            
            NSString *City =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 11)];
            [dictDSKHMoi setValue:City forKey:@"City"];
            
            NSString *District =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 12)];
            [dictDSKHMoi setValue:District forKey:@"District"];
            
            NSString *Ward =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 13)];
            [dictDSKHMoi setValue:Ward forKey:@"Ward"];
            
            NSString *Channel =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 14)];
            [dictDSKHMoi setValue:Channel forKey:@"Channel"];
            
            NSString *ClassId =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 15)];
            [dictDSKHMoi setValue:ClassId forKey:@"ClassId"];
            
            NSString *Area =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 16)];
            [dictDSKHMoi setValue:Area forKey:@"Area"];
            
            NSString *ShopType =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 17)];
            [dictDSKHMoi setValue:ShopType forKey:@"ShopType"];
            
            NSString *TradeType =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 18)];
            [dictDSKHMoi setValue:TradeType forKey:@"TradeType"];
            
            NSString *TradeName =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 19)];
            [dictDSKHMoi setValue:TradeName forKey:@"TradeName"];
            
            NSString *Lat =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 20)];
            [dictDSKHMoi setValue:Lat forKey:@"Lat"];
            
            NSString *Lng =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 21)];
            [dictDSKHMoi setValue:Lng forKey:@"Lng"];
            
            NSString *ImageFileName =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 22)];
            [dictDSKHMoi setValue:ImageFileName forKey:@"ImageFileName"];
            
            NSString *Status =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 23)];
            [dictDSKHMoi setValue:Status forKey:@"Status"];
            
            NSString *IsActive =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 24)];
            [dictDSKHMoi setValue:IsActive forKey:@"IsActive"];
            
            NSString *Crtd_Datetime =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 25)];
            [dictDSKHMoi setValue:Crtd_Datetime forKey:@"Crtd_Datetime"];
            
            NSString *LUpd_Datetime =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 26)];
            [dictDSKHMoi setValue:LUpd_Datetime forKey:@"LUpd_Datetime"];
            
            NSString *CpnyName =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 27)];
            [dictDSKHMoi setValue:CpnyName forKey:@"CpnyName"];
            
            NSString *AddrCpny =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 28)];
            [dictDSKHMoi setValue:AddrCpny forKey:@"AddrCpny"];
            
            NSString *DateCpny =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 29)];
            [dictDSKHMoi setValue:DateCpny forKey:@"DateCpny"];
            
            NSString *Owner =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 30)];
            [dictDSKHMoi setValue:Owner forKey:@"Owner"];
            
            NSString *BankAccount =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 31)];
            [dictDSKHMoi setValue:BankAccount forKey:@"BankAccount"];
            
            NSString *ContactName1 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 32)];
            [dictDSKHMoi setValue:ContactName1 forKey:@"ContactName1"];
            
            NSString *Addr11 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 33)];
            [dictDSKHMoi setValue:Addr11 forKey:@"Addr11"];
            
            NSString *Phone1 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 34)];
            [dictDSKHMoi setValue:Phone1 forKey:@"Phone1"];
            
            NSString *Email1 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 35)];
            [dictDSKHMoi setValue:Email1 forKey:@"Email1"];
            
            NSString *DOB1 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 36)];
            [dictDSKHMoi setValue:DOB1 forKey:@"DOB1"];
            
            NSString *ContactName2 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 37)];
            [dictDSKHMoi setValue:ContactName2 forKey:@"ContactName2"];
            
            NSString *Addr21 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 38)];
            [dictDSKHMoi setValue:Addr21 forKey:@"Addr21"];
            
            NSString *Phone2 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 39)];
            [dictDSKHMoi setValue:Phone2 forKey:@"Phone2"];
            
            NSString *Email2 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 40)];
            [dictDSKHMoi setValue:Email2 forKey:@"Email2"];
            
            NSString *DOB2 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 41)];
            [dictDSKHMoi setValue:DOB2 forKey:@"DOB2"];
            
            NSString *ContactName3 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 42)];
            [dictDSKHMoi setValue:ContactName3 forKey:@"ContactName3"];
            
            NSString *Addr31 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 43)];
            [dictDSKHMoi setValue:Addr31 forKey:@"Addr31"];
            
            NSString *Phone3 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 44)];
            [dictDSKHMoi setValue:Phone3 forKey:@"Phone3"];
            
            NSString *Email3 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 45)];
            [dictDSKHMoi setValue:Email3 forKey:@"Email3"];
            
            NSString *DOB3 =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 46)];
            [dictDSKHMoi setValue:DOB3 forKey:@"DOB3"];
            
            [arrDSKHMoi addObject:dictDSKHMoi];
        }
    }
    sqlite3_finalize(statement);
    
    return arrDSKHMoi;
}

-(void) deleteAR_NewCustomerInforWithCustID:(NSString *)strCustID
{
    NSString *deleteStatement = [NSString stringWithFormat:
                                 @"DELETE FROM AR_NEWCUSTOMERINFOR WHERE CustID Like %@",
                                 strCustID];
    const char *sql= [deleteStatement UTF8String];
    sqlite3_stmt *deleteStmt;
    //NSLog(@"query: %@",deleteStatement);
    
    if(sqlite3_prepare_v2(db, sql, -1, &deleteStmt, NULL) != SQLITE_OK)
    {
        NSAssert1(0, @"Error while creating delete statement. %s", sqlite3_errmsg(db));
    }
    
    //when binding parameters, index starts from 1 and not zero
    sqlite3_bind_text(deleteStmt, 1, [strCustID UTF8String], -1, SQLITE_TRANSIENT);
    
    if(SQLITE_DONE !=sqlite3_step(deleteStmt))
        NSAssert1(0, @"Error while editing. %s", sqlite3_errmsg(db));
}

//TT Phan Hoi
-(NSMutableArray *) arrTTPhanHoiFromDatabase
{
    NSMutableArray *arrTTPhanHoi = [[NSMutableArray alloc] init];
    
    NSString *query = @"SELECT 'T' AS Type, Cast(Code AS int) as Code, IssueHeader AS Description FROM PPC_TechnicalSupport UNION SELECT 'Y' AS Type, Cast(Code AS int) as Code, RequestHeader AS Description FROM PPC_NoticeBoardSubmit";
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableDictionary *dictTTPhanHoi = [[NSMutableDictionary alloc] init];
            
            NSString *Type =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 0)];
            [dictTTPhanHoi setValue:Type forKey:@"Type"];
            
            NSString *Code =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 1)];
            [dictTTPhanHoi setValue:Code forKey:@"Code"];
            
            NSString *Description =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 2)];
            [dictTTPhanHoi setValue:Description forKey:@"Description"];
            
            [arrTTPhanHoi addObject:dictTTPhanHoi];
        }
    }
    sqlite3_finalize(statement);
    
    return arrTTPhanHoi;
}

-(NSMutableDictionary *) arrNewTechnicalSupportFromDatabaseWithCode:(NSString*)strCode
{
    NSMutableDictionary *newTechnicalSupport = [[NSMutableDictionary alloc] init];
    
    NSString *query = [NSString stringWithFormat:@"SELECT  t.Code as Code, IssueType, IssueHeader, IssueContent, ImageFileName, ti.NoteID as NoteID FROM PPC_TechnicalSupport  t , PPC_OM_TechnicalSupport_Image ti WHERE t.code = ti.code and t.code = %@", strCode];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        int count = 0;
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            
            if(count == 0)
            {
                NSString *Code =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 0)];
                [newTechnicalSupport setObject:Code forKey:@"Code"];
                
                NSString *IssueType =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 1)];
                [newTechnicalSupport setObject:IssueType forKey:@"IssueType"];
                
                NSString *IssueHeader =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 2)];
                [newTechnicalSupport setObject:IssueHeader forKey:@"IssueHeader"];
                
                NSString *IssueContent =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 3)];
                [newTechnicalSupport setObject:IssueContent forKey:@"IssueContent"];
                
                NSString *ImageFileName =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 4)];
                [newTechnicalSupport setObject:ImageFileName forKey:@"ImageFileName1"];
                
                NSString *NoteID =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 5)];
                [newTechnicalSupport setObject:NoteID forKey:@"NoteID1"];
                
            }else if(count == 1)
            {
                NSString *ImageFileName =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 4)];
                [newTechnicalSupport setObject:ImageFileName forKey:@"ImageFileName2"];
                
                NSString *NoteID =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 5)];
                [newTechnicalSupport setObject:NoteID forKey:@"NoteID2"];
                
            }else
            {
                NSString *ImageFileName =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 4)];
                [newTechnicalSupport setObject:ImageFileName forKey:@"ImageFileName3"];
                
                NSString *NoteID =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 5)];
                [newTechnicalSupport setObject:NoteID forKey:@"NoteID3"];
            }
            count ++;
        }
    }
    sqlite3_finalize(statement);
    
    return newTechnicalSupport;
}

-(NSMutableDictionary *) arrNoticeBoardSubmitFromDatabaseWithCode:(NSString*)strCode
{
    NSMutableDictionary *noticeBoardSubmit= [[NSMutableDictionary alloc] init];
    
    NSString *query = [NSString stringWithFormat:@"SELECT  t.Code as Code, RequestType, RequestHeader, RequestContent, ImageFileName, ti.NoteID as NoteID FROM PPC_NoticeBoardSubmit  t , PPC_OM_NoticeBoardSubmit_Image ti WHERE t.code = ti.code and t.code = %@", strCode];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        int count = 0;
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            
            if(count == 0)
            {
                NSString *Code =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 0)];
                [noticeBoardSubmit setObject:Code forKey:@"Code"];
                
                NSString *RequestType =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 1)];
                [noticeBoardSubmit setObject:RequestType forKey:@"RequestType"];
                
                NSString *RequestHeader =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 2)];
                [noticeBoardSubmit setObject:RequestHeader forKey:@"RequestHeader"];
                
                NSString *RequestContent =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 3)];
                [noticeBoardSubmit setObject:RequestContent forKey:@"RequestContent"];
                
                NSString *ImageFileName =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 4)];
                [noticeBoardSubmit setObject:ImageFileName forKey:@"ImageFileName1"];
                
                NSString *NoteID =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 5)];
                [noticeBoardSubmit setObject:NoteID forKey:@"NoteID1"];
                
            }else if(count == 1)
            {
                NSString *ImageFileName =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 4)];
                [noticeBoardSubmit setObject:ImageFileName forKey:@"ImageFileName2"];
                
                NSString *NoteID =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 5)];
                [noticeBoardSubmit setObject:NoteID forKey:@"NoteID2"];
                
            }else
            {
                NSString *ImageFileName =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 4)];
                [noticeBoardSubmit setObject:ImageFileName forKey:@"ImageFileName3"];
                
                NSString *NoteID =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 5)];
                [noticeBoardSubmit setObject:NoteID forKey:@"NoteID3"];
            }
            count ++;
        }
    }
    sqlite3_finalize(statement);
    
    return noticeBoardSubmit;
}

-(NSMutableDictionary *) arrPhanHoiFromDatabaseWithCode:(NSString*)strCode
{
    NSMutableDictionary *dictPhanHoi = [[NSMutableDictionary alloc] init];
    
    NSString *query = [NSString stringWithFormat:@"SELECT  n.Code as Code, RequestHeader, RequestContent, ImageFileName FROM PPC_NoticeBoardSubmit  n , PPC_OM_NoticeBoardSubmit_Image ni WHERE n.code = ni.code and n.code = %@", strCode];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        int count = 0;
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            
            if(count == 0)
            {
                NSString *Code =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 0)];
                [dictPhanHoi setObject:Code forKey:@"Code"];
                
                NSString *RequestHeader =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 1)];
                [dictPhanHoi setObject:RequestHeader forKey:@"RequestHeader"];
                
                NSString *RequestContent =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 2)];
                [dictPhanHoi setObject:RequestContent forKey:@"RequestContent"];
                
                NSString *ImageFileName =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 3)];
                [dictPhanHoi setObject:ImageFileName forKey:@"ImageFileName"];
                
            }else if(count == 1)
            {
                NSString *ImageFileName =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 3)];
                [dictPhanHoi setObject:ImageFileName forKey:@"ImageFileName2"];
                
            }else
            {
                NSString *ImageFileName =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 3)];
                [dictPhanHoi setObject:ImageFileName forKey:@"ImageFileName3"];
            }
            count ++;
        }
    }
    sqlite3_finalize(statement);
    
    return dictPhanHoi;
    
}

-(void) deletePPC_TechnicalSupportWithCode:(NSString *)strCode
{
    NSString *deleteStatement = [NSString stringWithFormat:
                                 @"DELETE FROM PPC_TECHNICALSUPPORT WHERE Code Like %@",
                                 strCode];
    const char *sql= [deleteStatement UTF8String];
    sqlite3_stmt *deleteStmt;
    //NSLog(@"query: %@",deleteStatement);
    
    if(sqlite3_prepare_v2(db, sql, -1, &deleteStmt, NULL) != SQLITE_OK)
    {
        NSAssert1(0, @"Error while creating delete statement. %s", sqlite3_errmsg(db));
    }
    
    //when binding parameters, index starts from 1 and not zero
    sqlite3_bind_text(deleteStmt, 1, [strCode UTF8String], -1, SQLITE_TRANSIENT);
    
    if(SQLITE_DONE !=sqlite3_step(deleteStmt))
        NSAssert1(0, @"Error while editing. %s", sqlite3_errmsg(db));
}

-(void) deletePPC_OM_TechnicalSupport_ImageWithCode:(NSString *)strCode
{
    NSString *deleteStatement = [NSString stringWithFormat:
                                 @"DELETE FROM PPC_OM_TECHNICALSUPPORT_IMAGE WHERE Code Like %@",
                                 strCode];
    const char *sql= [deleteStatement UTF8String];
    sqlite3_stmt *deleteStmt;
    //NSLog(@"query: %@",deleteStatement);
    
    if(sqlite3_prepare_v2(db, sql, -1, &deleteStmt, NULL) != SQLITE_OK)
    {
        NSAssert1(0, @"Error while creating delete statement. %s", sqlite3_errmsg(db));
    }
    
    //when binding parameters, index starts from 1 and not zero
    sqlite3_bind_text(deleteStmt, 1, [strCode UTF8String], -1, SQLITE_TRANSIENT);
    
    if(SQLITE_DONE !=sqlite3_step(deleteStmt))
        NSAssert1(0, @"Error while editing. %s", sqlite3_errmsg(db));
}
-(void) deletePPC_NoticeBoardSubmitWithCode:(NSString *)strCode
{
    NSString *deleteStatement = [NSString stringWithFormat:
                                 @"DELETE FROM PPC_NOTICEBOARDSUBMIT WHERE Code Like %@",
                                 strCode];
    const char *sql= [deleteStatement UTF8String];
    sqlite3_stmt *deleteStmt;
    //NSLog(@"query: %@",deleteStatement);
    
    if(sqlite3_prepare_v2(db, sql, -1, &deleteStmt, NULL) != SQLITE_OK)
    {
        NSAssert1(0, @"Error while creating delete statement. %s", sqlite3_errmsg(db));
    }
    
    //when binding parameters, index starts from 1 and not zero
    sqlite3_bind_text(deleteStmt, 1, [strCode UTF8String], -1, SQLITE_TRANSIENT);
    
    if(SQLITE_DONE !=sqlite3_step(deleteStmt))
        NSAssert1(0, @"Error while editing. %s", sqlite3_errmsg(db));
}

-(void) deletePPC_NoticeBoardSubmitImageWithCode:(NSString *)strCode
{
    NSString *deleteStatement = [NSString stringWithFormat:
                                 @"DELETE FROM PPC_OM_NOTICEBOARDSUBMIT_IMAGE WHERE Code Like %@",
                                 strCode];
    const char *sql= [deleteStatement UTF8String];
    sqlite3_stmt *deleteStmt;
    //NSLog(@"query: %@",deleteStatement);
    
    if(sqlite3_prepare_v2(db, sql, -1, &deleteStmt, NULL) != SQLITE_OK)
    {
        NSAssert1(0, @"Error while creating delete statement. %s", sqlite3_errmsg(db));
    }
    
    //when binding parameters, index starts from 1 and not zero
    sqlite3_bind_text(deleteStmt, 1, [strCode UTF8String], -1, SQLITE_TRANSIENT);
    
    if(SQLITE_DONE !=sqlite3_step(deleteStmt))
        NSAssert1(0, @"Error while editing. %s", sqlite3_errmsg(db));
}

//Update Ho tro ky thuat
-(void) updateHoTroKyThuatUsingNSUserDefaultWithCompletionHandler:(CompletionHandler)completionHandler
{
    NSUserDefaults *user = [ NSUserDefaults standardUserDefaults];
    
    NSString *str1 = [user valueForKey:@"HT_Code"]; // Code
    NSString *str2 = [user valueForKey:@"HT_RequestType"];
    NSString *str3 = [user valueForKey:@"HT_RequestHeader"];
    NSString *str4 = [user valueForKey:@"HT_RequestContent"];
    NSString *str5 = [user valueForKey:@"HT_RequestDate"];
    NSString *str6 = [user valueForKey:@"HT_Status"];

    sqlite3_stmt *stmt2;
    NSString *query = @"UPDATE PPC_TechnicalSupport SET IssueType = ?, IssueHeader = ?, IssueContent = ?, IssueDate = ?, Status = ? WHERE Code = ?";
    
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
    {
        sqlite3_bind_text(stmt2, 1, str2.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt2, 2, str3.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt2, 3, str4.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt2, 4, str5.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt2, 5, str6.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt2, 6, str1.UTF8String, -1, NULL);
    }
    if (sqlite3_step(stmt2) != SQLITE_DONE)
    {
        NSAssert(0, @"Error updating table.");
    }
    //NSLog(@"Save Avatar Done");
    sqlite3_finalize(stmt2);   
     
     NSData *pic1 = [user valueForKey:@"HT_Pic1"];
     NSData *pic2 = [user valueForKey:@"HT_Pic2"];
     NSData *pic3 = [user valueForKey:@"HT_Pic3"];
    
    // Save Pic 1
     if (pic1)
     {
         NSString *str_pic_2 = str1; //code         
         NSString *str_pic_3 = [user valueForKey:@"ImageFileName1"];// ten hinh
         
         NSDateFormatter *format = [[NSDateFormatter alloc] init];
         [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
         NSString *str_pic_4 = [format stringFromDate:[NSDate date]];//date
         NSString *str_pic_5 = [user valueForKey:@"HT_NoteID1"];// Note ID
         
         // Save Database
         sqlite3_stmt *stm;
         NSString *queryPic = @"UPDATE PPC_OM_TechnicalSupport_Image SET ImageFileName = ? , CreateDate = ? WHERE Code = ? and NoteID = ?";
         if (sqlite3_prepare_v2(db, [queryPic UTF8String], -1, &stm, nil) == SQLITE_OK)
         {
             sqlite3_bind_text(stm, 1, str_pic_3.UTF8String, -1, NULL);
             sqlite3_bind_text(stm, 2, str_pic_4.UTF8String, -1, NULL);
             sqlite3_bind_text(stm, 3, str_pic_2.UTF8String, -1, NULL);
             sqlite3_bind_text(stm, 4, str_pic_5.UTF8String, -1, NULL);
             
         }
         if (sqlite3_step(stm) != SQLITE_DONE)
         {
             NSAssert(0, @"Error updating table.");
         }
         //NSLog(@"Save Avatar Done");
         sqlite3_finalize(stm);
         
         // Save document
         // Save Data to Document
         NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
         NSString *pathDocument = [paths objectAtIndex:0];
         
         NSString *pathAvatar = [pathDocument stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",str_pic_3]];
         NSError *error;
         [pic1 writeToFile:pathAvatar options:NSDataWritingAtomic error:&error];
     
     }
    
     if (pic2)
     {
         NSString *str_pic_2 = str1; //code
         NSString *str_pic_3 = [user valueForKey:@"ImageFileName2"];// ten hinh
         
         NSDateFormatter *format = [[NSDateFormatter alloc] init];
         [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
         NSString *str_pic_4 = [format stringFromDate:[NSDate date]];//date
         NSString *str_pic_5 = [user valueForKey:@"HT_NoteID2"];// Note ID
         
         // Save Database
         sqlite3_stmt *stm;
         NSString *queryPic = @"UPDATE PPC_OM_TechnicalSupport_Image SET ImageFileName = ? , CreateDate = ? WHERE Code = ? and NoteID = ?";
         if (sqlite3_prepare_v2(db, [queryPic UTF8String], -1, &stm, nil) == SQLITE_OK)
         {
             sqlite3_bind_text(stm, 1, str_pic_3.UTF8String, -1, NULL);
             sqlite3_bind_text(stm, 2, str_pic_4.UTF8String, -1, NULL);
             sqlite3_bind_text(stm, 3, str_pic_2.UTF8String, -1, NULL);
             sqlite3_bind_text(stm, 4, str_pic_5.UTF8String, -1, NULL);
             
         }
         if (sqlite3_step(stm) != SQLITE_DONE)
         {
             NSAssert(0, @"Error updating table.");
         }
         //NSLog(@"Save Avatar Done");
         sqlite3_finalize(stm);
         
         // Save document
         // Save Data to Document
         NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
         NSString *pathDocument = [paths objectAtIndex:0];
         
         NSString *pathAvatar = [pathDocument stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",str_pic_3]];
         NSError *error;
         [pic2 writeToFile:pathAvatar options:NSDataWritingAtomic error:&error];
     
     
     }
     if (pic3)
     {
         NSString *str_pic_2 = str1; //code         
         NSString *str_pic_3 = [user valueForKey:@"ImageFileName3"];// ten hinh
         
         NSDateFormatter *format = [[NSDateFormatter alloc] init];
         [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
         NSString *str_pic_4 = [format stringFromDate:[NSDate date]];//date
         NSString *str_pic_5 = [user valueForKey:@"HT_NoteID3"];// Note ID
         
         // Save Database
         sqlite3_stmt *stm;
         NSString *queryPic = @"UPDATE PPC_OM_TechnicalSupport_Image SET ImageFileName = ? , CreateDate = ? WHERE Code = ? and NoteID = ?";
         if (sqlite3_prepare_v2(db, [queryPic UTF8String], -1, &stm, nil) == SQLITE_OK)
         {
             sqlite3_bind_text(stm, 1, str_pic_3.UTF8String, -1, NULL);
             sqlite3_bind_text(stm, 2, str_pic_4.UTF8String, -1, NULL);
             sqlite3_bind_text(stm, 3, str_pic_2.UTF8String, -1, NULL);
             sqlite3_bind_text(stm, 4, str_pic_5.UTF8String, -1, NULL);
             
         }
         if (sqlite3_step(stm) != SQLITE_DONE)
         {
             NSAssert(0, @"Error updating table.");
         }
         //NSLog(@"Save Avatar Done");
         sqlite3_finalize(stm);
         
         // Save document
         // Save Data to Document
         NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
         NSString *pathDocument = [paths objectAtIndex:0];
         
         NSString *pathAvatar = [pathDocument stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",str_pic_3]];
         NSError *error;
         [pic3 writeToFile:pathAvatar options:NSDataWritingAtomic error:&error];
     
     }
     
    completionHandler(YES);
    
}

-(void) updatePhanHoiUsingNSUserDefaultWithCompletionHandler:(CompletionHandler)completionHandler
{
    NSUserDefaults *user = [ NSUserDefaults standardUserDefaults];
    
    NSString *str1 = [user valueForKey:@"PH_Code"]; // Code
    NSString *str2 = [user valueForKey:@"PH_RequestType"];
    NSString *str3 = [user valueForKey:@"PH_RequestHeader"];
    NSString *str4 = [user valueForKey:@"PH_RequestContent"];
    NSString *str5 = [user valueForKey:@"PH_RequestDate"];
    NSString *str6 = [user valueForKey:@"PH_Status"];
    
    sqlite3_stmt *stmt2;
    NSString *query = @"UPDATE PPC_NoticeBoardSubmit SET RequestType =? , RequestHeader =? , RequestContent =?, RequestDate = ?, Status = ? WHERE Code = ? ";
    
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
    {
        sqlite3_bind_text(stmt2, 1, str2.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt2, 2, str3.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt2, 3, str4.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt2, 4, str5.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt2, 5, str6.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt2, 6, str1.UTF8String, -1, NULL);
    }
    if (sqlite3_step(stmt2) != SQLITE_DONE)
    {
        NSAssert(0, @"Error updating table.");
    }
    //NSLog(@"Save Avatar Done");
    sqlite3_finalize(stmt2);
    
    
    // Save Pic 1
    NSData *pic1 = [user valueForKey:@"PH_Pic1"];
    NSData *pic2 = [user valueForKey:@"PH_Pic2"];
    NSData *pic3 = [user valueForKey:@"PH_Pic3"];
    
    if (pic1)
    {
        NSString *str_pic_1 = str1; // Code
        NSString *str_pic_2 = [user valueForKey:@"PH_NoticeNoteID1"]; //NoteID
        NSString *str_pic_3 = [user valueForKey:@"PH_NoticeImageFileName1"];// img Name
        
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *str_pic_4 = [format stringFromDate:[NSDate date]];// Date
        
        // Save Database
        sqlite3_stmt *stm;
        NSString *queryPic = @"UPDATE PPC_OM_NoticeBoardSubmit_Image SET ImageFileName = ? , CreateDate = ? WHERE Code = ? and NoteID = ?";
        if (sqlite3_prepare_v2(db, [queryPic UTF8String], -1, &stm, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stm, 1, str_pic_3.UTF8String, -1, NULL);
            sqlite3_bind_text(stm, 2, str_pic_4.UTF8String, -1, NULL);
            sqlite3_bind_text(stm, 3, str_pic_1.UTF8String, -1, NULL);
            sqlite3_bind_text(stm, 4, str_pic_2.UTF8String, -1, NULL);
            
        }
        if (sqlite3_step(stm) != SQLITE_DONE)
        {
            NSAssert(0, @"Error updating table.");
        }
        //NSLog(@"Save Avatar Done");
        sqlite3_finalize(stm);
        
        // Save document
        // Save Data to Document
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *pathDocument = [paths objectAtIndex:0];
        
        NSString *pathAvatar = [pathDocument stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",str_pic_3]];
        NSError *error;
        [pic1 writeToFile:pathAvatar options:NSDataWritingAtomic error:&error];
        
    }
    if (pic2)
    {
        
        NSString *str_pic_1 = str1; // Code
        NSString *str_pic_2 = [user valueForKey:@"PH_NoticeNoteID2"]; //NoteID
        NSString *str_pic_3 = [user valueForKey:@"PH_NoticeImageFileName2"];// img Name
        
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *str_pic_4 = [format stringFromDate:[NSDate date]];// Date
        
        // Save Database
        sqlite3_stmt *stm;
        NSString *queryPic = @"UPDATE PPC_OM_NoticeBoardSubmit_Image SET ImageFileName = ? , CreateDate = ? WHERE Code = ? and NoteID = ?";
        if (sqlite3_prepare_v2(db, [queryPic UTF8String], -1, &stm, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stm, 1, str_pic_3.UTF8String, -1, NULL);
            sqlite3_bind_text(stm, 2, str_pic_4.UTF8String, -1, NULL);
            sqlite3_bind_text(stm, 3, str_pic_1.UTF8String, -1, NULL);
            sqlite3_bind_text(stm, 4, str_pic_2.UTF8String, -1, NULL);
            
        }
        if (sqlite3_step(stm) != SQLITE_DONE)
        {
            NSAssert(0, @"Error updating table.");
        }
        //NSLog(@"Save Avatar Done");
        sqlite3_finalize(stm);
        
        // Save document
        // Save Data to Document
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *pathDocument = [paths objectAtIndex:0];
        
        NSString *pathAvatar = [pathDocument stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",str_pic_3]];
        NSError *error;
        [pic2 writeToFile:pathAvatar options:NSDataWritingAtomic error:&error];
        
        
    }
    if (pic3)
    {
        
        NSString *str_pic_1 = str1; // Code
        NSString *str_pic_2 = [user valueForKey:@"PH_NoticeNoteID3"]; //NoteID
        NSString *str_pic_3 = [user valueForKey:@"PH_NoticeImageFileName3"];// img Name
        
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *str_pic_4 = [format stringFromDate:[NSDate date]];// Date
        
        // Save Database
        sqlite3_stmt *stm;
        NSString *queryPic = @"UPDATE PPC_OM_NoticeBoardSubmit_Image SET ImageFileName = ? , CreateDate = ? WHERE Code = ? and NoteID = ?";
        if (sqlite3_prepare_v2(db, [queryPic UTF8String], -1, &stm, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stm, 1, str_pic_3.UTF8String, -1, NULL);
            sqlite3_bind_text(stm, 2, str_pic_4.UTF8String, -1, NULL);
            sqlite3_bind_text(stm, 3, str_pic_1.UTF8String, -1, NULL);
            sqlite3_bind_text(stm, 4, str_pic_2.UTF8String, -1, NULL);
            
        }
        if (sqlite3_step(stm) != SQLITE_DONE)
        {
            NSAssert(0, @"Error updating table.");
        }
        //NSLog(@"Save Avatar Done");
        sqlite3_finalize(stm);
        
        // Save document
        // Save Data to Document
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *pathDocument = [paths objectAtIndex:0];
        
        NSString *pathAvatar = [pathDocument stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",str_pic_3]];
        NSError *error;
        [pic3 writeToFile:pathAvatar options:NSDataWritingAtomic error:&error];
        
    }
    
    completionHandler(YES);
}

// Doi Chieu Cong No

-(NSMutableArray *) arrDoiChieuCongNoFromDatabaseWithCustomerID:(NSString *)custID
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    NSString *query =  [NSString stringWithFormat:@"SELECT CustID, RefNbr, InvNbr, Date, Descr, Debit, Credit FROM AR_Transaction WHERE CustID = '%@'",custID];
    NSLog(@"Query PPC_AgingDebt = %@",query);
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSString *CustID =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 0)];
            
            NSString *RefNbr =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 1)];
            
            NSString *InvNbr =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 2)];
            
            NSString *Date =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 3)];
            Date = [Date substringToIndex:10];
            
            NSString *Desc =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 4)];
            
            double Debit = (double) sqlite3_column_double(statement, 5);
            double Credit = (double) sqlite3_column_double(statement, 6);
                
            NSMutableDictionary *row = [NSMutableDictionary dictionaryWithObjectsAndKeys:CustID,@"CustID",
                                        RefNbr,@"RefNbr",
                                        InvNbr,@"InvNbr",
                                        Date,@"Date",
                                        Desc,@"Desc",
                                        [NSNumber numberWithDouble:Debit],@"Debit",
                                        [NSNumber numberWithDouble:Credit],@"Credit",nil];
            
            [arr addObject:row];
        }
    }
    sqlite3_finalize(statement);
    
    return arr;
}

// SL Ghi Nhan Don Hang
-(NSMutableArray *) arrSLGhiNhanDonHangFromDatabaseWithOrderNbr:(NSString*)orderNbr
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    NSString *query =  [NSString stringWithFormat:@"SELECT a.LineQty , a.InvtID,  b.CustID FROM OM_SalesOrdDet a , OM_SalesOrd b WHERE a.OrderNbr = b.OrderNbr and b.OrderNbr = %@", orderNbr];//a.SlsPrice
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            double LineQty = (double) sqlite3_column_double(statement, 0);
            char *InvtID = (char *) sqlite3_column_text(statement, 1);
            char *CustID = (char *) sqlite3_column_text(statement, 2);
            
            NSMutableDictionary *row = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:LineQty],@"LineQty",
                [NSString stringWithUTF8String:InvtID],@"InvtID",
                [NSString stringWithUTF8String:CustID],@"CustID",
                                        nil];
            
            [arr addObject:row];
        }
    }
    sqlite3_finalize(statement);
    
    return arr;
}
-(void) deleteDonHangCuFromDatabaseWithOrderNbr:(NSString*)orderNbr
{
    NSString *deleteStatement = [NSString stringWithFormat:
                                 @"DELETE FROM OM_SalesOrdDet WHERE OrderNbr = %@",
                                 orderNbr];
    const char *sql= [deleteStatement UTF8String];
    sqlite3_stmt *deleteStmt;
    //NSLog(@"query: %@",deleteStatement);
    
    if(sqlite3_prepare_v2(db, sql, -1, &deleteStmt, NULL) != SQLITE_OK)
    {
        NSAssert1(0, @"Error while creating delete statement. %s", sqlite3_errmsg(db));
    }
    
    //when binding parameters, index starts from 1 and not zero
    sqlite3_bind_text(deleteStmt, 1, [orderNbr UTF8String], -1, SQLITE_TRANSIENT);
    
    if(SQLITE_DONE !=sqlite3_step(deleteStmt))
        NSAssert1(0, @"Error while editing. %s", sqlite3_errmsg(db));
}

// Get max Id in Table
-(NSString *) maxIDForTable:(NSString *) table columnName:(NSString *) column
{
    
    // get current ID
    NSMutableArray *arrID = [[NSMutableArray alloc] init];
    NSString *query = [NSString stringWithFormat:@"SELECT %@ FROM %@",column, table ];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *ID = (char *) sqlite3_column_text(statement, 0);
            
            [arrID addObject:[NSString stringWithUTF8String:ID]];
        }
    }
    sqlite3_finalize(statement);
    
    // check if has = row - New table -no data
    if (arrID.count == 0)
        return @"0";
    
    // Current ID        
    NSInteger currentIndex;
    NSInteger maxIndex = 0;
    
    for(int i = 0; i < [arrID count]; i ++)
    {            
        currentIndex = [[arrID objectAtIndex:i] integerValue];
        if(currentIndex > maxIndex)
            maxIndex = currentIndex;
    }

    return [NSString stringWithFormat:@"%d",maxIndex + 1];
}

// Get URL Sync
-(NSMutableDictionary*)getURLSyncFromDatabase
{
    NSMutableDictionary *dictURL = [[NSMutableDictionary alloc] init];
    
    NSString *query = @"SELECT IsSyncWAN, SyncAddress, SyncAddressWAN FROM Setting";
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            int IsSyncWAN = (int) sqlite3_column_int(statement, 0);
            char *SyncAddress = (char *) sqlite3_column_text(statement, 1);
            char *SyncAddressWAN = (char *) sqlite3_column_text(statement, 2);
            
            dictURL= [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:IsSyncWAN],@"IsSyncWAN",
                                        [NSString stringWithUTF8String:SyncAddress],@"SyncAddress",
                                        [NSString stringWithUTF8String:SyncAddressWAN],@"SyncAddressWAN",
                                        nil];
        }
    }
    sqlite3_finalize(statement);
    
    return dictURL;
}

// Get Query KH
-(NSMutableArray*) arrPPC_ARCustomerInfoFromDatabase
{
    NSMutableArray *arrCust = [[NSMutableArray alloc] init];
    
    NSString *query = @"SELECT CustID, CustName, Addr1, TradeType FROM PPC_ARCustomerInfo";
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableDictionary *dictCust = [[NSMutableDictionary alloc] init];
            
            char *CustID = (char *) sqlite3_column_text(statement, 0);
            char *CustName = (char *) sqlite3_column_text(statement, 1);
            char *Addr1 = (char *) sqlite3_column_text(statement, 2);
            char *TradeType = (char *) sqlite3_column_text(statement, 3);
            
            dictCust= [NSMutableDictionary dictionaryWithObjectsAndKeys:
                       [NSString stringWithUTF8String:CustID],@"CustID",
                       [NSString stringWithUTF8String:CustName],@"CustName",
                       [NSString stringWithUTF8String:Addr1],@"Addr1",
                       [NSString stringWithUTF8String:TradeType],@"TradeType",
                       nil];
            [arrCust addObject:dictCust];
        }
    }
    sqlite3_finalize(statement);
    
    return arrCust;
}
    // Get Cust NonTrade
-(NSMutableArray*) arrCustomerNonTradeFromDatabaseWithCustID:(NSString*)custID
{
    NSMutableArray *arrCust = [[NSMutableArray alloc] init];
    
    NSString *query = [NSString stringWithFormat: @"SELECT CustID, CustName, Address FROM AR_Customer WHERE CustID in (SELECT CustID FROM PPC_Distributor WHERE Distributor = '%@')", custID];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        NSLog(@"count : %d", sqlite3_step(statement));
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableDictionary *dictCust = [[NSMutableDictionary alloc] init];
            
            char *CustID = (char *) sqlite3_column_text(statement, 0);
            char *CustName = (char *) sqlite3_column_text(statement, 1);
            char *Addr = (char *) sqlite3_column_text(statement, 2);
            
            dictCust= [NSMutableDictionary dictionaryWithObjectsAndKeys:
                       [NSString stringWithUTF8String:CustID],@"CustID",
                       [NSString stringWithUTF8String:CustName],@"CustName",
                       [NSString stringWithUTF8String:Addr],@"Address",
                       nil];
            [arrCust addObject:dictCust];
        }
    }
    sqlite3_finalize(statement);
    

    return arrCust;
}
    // Get Cust Trade
-(NSMutableArray*) arrCustomerTradeFromDatabaseWithCustID:(NSString*)custID
{
    NSMutableArray *arrCust = [[NSMutableArray alloc] init];
    
    NSString *query = [NSString stringWithFormat: @"SELECT CustID, CustName, Address FROM AR_Customer WHERE CustID in (SELECT Distributor FROM PPC_Distributor WHERE CustID = '%@')", custID];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableDictionary *dictCust = [[NSMutableDictionary alloc] init];
            
            char *CustID = (char *) sqlite3_column_text(statement, 0);
            char *CustName = (char *) sqlite3_column_text(statement, 1);
            char *Addr = (char *) sqlite3_column_text(statement, 2);
            
            dictCust= [NSMutableDictionary dictionaryWithObjectsAndKeys:
                       [NSString stringWithUTF8String:CustID],@"CustID",
                       [NSString stringWithUTF8String:CustName],@"CustName",
                       [NSString stringWithUTF8String:Addr],@"Address",
                       nil];
            [arrCust addObject:dictCust];
        }
    }
    sqlite3_finalize(statement);
    
    return arrCust;
}
-(NSMutableArray*) arrSurveyBrandFromDatabaseWithCustID:(NSString*)custID
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    NSString *query = [NSString stringWithFormat: @"SELECT Brand, ThucTe, ChiTieu Address FROM PPC_SurveyBrand WHERE CustID = '%@'", custID];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
            char *Brand = (char *) sqlite3_column_text(statement, 0);
            double ThucTe = (double) sqlite3_column_double(statement, 1);
            double ChiTieu = (double) sqlite3_column_double(statement, 2);
            
            dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                       [NSString stringWithUTF8String:Brand],@"Brand",
                       [NSNumber numberWithDouble:ThucTe],@"ThucTe",
                       [NSNumber numberWithDouble:ChiTieu],@"ChiTieu",
                       nil];
            [arr addObject:dict];
        }
    }
    sqlite3_finalize(statement);
    
    return arr;
}
// Price of Site
-(NSMutableArray*) arrSiteFromDatabaseWithInvtID:(NSString*)invtID
{
    NSMutableArray *arrSite = [[NSMutableArray alloc] init];
    
    NSString *query =[NSString stringWithFormat: @"SELECT SiteID, Name FROM In_Site  WHERE InvtID='%@'", invtID];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableDictionary *dictSite = [[NSMutableDictionary alloc] init];
            
            char *SiteID = (char *) sqlite3_column_text(statement, 0);
            char *Descr = (char *) sqlite3_column_text(statement, 1);
            
            dictSite= [NSMutableDictionary dictionaryWithObjectsAndKeys:
                       [NSString stringWithUTF8String:SiteID],@"SiteID",
                       [NSString stringWithUTF8String:Descr],@"Name",
                       nil];
            [arrSite addObject:dictSite];
        }
    }
    sqlite3_finalize(statement);
    
    return arrSite;
}
-(NSMutableArray*) arrSiteFromDatabase
{
    NSMutableArray *arrSite = [[NSMutableArray alloc] init];
    
    NSString *query =@"SELECT SiteID, Name FROM In_Site Group By SiteID, Name";
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableDictionary *dictSite = [[NSMutableDictionary alloc] init];
            
            char *SiteID = (char *) sqlite3_column_text(statement, 0);
            char *Name = (char *) sqlite3_column_text(statement, 1);
            
            dictSite= [NSMutableDictionary dictionaryWithObjectsAndKeys:
                       [NSString stringWithUTF8String:SiteID],@"SiteID",
                       [NSString stringWithUTF8String:Name],@"Name",
                       nil];
            [arrSite addObject:dictSite];
        }
    }
    sqlite3_finalize(statement);
    
    return arrSite;
}
-(CGFloat) priceOfSite:(NSString*)siteID AndInvtID:(NSString*)invtID
{
    CGFloat price;
    
    NSString *query =[NSString stringWithFormat: @"SELECT DiscPrice FROM PPC_PriceOfCust  WHERE SiteID='%@' AND InvtID='%@'", siteID, invtID];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            price = (double ) sqlite3_column_double(statement, 0);
            return price;
        }
    }
    sqlite3_finalize(statement);
    
    return 0;
}
// Task
-(NSMutableArray*) arrOM_DefineWorksFromDatabase
{
    NSMutableArray *arrWork = [[NSMutableArray alloc] init];
    
    NSString *query = @"SELECT TaskID, Name, Shooting, Required FROM OM_DefineWorks";
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableDictionary *dictWork = [[NSMutableDictionary alloc] init];
            
            char *TaskID = (char *) sqlite3_column_text(statement, 0);
            char *Name = (char *) sqlite3_column_text(statement, 1);
            char *Shooting = (char *) sqlite3_column_text(statement, 2);
            char *Required = (char *) sqlite3_column_text(statement, 3);
            
            dictWork= [NSMutableDictionary dictionaryWithObjectsAndKeys:
                       [NSString stringWithUTF8String:TaskID],@"TaskID",
                       [NSString stringWithUTF8String:Name],@"Name",
                       [NSString stringWithUTF8String:Shooting],@"Shooting",
                       [NSString stringWithUTF8String:Required],@"Required",
                       nil];
            [arrWork addObject:dictWork];
        }
    }
    sqlite3_finalize(statement);
    
    return arrWork;
    
}

-(BOOL)checkTaskExistInDatabaseWithCustID:(NSString*)custID AndTaskID:(NSString*)taskID
{
    NSString *query =[NSString stringWithFormat:@"SELECT * FROM PPC_Task WHERE CustID='%@' AND TaskID='%@'", custID, taskID];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            return YES;
        }
    }
    sqlite3_finalize(statement);
    return NO;
}

-(void) saveTaskDictionary:(NSMutableDictionary *) dict WithCompletionHandler:(CompletionHandler)completionHandler
{
    NSString *str1 = [dict valueForKey:@"TaskID"];
    NSString *str2 = [dict valueForKey:@"Name"];
    NSString *str3 = [dict valueForKey:@"ImageName"];
    NSString *str4 = [dict valueForKey:@"Note"];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *str5 = [format stringFromDate:[NSDate date]];
    
    NSString *str6 = [dict valueForKey:@"CustID"];
    
    sqlite3_stmt *stmt2;
    NSString *query = @"INSERT INTO PPC_Task VALUES(?,?,?,?,?,?)";
    
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt2, nil) == SQLITE_OK)
    {
        sqlite3_bind_text(stmt2, 1, str1.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt2, 2, str2.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt2, 3, str3.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt2, 4, str4.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt2, 5, str5.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt2, 6, str6.UTF8String, -1, NULL);
    }
    if (sqlite3_step(stmt2) != SQLITE_DONE)
    {
        NSAssert(0, @"Error insert table.");
    }
    //NSLog(@"Save Avatar Done");
    sqlite3_finalize(stmt2);
    
    // Save Pic 1
    NSData *pic1 = [dict valueForKey:@"HT_Pic"];
    
    if (pic1)
    {
        // Save document
        // Save Data to Document
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *pathDocument = [paths objectAtIndex:0];
        
        NSString *pathAvatar = [pathDocument stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",str3]];
        NSError *error;
        [pic1 writeToFile:pathAvatar options:NSDataWritingAtomic error:&error];   
    }

    completionHandler(YES);
    
}

-(void) updateTaskWithDict:(NSMutableDictionary*)dict WithCompletionHandler:(CompletionHandler)completionHandler
{
    
    NSString *str1 = [dict valueForKey:@"ImageName"];
    NSString *str2 = [dict valueForKey:@"Note"];
    NSString *str3 = [dict valueForKey:@"TaskID"];
    NSString *str4 = [dict valueForKey:@"CustID"];
    
    NSString *query3 = @"UPDATE PPC_Task SET ImageName =? , Note =? WHERE TaskID =? AND CustID= ?";
    
    
    sqlite3_stmt *stmt3;
    
    
    if (sqlite3_prepare_v2(db, [query3 UTF8String], -1, &stmt3, nil) == SQLITE_OK)
    {
        sqlite3_bind_text(stmt3, 1, str1.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt3, 2, str2.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt3, 3, str3.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt3, 4, str4.UTF8String, -1, NULL);
    }
    if (sqlite3_step(stmt3) != SQLITE_DONE)
    {
        NSAssert(0, @"Error updating table.");
    }
    sqlite3_finalize(stmt3);
    
    
    completionHandler(YES);
    
}

-(NSMutableDictionary*)arrTaskExistInDatabaseWithCustID:(NSString*)custID AndTaskID:(NSString*)taskID
{
    NSMutableDictionary *dictTask = [[NSMutableDictionary alloc] init];
    
    NSString *query =[NSString stringWithFormat:@"SELECT * FROM PPC_Task WHERE CustID='%@' AND TaskID='%@'", custID, taskID];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *ImageName = (char *) sqlite3_column_text(statement, 2);
            char *Note = (char *) sqlite3_column_text(statement, 3);
            
            dictTask= [NSMutableDictionary dictionaryWithObjectsAndKeys:
                       [NSString stringWithUTF8String:ImageName],@"ImageName",
                       [NSString stringWithUTF8String:Note],@"Note",
                       nil];
        }
    }
    sqlite3_finalize(statement);
    return dictTask;
}
@end
