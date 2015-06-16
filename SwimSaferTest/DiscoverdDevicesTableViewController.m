//
//  DiscoverdDevicesTableViewController.m
//  SwimSaferTest
//
//  Created by hupengcheng  on 15/6/11.
//  Copyright (c) 2015年 hupengcheng . All rights reserved.
//

#import "DiscoverdDevicesTableViewController.h"

@interface DiscoverdDevicesTableViewController ()
@property (nonatomic,strong) NSMutableArray * selectedPeripheral;
@end

@implementation DiscoverdDevicesTableViewController
@synthesize discoverdPeripherals = _discoverdPeripherals;
@synthesize selectedPeripheral = _selectedPeripheral;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(discoverPeripheralFinished:) name:@"discoverPeripheralFinished" object:nil];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Blur.png"]];
    self.tableView.backgroundView.alpha = 0.4;
    
}
-(void)viewDidDisappear:(BOOL)animated
{
    
    NSDictionary * storedPeripherals = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"storedPeripherals"];
    NSMutableDictionary * toStorePeripherals = [NSMutableDictionary dictionaryWithDictionary:storedPeripherals];
    for (CBPeripheral * selectedPeripheral in self.selectedPeripheral) {
        NSString * identifier = [selectedPeripheral.identifier UUIDString];
        if (![toStorePeripherals objectForKey:identifier]) {
            NSString * nameOfPeripheral = selectedPeripheral.name;
            NSNumber * alertTime =[NSNumber numberWithInt:5] ;
            NSMutableDictionary * toStorePeripheral =[NSMutableDictionary dictionaryWithObjectsAndKeys:identifier,@"identifier",nameOfPeripheral,@"name",alertTime,@"alertTime",nil];
            [toStorePeripherals setObject:toStorePeripheral forKey:identifier]
            ;
        }
        
    }
    [[NSUserDefaults standardUserDefaults] setObject:toStorePeripherals forKey:@"storedPeripherals"];
}
-(void)discoverPeripheralFinished:(NSNotification *)notification
{
    self.discoverdPeripherals = notification.object;
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.discoverdPeripherals count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"discoverDevices";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    if ([_discoverdPeripherals count]!=0) {
        CBPeripheral * peripheral = [_discoverdPeripherals objectAtIndex:[indexPath row]];
        
        cell.textLabel.text = peripheral.name;
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    [selectedCell setAccessoryType:UITableViewCellAccessoryCheckmark];
    if (self.selectedPeripheral ==nil) {
        self.selectedPeripheral = [NSMutableArray arrayWithObject:[self.discoverdPeripherals objectAtIndex:[indexPath row]]];
    }else
    {
        [self.selectedPeripheral addObject:[self.discoverdPeripherals objectAtIndex:[indexPath row]]];
    }
}
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
