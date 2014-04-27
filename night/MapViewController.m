//
//  MapViewController.m
//  night
//
//  Created by Jie Mei on 4/26/14.
//  Copyright (c) 2014 Yan Wen. All rights reserved.
//

#import "MapViewController.h"
#import "MapAnnotations.h"
#import <Parse/Parse.h>
#import "PhotoWallViewController.h"

#define METERS_PER_MILE 1609.344

@interface MapViewController ()

@end

@implementation MapViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    
    //add all the annotations for bars
    CLLocationCoordinate2D coordinate1;
    coordinate1.latitude = 41.304534;
    coordinate1.longitude = -72.926257;
    MapAnnotations *annotation1 = [[MapAnnotations alloc] initWithCoordinate:coordinate1 title:@"116 Crown"];
    annotation1.pfObjectId = @"FxkZXV61Kd";
    [self.mapView addAnnotation:annotation1];
    
    CLLocationCoordinate2D coordinate2;
    coordinate2.latitude = 41.311525;
    coordinate2.longitude = -72.929586;
    MapAnnotations *annotation2 = [[MapAnnotations alloc] initWithCoordinate:coordinate2 title:@"Toad's Place"];
    annotation2.pfObjectId = @"yB3BKeVnJy";
    [self.mapView addAnnotation:annotation2];
    
    CLLocationCoordinate2D coordinate3;
    coordinate3.latitude = 41.309384;
    coordinate3.longitude = -72.931854;
    MapAnnotations *annotation3 = [[MapAnnotations alloc] initWithCoordinate:coordinate3 title:@"Gpscy Bar"];
    annotation3.pfObjectId = @"WvbF4xTxsb";
    [self.mapView addAnnotation:annotation3];
    
    CLLocationCoordinate2D coordinate4;
    coordinate4.latitude = 41.307956;
    coordinate4.longitude = -72.922231;
    MapAnnotations *annotation4 = [[MapAnnotations alloc] initWithCoordinate:coordinate4 title:@"Christy's Irish Pub"];
    annotation4.pfObjectId = @"6a9O3DMdoC";
    [self.mapView addAnnotation:annotation4];
    
    CLLocationCoordinate2D coordinate5;
    coordinate5.latitude = 41.306182;
    coordinate5.longitude = -72.930003;
    MapAnnotations *annotation5 = [[MapAnnotations alloc] initWithCoordinate:coordinate5 title:@"Bar"];
    annotation5.pfObjectId =  @"SuqGT2Iw7Z";
    [self.mapView addAnnotation:annotation5];
    
    myAnnotations = [NSMutableArray arrayWithObjects:annotation1,annotation2,annotation3,annotation4,annotation5,nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//  the view first shown when map displays
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CLLocationCoordinate2D zoomLocation;
    // New Haven Yale: 41.312601, -72.922229
    zoomLocation.latitude = 41.312601;
    zoomLocation.longitude= -72.922229;

    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 2.8 * METERS_PER_MILE, 2.8 * METERS_PER_MILE);
    [self.mapView setRegion:viewRegion animated:YES];
}

#pragma mark - MapView Delegate Methods
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if([annotation isKindOfClass:[MKUserLocation class]]){
        return nil;
    }
    
    static NSString *identifier = @"MapAnnotations";
    MKPinAnnotationView * annotationView = (MKPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];

    if (!annotationView)
    {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.pinColor = MKPinAnnotationColorPurple;
        annotationView.animatesDrop = YES;
        annotationView.canShowCallout = YES;
    }else {
        annotationView.annotation = annotation;
    }
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    PFQuery* query = [PFQuery queryWithClassName:@"Location"];
    MapAnnotations* mapAnno = view.annotation;
    [query whereKey:@"objectId" equalTo:mapAnno.pfObjectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError* error){
        if (objects.count == 0) {
            return;
        }
        [self performSegueWithIdentifier:@"push_from_map" sender:objects[0]];
    }];
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PhotoWallViewController* pvc = [segue destinationViewController];
    pvc.currentLocation = sender;
}

@end
