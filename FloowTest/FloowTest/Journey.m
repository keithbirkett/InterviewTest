//
//  Journey.m
//  FloowTest
//
//  Created by Keith Birkett on 24/06/2017.
//  Copyright © 2017 Keith Birkett. All rights reserved.
//

#import "Journey.h"

const static int kInitialCapacity = 64;
const static float kConvertMetresToMiles = 1609.344f;
const static float kSecondsInHour = 60.0f*60.0f;

static NSString *kJourneyStart        = @"journeyStart";
static NSString *kJourneyEnd          = @"journeyEnd";
static NSString *kJourneyLocations    = @"journeyLocations";

@implementation Journey

-(NSString *)makeDateStringFromNSDate:(NSDate *)date
{
    NSString *dateString = [NSDateFormatter localizedStringFromDate:date
                                                      dateStyle:NSDateFormatterShortStyle
                                                      timeStyle:NSDateFormatterMediumStyle];

    return dateString;
}

-(void)calculateSpeed
{
    float speed;
    
    if (time == 0.0f)
    {
        speed = 0;
    }
    else
    {
        speed = distance / time;
    }
    
    _journeyAverageSpeedString = [NSString stringWithFormat:@"%.2f", speed];
}

-(void)calculateTime:(NSTimeInterval)timeDifference
{
    time = timeDifference / kSecondsInHour;
}

+(float)distanceBetweenCoordinatesMetres:(CLLocationCoordinate2D)startCoordinate endCoordinate:(CLLocationCoordinate2D)endCoordinate
{
    MKMapPoint startMapPoint = MKMapPointForCoordinate(startCoordinate);
    MKMapPoint endMapPoint = MKMapPointForCoordinate(endCoordinate);
    
    return MKMetersBetweenMapPoints(startMapPoint, endMapPoint);
}

-(void)calculateDistance
{
    CLLocationCoordinate2D startCoordinate;
    CLLocationCoordinate2D endCoordinate;
    int numberOfSamples = (int)[self.journeyLocations count];
    distance = 0;
    
    startCoordinate = self.journeyLocations[0].coordinate;
    for(int i=1;i<numberOfSamples;i++)
    {
        endCoordinate = self.journeyLocations[i].coordinate;

        distance += [Journey distanceBetweenCoordinatesMetres:startCoordinate endCoordinate:endCoordinate];
        
        startCoordinate = endCoordinate;
    }
    
    distance /= kConvertMetresToMiles;
    
    _journeyDistanceString = [NSString stringWithFormat:@"%.2f", distance];
}

-(void)buildStartString
{
    if (_journeyStartString == nil)
    {
        _journeyStartString = [self makeDateStringFromNSDate:journeyStart];
    }
}

-(void)initJourney
{
    // Create with a decent capacity so that we aren't constantly reallocting
    _journeyLocations = [NSMutableArray<CLLocation *> arrayWithCapacity:kInitialCapacity];
    // Set the journey start time
    journeyStart = [NSDate date];
    [self buildStartString];
}

-(void)buildStrings
{
    [self buildStartString];

    _journeyEndString = [self makeDateStringFromNSDate:journeyEnd];
    
    // Set the total journey time
    NSTimeInterval journeyTime = [journeyEnd timeIntervalSinceDate:journeyStart];
    
    [self calculateTime:journeyTime];
    
    // Create a string from the time interval
    NSDateComponentsFormatter *dateComponentsFormatter = [[NSDateComponentsFormatter alloc] init];
    dateComponentsFormatter.unitsStyle = NSDateComponentsFormatterUnitsStyleAbbreviated;
    _journeyTimeString = [dateComponentsFormatter stringFromTimeInterval:journeyTime];
    
    _journeySamplesString = [NSString stringWithFormat:@"%i", (int)[self.journeyLocations count]];
    
    if ([self.journeyLocations count] == 0)
    {
        return;
    }
    
    [self calculateDistance];
    [self calculateSpeed];
}

-(void)endJourney
{
    // Set the journey start time
    journeyEnd = [NSDate date];
    
    [self buildStrings];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init])
    {
        journeyStart = [decoder decodeObjectForKey:kJourneyStart];
        journeyEnd = [decoder decodeObjectForKey:kJourneyEnd];
        _journeyLocations = [decoder decodeObjectForKey:kJourneyLocations];
        
        [self buildStrings];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:journeyStart forKey:kJourneyStart];
    [encoder encodeObject:journeyEnd forKey:kJourneyEnd];
    [encoder encodeObject:self.journeyLocations forKey:kJourneyLocations];
}


@end
