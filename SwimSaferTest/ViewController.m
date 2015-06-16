//
//  ViewController.m
//  SwimSaferTest
//
//  Created by hupengcheng  on 15/6/11.
//  Copyright (c) 2015年 hupengcheng . All rights reserved.
//

#import "ViewController.h"
#import "DiscoverdDevicesTableViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "QuartzCore/QuartzCore.h"
#import "DevicesTableViewCell.h"
@interface ViewController ()
@property (nonatomic,strong) CBCentralManager *manager;
@property (strong, nonatomic) UITableView *devicesTableView;
@property (strong,nonatomic) NSMutableArray * discoverdPeripherals;
@property (nonatomic,strong) NSMutableArray *selectedPeripherals;
@property (nonatomic,strong) NSMutableArray * disconnectedPeripherals;
@property (nonatomic,strong) NSTimer * reconnectTimer;
@property (nonatomic,strong) NSDictionary * storedPeripherals;
@property (nonatomic) UIBackgroundTaskIdentifier  backgroundTaskIdentifier;
@property (nonatomic,strong) NSMutableArray * mannuallyDisconnectedPeripheralsArray;
@property(nonatomic,strong) UIBarButtonItem * stopAlarmButton;
@end

@implementation ViewController
@synthesize stopAlarmButton = _stopAlarmButton;
@synthesize manager = _manager;
@synthesize devicesTableView = _devicesTableView;
@synthesize discoverdPeripherals = _discoverdPeripherals;
@synthesize selectedPeripherals = _selectedPeripherals;
@synthesize disconnectedPeripherals = _disconnectedPeripherals;
@synthesize reconnectTimer = _reconnectTimer;
@synthesize storedPeripherals = _storedPeripherals;
@synthesize backgroundTaskIdentifier = _backgroundTaskIdentifier;
@synthesize mannuallyDisconnectedPeripheralsArray = _mannuallyDisconnectedPeripheralsArray;
-(NSMutableArray *)discoverdPeripherals
{
    if (_discoverdPeripherals ==nil) {
        _discoverdPeripherals = [[NSMutableArray alloc] init];
    }
    return _discoverdPeripherals;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnectWithPeripheral:) name:@"disconnecWithPeripheral" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectWithPeripheral:) name:@"connecWithPeripheral" object:nil];
    
    self.backgroundTaskIdentifier =[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
    }];
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.devicesTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    self.devicesTableView.delegate = self;
    self.devicesTableView.dataSource = self;
    [self.view addSubview:self.devicesTableView];
    self.devicesTableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Blur.png"]];
    self.devicesTableView.backgroundView.alpha = 0.4;
    self.devicesTableView.separatorInset = UIEdgeInsetsMake(0,10, 0, 10);        // 设置端距，这里表示separator离左边和右边均80像素
    
    self.devicesTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    self.stopAlarmButton= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(stopAlarm)];
    

}
-(void)stopAlarm
{
    [self.reconnectTimer invalidate];
    self.reconnectTimer = nil;
    self.navigationItem.leftBarButtonItem = nil;
    UIAlertView * stopAlarmAlertView = [[UIAlertView alloc] initWithTitle:@"警告" message:@"您已暂停此次警报，系统将不再自动连接当前已经断开的设备" delegate:self cancelButtonTitle:@"确认" otherButtonTitles: nil];
    [stopAlarmAlertView show];
}
-(void)viewDidAppear:(BOOL)animated
{
    [self reloadDevicesTableView];
}
-(void)reconnectTimerFired
{
    if ([self.disconnectedPeripherals count]==0) {
        [self.reconnectTimer invalidate];
        self.reconnectTimer = nil;
        self.navigationItem.leftBarButtonItem = nil;
    }else
    {
        for (NSArray * disconnectInfoOfPeripheral in self.disconnectedPeripherals) {
            CBPeripheral * peripheral = [disconnectInfoOfPeripheral objectAtIndex:0];
            if (self.mannuallyDisconnectedPeripheralsArray ==nil) {
                self.mannuallyDisconnectedPeripheralsArray = [[NSMutableArray alloc] init];
            }
            if ([self.mannuallyDisconnectedPeripheralsArray indexOfObject:peripheral]) {
                NSDate * disconnectDate = [disconnectInfoOfPeripheral objectAtIndex:1];
                if ([self isPeripheral:peripheral ExpiredTime:disconnectDate]) {
                    [self playAlarmSound];
                }
                NSLog(@"try to reconnect ");
                
                [self.manager connectPeripheral:peripheral options:nil];
            }
        }
    }
}
-(void)playAlarmSound
{
    
    self.navigationItem.leftBarButtonItem = self.stopAlarmButton;

    CFBundleRef mainBundle;
    SystemSoundID soundFileObject;
    mainBundle = CFBundleGetMainBundle ();
    CFURLRef soundFileURLRef  = CFBundleCopyResourceURL (mainBundle,CFSTR ("ALARM"),CFSTR ("WAV"),NULL);
    AudioServicesCreateSystemSoundID (soundFileURLRef,&soundFileObject);
    AudioServicesPlaySystemSound(soundFileObject);
    
    
}
-(BOOL)isPeripheral:(CBPeripheral *)peripheral ExpiredTime:(NSDate *)disconnectDate
{
    NSString * identifier = peripheral.identifier.UUIDString;
    NSDictionary * peripheralInfo = [self.storedPeripherals valueForKey:identifier];
    NSNumber * alertTime = [peripheralInfo valueForKey:@"alertTime"];
    NSTimeInterval  timeInterval  = [[NSDate date] timeIntervalSinceDate:disconnectDate];
    if (timeInterval >[alertTime intValue] ) {
        if (peripheral.state !=CBPeripheralStateConnected) {
            return YES;
        }else
        {
            return NO;

        }
    }else
    {
        return NO;
    }
}
-(void)reloadDevicesTableView
{
    self.storedPeripherals = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"storedPeripherals"];
    NSMutableArray * peripheralIdentifiers = [[NSMutableArray alloc] init];

    NSArray * identifierArray = [self.storedPeripherals allKeys];
    for (NSString *identifierString in identifierArray) {
        NSUUID * identifier = [[NSUUID alloc] initWithUUIDString:identifierString];
        [peripheralIdentifiers addObject:identifier];
    }
    
    
    
    NSArray * peripherals = [self.manager retrievePeripheralsWithIdentifiers:[NSArray arrayWithArray:peripheralIdentifiers]];
    self.selectedPeripherals =[NSMutableArray arrayWithArray:peripherals];
    [self.devicesTableView reloadData];
    
}
-(void)disconnectWithPeripheral:(NSNotification *)notification
{
    NSInteger rowOfPeripheral = [self.selectedPeripherals indexOfObject:[notification object]];
    NSIndexPath * cellIndexPath = [NSIndexPath indexPathForRow:rowOfPeripheral inSection:0];
    UITableViewCell * peripheralCell = [self.devicesTableView cellForRowAtIndexPath:cellIndexPath];
    peripheralCell.detailTextLabel.text = @"disconneted";
}
-(void)connectWithPeripheral:(NSNotification *)notification
{
    CBPeripheral * peripheral =[notification object];
    NSInteger rowOfPeripheral = [self.selectedPeripherals indexOfObject:peripheral];
    NSIndexPath * cellIndexPath = [NSIndexPath indexPathForRow:rowOfPeripheral inSection:0];
    UITableViewCell * peripheralCell = [self.devicesTableView cellForRowAtIndexPath:cellIndexPath];
    peripheralCell.detailTextLabel.text = @"connected";
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_selectedPeripherals count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identified = @"selected";
    DevicesTableViewCell *cell = [self.devicesTableView dequeueReusableCellWithIdentifier:identified];
    if (cell == nil) {
        cell = [[DevicesTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identified];
        
    }
    if ([_selectedPeripherals count]!=0) {
        CBPeripheral * peripheral = [_selectedPeripherals objectAtIndex:[indexPath row]];
        cell.textLabel.text =[self getNameOfPeripheral:peripheral];
        if (peripheral.state ==CBPeripheralStateConnected) {
            cell.detailTextLabel.text = @"conneted";
        }else
        {
            cell.detailTextLabel.text = @"disconneted";
        }
        NSFileManager * fileManager = [NSFileManager defaultManager];
        NSString *documentsPath =[self dirDoc];
        NSString *imageDirectory = [documentsPath stringByAppendingPathComponent:@"UserImage"];
        BOOL isDir = FALSE;
        
        BOOL isDirExist = [fileManager fileExistsAtPath:imageDirectory isDirectory:&isDir];
        UIImage * userImage;
        if(!(isDirExist && isDir))
            
        {
            BOOL res=[fileManager createDirectoryAtPath:imageDirectory withIntermediateDirectories:YES attributes:nil error:nil];
            if (res) {
                NSLog(@"文件夹创建成功");
            }else
                NSLog(@"文件夹创建失败");
            userImage = [UIImage imageNamed:@"defaultImage"];
        }else
        {
            NSString * imagePath = [imageDirectory stringByAppendingString:[NSString stringWithFormat:@"%@.png",peripheral.identifier.UUIDString]];
            if([fileManager fileExistsAtPath:imagePath])
            {
                userImage = [UIImage imageWithContentsOfFile:imagePath];
            }else
            {
                userImage = [UIImage imageNamed:@"defaultImage"];
                
            }
        }
        
        cell.imageView.image = userImage;
    }
    return cell;
}
-(NSString *)dirDoc{
    //[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSLog(@"app_home_doc: %@",documentsDirectory);
    return documentsDirectory;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
-(NSString *)getNameOfPeripheral:(CBPeripheral *)peripheral
{
    NSDictionary * peripheralInfo = [self.storedPeripherals valueForKey:peripheral.identifier.UUIDString];
    NSString * nameOfPeripheral  = [peripheralInfo valueForKey:@"name"];
    return nameOfPeripheral;
}
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    PeripheralDetailViewViewController * peripheralDetailViewController = [[PeripheralDetailViewViewController alloc] init];
    CBPeripheral * peripheral  = [self.selectedPeripherals objectAtIndex:[indexPath row]];
    peripheralDetailViewController.peripheral =peripheral;
    peripheralDetailViewController.delegate = self;
    [self.navigationController pushViewController:peripheralDetailViewController animated:NO];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBPeripheral *peripheral = [self.selectedPeripherals objectAtIndex:[indexPath row]];
    if (peripheral.state ==CBPeripheralStateConnected) {
        [self mannuallyDisconnectWithPeripheral:peripheral];
    }else
    {
        if (peripheral.state ==CBPeripheralStateDisconnected) {
            [self.manager connectPeripheral:peripheral options:nil];
        }
    }
    
}
-(void)mannuallyDisconnectWithPeripheral:(CBPeripheral *)peripheral
{
    if (self.mannuallyDisconnectedPeripheralsArray ==nil) {
        self.mannuallyDisconnectedPeripheralsArray = [NSMutableArray arrayWithObject:peripheral];
    }else
    {
        [self.mannuallyDisconnectedPeripheralsArray addObject:peripheral];
    }
    UIActionSheet * actionsheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"您确认断开与%@之间的连接嘛？",[self getNameOfPeripheral:peripheral]] delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [actionsheet showInView:self.view];
}
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex !=[actionSheet cancelButtonIndex]) {
        for (CBPeripheral * peripheral in self.mannuallyDisconnectedPeripheralsArray) {
            if (peripheral.state ==CBPeripheralStateConnected) {
                [self.manager cancelPeripheralConnection:peripheral];
            }
        }
    }
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"已选择的设备:";
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle ==UITableViewCellEditingStyleDelete)
    {
        CBPeripheral * peripheral  = [self.selectedPeripherals objectAtIndex:[indexPath row]];
        NSString * identifier = peripheral.identifier.UUIDString;
        NSMutableDictionary * tostorePeripherals = [NSMutableDictionary dictionaryWithDictionary:self.storedPeripherals];
        [tostorePeripherals removeObjectForKey:identifier];
        [[NSUserDefaults standardUserDefaults] setObject:tostorePeripherals forKey:@"storedPeripherals"];
        [self reloadDevicesTableView];
        [self.manager cancelPeripheralConnection:peripheral];
        if(self.mannuallyDisconnectedPeripheralsArray==nil)
        {
            self.mannuallyDisconnectedPeripheralsArray = [NSMutableArray arrayWithObject:peripheral];
        }else
        {
            [self.mannuallyDisconnectedPeripheralsArray addObject:peripheral];
        }
       
    }
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier  isEqual:@"discover"]) {
        self.discoverdPeripherals = nil;
        [self scanPeriphralInTime:15];
    }
}

#pragma CBCenterManagerDelegate
-(void)scanPeriphralInTime:(int)timeout
{
//    if (_manager.state !=CBCentralManagerStatePoweredOn) {
//        NSLog(@"the divices did'nt turned on");
//    }
    [NSTimer scheduledTimerWithTimeInterval:(float)timeout target:self selector:@selector(stopScan) userInfo:nil repeats:NO];
    [self.manager scanForPeripheralsWithServices:nil options:nil];
    
}
-(void)stopScan
{
    [self.manager stopScan];
    
}
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"we found the peripheral:%@",peripheral.name);
    if (self.discoverdPeripherals ==nil) {
        self.discoverdPeripherals = [NSMutableArray arrayWithObject:peripheral];
    }else
    {
        [self.discoverdPeripherals addObject:peripheral];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"discoverPeripheralFinished" object:self.discoverdPeripherals];
}
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            NSLog(@"state powerd on");
            break;
        case CBCentralManagerStateResetting:
            NSLog(@"state resetting");
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@"state powerd off");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"state unauthorized");
            break;
        case CBCentralManagerStateUnknown:
            NSLog(@"state unkown");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"state unsupported");
            break;
        default:
            break;
    }
}
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"we have connected the peripheral:%@",peripheral.name);
    for (NSArray * disconnetedInfoOfPeripheral in self.disconnectedPeripherals) {
        CBPeripheral * disconnetedPeripheral = [disconnetedInfoOfPeripheral objectAtIndex:0];
        if ([peripheral isEqual:disconnetedPeripheral]) {
            [self.disconnectedPeripherals removeObject:disconnetedInfoOfPeripheral];
        }
    }
    if ([self.mannuallyDisconnectedPeripheralsArray indexOfObject:peripheral]!=NSNotFound) {
        [self.mannuallyDisconnectedPeripheralsArray removeObject:peripheral];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"connecWithPeripheral" object:peripheral];
    
    
    
}
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"disconnect with :%@",peripheral.name);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"disconnecWithPeripheral" object:peripheral];
    if (self.mannuallyDisconnectedPeripheralsArray ==nil) {
        self.mannuallyDisconnectedPeripheralsArray = [[NSMutableArray alloc] init];
    }
    if([self.mannuallyDisconnectedPeripheralsArray indexOfObject:peripheral])
    {
        if ([self.selectedPeripherals indexOfObject:peripheral]!=NSNotFound) {
          
            NSDate * disconnectTime = [NSDate date];
            NSArray * disconnectInfoOfPeripheral = [NSArray arrayWithObjects:peripheral,disconnectTime, nil];
            if (self.disconnectedPeripherals ==nil) {
                self.disconnectedPeripherals = [NSMutableArray arrayWithObject:disconnectInfoOfPeripheral];
            }else
            {
                [self.disconnectedPeripherals addObject:disconnectInfoOfPeripheral];
            }
            if ([self.disconnectedPeripherals count]==1) {
                [self.reconnectTimer invalidate];
                self.reconnectTimer = nil;
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    
                    self.reconnectTimer =
                    [NSTimer timerWithTimeInterval:1.8
                                            target:self
                                          selector:@selector(reconnectTimerFired)
                                          userInfo:nil
                                           repeats:YES];
                    
                    [[NSRunLoop mainRunLoop] addTimer:self.reconnectTimer
                                              forMode:NSDefaultRunLoopMode];
                });
                
            }
        }
    }
    
}
#pragma handlePeripheralDelegate
-(void)delegateConnectWithPeripheral:(CBPeripheral *)peripheral
{
    [self.manager connectPeripheral:peripheral options:nil];
}
-(void)delegatedisconnectWithPeripheral:(CBPeripheral *)peripheral
{
    if (self.mannuallyDisconnectedPeripheralsArray ==nil) {
        self.mannuallyDisconnectedPeripheralsArray = [NSMutableArray arrayWithObject:peripheral];
    }else
    {
        [self.mannuallyDisconnectedPeripheralsArray addObject:peripheral];
    }
    if (peripheral.state ==CBPeripheralStateConnected) {
        [self.manager cancelPeripheralConnection:peripheral];
    }
}
@end
