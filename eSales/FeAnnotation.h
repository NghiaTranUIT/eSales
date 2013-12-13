//
//  FeAnnotation.h
//  eSales
//
//  Created by Nghia Tran on 9/3/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface FeAnnotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *custID;
-(id)initWithCoordinate:(CLLocationCoordinate2D)coord;

@end
