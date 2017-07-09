//
//  CatExhibitParams.m
//  BFGParamsExample
//
//  Created by Benjamin Flynn on 7/8/17.
//  Copyright © 2017 Big Fish Games, Inc. All rights reserved.
//

#import "CatExhibitParams.h"


@implementation CatExhibitParams

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self.paramsIncludedInGET addObjectsFromArray:@[ @"subParams_CatParams_cats" ]];
        [self.paramsIncludedInPOST addObjectsFromArray:self.paramsIncludedInGET];
    }
    return self;
}

- (NSArray<CatParams *> *)cats
{
    return self.subParams_CatParams_cats;
}

@end
