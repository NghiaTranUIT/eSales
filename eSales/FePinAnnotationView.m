//
//  FePinAnnotationView.m
//  eSales
//
//  Created by Nghia Tran on 9/3/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FePinAnnotationView.h"
#import "FeAnnotation.h"

@implementation FePinAnnotationView

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
        _labelTitle.backgroundColor = [UIColor colorWithWhite:0.7f alpha:0.5f];
        _labelTitle.center = self.center;
        _labelTitle.frame = CGRectMake(_labelTitle.frame.origin.x, _labelTitle.frame.origin.y + 50, _labelTitle.frame.size.width, _labelTitle.frame.size.height);
        _labelTitle.clipsToBounds = NO;
        [self addSubview:_labelTitle];
    }
    return self;
}
-(void) setTitleForAnnotation:(id) annotation
{
    FeAnnotation *anno = (FeAnnotation *) annotation;
    
    _labelTitle.text = anno.title;
    [_labelTitle sizeToFit];
    _labelTitle.frame = CGRectMake(0 - _labelTitle.frame.size.width + _labelTitle.frame.size.width/2 , 35, _labelTitle.frame.size.width, _labelTitle.frame.size.height);

    NSLog(@"frame self = %@",NSStringFromCGRect(self.frame));
    NSLog(@"frame = %@",NSStringFromCGRect(_labelTitle.frame));
    
}
@end
