//
//  FePinAnnotationView.h
//  eSales
//
//  Created by Nghia Tran on 9/3/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface FePinAnnotationView : MKPinAnnotationView

@property (strong, nonatomic) UILabel *labelTitle;

-(id) initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier;
-(void) setTitleForAnnotation:(id) annotation;
@end
