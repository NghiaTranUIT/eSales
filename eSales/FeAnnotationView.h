//
//  FeAnnotationView.h
//  eSales
//
//  Created by Nghia Tran on 9/3/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface FeAnnotationView : MKAnnotationView
@property (strong, nonatomic) UILabel *labelTitle;

-(id) initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier;
@end
