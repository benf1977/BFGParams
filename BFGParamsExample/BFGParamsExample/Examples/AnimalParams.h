//
//  AnimalParams.h
//  BFGParamsExample
//
//  Created by Benjamin Flynn on 7/8/17.
//  Copyright © 2017 Big Fish Games, Inc. All rights reserved.
//

#import "BFGParams.h"

@interface AnimalParams : BFGParams

@property (nonatomic, copy) NSString*       name;
@property (nonatomic, strong) NSNumber*     weightInKG;

// Intended to be overridden
@property (nonatomic, readonly) NSString*   specie;

@end
