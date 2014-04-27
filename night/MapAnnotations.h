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

@property (nonatomic, copy) NSString *title;
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic) NSString* pfObjectId;
-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title;

@end

