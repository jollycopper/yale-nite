//
//  MapAnnotations.h
//  night
//
//  Created by Jie Mei on 4/26/14.
//  Copyright (c) 2014 Yan Wen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface MapAnnotations : NSObject <MKAnnotation>

@property (strong, nonatomic) NSString *title;
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title;

@end

