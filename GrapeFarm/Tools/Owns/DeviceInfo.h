//
//  DeviceInfo.h
//  CommonProject
//
//  Created by wuyoujian on 16/5/13.
//  Copyright © 2016年 wuyoujian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger ,DeviceInfo_Model) {
    
    MODEL_UNKNOWN = 1,
    MODEL_IPHONE_SIMULATOR,
    MODEL_IPOD_TOUCH,
    MODEL_IPOD_TOUCH_2G,
    MODEL_IPOD_TOUCH_3G,
    MODEL_IPOD_TOUCH_4G,
    MODEL_IPHONE,
    MODEL_IPHONE_3G,
    MODEL_IPHONE_3GS,
    MODEL_IPHONE_4G,
    MODEL_IPHONE_4G_REV_A, //3,2
    MODEL_IPHONE_4G_CDMA,  //3,3
    MODEL_IPHONE_4GS,      //4,1
    MODEL_IPHONE_5G_A1428, //5,1
    MODEL_IPHONE_5G_A1429, //5,2
    MODEL_IPHONE_5C,
    MODEL_IPHONE_5S,
    MODEL_IPHONE_6,
    MODEL_IPHONE_6PLUS,
    MODEL_IPHONE_6S,
    MODEL_IPHONE_6SPLUS,
    MODEL_IPHONE_SE,
    MODEL_IPHONE_7,
    MODEL_IPHONE_7plus,
    MODEL_IPHONE_8,
    MODEL_IPHONE_8plus,
    MODEL_IPHONE_X,
    MODEL_IPAD
};

@interface DeviceInfo : NSObject

+ (NSString *) platform;
+ (DeviceInfo_Model) detectModel;
+ (NSString *) returnDeviceName;
+ (uint)detectDevice;

//是否越狱
+ (BOOL) isJailBreak;
+ (BOOL) isEmulator;
+ (BOOL) isOS7;
+ (BOOL) isOS8;
+ (BOOL) isOS9;
+ (BOOL) isOS10;
+ (BOOL) isOS11;
+ (BOOL) isRetinaScreen;
+ (CGFloat) screenScale;
+ (NSString*) getSystemVersion;
+ (CGSize) getLogicScreenSize;
+ (CGSize) getDeviceScreenSize;
+ (CGFloat) screenWidth;
+ (CGFloat) screenHeight;
+ (NSInteger) getSystemTime;
+ (NSString*) getSystemTimeStamp;
+ (NSString*) getSoftVersion;
+ (NSString*) getHomePath;
+ (NSString*) getMainBundlePath;
+ (NSString*) getDocumentsPath;
+ (NSString*) getCachePath;
+ (NSString*) getTmpPath;
+ (NSString*) platformString;

+ (NSInteger) navigationBarHeight;
+ (NSInteger) statusBarHeight;

+ (NSString*) getIPAddress:(BOOL)preferIPv4;
+ (NSDictionary*) getIPAddresses;

+ (BOOL)isiPhone;
+ (BOOL)isiPad;

+ (BOOL)isInstalledAppWithSchemes:(NSString *)schemes;

@end
