//
//  CatParams.h
//  BFGParamsExample
//
//  Created by Benjamin Flynn on 7/8/17.
//  Copyright © 2017 Big Fish Games, Inc. All rights reserved.
//

#import "AnimalParams.h"

@interface CatParams : AnimalParams

// Serializeables
@property (nonatomic, strong) NSNumber*     likesWaterNumber;
@property (nonatomic, copy) NSString*       specie;

// Transient Helpers
@property (nonatomic, readonly) BOOL        likesWater;

@end
