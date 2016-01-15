//
//  ZWAddressItems.h
//  ZWSendMessage
//
//  Created by ZZWU on 16/1/15.
//  Copyright © 2016年 ZZWU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZWAddressItems : NSObject

@property(nonatomic,copy)NSString *firstName;
@property(nonatomic,copy)NSString *lastName;
@property(nonatomic,copy)NSString *middleName;
@property(nonatomic,copy)NSArray *phoneArray;

/**
 *  是否选中状态
 */
@property(assign,nonatomic)BOOL selectState;

@end
