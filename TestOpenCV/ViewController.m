//
//  ViewController.m
//  TestOpenCV
//
//  Created by Ping Chen on 3/14/17.
//  Copyright © 2017 Ping Chen. All rights reserved.
//
#import "ViewController.h"
#import "BLRTestBroadcastViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *broadcastButton;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (IBAction)broadcastPressed:(id)sender {
    BLRTestBroadcastViewController *testVC = [[BLRTestBroadcastViewController alloc] init];
    
    [self presentViewController:testVC animated:YES completion:nil];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
