//
//  UIDevice+Extension.h
//  Universal
//
//  Created by emiaobao on 15/9/1.
//  Copyright (c) 2015年 emiaobao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (Extension)

+ (BOOL)IPhone;

+ (float)systemVersion;

+ (BOOL)IOS9;

+ (BOOL)IOS8;

+ (BOOL)IOS7;

+ (BOOL)IOS6;

/**
 *   返回针对与一个应用的唯一ID
 *
 *   @return 针对与一个应用的唯一ID
 */
+ (NSString *)uniqueDeviceIdentifier;


/**
 *   返回设备的唯一ID
 *
 *   @return 设备的唯一ID
 */
+ (NSString *)uniqueGlobalDeviceIdentifier;
/**
 *  用户定义设备名称
 *
 *  @return
 */
+ (NSString*)deviceName;
/**
 *  系统名称
 *
 *  @return
 */
+ (NSString*)systemName;
/**
 *  设备型号
 *
 *  @return
 */
+ (NSString*)deviceModel;
/**
 *  国际化区域名称
 *
 *  @return
 */
+ (NSString*)deviceLocationModel;

@end
