//
//  DiscoverdDevicesTableViewController.h
//  SwimSaferTest
//
//  Created by hupengcheng  on 15/6/11.
//  Copyright (c) 2015年 hupengcheng . All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface DiscoverdDevicesTableViewController : UITableViewController
@property (nonatomic,strong) NSMutableArray * discoverdPeripherals;
@end
