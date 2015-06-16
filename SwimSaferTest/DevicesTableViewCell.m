//
//  DevicesTableViewCell.m
//  SwimSaferTest
//
//  Created by hupengcheng  on 15/6/16.
//  Copyright (c) 2015年 hupengcheng . All rights reserved.
//

#import "DevicesTableViewCell.h"

@implementation DevicesTableViewCell

- (void)awakeFromNib {
    // Initialization code
}
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    [self.imageView setFrame:CGRectMake(5, 7, 56, 56)];
    self.imageView.layer.cornerRadius = 9;
    self.imageView.layer.masksToBounds = YES;
    CGRect frameOfTextLabel = self.textLabel.frame;
    frameOfTextLabel.origin.x = frameOfTextLabel.origin.x-30;
    self.textLabel.frame = frameOfTextLabel;
    CGRect frameOfDetailLabel = self.detailTextLabel.frame;
    frameOfDetailLabel.origin.x = frameOfDetailLabel.origin.x-30;
    self.detailTextLabel.frame =frameOfDetailLabel;
}
@end
