//
//  FeGPSViewController.m
//  eSales
//
//  Created by Nghia Tran on 9/2/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeGPSViewController.h"
#import "FeDatabaseManager.h"
#import "ActionSheetPicker.h"
#import "FeAnnotation.h"
#import "FeAnnotationView.h"
#import "FePinAnnotationView.h"


@interface FeGPSViewController () <UITextFieldDelegate>
{
    BOOL isTabBanDoSelected;
    BOOL isTabDSKhachHangSelected;
    BOOL isSearching;
    NSInteger indexTimTheo;
    
    NSMutableArray *_arrSearching;
}

@property (strong, nonatomic) NSMutableArray *arrDSKhachHang;
@property (strong, nonatomic) NSMutableArray *arrTimKiem;
@property (strong, nonatomic) NSString *dateSelected;
@property (strong, nonatomic) NSMutableArray *arrKHChangedGPS;

- (void)dateWasSelected:(NSDate *)selectedDate element:(id)element;

-(void) setupDefaultView;

-(void) btnCapNhatGPS:(id) sender;
@end

@implementation FeGPSViewController
@synthesize txbNgayVT = _txbNgayVT, txbTimTheo = _txbTimTheo, tabBanDo = _tabBanDo, tabDSKhachHang = _tabDSKhachHang, mainViewBanDo = _mainViewBanDo, mapView = _mapView;
@synthesize arrDSKhachHang = _arrDSKhachHang, arrTimKiem = _arrTimKiem;
@synthesize dateSelected = _dateSelected;
@synthesize locationManager = _locationManager, mainViewDSKhachHang = _mainViewDSKhachHang;
@synthesize toolBarMap = _toolBarMap, searchBar = _searchBar;
@synthesize arrKHChangedGPS = _arrKHChangedGPS;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setupDefaultView];
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    bg.frame = self.view.frame;
    bg.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:bg atIndex:0];
    
}
-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // Save to database
    [_locationManager stopUpdatingLocation];
    
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    [db saveGPSForCustomerWithArr:_arrKHChangedGPS];
    
}
-(void) setupDefaultView
{
    // default Tab
    isSearching = NO;
    isTabBanDoSelected = YES;
    isTabDSKhachHangSelected = NO;
    _tabBanDo.style = UIBarButtonItemStyleDone;
    _arrKHChangedGPS = [[NSMutableArray alloc] init];
    
    
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    _dateSelected = [db stringMaxDateFromDatabase];
    
    NSLog(@"date Selected = %@",_dateSelected);
    _arrDSKhachHang = [db arrGSPDSKhachHangFromDatabaseAtDate:_dateSelected];
    
    if (!_arrDSKhachHang || _arrDSKhachHang.count == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Thông Báo" message:@"Không tìm thấy khách hàng" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alertView show];
        
    }
    
    NSLog(@"original = %@",_arrDSKhachHang);
    
    _arrTimKiem = [[NSMutableArray alloc] initWithObjects:@"Tất cả", nil];
    
    // Set default value
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd 00:00:00"];
    NSDate *date = [format dateFromString:_dateSelected];
    
    NSDateFormatter *newFormat = [[NSDateFormatter alloc] init];
    [newFormat setDateFormat:@"yyy-MM-dd"];
    _txbNgayVT.text = [newFormat stringFromDate:date];
    
    indexTimTheo = 0;
    _txbTimTheo.text = [_arrTimKiem objectAtIndex:indexTimTheo];
    
    // init Core Location
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager startUpdatingLocation];
    
    _mapView.delegate = self;
    [_mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
    
    // Add Bar
    //Create BarButtonItem for controller user location tracking
    MKUserTrackingBarButtonItem *trackingBarButton = [[MKUserTrackingBarButtonItem alloc] initWithMapView:_mapView];
    UIBarButtonItem *capNhatBtn = [[UIBarButtonItem alloc] initWithTitle:@"Cập nhật vị trí hiện tại" style:UIBarButtonItemStyleBordered target:self action:@selector(btnCapNhatGPS:)];
    
    //Add UserTrackingBarButtonItem to
    [_toolBarMap setItems:[NSArray arrayWithObjects:trackingBarButton,capNhatBtn, nil] animated:YES];
    
    // init Some annotaton
    for (NSMutableDictionary *dict in _arrDSKhachHang)
    {
        NSString *title = [dict objectForKey:@"CustName"];
        NSString *custID = [dict objectForKey:@"CustID"];
        NSString *add = [dict objectForKey:@"Addr1"];
        NSNumber *lng = [dict objectForKey:@"lng"];
        NSNumber *lat = [dict objectForKey:@"lat"];
        
        if (lat.floatValue == 0 || lng.floatValue == 0)
        {
            lng = [NSNumber numberWithDouble:_locationManager.location.coordinate.longitude];
            lat = [NSNumber numberWithDouble:_locationManager.location.coordinate.latitude];
            
        }
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(lat.doubleValue, lng.doubleValue);
        
        FeAnnotation *myAnnotation = [[FeAnnotation alloc] initWithCoordinate:location];
        myAnnotation.title = title;
        myAnnotation.subtitle = add;
        myAnnotation.custID = custID;
        
        [_mapView  addAnnotation:myAnnotation];
    }

}
-(void) btnCapNhatGPS:(id)sender
{
    NSArray *arr = [_mapView selectedAnnotations];
    if (arr.count > 0)
    {
        FeAnnotation *anno = [arr lastObject];
        
        // CHeck isKindOfClass MKUserLocation
        if ([anno isKindOfClass:[MKUserLocation class]])
            return;
        
        NSLog(@"cust Name = %@ , custID = %@",anno.title,anno.custID);
        
        for (NSMutableDictionary *dict in _arrDSKhachHang)
        {
            if ([[dict objectForKey:@"CustID"] isEqualToString:anno.custID])
            {
                NSNumber *lng = [dict objectForKey:@"lng"];
                NSNumber *lat = [dict objectForKey:@"lat"];
                
                lng = [NSNumber numberWithDouble:_locationManager.location.coordinate.longitude];
                lat = [NSNumber numberWithDouble:_locationManager.location.coordinate.latitude];
                
                anno.coordinate = CLLocationCoordinate2DMake(lat.doubleValue, lng.doubleValue);
                
                // Set again
                [dict setObject:lng forKey:@"lng"];
                [dict setObject:lat forKey:@"lat"];
                
                // add to arrGPSChanged;
                [_arrKHChangedGPS addObject:dict];
                
                break;
            }
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông báo" message:[NSString stringWithFormat:@"Cập nhật vị trí của KH %@ thành công",anno.title] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];

        [alert show];

    }
    NSLog(@"cap nhat vi tri = %@",arr);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [_txbTimTheo resignFirstResponder];
    
    return YES;
}
-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if (isSearching || _searchBar.isFirstResponder )
    {
        [_searchBar resignFirstResponder];
        [self searchBarCancelButtonClicked:_searchBar];
    }
    if (textField == _txbNgayVT)
    {
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd 00:00:00"];
        NSDate *date = [format dateFromString:_dateSelected];
        
        ActionSheetDatePicker *actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Ngày VT" datePickerMode:UIDatePickerModeDate selectedDate:date target:self action:@selector(dateWasSelected:element:) origin:_txbNgayVT];
        
        [actionSheetPicker showActionSheetPicker];
        
        return NO;
        
    }
    if (textField == _txbTimTheo)
    {
        ActionSheetStringPicker *stringPicker = [[ActionSheetStringPicker alloc] initWithTitle:@"Tìm theo ?" rows:_arrTimKiem initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
        {
            _txbTimTheo.text = (NSString *) selectedValue;
        } cancelBlock:^(ActionSheetStringPicker *picker)
        {
            
        } origin:_txbTimTheo];
        
        [stringPicker showActionSheetPicker];
        
        return NO;
    }
    return YES;
}
-(void) dateWasSelected:(NSDate *)selectedDate element:(id)element
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd 00:00:00"];
    NSString *date = [format stringFromDate:selectedDate];
    
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    _arrDSKhachHang = [db arrGSPDSKhachHangFromDatabaseAtDate:date];
    
    NSLog(@"_arr DSKH after filter by Date = %@",_arrDSKhachHang);
    
    if (!_arrDSKhachHang || _arrDSKhachHang.count == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Thông Báo" message:@"Không tìm thấy khách hàng" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alertView show];
        
        // Remove ALl annotation
        id userLocation = [_mapView userLocation];
        NSMutableArray *pins = [[NSMutableArray alloc] initWithArray:[_mapView annotations]];
        if ( userLocation != nil ) {
            [pins removeObject:userLocation]; // avoid removing user location off the map
        }
        
        [_mapView removeAnnotations:pins];
        [_mainViewDSKhachHang reloadTableViewWithDSKhachHang:_arrDSKhachHang];
        
    }
    else
    {
        // Remove ALl annotation
        id userLocation = [_mapView userLocation];
        NSMutableArray *pins = [[NSMutableArray alloc] initWithArray:[_mapView annotations]];
        if ( userLocation != nil ) {
            [pins removeObject:userLocation]; // avoid removing user location off the map
        }
        
        [_mapView removeAnnotations:pins];
        
        // init Some annotaton
        for (NSDictionary *dict in _arrDSKhachHang)
        {
            NSString *title = [dict objectForKey:@"CustName"];
            NSString *add = [dict objectForKey:@"Addr1"];
            NSString *custID = [dict objectForKey:@"CustID"];
            NSNumber *lng = [dict objectForKey:@"lng"];
            NSNumber *lat = [dict objectForKey:@"lat"];

            if (lat.floatValue == 0 || lng.floatValue == 0)
            {
                lng = [NSNumber numberWithDouble:_locationManager.location.coordinate.longitude];
                lat = [NSNumber numberWithDouble:_locationManager.location.coordinate.latitude];
                
            }

            
            CLLocationCoordinate2D location = CLLocationCoordinate2DMake(lat.doubleValue, lng.doubleValue);
            
            FeAnnotation *myAnnotation = [[FeAnnotation alloc] initWithCoordinate:location];
            myAnnotation.title = title;
            myAnnotation.subtitle = add;
            myAnnotation.custID = custID;
            
            [_mapView  addAnnotation:myAnnotation];
        }
        
        [_mainViewDSKhachHang reloadTableViewWithDSKhachHang:_arrDSKhachHang];

    }
    [format setDateFormat:@"yyyy-MM-dd"];
    _txbNgayVT.text = [format stringFromDate:selectedDate];
    
    NSLog(@"all Annotation found = %d",_mapView.annotations.count);
}
-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Lỗi" message:@"Yêu cầu bật Location Service trong Setting" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
    
}
-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
}
- (IBAction)tabBanDoTapped:(id)sender
{
    if (isTabBanDoSelected)
        return;
    
    isTabBanDoSelected = YES;
    isTabDSKhachHangSelected = NO;
    
    _mainViewDSKhachHang.hidden = YES;
    _mainViewBanDo.hidden = NO;
    
    // Set style Bar Button
    _tabBanDo.style = UIBarButtonItemStyleDone;
    _tabDSKhachHang.style = UIBarButtonItemStyleBordered;
}

- (IBAction)tabDSKhachHangTapped:(id)sender
{
    if (isTabDSKhachHangSelected)
        return;
    
    
    if (!_mainViewDSKhachHang)
    {
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"FeDSKhachHang" owner:self options:nil];
        _mainViewDSKhachHang = [arr lastObject];
        _mainViewDSKhachHang.frame = CGRectMake(0, 200, 768, 798);
        _mainViewDSKhachHang.delegate =self;
        [self.view addSubview:_mainViewDSKhachHang];
    }
    
    // BOOL
    isTabBanDoSelected  = NO;
    isTabDSKhachHangSelected = YES;
    
    if (isSearching)
    {
        [_mainViewDSKhachHang reloadTableViewWithDSKhachHang:_arrSearching];
    }
    else
        [_mainViewDSKhachHang reloadTableViewWithDSKhachHang:_arrDSKhachHang];
    
    _mainViewDSKhachHang.hidden = NO;
    _mainViewBanDo.hidden = YES;
    
    _tabDSKhachHang.style = UIBarButtonItemStyleDone;
    _tabBanDo.style = UIBarButtonItemStyleBordered;
}
-(MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    /*
    if ([annotation isKindOfClass:[FeAnnotation class]])
    {
        static NSString *IDAnnotation = @"FeAnnoation";
        
        FeAnnotationView *feAnnotation = (FeAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:IDAnnotation];
        feAnnotation.annotation = annotation;
        
        if (!feAnnotation)
        {
            feAnnotation = [[FeAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:IDAnnotation];
        }
        feAnnotation.canShowCallout = YES;
        
        return feAnnotation;
        
    }
    return nil;
     */
    if ([annotation isKindOfClass:[FeAnnotation class]])
    {
        static NSString *IDAnnotation = @"FeAnnoation";
        
        FePinAnnotationView *feAnnotation = (FePinAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:IDAnnotation];
        feAnnotation.annotation = annotation;
        
        if (!feAnnotation)
        {
            feAnnotation = [[FePinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:IDAnnotation];
        }
        feAnnotation.canShowCallout = YES;
        
        [feAnnotation setTitleForAnnotation:annotation];
        
        return feAnnotation;
        
    }
    return nil;
}
-(void) mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    MKMapRect zoomRect = MKMapRectNull;
    for (id <MKAnnotation> annotation in mapView.annotations) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MKMapRectIsNull(zoomRect)) {
            zoomRect = pointRect;
        } else {
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
    }
    [mapView setVisibleMapRect:zoomRect animated:YES];
}
-(void) FeDSKhachHange:(FeDSKhachHang *)sender selectedCustID:(NSString *)custID
{
    for (FeAnnotation *anno in _mapView.annotations)
    {
        if ([anno isKindOfClass:[FeAnnotation class]])
        {
            if ([anno.custID isEqualToString:custID])
            {
                [_mapView selectAnnotation:anno animated:YES];
                break;
            }
        }
    }
    
}
-(void) searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    if (isTabDSKhachHangSelected)
    {
        [_mainViewDSKhachHang reloadTableViewWithDSKhachHang:_arrDSKhachHang];
    }
    
    isSearching = NO;
    _searchBar.text = @"";
    [_searchBar resignFirstResponder];
    
}

-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    isSearching = YES;
    _arrSearching = [[NSMutableArray alloc] init];
    
    // Switch to DS KH Main View
    if (isTabBanDoSelected )
    {
        [self tabDSKhachHangTapped:self];
    }
    
    if (![searchText isEqualToString:@""])
    {
        for (NSMutableDictionary *dict in _arrDSKhachHang)
        {
            NSString *title = [dict valueForKey:@"CustName"];
            if ([title rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                [_arrSearching addObject:dict];
            }
        }
        
        [_mainViewDSKhachHang reloadTableViewWithDSKhachHang:_arrSearching];
    }
    else
    {
        isSearching = NO;
        [_mainViewDSKhachHang reloadTableViewWithDSKhachHang:_arrDSKhachHang];
    }
    NSLog(@"reload data");
}
-(void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    isSearching = NO;
    [self tabDSKhachHangTapped:self];
}
-(void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    
}
- (IBAction)btnCapNhatViTri:(id)sender
{
    NSArray *arr = [_mapView selectedAnnotations];
    
    NSLog(@"cap nhat vi tri = %@",arr);
}
@end
