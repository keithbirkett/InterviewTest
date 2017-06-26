//
//  LocationData.h
//  FloowTest
//
//  Created by Keith Birkett on 24/06/2017.
//  Copyright © 2017 Keith Birkett. All rights reserved.
//

#ifndef LocationData_h
#define LocationData_h

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "Notifications.h"

@interface LocationData : NSObject <CLLocationManagerDelegate>
{
    CLLocationManager   *locationManager;
    bool                inBackground;
    bool                inUseRequestMade;
}

@property (nonatomic) bool trackingEnabled;

-(void)initLocationData;
-(void)registerNotifications;

-(void)setTrackingEnabled:(bool)value;

// Notifications callbacks
- (void)receivedEnterBackgroundNotification:(id)object;
- (void)receivedEnterForegroundNotification:(id)object;

@end


#endif /* LocationData_h */
