//
//  ZooParams.h
//  BFGParamsExample
//
//  Created by Benjamin Flynn on 7/8/17.
//  Copyright © 2017 Big Fish Games, Inc. All rights reserved.
//

#import "BFGParams.h"
#import "CatExhibitParams.h"

@interface ZooParams : BFGParams

// Serializeables
@property (nonatomic, copy) NSString*               name;
@property (nonatomic, strong) NSNumber*             foundingDateEpoch;
@property (nonatomic, strong) NSNumber*             openDailyNumber;
@property (nonatomic, strong) CatExhibitParams*     subParams_CatExhibitParams_catExhibit;

// Transient Helpers
@property (nonatomic, readonly) CatExhibitParams*   catExhibit;
@property (nonatomic, readonly) NSDate*             foundingDate;
@property (nonatomic, readonly) BOOL                openDaily;

@end
