//
//  AppDelegate.h
//  Free Food
//
//  Created by David Cottrell on 2013-10-05.
//  Copyright (c) 2013 David Cottrell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)uploadEvent:(NSString *)tag;
@property (assign, nonatomic) BOOL ignoreAllNotifications;



@end
