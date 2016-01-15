//
//  ZWAddressBookCell.h
//  ZWSendMessage
//
//  Created by ZZWU on 16/1/15.
//  Copyright © 2016年 ZZWU. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZWAddressItems;

@interface ZWAddressBookCell : UITableViewCell

@property (nonatomic, weak)ZWAddressItems *addressItems;
+ (instancetype) zw_cellWithTableView:(UITableView *)tableView;

@end
