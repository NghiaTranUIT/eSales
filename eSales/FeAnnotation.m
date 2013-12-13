//
//  FeAnnotation.m
//  eSales
//
//  Created by Nghia Tran on 9/3/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeAnnotation.h"

@implementation FeAnnotation
@synthesize coordinate = _coordinate,custID = _custID;

-(id) initWithCoordinate:(CLLocationCoordinate2D)coord
{
    self = [super init];
    if (self)
    {
        _coordinate = coord;
    }
    
    return self;
}
@end
