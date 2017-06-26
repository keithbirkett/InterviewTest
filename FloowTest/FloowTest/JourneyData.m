//
//  JourneyData.m
//  FloowTest
//
//  Created by Keith Birkett on 24/06/2017.
//  Copyright © 2017 Keith Birkett. All rights reserved.
//

#import "JourneyData.h"

const static int kInitialCapacity = 32;
static NSString *kJourneys        = @"journeys";


@implementation JourneyData

-(void)initJourneyData
{
    if (self.journeys == nil)
    {
        // Make some space for some journeys
        self.journeys = [NSMutableArray<Journey *> arrayWithCapacity:kInitialCapacity];
    }
    
    // We aren't recording a journey on start up
    recordingJourney = false;
    
    [self registerNotifications];
}

-(void)switchJourney:(bool)switchValue
{
    if (switchValue)
    {
        Journey *newJourney = [Journey new];
        
        [newJourney initJourney];
        
        [self.journeys addObject:newJourney];
    }
    else
    {
        Journey *lastJourney = [self.journeys lastObject];
        
        if (lastJourney == nil)
        {
            // In a real app we would have some kind of logging system, that could log or raise errors, asserts etc if it was considered necessary
            NSLog(@"Received empty location data");
            return;
        }
        
        [lastJourney endJourney];
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
        data = [Encryption encrypt:data];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"floowtest"];
    }
    
    recordingJourney = switchValue;
}

-(void)registerNotifications
{
    // Get locations updates from the location update provider (in this case the LocationData class)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedLocationDataNotification:)
                                                 name:kNotificatonLocationData object:nil];
}

- (void)receivedLocationDataNotification:(id)object;
{
    if (!recordingJourney)
    {
        // In a real app we would have some kind of logging system, that could log or raise errors, asserts etc if it was considered necessary
        NSLog(@"Received location data when not recording.");
        return;
    }
    
    NSArray<CLLocation *> *locationData = [object object];
    
    Journey *currentJourney = [self.journeys lastObject];
    
    if (currentJourney == nil)
    {
        // In a real app we would have some kind of logging system, that could log or raise errors, asserts etc if it was considered necessary
        NSLog(@"Journey array doesn't contain any journeys");
        
        return;
    }
    
    [currentJourney.journeyLocations addObjectsFromArray:locationData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificatonJourneyDataUpdated object:nil];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init])
    {
        self.journeys = [decoder decodeObjectForKey:kJourneys];

    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.journeys forKey:kJourneys];
}

@end
