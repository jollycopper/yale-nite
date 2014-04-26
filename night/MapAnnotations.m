//
//  MapAnnotations.m
//  night
//
//  Created by Jie Mei on 4/26/14.
//  Copyright (c) 2014 Yan Wen. All rights reserved.
//

#import "MapAnnotations.h"

@implementation MapAnnotations

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title {
    if ((self = [super init])) {
        self.coordinate =coordinate;
        self.title = title;
    }
    return self;
}

@end
