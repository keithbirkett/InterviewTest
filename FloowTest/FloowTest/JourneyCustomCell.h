//
//  JourneyCustomCell.h
//  FloowTest
//
//  Created by Keith Birkett on 25/06/2017.
//  Copyright © 2017 Keith Birkett. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JourneyCustomCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *journeyNumber;
@property (weak, nonatomic) IBOutlet UILabel *numberSamples;
@property (weak, nonatomic) IBOutlet UILabel *startTime;
@property (weak, nonatomic) IBOutlet UILabel *endTime;
@property (weak, nonatomic) IBOutlet UILabel *journeyTime;
@property (weak, nonatomic) IBOutlet UILabel *distance;
@property (weak, nonatomic) IBOutlet UILabel *averageSpeed;

@end
