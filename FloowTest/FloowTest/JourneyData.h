//
//  JourneyData.h
//  FloowTest
//
//  Created by Keith Birkett on 24/06/2017.
//  Copyright © 2017 Keith Birkett. All rights reserved.
//

#ifndef JourneyData_h
#define JourneyData_h

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "Notifications.h"
#import "Journey.h"
#import "Encryption.h"

@interface JourneyData : NSObject <NSCoding>
{
    // Am I currently recording a journey
    bool recordingJourney;
}

@property (nonatomic) NSMutableArray<Journey *> *journeys;

-(void)initJourneyData;
-(void)switchJourney:(bool)switchValue;
-(void)registerNotifications;

- (void)receivedLocationDataNotification:(id)object;

- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;
@end

#endif /* JourneyData_h */
