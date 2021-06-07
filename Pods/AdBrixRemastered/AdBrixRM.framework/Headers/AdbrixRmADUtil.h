//
//  AdPopcornUtil.h
//  IgaworksAd
//
//  Created by wonje,song on 2014. 1. 15.. remaster freddy on 2018
//  Copyright (c) 2018. igaworks All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage(IgaworksADGrayScaleAdditions)

@property (NS_NONATOMIC_IOSONLY, readonly, strong) UIImage *igaworksAD_toGrayScale;
+ (UIImage *)igaworksAD_imageWithColor:(UIColor *)color;
@end

@interface UIColor(IgaworksADHexStringAdditions)

+ (UIColor *)igaworksAD_colorFromHexString:(NSString *)hexString;

@end

@interface NSDate(IgaworksADCLRTicksAdditions)
+ (NSDate *)igaworksAD_dateWithCLRTicks:(int64_t)ticks;
+ (NSDate *)igaworksAD_dateWithCLRTicks:(int64_t)ticks withTimeIntervalAddition:(NSTimeInterval)timeIntervalAddition;


@end

/*!
 @discussion idfa, idfv, network, md4, utc 등 제반사항을 다루는 유틸리티 구현체
 @author freddy
 */
@interface AdbrixRmADUtil : NSObject


+ (NSString *)checkNilToBlankString:(id)target;

+ (BOOL)checkNilToNo:(NSString *)target;
+ (int)checkNilToZero:(id)target;
+ (int64_t)checkLongLongNilToZero:(id)target;
+ (NSInteger)checkIntegerNilToZero:(id)target;

+ (float)checkFloatNilToZero:(id)target;
+ (double)checkDoubleNilToZero:(id)target;

+ (BOOL)checkValidEmailAddress:(NSString *)emailAddress;

+ (NSString *)IDFA;
+ (NSString *)IDFV;
+ (BOOL)isAppleAdvertisingTrackingEnabled;
+ (NSString *)platformString;
+ (BOOL)isPhone;
+ (NSString *)carrier;

+ (NSString *)screenHeight;
+ (NSString *)screenWidth;
+ (NSString *)orientation;

+ (NSString *)detectNetworkInfo;
+ (NSString *)getNetworkStatus;

+ (NSString *)getKoreaDateFormateDate:(NSDate *)date;
+ (NSString *)getUTCFormateDate:(NSDate *)date;
+ (NSString *)getUTCFormateDateWithFormatExp:(NSDate *)date format:(NSString *)format;
+ (NSDate *)msToDate:(double)baseTime;
+ (NSString *)getUTCFormatByMs:(double)baseTime;

+ (NSString *)md5:(NSString *)input;
+ (NSString *)sha1:(NSString *)input;
+ (BOOL)isRetinaDisplay;

+ (NSString *)queryString:(NSDictionary *)parameterDict;

+ (CGSize)getDeviceResolution;


+ (NSString *)getDefaultLanguage;
+ (NSString *)getDefaultLocation;

+ (NSDictionary *)getURLParmaters:(NSURL *)URL;

+ (NSTimeInterval)timeIntervalSinceServerDate:(NSDate *)date sinceBaseTime:(NSTimeInterval)baseTime;

+ (NSString *)getIPAddress;
+ (NSArray *)getLocalDate;

+ (unsigned int) getFreeRam;
+ (NSString *)freeDiskSpace;
+ (NSString *)memoryFormatter:(long long)diskSpace;
+ (NSString *)getIgaworksDevice;

+ (NSData *)igaworksAD_AES256Encryption:(NSData *)jsonData key:(NSString *)key;
+ (NSData *)igaworksAD_AES256Decryption:(NSData *)jsonData key:(NSString *)key;
+ (NSString *)igaworksAD_tracerByteToHex:(NSData *)data;

@end
