//
//  ExhibitParams.m
//  BFGParamsExample
//
//  Created by Benjamin Flynn on 7/8/17.
//  Copyright © 2017 Big Fish Games, Inc. All rights reserved.
//

#import "ExhibitParams.h"

@implementation ExhibitParams

BFG_SAFE_SETTER(setName, NSString, _name, YES);
BFG_SAFE_SETTER(setIndoorsNumber, NSNumber, _indoorsNumber, NO);

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self.paramsIncludedInGET addObjectsFromArray:@[ @"name", @"indoorsNumber" ]];
        [self.paramsIncludedInPOST addObjectsFromArray:self.paramsIncludedInGET];
        [self.externalNameMap addEntriesFromDictionary:@{ @"indoorsNumber": @"is-indoors" }];
    }
    return self;
}

- (BOOL)indoors
{
    return self.indoorsNumber.boolValue;
}

@end
