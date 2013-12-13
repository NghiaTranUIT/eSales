//
//  FeGPSViewController.h
//  eSales
//
//  Created by Nghia Tran on 9/2/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "FeDSKhachHang.h"

@interface FeGPSViewController : UIViewController < CLLocationManagerDelegate,MKMapViewDelegate,FeDSKhachHangDelegate,UISearchBarDelegate>

// Text Box
@property (weak, nonatomic) IBOutlet UITextField *txbNgayVT;
@property (weak, nonatomic) IBOutlet UITextField *txbTimTheo;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

// Tab
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tabBanDo;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tabDSKhachHang;
- (IBAction)tabBanDoTapped:(id)sender;
- (IBAction)tabDSKhachHangTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBarMap;

// Main View
@property (strong, nonatomic) IBOutlet UIView *mainViewBanDo;
@property (strong, nonatomic) FeDSKhachHang *mainViewDSKhachHang;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

// GPS
- (IBAction)btnCapNhatViTri:(id)sender;
@property (strong, nonatomic) CLLocationManager *locationManager;
@end
