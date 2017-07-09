//
//  CatParams.m
//  BFGParamsExample
//
//  Created by Benjamin Flynn on 7/8/17.
//  Copyright © 2017 Big Fish Games, Inc. All rights reserved.
//

#import "CatParams.h"

@implementation CatParams

@synthesize specie = _specie;

BFG_SAFE_SETTER(setSpecie, NSString, _specie, YES);

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self.paramsIncludedInGET addObjectsFromArray:@[ @"likesWaterNumber" ]];        
        [self.paramsIncludedInPOST addObjectsFromArray:self.paramsIncludedInGET];
        [self.externalNameMap addEntriesFromDictionary:@{ @"likesWaterNumber": @"likesWater" }];
    }
    return self;
}

- (void)populateWithDefaultValues
{
    self.likesWaterNumber = @(NO);
}

- (BOOL)likesWater
{
    return self.likesWaterNumber.boolValue;
}
@end
