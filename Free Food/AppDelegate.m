//
//  AppDelegate.m
//  Free Food
//
//  Created by David Cottrell on 2013-10-05.
//  Copyright (c) 2013 David Cottrell. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "EventViewController.h"
#import "GeoFire.h"


static  NSString *const kNotificationLocationKey = @"kNotificationLocationKey";
static  NSString *const kNotificationTagKey = @"kNotificationTagKey";
static  NSString *const kFirebaseUrl = @"https://freefood.firebaseio.com/";
static NSString *const ktagKey = @"ktag";
static NSString *const klocationKey = @"klocation";

static const int kradius = 0.200;

static const int kDistanceDelta = 1;
static  char *const kFirebase32 = "0123456789bcdefghjkmnpqrstuvwxyz";

static NSString *const kignoreHashesUserDefaultsKey = @"kignoreHashesUserDefaultsKey";


@interface AppDelegate () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *lastRelevantLocation;

@property (strong, nonatomic) NSDictionary *neighbours;
@property (strong, nonatomic) NSDictionary *borders;
@property (strong, nonatomic) GeoFire *geofire;



// HACKS
@property (strong, nonatomic) CLLocation *notificationLocation;
@property (strong, nonatomic) NSMutableSet *ignoreHashes;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    _geofire = [[GeoFire alloc] initWithURL:kFirebaseUrl];
    MainViewController *mainController = [[MainViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:mainController];
    nav.navigationBarHidden = YES;
    nav.toolbarHidden = YES;
    
    _ignoreAllNotifications = NO;
    
    self.window.rootViewController = nav;
    
    
    if (!_ignoreHashes) {
        _ignoreHashes = [[NSMutableSet alloc] init];
    }
    
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager setDelegate:self];
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [_locationManager startUpdatingLocation];
    _lastRelevantLocation = nil;
    
    
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSString *tag = [notification.userInfo objectForKey:kNotificationTagKey];
    
    CLLocation *location = _notificationLocation;
    EventViewController *eventController = [[EventViewController alloc] initWithLocation:location withTag:tag];
    if (!_ignoreAllNotifications) {
        [(UINavigationController *)self.window.rootViewController pushViewController:eventController animated:YES];
        _ignoreAllNotifications = YES;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (_lastRelevantLocation == nil || [_lastRelevantLocation distanceFromLocation:manager.location] >= kDistanceDelta) {
        _lastRelevantLocation = manager.location;
        [self updateForLocation:manager.location];
    }
}

- (void)updateForLocation:(CLLocation *)location
{
    [_geofire handleLocation:location];
    
}

- (void)sendPushNotification:(CLLocation *)location withTag:(NSString *)tag
{
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    localNotification.alertBody = tag;
    _notificationLocation = location;
    localNotification.userInfo = [NSDictionary dictionaryWithObjectsAndKeys: tag, kNotificationTagKey, nil];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (void)uploadEvent:(NSString *)tag
{
    CLLocationCoordinate2D coordinate = _lastRelevantLocation.coordinate;
    // TODO: Check lastRelevantLocation was recent. Prompt if not.
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [_geofire uploadEvent:location withTag:tag];
}




@end
