//
//  AppSettingTableViewController.m
//  SwimSaferTest
//
//  Created by hupengcheng  on 15/6/15.
//  Copyright (c) 2015年 hupengcheng . All rights reserved.
//

#import "AppSettingTableViewController.h"

@interface AppSettingTableViewController ()

@end

@implementation AppSettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Blur.png"]];
    self.tableView.backgroundView.alpha = 0.4;
    self.title = @"设置";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section ==0) {
        return 2;
    }else if (section ==1)
    {
        return 1;
    }else
    {
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = nil;
    UITableViewCell * cell = [[UITableViewCell alloc] init];
    if (indexPath.section==0) {
        if (indexPath.row ==0) {
            CellIdentifier = @"indicate";
        }else
        {
            CellIdentifier = @"legacy";
        }
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }else if (indexPath.section ==1)
    {
        CellIdentifier = @"reset";
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reset"];
        
        UIButton * resetButton =[UIButton buttonWithType:UIButtonTypeRoundedRect];
        resetButton.frame = CGRectMake(20, 0, self.view.frame.size.width-40, 44);
        [resetButton setTitle:@"清除所有记录" forState:UIControlStateNormal];
        [resetButton addTarget:self action:@selector(resetButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:resetButton];
    }else
    {
        CellIdentifier = @"about";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }
    cell.backgroundColor = [UIColor clearColor];

    return cell;
}
-(void)resetButtonPressed
{
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"数据将不能恢复" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex !=[actionSheet cancelButtonIndex]) {
        [self deleteAllRecords];
        
    }
}
-(void)deleteAllRecords
{
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"storedPeripherals"];
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return @"使用及法律";
    }else if (section==1)
    {
        return @"还原";
    }else
    {
        return @"About Us";
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return 50;
    }else if (section==1)
    {
        return 50;
    }else
    {
        return 40;
    }
    
}
/*
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)] ;
    
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    return headerView;
}
*/
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
