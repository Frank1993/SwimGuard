//
//  PeripheralDetailViewViewController.h
//  SwimSaferTest
//
//  Created by hupengcheng  on 15/6/14.
//  Copyright (c) 2015年 hupengcheng . All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol handlePeripheralDelegate <NSObject>

-(void)delegatedisconnectWithPeripheral:(CBPeripheral *)peripheral;
-(void)delegateConnectWithPeripheral:(CBPeripheral *)peripheral;

@end
@interface PeripheralDetailViewViewController : UIViewController<UITextFieldDelegate>
@property(nonatomic,strong) CBPeripheral * peripheral;
@property (nonatomic,assign) id <handlePeripheralDelegate> delegate;
@end
