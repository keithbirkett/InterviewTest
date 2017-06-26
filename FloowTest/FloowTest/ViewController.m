//
//  ViewController.m
//  FloowTest
//
//  Created by Keith Birkett on 23/06/2017.
//  Copyright © 2017 Keith Birkett. All rights reserved.
//

#import "ViewController.h"

static NSString *kResuable = @"cell";

static NSString *kLocationError = @"Can't get GPS data at the moment. App will not work properly.";
static NSString *kLocationDenied = @"Access to GPS data denied. App cannot function without it.";

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create a class to handle journeys
    [self initJourneyData];
    // Create a class to handle location data collection
    [self initLocationData];
    // Do whatever extra setup is required on the map class
    [self initMapView];
    // Setup the journey view
    [self initJourneyView];
    // Register for journey related notifications
    [self registerNotifications];
}

-(void)initJourneyView
{
    // Add a scroll bar, enable user interaction and a nice bounce for the scrolling
    self.journeysView.scrollEnabled = YES;
    self.journeysView.showsVerticalScrollIndicator = YES;
    self.journeysView.userInteractionEnabled = YES;
    self.journeysView.bounces = YES;
    
    // Set the delegate and data delegate up
    self.journeysView.delegate = self;
    self.journeysView.dataSource = self;
    
    // Load and register the nib file that defines the cell row
    [self.journeysView registerNib:[UINib nibWithNibName:@"JourneyCustomCell" bundle:nil] forCellReuseIdentifier:kResuable];
    
    // Create a row to use as the header
    JourneyCustomCell *cell = [self.journeysView dequeueReusableCellWithIdentifier:kResuable];

    // Distinguish the header from the rest of the table
    cell.backgroundColor = [UIColor lightGrayColor];
    
    // Set the header
    self.journeysView.tableHeaderView = cell;
    // Hide the journey view until the user requests it
    self.journeysView.hidden = true;
}

// Do whatever is required to set the mapview up
-(void)initMapView
{
    self.mapView.delegate = self;
    [self setMapViewScroll:false];
    polyline = nil;
}

// Create the location data collection class
-(void)initLocationData
{
    // Create the location data tracker, this is the model, we are the controller
    // We will talk directly to it using its interface, it will notify us as required
    // This way the model has no dependencies on the controller
    locationData = [[LocationData alloc] init];
    [locationData initLocationData];
    
    // Tracking starts disabled
    locationData.trackingEnabled = false;
}

// Create the journey recording class
-(void)initJourneyData
{
    // Set the encryption key, just before we load
    // Probably not the best place to do it!
    [Encryption setEncryptionKey:@"ASuperAwesomeEncryptionKey"];
    
    NSData *journeyNSData = [[NSUserDefaults standardUserDefaults] objectForKey:@"floowtest"];
    
    if (journeyNSData != nil)
    {
        journeyNSData = [Encryption decrypt:journeyNSData];
        journeyData = [NSKeyedUnarchiver unarchiveObjectWithData:journeyNSData];
    }
    else
    {
        journeyData = [[JourneyData alloc] init];
    }
    [journeyData initJourneyData];
}

// Register for the notifications we want to receive
-(void)registerNotifications
{
    // Get locations updates from the location update provider (in this case the LocationData class)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedJourneyUpdateNotification:)
                                                 name:kNotificatonJourneyDataUpdated object:nil];
    
    // Get locations updates from the location update provider (in this case the LocationData class)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedLocationErrorNotification:)
                                                 name:kNotificatonLocationError object:nil];

    // Get locations updates from the location update provider (in this case the LocationData class)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedLocationDeniedNotification:)
                                                 name:kNotificatonLocationDenied object:nil];

    
}

// Make a polyline from the given journey
// Lots of code to find the max and min point that I didn't really have time to make work
// Was supposed to position the map such that the whole of the path was visible
-(void)makePolylineForJourney:(Journey *)journey polylineToUse:(MKPolyline * __strong *)polylinePointer smallestCoord:(CLLocationCoordinate2D *)southWest largestCoord:(CLLocationCoordinate2D *)northEast;
{
    int numberJourneyLocations = (int)[journey.journeyLocations count];
    
    if (numberJourneyLocations < 2)
    {
        // Not enough points to draw a line yet
        return;
    }
    
    CLLocationCoordinate2D coordinates[numberJourneyLocations];
    
    double smallestLongitude = 1000;
    double smallestLatitude = 1000;
    double largestLongitude = -1000;
    double largestLatitude = -1000;
    
    for(int i=0;i<numberJourneyLocations;i++)
    {
        coordinates[i] = [journey.journeyLocations[i] coordinate];
        
        if (coordinates[i].latitude < smallestLatitude)
        {
            smallestLatitude = coordinates[i].latitude;
        }
        if (coordinates[i].latitude > largestLatitude)
        {
            largestLatitude = coordinates[i].latitude;
        }
        
        if (coordinates[i].longitude < smallestLongitude)
        {
            smallestLongitude = coordinates[i].longitude;
        }
        if (coordinates[i].longitude > largestLongitude)
        {
            largestLongitude = coordinates[i].longitude;
        }
    }
    
    if (southWest)
    {
        (*southWest).latitude = smallestLatitude;
        (*southWest).longitude = smallestLongitude;
    }

    if (northEast)
    {
        (*northEast).latitude = largestLatitude;
        (*northEast).longitude = largestLongitude;
    }

    [self removePolyline:*polylinePointer];
    
    *polylinePointer = [MKPolyline polylineWithCoordinates:coordinates count:numberJourneyLocations];
    [self.mapView addOverlay:*polylinePointer];
}

// Something changed in the current journey so update the polyline
-(void)receivedJourneyUpdateNotification:(id)object
{
    Journey *journey = [journeyData.journeys lastObject];
    
    [self makePolylineForJourney:journey polylineToUse:&polyline smallestCoord:nil largestCoord:nil];
}


// Called when switching the tracking switch
- (IBAction)trackingSwitch:(UISwitch *)sender
{
    bool switchIsOn = [sender isOn];
    
    // Inform the location data module that the tracking switch has changed
    locationData.trackingEnabled = switchIsOn;
    // Inform the journey module that the tracking switch has changed
    [journeyData switchJourney: switchIsOn];
    
    // Things may have changed so update the journeys view
    // or tell the OS to the next time it is displayed
    [self.journeysView reloadData];
    
    // If we are finishing a journey remove the path
    if (!switchIsOn)
    {
        [self removePolyline:polyline];
    }
}

-(void)setMapViewScroll:(bool)journeyViewVisible
{
    // If journey view visible then allow free movement
    self.mapView.scrollEnabled = journeyViewVisible;
    
    MKUserTrackingMode trackingMode = MKUserTrackingModeFollowWithHeading;
    
    if (journeyViewVisible)
    {
        trackingMode = MKUserTrackingModeNone;
    }
    
    self.mapView.userTrackingMode = trackingMode;
}

// Called when the Journeys button is pressed
- (IBAction)JourneyButton:(UIButton *)sender
{
    if ([journeyData.journeys count] < 1)
    {
        return;
    }

    // Tapping the journeys button toggles the visibility
    self.journeysView.hidden = !self.journeysView.hidden;

    // Set the map view movement
    [self setMapViewScroll:self.journeysView.hidden==false];

    // Hidden now remove the selection and any selected lines
    if (self.journeysView.hidden)
    {
        // Remove any line we were showing on the journey view
        [self removePolyline:polylineSelected];
    
        // Clear the selected row on the journey view
        NSIndexPath *indexPath = self.journeysView.indexPathForSelectedRow;
        if (indexPath)
        {
            [self.journeysView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }
}

// The map view requests for us to make a renderer to our specifications
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *polyLineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
 
    if (polyline == overlay)
    {
        polyLineRenderer.strokeColor = [UIColor redColor];
    }
    else
    {
        polyLineRenderer.strokeColor = [UIColor blueColor];
    }
    polyLineRenderer.lineWidth = 1.0;
    
    return polyLineRenderer;
}

// Remove a polyline from the map
-(void)removePolyline:(MKPolyline *)polylineToRemove
{
    if (polylineToRemove != nil)
    {
        [self.mapView removeOverlay:polylineToRemove];
        polylineToRemove = nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Journey *selectedJourney = journeyData.journeys[indexPath.row];
    
    if ([selectedJourney.journeyLocations count] < 2)
    {
        // Can't draw lines if there aren't at least two points
        return;
    }
    
    // If we were showing the selected polyline then
    [self removePolyline:polylineSelected];
    
    CLLocationCoordinate2D southWest;
    CLLocationCoordinate2D northEast;
    
    [self makePolylineForJourney:selectedJourney polylineToUse:&polylineSelected
                   smallestCoord:&southWest largestCoord:&northEast];

//    Didn't have time to make this work
    
//    MKMapPoint southWestPoint = MKMapPointForCoordinate(southWest);
//    MKMapPoint northEastPoint = MKMapPointForCoordinate(northEast);
//    
//    MKMapRect mapRect = MKMapRectMake(southWestPoint.x, southWestPoint.y,
//                                      northEastPoint.x - southWestPoint.x, northEastPoint.y - southWestPoint.y);
//    
//    [self.mapView setVisibleMapRect:mapRect];
}


// How many table rows are there?
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [journeyData.journeys count];
}

// Fill in the data for the requested table row
// The journey class has pre-built everything for us.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JourneyCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:kResuable];
    
    Journey *journey = journeyData.journeys[indexPath.row];
    
    cell.journeyNumber.text = [NSString stringWithFormat:@"%i", (int)(indexPath.row + 1)];
    cell.numberSamples.text = journey.journeySamplesString;
    cell.startTime.text     = journey.journeyStartString;
    cell.endTime.text       = journey.journeyEndString;
    cell.journeyTime.text   = journey.journeyTimeString;
    cell.distance.text      = journey.journeyDistanceString;
    cell.averageSpeed.text  = journey.journeyAverageSpeedString;
    
    return cell;
}

-(void)showAlert:(NSString *)message
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Problem!"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

// Location Data Error
-(void)receivedLocationErrorNotification:(id)object
{
    [self showAlert:kLocationError];
}

// Location Data Denied
-(void)receivedLocationDeniedNotification:(id)object
{
    [self showAlert:kLocationDenied];
}

@end
