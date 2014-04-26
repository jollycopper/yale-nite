//
//  MapViewController.h
//  night
//
//  Created by Jie Mei on 4/26/14.
//  Copyright (c) 2014 Yan Wen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
