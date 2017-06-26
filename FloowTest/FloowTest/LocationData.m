//
//  LocationData.m
//  FloowTest
//
//  Created by Keith Birkett on 24/06/2017.
//  Copyright © 2017 Keith Birkett. All rights reserved.
//

#import "LocationData.h"

@implementation LocationData

-(void)initLocationData
{
    locationManager = [[CLLocationManager alloc] init];
    
    [locationManager setDelegate:self];
    
    CLAuthorizationStatus locationStatus = [CLLocationManager authorizationStatus];
    
    inUseRequestMade = false;
    
    [self requestUseIfNecessary:locationStatus];
  
    // Don't let the OS stop our location updates on what seems like its whim
    // We cannot ever restart them if we allow this to happen
    locationManager.pausesLocationUpdatesAutomatically = NO;
    
    inBackground = false;
    
    [self registerNotifications];
}

-(void)requestUseIfNecessary:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusNotDetermined)
    {
        inUseRequestMade = true;
        [locationManager requestWhenInUseAuthorization];
    }
}

-(void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedEnterBackgroundNotification:)
                                                 name:kNotificatonEnteredBackground object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedEnterForegroundNotification:)
                                                 name:kNotificatonEnteredForeground object:nil];
}

- (void)receivedEnterBackgroundNotification:(id)object
{
    inBackground = true;
}

- (void)receivedEnterForegroundNotification:(id)object
{
    inBackground = false;
}

-(void)setTrackingEnabled:(bool)value
{
    _trackingEnabled = value;
    
    // This requires at least iOS 9 to work.
    // The best I can figure location updates in the background just work before this
    if ([locationManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)])
    {
        // If tracking is on we want to enable the background updates, so we can continue
        // to track the user even if the app is backgrounded.
        locationManager.allowsBackgroundLocationUpdates = value;
    }
    
    // If tracking is on start tracking
    if (value)
    {
        [locationManager startUpdatingLocation];
    }
    else
    {
        [locationManager stopUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [self requestUseIfNecessary:status];
    
    // If a request has been made and we have been denied then show the message.
    // Otherwise we get these messages if location services are turned off, not helpful Apple.
    if (inUseRequestMade && (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied))
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificatonLocationDenied object:nil];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificatonLocationError object:nil];
}


// CLLocationManager delegate functions
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificatonLocationData object:locations];

    NSLog(@"Got update: locations %d\n", (int)[locations count]);
}

@end
