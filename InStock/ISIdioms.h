//
//  ISModel.h
//  InStock
//
//  Created by Ahmet Alp Balkan on 10/26/13.
//  Copyright (c) 2013 Luminous Apps. All rights reserved.
//

#define N(x) [NSNumber numberWithInteger:x]


typedef NS_ENUM(NSInteger, ISIdiom) {
    ISIdiomMobileDeviceCapacity = 0,
    ISIdiomMacBookScreenSize,
    ISIdiomMacMini,
    ISIdiomiMacConfiguration,
    ISIdiomMacProConfiguration,
    ISIdiomiPhoneColor,
    ISIdiomiPadType,
    ISIdiomNetworkCarrier
};

typedef NS_ENUM(NSInteger, ISMobileDeviceCapacity) {
    ISMobileDeviceCapacity8GB = 0,
    ISMobileDeviceCapacity16GB,
    ISMobileDeviceCapacity32GB,
    ISMobileDeviceCapacity64GB,
    ISMobileDeviceCapacity128GB,
};

typedef NS_ENUM(NSInteger, ISMacBookScreenSize) {
    ISMacBookScreenSize11inch = 0,
    ISMacBookScreenSize13inch,
    ISMacBookScreenSize15inch
};

typedef NS_ENUM(NSInteger, ISMacMini) {
    ISMacMini2_5GHz = 0,
    ISMacMini2_3GHz,
    ISMacMini2_3GHzWithOsXServer
};

typedef NS_ENUM(NSInteger, ISiMacConfiguration) {
    ISiMacConfiguration21_5inch2_7GHz = 0,
    ISiMacConfiguration21_5inch2_9GHz,
    ISiMacConfiguration27_5inch3_2GHz,
    ISiMacConfiguration27_5inch3_4GHz
};

typedef NS_ENUM(NSInteger, ISMacProConfiguration) {
    ISMacProConfiguration4Core = 0,
    ISMacProConfiguration6Core
};

typedef NS_ENUM(NSInteger, ISiPhoneColor) {
    ISiPhoneColorBlack = 0,
    ISiPhoneColorWhite,
    ISiPhoneColorSilver,
    ISiPhoneColorSpaceGray,
    ISiPhoneColorGold,
    ISiPhoneColorPink,
    ISiPhoneColorYellow,
    ISiPhoneColorBlue,
    ISiPhoneColorGreen
};

typedef NS_ENUM(NSInteger, ISiPadType) {
    ISiPadTypeWifi = 0,
    ISiPadTypeWifiCellular
};

typedef NS_ENUM(NSInteger, ISNetworkCarrier) {
    ISNetworkCarrierAtt = 0,
    ISNetworkCarrierSprint,
    ISNetworkCarrierVerizon,
    ISNetworkCarrierTmobileContractFree,
    ISNetworkCarrierUnlockedSimFree,
    ISNetworkCarrierTmobile
};

@interface ISIdioms : NSObject

+(NSString*)titleForIdiom:(ISIdiom)idiom;
+(NSString*)nameForOption:(NSInteger)option inIdiom:(ISIdiom)idiom;

@end