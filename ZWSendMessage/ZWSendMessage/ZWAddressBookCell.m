//
//  ZWAddressBookCell.m
//  ZWSendMessage
//
//  Created by ZZWU on 16/1/15.
//  Copyright © 2016年 ZZWU. All rights reserved.
//

#import "ZWAddressBookCell.h"
#import "ZWAddressItems.h"

@interface ZWAddressBookCell ()

@property(weak,nonatomic)UIButton *selectBtn;

@property(weak,nonatomic)UILabel *userName;

@property(weak,nonatomic)UILabel *phoneNumber;

//@property(assign,nonatomic)BOOL selectState;

@end

@implementation ZWAddressBookCell

+(instancetype)zw_cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"addressBook";
    ZWAddressBookCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[ZWAddressBookCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    return cell;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self wu_creatAddressBookViewCell];
    }
    return self;
}

- (void)wu_creatAddressBookViewCell
{
    UIButton *selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 25, 25, 25)];
    [selectBtn setImage:nil forState:UIControlStateNormal];
    [selectBtn setImage:[UIImage imageNamed:@"shopCar_choose"] forState:UIControlStateSelected];
    self.selectBtn = selectBtn;
    [self addSubview:selectBtn];
    
    UILabel *userName = [[UILabel alloc] initWithFrame:CGRectMake(selectBtn.frame.size.width + selectBtn.frame.origin.x + 10, 5, 200, 35)];
    userName.textAlignment = NSTextAlignmentLeft;
    userName.font = [UIFont systemFontOfSize:20];
    self.userName = userName;
    [self addSubview:userName];
    
    UILabel *phoneNumber = [[UILabel alloc] initWithFrame:CGRectMake(selectBtn.frame.size.width + selectBtn.frame.origin.x + 10, userName.frame.size.height + userName.frame.origin.y + 5, 200, 25)];
    phoneNumber.textAlignment = NSTextAlignmentLeft;
    phoneNumber.font = [UIFont systemFontOfSize:15];
    self.phoneNumber = phoneNumber;
    [self addSubview:phoneNumber];
}

- (void)setAddressItems:(ZWAddressItems *)addressItems
{
    _addressItems = addressItems;
    
    self.selectBtn.selected = NO;
    self.userName.text = nil;
    self.phoneNumber.text = nil;
    if (addressItems.middleName && addressItems.firstName && addressItems.lastName) {
        self.userName.text = [NSString stringWithFormat:@"%@%@%@", addressItems.lastName, addressItems.middleName, addressItems.firstName];
    }
    else if (addressItems.firstName && addressItems.lastName){
        self.userName.text = [NSString stringWithFormat:@"%@%@", addressItems.lastName, addressItems.firstName];
    }
    else if (addressItems.lastName){
        self.userName.text = [NSString stringWithFormat:@"%@", addressItems.lastName];
    }
    if (addressItems.phoneArray[0]) {
        self.phoneNumber.text = [NSString stringWithFormat:@"%@", addressItems.phoneArray[0]];
    }
    self.selectBtn.selected = addressItems.selectState;
}

@end
