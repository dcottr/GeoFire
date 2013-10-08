//
//  GeoFire.h
//  Free Food
//
//  Created by David Cottrell on 2013-10-08.
//  Copyright (c) 2013 David Cottrell. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLLocation;
@interface GeoFire : NSObject

- (id)initWithURL:(NSString *)URL;
- (void)handleLocation:(CLLocation *)location;
- (void)uploadEvent:(CLLocation *)location withTag:(NSString *)tag;


@end
