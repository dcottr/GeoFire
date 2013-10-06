//
//  EventViewController.m
//  Free Food
//
//  Created by David Cottrell on 2013-10-05.
//  Copyright (c) 2013 David Cottrell. All rights reserved.
//

#import "EventViewController.h"
#import <MapKit/MapKit.h>
#import "AppDelegate.h"


@interface EventViewController ()
@property (weak, nonatomic) IBOutlet UILabel *tag;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) NSString *tagString;

@end

@implementation EventViewController

- (id)initWithLocation:(CLLocation *)location withTag:(NSString *)tag;
{
    self = [super initWithNibName:@"EventViewController" bundle:nil];
    if (self) {
        _location = location;
        _tagString = tag;
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tag.text = _tagString;
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:_location.coordinate];
    [annotation setTitle:_tagString];
    [self.mapView addAnnotation:annotation];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance (_location.coordinate, 50, 50);
    [_mapView setRegion:region animated:NO];
    
    
    if ([_tagString isEqualToString:@"Hamburger"]) {
        [_image setImage:[UIImage imageNamed:@"Fastfood_icon"]];
    } else if([_tagString isEqualToString:@"Coffee"]) {
        [_image setImage:[UIImage imageNamed:@"Coffee_icon"]];
    } else if([_tagString isEqualToString:@"Asian Food"]) {
        [_image setImage:[UIImage imageNamed:@"Asian_icon"]];
    } else if([_tagString isEqualToString:@"Ice Cream"]) {
        [_image setImage:[UIImage imageNamed:@"IceCream_icon"]];
    }
    
}
- (IBAction)backBtn:(id)sender
{
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).ignoreAllNotifications = NO;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
