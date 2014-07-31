//
//  MOBIDDetailVIewController.m
//  MOBviewTest
//
//  Created by luc  on 31.07.14.
//  Copyright (c) 2014 BOSS. All rights reserved.
//

#import "MOBIDDetailVIewController.h"

@interface MOBIDDetailVIewController ()

@property (weak, nonatomic) IBOutlet UILabel *macLabel;
@property (weak, nonatomic) IBOutlet UILabel *ttlLabel;
@property (weak, nonatomic) IBOutlet UILabel *creationDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *nonceLabel;
@property (weak, nonatomic) IBOutlet UILabel *ttlText;
@property (weak, nonatomic) IBOutlet UILabel *nonceText;
@property (weak, nonatomic) IBOutlet UILabel *macText;
@property (weak, nonatomic) IBOutlet UILabel *creationDateText;

@end

@implementation MOBIDDetailVIewController

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
    // Do any additional setup after loading the view.
    [self refreshViewForID];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refreshViewForID
{
    self.ttlText.text = self.idObject.ttl;
    self.macText.text = self.idObject.mac;
    self.nonceText.text = self.idObject.nonce;
    self.creationDateText.text = self.idObject.creationDate;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
