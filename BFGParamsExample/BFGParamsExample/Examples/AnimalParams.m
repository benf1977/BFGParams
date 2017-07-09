//
//  AnimalParams.m
//  BFGParamsExample
//
//  Created by Benjamin Flynn on 7/8/17.
//  Copyright © 2017 Big Fish Games, Inc. All rights reserved.
//

#import "AnimalParams.h"

@implementation AnimalParams

BFG_SAFE_SETTER(setName, NSString, _name, YES);
BFG_SAFE_SETTER(setWeightInKG, NSNumber, _weightInKG, NO);

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self.paramsIncludedInGET addObjectsFromArray:@[ @"name", @"weightInKG", @"specie" ]];
        [self.paramsIncludedInPOST addObjectsFromArray:self.paramsIncludedInGET];        
    }
    return self;
}

// Override me!
- (NSString *)specie
{
    return nil;
}

@end
