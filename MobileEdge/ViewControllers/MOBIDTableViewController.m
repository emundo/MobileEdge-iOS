//
//  MOBIDTableViewController.m
//  MOBviewTest
//
//  Created by luc  on 30.07.14.
//  Copyright (c) 2014 BOSS. All rights reserved.
//

#import "MOBIDTableViewController.h"

@interface MOBIDTableViewController ()

@end

@implementation MOBIDTableViewController
@synthesize arrayIDs = _arrayIDs;

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
    self.arrayIDs = [[NSMutableArray alloc] init];
    
    MOBIdentity *ID1 = [[MOBIdentity alloc] init];
    
    [self.arrayIDs addObject:ID1];
    [self.tableView reloadData];
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
    return [self.arrayIDs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    MOBIdentity *idObject = [self.arrayIDs objectAtIndex:indexPath.row];
    cell.textLabel.text = idObject.ttl;
    
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;
{
    MOBIDDetailViewController *controllerID = [self.storyboard instantiateViewControllerWithIdentifier:@"MOBIDDetailView"];
    
    controllerID.idObject = [self.arrayIDs objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:controllerID animated:YES];
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
