//
//  ViewController.h
//  SwimSaferTest
//
//  Created by hupengcheng  on 15/6/11.
//  Copyright (c) 2015年 hupengcheng . All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "PeripheralDetailViewViewController.h"
@interface ViewController : UIViewController<CBCentralManagerDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate,handlePeripheralDelegate>


@end

