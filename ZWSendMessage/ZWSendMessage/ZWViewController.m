//
//  ZWViewController.m
//  ZWSendMessage
//
//  Created by ZZWU on 16/1/15.
//  Copyright © 2016年 ZZWU. All rights reserved.
//

#import "ZWViewController.h"
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>
#import "ZWAddressItems.h"
#import "ZWAddressBookCell.h"

@interface ZWViewController ()<MFMessageComposeViewControllerDelegate>

@property(nonatomic,strong)NSArray *body;
@property(nonatomic,assign)NSInteger number;
@property(nonatomic,strong)NSMutableArray *addressItemsArray;
@property(nonatomic,strong)NSMutableArray *selectAddressItemsArray;

@end

@implementation ZWViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addressBook:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(sendMessage:)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    self.tableView.rowHeight = 75;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)addressItemsArray
{
    if (_addressItemsArray == nil) {
        NSMutableArray *addressItemsArray = [NSMutableArray array];
        _addressItemsArray = addressItemsArray;
    }
    return _addressItemsArray;
}

-(NSMutableArray *)selectAddressItemsArray
{
    if (_selectAddressItemsArray == nil) {
        NSMutableArray *addressItemsArray = [NSMutableArray array];
        _selectAddressItemsArray = addressItemsArray;
    }
    return _selectAddressItemsArray;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.addressItemsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZWAddressBookCell *cell = [ZWAddressBookCell zw_cellWithTableView:tableView];
    ZWAddressItems *addressItems = self.addressItemsArray[indexPath.row];
    cell.addressItems = addressItems;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ZWAddressItems *addressItems = self.addressItemsArray[indexPath.row];
    if (addressItems.selectState == YES) {
        addressItems.selectState = NO;
        [self.selectAddressItemsArray removeObject:addressItems];
    }
    else if(addressItems.selectState == NO)
    {
        addressItems.selectState = YES;
        [self.selectAddressItemsArray addObject:addressItems];
    }
    NSLog(@"%lu",(unsigned long)self.selectAddressItemsArray.count);
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)addressBook:(UIButton *)sender {
    [self getAddressBook];
    [self.tableView reloadData];
}

- (void)sendMessage:(UIButton *)sender {
    if ([MFMessageComposeViewController canSendText]) {
        NSArray *body = @[@"测试", @"测试测试测试",@"测试测试", @"测试测试测试测试测试测试测试测试测试"];
        self.body = body;
        ZWAddressItems *addressItems = self.selectAddressItemsArray[0];
        [self forMessageWith:body[0] recipients:addressItems.phoneArray[0]];
        NSLog(@"%@",[NSThread currentThread]);
    }
}

- (void)forMessageWith:(NSString *)body recipients:(NSString *)recipients
{
    MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc]init]; //autorelease];
    
    controller.recipients = [NSArray arrayWithObject:recipients];
    controller.body = body;
    controller.messageComposeDelegate = self;
    
    [self presentViewController:controller animated:YES completion:^{
        
    }];
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissViewControllerAnimated:NO completion:^{
        if (result && _number < self.selectAddressItemsArray.count - 1) {
            _number ++;
            ZWAddressItems *addressItems = self.selectAddressItemsArray[_number];
            [self forMessageWith:self.body[1] recipients:addressItems.phoneArray[0]];
        }
    }];
    
    switch ( result ) {
            
        case MessageComposeResultCancelled:
            NSLog(@"发送取消");
            [controller dismissViewControllerAnimated:YES completion:^{
                
            }];
            break;
        case MessageComposeResultFailed:
            NSLog(@"发送失败");
            [controller dismissViewControllerAnimated:YES completion:^{
                
            }];
            break;
        case MessageComposeResultSent:
            NSLog(@"发送成功");
            break;
        default:
            break;
    }
}

- (void)getAddressBook
{
    //这个变量用于记录授权是否成功，即用户是否允许我们访问通讯录
    int __block tip = 0;
    //声明一个通讯簿的引用
    ABAddressBookRef addBook = nil;
    //创建通讯簿的引用
    addBook = ABAddressBookCreateWithOptions(NULL, NULL);
    //创建一个出事信号量为0的信号
    dispatch_semaphore_t sema=dispatch_semaphore_create(0);
    //申请访问权限
    ABAddressBookRequestAccessWithCompletion(addBook, ^(bool greanted, CFErrorRef error){
        //greanted为YES是表示用户允许，否则为不允许
        if (!greanted) {
            tip = 1;
        }
        //发送一次信号
        dispatch_semaphore_signal(sema);
    });
    //等待信号触发
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    if (tip) {
        //做一个友好的提示
        UIAlertView * alart = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"请您设置允许APP访问您的通讯录\nSettings>General>Privacy" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alart show];
        return;
    }
    
    //获取所有联系人的数组
    CFArrayRef allLinkPeople = ABAddressBookCopyArrayOfAllPeople(addBook);
    //获取联系人总数
    CFIndex number = ABAddressBookGetPersonCount(addBook);
    //进行遍历
    for (NSInteger i = 0; i < number; i++) {
        ZWAddressItems *addressItems = [[ZWAddressItems alloc] init];
        //获取联系人对象的引用
        ABRecordRef  people = CFArrayGetValueAtIndex(allLinkPeople, i);
        //获取当前联系人名字
        NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(people, kABPersonFirstNameProperty));
        addressItems.firstName = firstName;
        //获取当前联系人姓氏
        NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(people, kABPersonLastNameProperty));
//        NSLog(@"%@%@", lastName, firstName);
        addressItems.lastName = lastName;
        //获取当前联系人中间名
        NSString *middleName = (__bridge NSString*)(ABRecordCopyValue(people, kABPersonMiddleNameProperty));
//        NSLog(@"%@", middleName);
        addressItems.middleName = middleName;
//        //获取当前联系人的名字前缀
//        NSString *prefix = (__bridge NSString*)(ABRecordCopyValue(people, kABPersonPrefixProperty));
////        NSLog(@"%@%@", middleName, firstName);
//        //获取当前联系人的名字后缀
//        NSString *suffix = (__bridge NSString*)(ABRecordCopyValue(people, kABPersonSuffixProperty));
//        NSLog(@"%@%@", prefix, suffix);
//        //获取当前联系人的昵称
//        NSString *nickName = (__bridge NSString*)(ABRecordCopyValue(people, kABPersonNicknameProperty));
//        NSLog(@"%@", nickName);
//        //获取当前联系人的名字拼音
//        NSString *firstNamePhoneic = (__bridge NSString*)(ABRecordCopyValue(people, kABPersonFirstNamePhoneticProperty));
////        NSLog(@"%@%@", lastName, firstName);
//        //获取当前联系人的姓氏拼音
//        NSString *lastNamePhoneic = (__bridge NSString*)(ABRecordCopyValue(people, kABPersonLastNamePhoneticProperty));
////        NSLog(@"%@%@", lastName, firstName);
//        //获取当前联系人的中间名拼音
//        NSString *middleNamePhoneic = (__bridge NSString*)(ABRecordCopyValue(people, kABPersonMiddleNamePhoneticProperty));
//        NSLog(@"%@%@%@", lastNamePhoneic, middleNamePhoneic, firstNamePhoneic);
//        //获取当前联系人的公司
//        NSString *organization = (__bridge NSString*)(ABRecordCopyValue(people, kABPersonOrganizationProperty));
//        NSLog(@"%@", organization);
//        //获取当前联系人的职位
//        NSString *job = (__bridge NSString*)(ABRecordCopyValue(people, kABPersonJobTitleProperty));
////        NSLog(@"%@%@", lastName, firstName);
//        //获取当前联系人的部门
//        NSString *department = (__bridge NSString*)(ABRecordCopyValue(people, kABPersonDepartmentProperty));
//        NSLog(@"%@%@", job, department);
//        //获取当前联系人的生日
//        NSString *birthday = (__bridge NSString*)(ABRecordCopyValue(people, kABPersonBirthdayProperty));
//        NSLog(@"%@", birthday);
//        NSMutableArray *emailArr = [[NSMutableArray alloc]init];
//        //获取当前联系人的邮箱 注意是数组
//        ABMultiValueRef emails = ABRecordCopyValue(people, kABPersonEmailProperty);
//        for (NSInteger j = 0; j < ABMultiValueGetCount(emails); j++) {
//            [emailArr addObject:(__bridge NSString *)(ABMultiValueCopyValueAtIndex(emails, j))];
//            NSLog(@"%@", emails);
//        }
//        //获取当前联系人的备注
//        NSString *notes = (__bridge NSString*)(ABRecordCopyValue(people, kABPersonNoteProperty));
//        NSLog(@"%@", notes);
        //获取当前联系人的电话 数组
        NSMutableArray *phoneArr = [[NSMutableArray alloc] init];
        ABMultiValueRef phones = ABRecordCopyValue(people, kABPersonPhoneProperty);
        for (NSInteger j = 0; j < ABMultiValueGetCount(phones); j++) {
            [phoneArr addObject:(__bridge NSString *)(ABMultiValueCopyValueAtIndex(phones, j))];
            NSLog(@"%@",phoneArr);
            addressItems.phoneArray = phoneArr;
        }
//        //获取创建当前联系人的时间 注意是NSDate
//        NSDate *creatTime = (__bridge NSDate*)(ABRecordCopyValue(people, kABPersonCreationDateProperty));
////        NSLog(@"%@%@", lastName, firstName);
//        //获取最近修改当前联系人的时间
//        NSDate *alterTime = (__bridge NSDate*)(ABRecordCopyValue(people, kABPersonModificationDateProperty));
//        NSLog(@"%@%@", creatTime, alterTime);
//        //获取地址
//        ABMultiValueRef address = ABRecordCopyValue(people, kABPersonAddressProperty);
//        for (int j = 0; j < ABMultiValueGetCount(address); j++) {
//            //地址类型
//            NSString *type = (__bridge NSString *)(ABMultiValueCopyLabelAtIndex(address, j));
//            NSDictionary *temDic = (__bridge NSDictionary *)(ABMultiValueCopyValueAtIndex(address, j));
//            //地址字符串，可以按需求格式化
//            NSString *adress = [NSString stringWithFormat:@"国家:%@\n省:%@\n市:%@\n街道:%@\n邮编:%@",[temDic valueForKey:(NSString*)kABPersonAddressCountryKey], [temDic valueForKey:(NSString*)kABPersonAddressStateKey], [temDic valueForKey:(NSString*)kABPersonAddressCityKey], [temDic valueForKey:(NSString*)kABPersonAddressStreetKey], [temDic valueForKey:(NSString*)kABPersonAddressZIPKey]];
//            NSLog(@"%@%@", adress, type);
//        }
//        //获取当前联系人头像图片
//        NSData *userImage = (__bridge NSData*)(ABPersonCopyImageData(people));
//        NSLog(@"%@", userImage);
//        //获取当前联系人纪念日
//        NSMutableArray *dateArr = [[NSMutableArray alloc]init];
//        ABMultiValueRef dates = ABRecordCopyValue(people, kABPersonDateProperty);
//        for (NSInteger j = 0; j<ABMultiValueGetCount(dates); j++) {
//            //获取纪念日日期
//            NSDate *data =(__bridge NSDate*)(ABMultiValueCopyValueAtIndex(dates, j));
//            //获取纪念日名称
//            NSString *str = (__bridge NSString*)(ABMultiValueCopyLabelAtIndex(dates, j));
//            NSDictionary *temDic = [NSDictionary dictionaryWithObject:data forKey:str];
//            [dateArr addObject:temDic];
//        }
        [self.addressItemsArray addObject:addressItems];
    }
    //        一点扩展：相同的方法，可以获取关联人信息，社交信息，邮箱信息，各种类型的电话信息，字段如下：
    
    //相关人，组织字段
    //        const ABPropertyID kABPersonKindProperty;
    //        const CFNumberRef kABPersonKindPerson;
    //        const CFNumberRef kABPersonKindOrganization;
    //
    //        // 电话相关字段
    //        AB_EXTERN const ABPropertyID kABPersonPhoneProperty;
    //        AB_EXTERN const CFStringRef kABPersonPhoneMobileLabel;
    //        AB_EXTERN const CFStringRef kABPersonPhoneIPhoneLabel;
    //        AB_EXTERN const CFStringRef kABPersonPhoneMainLabel;
    //        AB_EXTERN const CFStringRef kABPersonPhoneHomeFAXLabel;
    //        AB_EXTERN const CFStringRef kABPersonPhoneWorkFAXLabel;
    //        AB_EXTERN const CFStringRef kABPersonPhoneOtherFAXLabel;
    //        AB_EXTERN const CFStringRef kABPersonPhonePagerLabel;
    //
    //        // 即时聊天信息相关字段
    //        AB_EXTERN const ABPropertyID kABPersonInstantMessageProperty;
    //        AB_EXTERN const CFStringRef kABPersonInstantMessageServiceKey;
    //        AB_EXTERN const CFStringRef kABPersonInstantMessageServiceYahoo;
    //        AB_EXTERN const CFStringRef kABPersonInstantMessageServiceJabber;
    //        AB_EXTERN const CFStringRef kABPersonInstantMessageServiceMSN;
    //        AB_EXTERN const CFStringRef kABPersonInstantMessageServiceICQ;
    //        AB_EXTERN const CFStringRef kABPersonInstantMessageServiceAIM;
    //        AB_EXTERN const CFStringRef kABPersonInstantMessageServiceQQ;
    //        AB_EXTERN const CFStringRef kABPersonInstantMessageServiceGoogleTalk;
    //        AB_EXTERN const CFStringRef kABPersonInstantMessageServiceSkype;
    //        AB_EXTERN const CFStringRef kABPersonInstantMessageServiceFacebook;
    //        AB_EXTERN const CFStringRef kABPersonInstantMessageServiceGaduGadu;
    //        AB_EXTERN const CFStringRef kABPersonInstantMessageUsernameKey;
    //
    //        // 个人网页相关字段
    //        AB_EXTERN const ABPropertyID kABPersonURLProperty;
    //        AB_EXTERN const CFStringRef kABPersonHomePageLabel;
    //        //相关人姓名字段
    //        AB_EXTERN const ABPropertyID kABPersonRelatedNamesProperty;
    //        AB_EXTERN const CFStringRef kABPersonFatherLabel;    // Father
    //        AB_EXTERN const CFStringRef kABPersonMotherLabel;    // Mother
    //        AB_EXTERN const CFStringRef kABPersonParentLabel;    // Parent
    //        AB_EXTERN const CFStringRef kABPersonBrotherLabel;   // Brother
    //        AB_EXTERN const CFStringRef kABPersonSisterLabel;    // Sister
    //        AB_EXTERN const CFStringRef kABPersonChildLabel;      // Child
    //        AB_EXTERN const CFStringRef kABPersonFriendLabel;    // Friend
    //        AB_EXTERN const CFStringRef kABPersonSpouseLabel;    // Spouse
    //        AB_EXTERN const CFStringRef kABPersonPartnerLabel;   // Partner
    //        AB_EXTERN const CFStringRef kABPersonAssistantLabel; // Assistant
    //        AB_EXTERN const CFStringRef kABPersonManagerLabel;   // Manager
}

@end
