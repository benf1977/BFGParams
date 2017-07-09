//
//  ZooParams.m
//  BFGParamsExample
//
//  Created by Benjamin Flynn on 7/8/17.
//  Copyright © 2017 Big Fish Games, Inc. All rights reserved.
//

#import "ZooParams.h"

@implementation ZooParams

BFG_SAFE_SETTER(setName, NSString, _name, YES);
BFG_SAFE_SETTER(setFoundingDateEpoch, NSNumber, _foundingDateEpoch, NO);
BFG_SAFE_SETTER(setOpenDailyNumber, NSNumber, _openDailyNumber, NO);

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self.paramsIncludedInGET addObjectsFromArray:@[ @"foundingDateEpoch", @"name", @"openDailyNumber", @"subParams_CatExhibitParams_catExhibit" ]];
        [self.paramsIncludedInPOST addObjectsFromArray:self.paramsIncludedInGET];
        [self.externalNameMap addEntriesFromDictionary:@{ @"foundingDateEpoch": @"founding-date", @"openDailyNumber": @"is-open-daily" }];
    }
    return self;
}

- (void)populateWithDefaultValues
{
    [super populateWithDefaultValues];
    self.name = @"Generic Zoo";
}

- (NSDate *)foundingDate
{
    return [NSDate dateWithTimeIntervalSince1970:self.foundingDateEpoch.doubleValue];
}

- (BOOL)openDaily
{
    return self.openDailyNumber.boolValue;
}

- (CatExhibitParams *)catExhibit
{
    return self.subParams_CatExhibitParams_catExhibit;
}

@end
