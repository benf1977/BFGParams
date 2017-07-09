//
//  CatExhibitParams.h
//  BFGParamsExample
//
//  Created by Benjamin Flynn on 7/8/17.
//  Copyright © 2017 Big Fish Games, Inc. All rights reserved.
//

#import "ExhibitParams.h"

#import "CatParams.h"

@interface CatExhibitParams : ExhibitParams

// Serializeables
@property (nonatomic, strong) NSArray<CatParams *>*     subParams_CatParams_cats;

// Transient Helpers
@property (nonatomic, readonly) NSArray<CatParams *>*   cats;

@end
