//
//  FeAnnotationView.m
//  eSales
//
//  Created by Nghia Tran on 9/3/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeAnnotationView.h"
#import "FeAnnotation.h"

@implementation FeAnnotationView
@synthesize labelTitle = _labelTitle;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id) initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        _labelTitle.text = ((FeAnnotation *) annotation).title;
        [_labelTitle sizeToFit];
        _labelTitle.center = self.center;
        
        //[self addSubview:_labelTitle];
    }
    return self;
}

@end
