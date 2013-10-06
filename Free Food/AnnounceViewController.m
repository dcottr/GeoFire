//
//  AnnounceViewController.m
//  Free Food
//
//  Created by David Cottrell on 2013-10-05.
//  Copyright (c) 2013 David Cottrell. All rights reserved.
//

#import "AnnounceViewController.h"
#import "AppDelegate.h"

@interface AnnounceViewController ()

@end

@implementation AnnounceViewController

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

- (IBAction)btnOne:(id)sender
{
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) uploadEvent:@"Hamburger"];
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).ignoreAllNotifications = NO;
    [self.navigationController popToRootViewControllerAnimated:YES];

}
- (IBAction)btnTwo:(id)sender
{
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) uploadEvent:@"Coffee"];
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).ignoreAllNotifications = NO;
    [self.navigationController popToRootViewControllerAnimated:YES];

}

- (IBAction)btnThree:(id)sender
{
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) uploadEvent:@"Asian Food"];
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).ignoreAllNotifications = NO;
    [self.navigationController popToRootViewControllerAnimated:YES];


}
- (IBAction)btnFour:(id)sender
{
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) uploadEvent:@"Ice Cream"];
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).ignoreAllNotifications = NO;
    [self.navigationController popToRootViewControllerAnimated:YES];

}

- (IBAction)backbtn:(id)sender
{
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).ignoreAllNotifications = NO;
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
