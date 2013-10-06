//
//  EventViewController.h
//  Free Food
//
//  Created by David Cottrell on 2013-10-05.
//  Copyright (c) 2013 David Cottrell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface EventViewController : UIViewController

- (id)initWithLocation:(CLLocation *)location withTag:(NSString *)tag;

@end
