//
//  MOBSettingsViewController.m
//  MOBviewTest
//
//  Created by luc  on 30.07.14.
//  Copyright (c) 2014 BOSS. All rights reserved.
//

#import "MOBSettingsViewController.h"

@interface MOBSettingsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *settingsLabel1;
@property (weak, nonatomic) IBOutlet UILabel *settingsLabel2;
@property (weak, nonatomic) IBOutlet UISwitch *settingsSwitch1;
@property (weak, nonatomic) IBOutlet UITextField *settingsTextField2;

@end

@implementation MOBSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

static NSString* APP_SETTING = @"APP_SETTING";
static NSString* APP_SETTING2 = @"APP_SETTING2";

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //set your app settings keys
    [[NSUserDefaults standardUserDefaults] objectForKey:APP_SETTING];
    [[NSUserDefaults standardUserDefaults] objectForKey:APP_SETTING2];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.settingsTextField2.delegate = self;
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(handleTap:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];   
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (IBAction)settingsSwitch1Changed:(id)sender {
    if (_settingsSwitch1.on)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:APP_SETTING];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:APP_SETTING];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (IBAction)settingsTextField2Changed:(UITextField *)sender {
    UITextField *textfield = sender;
    [[NSUserDefaults standardUserDefaults] setObject:[textfield text] forKey:APP_SETTING2];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textfield {
    if (textfield == self.settingsTextField2) {
        [textfield resignFirstResponder];
    }
    return YES;
}

- (void)handleTap:(UITapGestureRecognizer *)aSender
{
	if(UIGestureRecognizerStateEnded == aSender.state)
	{
		[self.settingsTextField2 resignFirstResponder];
	}
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
