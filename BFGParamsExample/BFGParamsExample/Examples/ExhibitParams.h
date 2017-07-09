//
//  ExhibitParams.h
//  BFGParamsExample
//
//  Created by Benjamin Flynn on 7/8/17.
//  Copyright © 2017 Big Fish Games, Inc. All rights reserved.
//

#import "BFGParams.h"

@interface ExhibitParams : BFGParams

// Serializeables
@property (nonatomic, strong) NSNumber*     indoorsNumber;
@property (nonatomic, copy) NSString*       name;

// Transient Helpers
@property (nonatomic, readonly) BOOL        indoors;

@end
