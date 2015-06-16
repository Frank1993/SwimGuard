//
//  PeripheralDetailViewViewController.m
//  SwimSaferTest
//
//  Created by hupengcheng  on 15/6/14.
//  Copyright (c) 2015年 hupengcheng . All rights reserved.
//

#import "PeripheralDetailViewViewController.h"
#import "VPImageCropperViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>
#define ORIGINAL_MAX_WIDTH 640.0f
#define TOTAL_ALARM_TIME 30
@interface PeripheralDetailViewViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, VPImageCropperDelegate>
@property (nonatomic, strong) UIImageView *portraitImageView;
@property (nonatomic,strong) NSDictionary * peripheralsInfoDictionary;
@property (nonatomic,strong) UITextField * nameTextField;
@property (nonatomic,strong) UISlider * timeForAlarmSlider;
@property (nonatomic,strong) UIButton * startButton;
@property (nonatomic,strong) UILabel * alarmTimeLabel;
@end

@implementation PeripheralDetailViewViewController
@synthesize nameTextField = _nameTextField;
@synthesize timeForAlarmSlider = _timeForAlarmSlider;
@synthesize startButton;
@synthesize peripheralsInfoDictionary = _peripheralsInfoDictionary;
@synthesize alarmTimeLabel = _alarmTimeLabel;
-(NSDictionary *)infoOfThisPeripheral
{
    if (self.peripheralsInfoDictionary==nil) {
        self.peripheralsInfoDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"storedPeripherals"];
    }

    NSDictionary * infoOfThisPeripheral = [self.peripheralsInfoDictionary valueForKey:self.peripheral.identifier.UUIDString];
    return infoOfThisPeripheral;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnectWithPeripheral:) name:@"disconnecWithPeripheral" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectWithPeripheral:) name:@"connecWithPeripheral" object:nil];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Blur.png"]]];
    self.view.alpha = 1.0;
    
    [self.view addSubview:self.portraitImageView];
    [self loadPortrait];
    
    NSDictionary * infoOfThisPeripheral  = [self infoOfThisPeripheral];
    
    
    
    self.nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 250, self.view.frame.size.width-40, 44)];
    [self.nameTextField setBorderStyle:UITextBorderStyleRoundedRect];
    
    [self.nameTextField setFont:[UIFont fontWithName:@"STHeitiSC" size:20.00]];
    NSString * nameOfThisPeripheral =[infoOfThisPeripheral valueForKey:@"name"];
    self.nameTextField.text = nameOfThisPeripheral;
    self.title = nameOfThisPeripheral;

    self.nameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.nameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.nameTextField.returnKeyType = UIReturnKeyDone;
    self.nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing; //编辑时会出现个修改X
    self.nameTextField.keyboardType = UIKeyboardTypeNamePhonePad;
    self.nameTextField.backgroundColor = [UIColor clearColor];
    //   _textSendField.returnKeyType = UIReturnKeySend;
    self.nameTextField.delegate = self;
    /*
    self.nameTextField.layer.shadowColor = [UIColor blackColor].CGColor;
    self.nameTextField.layer.shadowOffset = CGSizeMake(2, 2);
    self.nameTextField.layer.shadowOpacity = 0.1;
    self.nameTextField.layer.shadowRadius = 0.9;
     */
    self.nameTextField.layer.borderColor = [[UIColor blackColor] CGColor];
    self.nameTextField.layer.borderWidth =1.0f;
    self.nameTextField.layer.cornerRadius = 5.0;
    [self.view addSubview:self.nameTextField];
    
    self.timeForAlarmSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height-190, self.view.frame.size.width-80, 44)];
    self.timeForAlarmSlider.minimumValue = 0;
    self.timeForAlarmSlider.maximumValue = 30;
    NSNumber * alarmTime = [infoOfThisPeripheral valueForKey:@"alertTime"];
    self.timeForAlarmSlider.value = [alarmTime floatValue];
    [self.timeForAlarmSlider addTarget:self action:@selector(timeForAlarmSliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.timeForAlarmSlider];
    
    UILabel * timeSelectLable = [[UILabel alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height-240, 150, 44)];
    timeSelectLable.text =@"延迟报警时间：";
    timeSelectLable.font = [UIFont systemFontOfSize:20];
    timeSelectLable.adjustsFontSizeToFitWidth = YES;
    timeSelectLable.backgroundColor = [UIColor clearColor];
    timeSelectLable.userInteractionEnabled = NO;
    [self.view addSubview:timeSelectLable];
    
    self.alarmTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-30, self.view.frame.size.height-190, 60, 44)];
    self.alarmTimeLabel.font = [UIFont systemFontOfSize:20];
    self.alarmTimeLabel.adjustsFontSizeToFitWidth = YES;
    self.alarmTimeLabel.backgroundColor = [UIColor clearColor];
    self.alarmTimeLabel.userInteractionEnabled = NO;
    self.alarmTimeLabel.text = [NSString stringWithFormat:@"%d",[alarmTime intValue]];
    [self.view addSubview:self.alarmTimeLabel];
    
    self.startButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.startButton.frame = CGRectMake(self.view.frame.size.width/2-50,self.view.frame.size.height-120, 100, 30);
    [self.startButton addTarget:self action:@selector(startButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.startButton.titleLabel.font = [UIFont systemFontOfSize: 20.0];
    self.startButton.layer.borderWidth = 1;
    self.startButton.layer.borderColor = [[UIColor grayColor] CGColor];
    self.startButton.layer.cornerRadius = 8;
    self.startButton.layer.masksToBounds = YES;
    if (self.peripheral.state ==CBPeripheralStateConnected) {
        [self.startButton setTitle:@"断开连接" forState:UIControlStateNormal];
    }else
    {
        [self.startButton setTitle:@"连接" forState:UIControlStateNormal];
    }
    [self.view addSubview:self.startButton];

    
    
    
}
-(void)disconnectWithPeripheral:(NSNotification *)notification
{
    [self updateStartButtonText];
}
-(void)connectWithPeripheral:(NSNotification *)notification
{
    [self updateStartButtonText];
}
-(void)startButtonPressed
{
    if (self.peripheral.state ==CBPeripheralStateConnected) {
        [self.delegate delegatedisconnectWithPeripheral:self.peripheral];
    }else
    {
        [self.delegate delegateConnectWithPeripheral:self.peripheral];
        
    }
}
-(void)updateStartButtonText
{
    if (self.peripheral.state ==CBPeripheralStateConnected) {
        [self.startButton setTitle:@"断开连接" forState:UIControlStateNormal];
    }else
    {
        [self.startButton setTitle:@"连接" forState:UIControlStateNormal];
    }
}
-(void)timeForAlarmSliderValueChanged
{
    self.alarmTimeLabel.text = [NSString stringWithFormat:@"%d",(int)self.timeForAlarmSlider.value];
    NSMutableDictionary * toStorePeripheral = [NSMutableDictionary dictionaryWithDictionary:[self infoOfThisPeripheral]];
    
    [toStorePeripheral setValue:[NSNumber numberWithInt:(int)self.timeForAlarmSlider.value] forKey:@"alertTime"];
    
    NSMutableDictionary * toStorePeripherals = [NSMutableDictionary dictionaryWithDictionary:self.peripheralsInfoDictionary];
    
    [toStorePeripherals setValue:toStorePeripheral forKey:self.peripheral.identifier.UUIDString];
    
    [[NSUserDefaults standardUserDefaults] setValue:toStorePeripherals forKey:@"storedPeripherals"];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)loadPortrait {
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString *documentsPath =[self dirDoc];
    NSString *imageDirectory = [documentsPath stringByAppendingPathComponent:@"UserImage"];
    BOOL isDir = FALSE;
    
    BOOL isDirExist = [fileManager fileExistsAtPath:imageDirectory isDirectory:&isDir];
    if(!(isDirExist && isDir))
        
    {
        BOOL res=[fileManager createDirectoryAtPath:imageDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        if (res) {
            NSLog(@"文件夹创建成功");
        }else
            NSLog(@"文件夹创建失败");
        self.portraitImageView.image = [UIImage imageNamed:@"defaultImage"];
    }else
    {
        NSString * imagePath = [imageDirectory stringByAppendingString:[NSString stringWithFormat:@"%@.png",self.peripheral.identifier.UUIDString]];
        if([fileManager fileExistsAtPath:imagePath])
        {
            UIImage *userImage = [UIImage imageWithContentsOfFile:imagePath];
            self.portraitImageView.image = userImage;
        }else
        {
            self.portraitImageView.image = [UIImage imageNamed:@"defaultImage"];

        }
    }
    
}

- (void)editPortrait {
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    [choiceSheet showInView:self.view];
}

#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    self.portraitImageView.image = editedImage;
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO
    }];
    NSData * data;
    if (UIImagePNGRepresentation(editedImage)==nil) {
        data = UIImageJPEGRepresentation(editedImage, 1);
    }else
    {
        data = UIImagePNGRepresentation(editedImage);
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath =[self dirDoc];
    NSString *imageDirectory = [documentsPath stringByAppendingPathComponent:@"UserImage"];
    BOOL isDir = FALSE;
    
    BOOL isDirExist = [fileManager fileExistsAtPath:imageDirectory isDirectory:&isDir];
    if(!(isDirExist && isDir))
        
    {
        BOOL res=[fileManager createDirectoryAtPath:imageDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        if (res) {
            NSLog(@"文件夹创建成功");
        }else
            NSLog(@"文件夹创建失败");
    }
    
    BOOL res =[fileManager createFileAtPath:[imageDirectory stringByAppendingString:[NSString stringWithFormat:@"%@.png",self.peripheral.identifier.UUIDString]] contents:data attributes:nil];
    if (res) {
         NSLog(@"文件创建成功: %@" ,[imageDirectory stringByAppendingString:[NSString stringWithFormat:@"%@.png",self.peripheral.identifier.UUIDString]]);
    }else
    {
         NSLog(@"文件创建失败");
    }
    
}
-(NSString *)dirDoc{
    //[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSLog(@"app_home_doc: %@",documentsDirectory);
    return documentsDirectory;
}
- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // 拍照
        if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([self isFrontCameraAvailable]) {
                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
        
    } else if (buttonIndex == 1) {
        // 从相册中选取
        if ([self isPhotoLibraryAvailable]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [self imageByScalingToMaxSize:portraitImg];
        // 裁剪
        VPImageCropperViewController *imgEditorVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgEditorVC.delegate = self;
        [self presentViewController:imgEditorVC animated:YES completion:^{
            // TO DO
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}

#pragma mark camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark portraitImageView getter
- (UIImageView *)portraitImageView {
    if (!_portraitImageView) {
        CGFloat w = 140.0f; CGFloat h = w;
        CGFloat x = (self.view.frame.size.width - w) / 2;
        CGFloat y =90;
        _portraitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        [_portraitImageView.layer setCornerRadius:(_portraitImageView.frame.size.height/2)];
        [_portraitImageView.layer setMasksToBounds:YES];
        [_portraitImageView setContentMode:UIViewContentModeScaleAspectFill];
        [_portraitImageView setClipsToBounds:YES];
        _portraitImageView.layer.shadowColor = [UIColor blackColor].CGColor;
        _portraitImageView.layer.shadowOffset = CGSizeMake(4, 4);
        _portraitImageView.layer.shadowOpacity = 0.5;
        _portraitImageView.layer.shadowRadius = 2.0;
        _portraitImageView.layer.borderColor = [[UIColor blackColor] CGColor];
        _portraitImageView.layer.borderWidth = 2.0f;
        _portraitImageView.userInteractionEnabled = YES;
        _portraitImageView.backgroundColor = [UIColor blackColor];
        UITapGestureRecognizer *portraitTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editPortrait)];
        [_portraitImageView addGestureRecognizer:portraitTap];
    }
    return _portraitImageView;
}
#pragma textFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString * nameText = [[self infoOfThisPeripheral] valueForKey:@"name"];
    if (![textField.text isEqualToString:nameText]) {
        NSMutableDictionary * toStorePeripheral = [NSMutableDictionary dictionaryWithDictionary:[self infoOfThisPeripheral]];
        
        [toStorePeripheral setValue:textField.text forKey:@"name"];
        
        NSMutableDictionary * toStorePeripherals = [NSMutableDictionary dictionaryWithDictionary:self.peripheralsInfoDictionary];
        
        [toStorePeripherals setValue:toStorePeripheral forKey:self.peripheral.identifier.UUIDString];
        
        [[NSUserDefaults standardUserDefaults] setValue:toStorePeripherals forKey:@"storedPeripherals"];
    }
}
@end
