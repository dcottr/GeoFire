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


static  NSString *const kNotificationLocationKey = @"kNotificationLocationKey";
static  NSString *const kNotificationTagKey = @"kNotificationTagKey";
static  NSString *const kFirebaseUrl = @"https://freefood.firebaseio.com/";
static NSString *const ktagKey = @"ktag";
static NSString *const klocationKey = @"klocation";

static const int kradius = 0.020;

static const int kDistanceDelta = 15;
static  char *const kFirebase32 = "0123456789bcdefghjkmnpqrstuvwxyz";

static NSString *const kignoreHashesUserDefaultsKey = @"kignoreHashesUserDefaultsKey";


@interface AppDelegate () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *lastRelevantLocation;
@property (strong, nonatomic) Firebase *firebase;

@property (strong, nonatomic) NSDictionary *neighbours;
@property (strong, nonatomic) NSDictionary *borders;


// HACKS
@property (strong, nonatomic) CLLocation *notificationLocation;
@property (strong, nonatomic) NSMutableSet *ignoreHashes;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    _firebase = [[Firebase alloc] initWithUrl:kFirebaseUrl];
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
    
    
    
    NSDictionary *north = [[NSDictionary alloc] initWithObjectsAndKeys:@"p0r21436x8zb9dcf5h7kjnmqesgutwvy", @"even", @"bc01fg45238967deuvhjyznpkmstqrwx", @"odd", nil];
    NSDictionary *east = [[NSDictionary alloc] initWithObjectsAndKeys:@"bc01fg45238967deuvhjyznpkmstqrwx", @"even", @"p0r21436x8zb9dcf5h7kjnmqesgutwvy", @"odd", nil];
    NSDictionary *south = [[NSDictionary alloc] initWithObjectsAndKeys:@"14365h7k9dcfesgujnmqp0r2twvyx8zb", @"even", @"238967debc01fg45kmstqrwxuvhjyznp", @"odd", nil];
    NSDictionary *west = [[NSDictionary alloc] initWithObjectsAndKeys:@"238967debc01fg45kmstqrwxuvhjyznp", @"even", @"14365h7k9dcfesgujnmqp0r2twvyx8zb", @"odd", nil];
    
    _neighbours = [[NSDictionary alloc] initWithObjectsAndKeys:north, @"north", east, @"east", south, @"south", west, @"west", nil];
    
    NSDictionary *bnorth = [[NSDictionary alloc] initWithObjectsAndKeys:@"prxz", @"even", @"bcfguvyz", @"odd", nil];
    NSDictionary *beast = [[NSDictionary alloc] initWithObjectsAndKeys:@"bcfguvyz", @"even", @"prxz", @"odd", nil];
    NSDictionary *bsouth = [[NSDictionary alloc] initWithObjectsAndKeys:@"028b", @"even", @"0145hjnp", @"odd", nil];
    NSDictionary *bwest = [[NSDictionary alloc] initWithObjectsAndKeys:@"0145hjnp", @"even", @"028b", @"odd", nil];
    
    _borders = [[NSDictionary alloc] initWithObjectsAndKeys:bnorth, @"north", beast, @"east", bsouth, @"south", bwest, @"west", nil];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"HERE");
    NSString *tag = [notification.userInfo objectForKey:kNotificationTagKey];
    
    CLLocation *location = _notificationLocation;
    NSLog(@"Location: %@", location);
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
    [self firebaseHandleLocation:location];
    
}

- (void)sendPushNotification:(CLLocation *)location withTag:(NSString *)tag
{
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    localNotification.alertBody = tag;
    NSLog(@"sending for location: %@", location);
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
    [self firebaseUploadEvent:location withTag:tag];
}


#pragma mark("Firebase Management")

- (void)firebaseUploadEvent:(CLLocation *)location withTag:(NSString *)tag
{
    NSString *hash = [self firebaseEncode:location withPrecision:12];
    [_ignoreHashes addObject:hash];
    [_firebase updateChildValues:[[NSDictionary alloc] initWithObjectsAndKeys:tag, hash, nil]];
    
}

- (void)firebaseHandleLocation:(CLLocation *)location
{
    NSString *hash = [self firebaseEncode:location withPrecision:12];
//    NSMutableArray *neighbourPrefixes = [[NSMutableArray alloc] init];
//    NSMutableArray *matchesFiltered = [[NSMutableArray alloc] init];
    NSMutableDictionary *matchesByPrefix = [[NSMutableDictionary alloc] init];
//    NSMutableDictionary *distDict = [[NSMutableDictionary alloc] init];
//    int i = 0;
    
    NSArray *boundingBowShortestEgesByHashLength = [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat:INFINITY], [NSNumber numberWithFloat:5003.771699005143], [NSNumber numberWithFloat:625.4714623756429], [NSNumber numberWithFloat:156.36786559391072], [NSNumber numberWithFloat:19.54598319923884], [NSNumber numberWithFloat:4.88649579980971], [NSNumber numberWithFloat:0.6108119749762138], nil];
    
    int zoomlevel = 6;
    while (kradius > [[boundingBowShortestEgesByHashLength objectAtIndex:(NSInteger)zoomlevel] floatValue]) {
        zoomlevel --;
    }
    
    hash = [hash substringToIndex:zoomlevel];
    
    NSMutableArray *query = [NSMutableArray arrayWithArray:[self neighbours:[[NSMutableString alloc] initWithString:hash]]];
    [query addObject:hash];
    
    NSMutableDictionary *uniqueObj = [[NSMutableDictionary alloc] init];
    for (int ix = 0; ix < query.count; ix++) {
        NSString *temp = [query objectAtIndex:ix];
        if (temp.length > 0) {
            [uniqueObj setObject:temp forKey:temp];
            [matchesByPrefix setObject:[[NSArray alloc] init] forKey:temp];
        }
    }

    NSArray *queries = [uniqueObj allValues];

    void (^callback)(FDataSnapshot *) = ^void (FDataSnapshot *snapshot)
    {
        double minDist = INFINITY;
        double temp;
        CLLocation *minDistLocation;
        NSString *minDistTag;
        NSString *minDistHashCode;
        NSDictionary *data = [snapshot value];
        if (![data isEqual:[NSNull null]]) {
            NSLog(@"EXISTING with data: %@", data);
            NSArray *keys = [data allKeys];
            for (NSString *key in keys) {
                NSString *tag = [data objectForKey:key];
                NSArray *locationArray = [self firebaseDecode:key];
                CLLocation *location = [[CLLocation alloc] initWithLatitude:[[locationArray objectAtIndex:0] floatValue] longitude:[[locationArray objectAtIndex:1] floatValue]];
                temp = [_lastRelevantLocation distanceFromLocation:location];
                if (temp < minDist) {
                    minDistHashCode = key;
                    minDist = temp;
                    minDistLocation = location;
                    minDistTag = tag;
                }
            }
            if (![_ignoreHashes containsObject:minDistHashCode]) {
                [self sendPushNotification:minDistLocation withTag:minDistTag];
                [_ignoreHashes addObject:minDistHashCode];
            }
        }
    };

    for (int ix = 0; ix < queries.count; ix++) {
        NSString *startPrefix = [[queries objectAtIndex:ix] substringToIndex:zoomlevel];
        NSString *endPrefix = [NSString stringWithFormat:@"%@%@", startPrefix, @"~"];
        FQuery *startAt = [_firebase queryStartingAtPriority:nil andChildName:startPrefix];
        FQuery *endAt = [startAt queryEndingAtPriority:nil andChildName:endPrefix];
        [endAt observeEventType:FEventTypeValue withBlock:callback];
    }
}

- (NSArray *)neighbours:(NSMutableString *)hash
{
    NSMutableArray *neighbours = [[NSMutableArray alloc] initWithObjects:[self neighbour:hash withDirection:@"north"], [self neighbour:hash withDirection:@"south"], [self neighbour:hash withDirection:@"east"], [self neighbour:hash withDirection:@"west"], nil];
    [neighbours addObject:[self neighbour:[NSMutableString stringWithString:[neighbours objectAtIndex:0]] withDirection:@"east"]];
    [neighbours addObject:[self neighbour:[NSMutableString stringWithString:[neighbours objectAtIndex:0]] withDirection:@"west"]];
    [neighbours addObject:[self neighbour:[NSMutableString stringWithString:[neighbours objectAtIndex:1]] withDirection:@"east"]];
    [neighbours addObject:[self neighbour:[NSMutableString stringWithString:[neighbours objectAtIndex:1]] withDirection:@"west"]];

    
    return neighbours;
}

- (NSMutableString *)neighbour:(NSMutableString *)hash withDirection:(NSString *)dir
{
    hash = [[NSMutableString alloc] initWithString:[hash lowercaseString]];
    char lastChar = [hash characterAtIndex:hash.length-1];
    NSMutableString *type = [[NSMutableString alloc] initWithString:(hash.length % 2) ? @"odd" : @"even" ];
    NSMutableString *base = [[NSMutableString alloc] initWithString:[hash substringToIndex:hash.length-1]];

    int temp = -1;
    NSString *cur = [[_borders objectForKey:dir] objectForKey:type];
    for (int k = 0; k < cur.length ; k++) {
        char element = [cur characterAtIndex:k];
        if (element == lastChar) {
            temp = k;
            break;
        }
    }

    if (temp != -1) {
        if (base.length <= 0) {
            return [[NSMutableString alloc] initWithString:@""];
        }
        base = [self neighbour:base withDirection:dir];
    }
    
    temp = -1;
    cur = [[_neighbours objectForKey:dir] objectForKey:type];
    for (int k = 0; k < cur.length ; k++) {
        char element = [cur characterAtIndex:k];
        if (element == lastChar) {
            temp = k;
            break;
        }
    }
    [base appendString:[NSString stringWithFormat:@"%c", kFirebase32[temp]]];
    return base;
}

- (NSString *)firebaseEncode:(CLLocation *)location withPrecision:(NSInteger)precision
{
    float lattitude = location.coordinate.latitude;
    float longitude = location.coordinate.longitude;
    NSMutableString *hash = [[NSMutableString alloc] init];
    int hashVal = 0;
    int bits = 0;
    BOOL even = YES;
    
    NSMutableDictionary *latRange = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithFloat:-90], @"min", [NSNumber numberWithFloat:90], @"max", nil];
    NSMutableDictionary *lonRange = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithFloat:-180], @"min", [NSNumber numberWithFloat:180], @"max", nil];

    NSMutableDictionary *range;
    float mid, val;
    
    precision = MIN((precision ? precision : 12), 22);
    
    if (lattitude < [[latRange objectForKey:@"min"] floatValue] || lattitude > [[latRange objectForKey:@"max"] floatValue]) {
        return nil;
    }
    if (longitude < [[lonRange objectForKey:@"min"] floatValue] || longitude > [[lonRange objectForKey:@"max"] floatValue]) {
        return nil;
    }
    
    while (hash.length < precision) {
        val = even ? longitude : lattitude;
        range = (even ? lonRange : latRange);
        mid = (([[range objectForKey:@"min"] floatValue] + [[range objectForKey:@"max"] floatValue]) / 2.0);
        if (val > mid) {
            hashVal = hashVal * 2 + 1;
            [range setObject:[NSNumber numberWithFloat:mid] forKey:@"min"];
        } else {
            hashVal = hashVal * 2;
            [range setObject:[NSNumber numberWithFloat:mid] forKey:@"max"];
        }
        even = !even;
        if (bits < 4) {
            bits ++;
        } else {
            bits = 0;
            [hash appendString:[NSString stringWithFormat:@"%c", kFirebase32[hashVal]]];
            hashVal = 0;
        }
        
    }
    
    
    return hash;
}

- (NSArray *)firebaseDecode:(NSString *)hash
{
    float lattitude, longitude;
    int decimal, mask;
    BOOL even = YES;
    NSMutableDictionary *latRange = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithFloat:-90], @"min", [NSNumber numberWithFloat:90], @"max", nil];
    NSMutableDictionary *lonRange = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithFloat:-180], @"min", [NSNumber numberWithFloat:180], @"max", nil];
    NSMutableDictionary *interval;
    
    for (int i = 0; i < hash.length; i++) {
        char key = [hash characterAtIndex:i];
        for (int k = 0; k < 32 ; k++) {
            char element = kFirebase32[k];
            if (element == key) {
                decimal = k;
                break;
            }
        }
        
        for (int j = 0; j < 5; j++) {
            interval = (even ? lonRange : latRange);
            mask =  pow(2, (4-j));
            float mid = ([[interval objectForKey:@"min"] floatValue] + [[interval objectForKey:@"max"] floatValue]) / 2.0;
            if (decimal & mask) {
                [interval setObject:[NSNumber numberWithFloat:mid] forKey:@"min"];
            } else {
                [interval setObject:[NSNumber numberWithFloat:mid] forKey:@"max"];
            }
            even = !even;
        }
        
    }
    
    lattitude =([[latRange objectForKey:@"min"] floatValue] + [[latRange objectForKey:@"max"] floatValue]) / 2.0;
    longitude = ([[lonRange objectForKey:@"min"] floatValue] + [[lonRange objectForKey:@"max"] floatValue]) / 2.0;
    
    NSArray *result = [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat:lattitude], [NSNumber numberWithFloat:longitude], nil];
    return  result;
}


@end
