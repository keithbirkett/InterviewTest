//
//  ViewController.h
//  FloowTest
//
//  Created by Keith Birkett on 23/06/2017.
//  Copyright © 2017 Keith Birkett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "LocationData.h"
#import "JourneyData.h"
#import "Notifications.h"
#import "JourneyCustomCell.h"

@interface ViewController : UIViewController <MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    LocationData *locationData;
    JourneyData *journeyData;
    MKPolyline *polyline;
    MKPolyline *polylineSelected;
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *journeysView;

-(void)initMapView;
-(void)initLocationData;
-(void)initJourneyData;
-(void)initJourneyView;
-(void)registerNotifications;
-(void)receivedJourneyUpdateNotification:(id)object;
-(void)receivedLocationErrorNotification:(id)object;
-(void)receivedLocationDeniedNotification:(id)object;
-(void)removePolyline:(MKPolyline *)polylineToRemove;
-(void)makePolylineForJourney:(Journey *)journey polylineToUse:(MKPolyline * __strong *)polylinePointer smallestCoord:(CLLocationCoordinate2D *)southWest largestCoord:(CLLocationCoordinate2D *)northEast;
-(void)showAlert:(NSString *)message;
-(void)setMapViewScroll:(bool)journeyViewVisible;

@end

