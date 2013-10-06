//
//  MainViewController.m
//  Free Food
//
//  Created by David Cottrell on 2013-10-05.
//  Copyright (c) 2013 David Cottrell. All rights reserved.
//

#import "MainViewController.h"
#import "AnnounceViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)announceEventBtn:(id)sender
{
    AnnounceViewController *announce = [[AnnounceViewController alloc] init];
    [self.navigationController pushViewController:announce animated:YES];
}



@end
