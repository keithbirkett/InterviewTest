//
//  Journey.h
//  FloowTest
//
//  Created by Keith Birkett on 24/06/2017.
//  Copyright © 2017 Keith Birkett. All rights reserved.
//

#ifndef Journey_h
#define Journey_h

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

// This will store the data for an individual journey
@interface Journey : NSObject <NSCoding>
{
    NSDate *journeyStart;
    NSDate *journeyEnd;
    float distance; // Unit is miles
    float time; // Unit is hours
}

@property (nonatomic, readonly) NSMutableArray<CLLocation *> *journeyLocations;
@property (nonatomic, readonly) NSString *journeySamplesString;
@property (nonatomic, readonly) NSString *journeyStartString;
@property (nonatomic, readonly) NSString *journeyEndString;
@property (nonatomic, readonly) NSString *journeyTimeString;
@property (nonatomic, readonly) NSString *journeyDistanceString;
@property (nonatomic, readonly) NSString *journeyAverageSpeedString;

-(void)initJourney;
-(void)endJourney;
-(void)calculateDistance;
-(void)calculateSpeed;
-(void)calculateTime:(NSTimeInterval)timeDifference;
-(void)buildStrings;
-(void)buildStartString;

+(float)distanceBetweenCoordinatesMetres:(CLLocationCoordinate2D)startCoordinate endCoordinate:(CLLocationCoordinate2D)endCoordinate;

- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;
@end


#endif /* Journey_h */
