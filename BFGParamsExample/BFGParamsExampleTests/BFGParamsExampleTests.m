//
//  BFGParamsExampleTests.m
//  BFGParamsExampleTests
//
//  Created by Benjamin Flynn on 2/14/16.
//  Copyright © 2016 Big Fish Games, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//


#import <XCTest/XCTest.h>

#import "NSJSONSerialization+BFG.h"
#import "NSString+BFG.h"

#import "ZooParams.h"
#import "CatExhibitParams.h"
#import "CatParams.h"

@interface BFGParamsExampleTests : XCTestCase

@end

@implementation BFGParamsExampleTests

- (void)test_ZooCreatedFromDictionary_hasCorrectTopLevelMembers
{
    NSDictionary *dict = @{ @"name": @"My Zoo", @"founding-date": @(1499548643), @"is-open-daily": @(YES) };
    ZooParams *zoo = [ZooParams paramsWithValuesFromDictionary:dict];
    XCTAssertEqualObjects(zoo.name, @"My Zoo");
    XCTAssertEqual(zoo.openDaily, YES);
    XCTAssertEqualObjects(zoo.foundingDate, [[NSDate alloc] initWithTimeIntervalSince1970:1499548643]);
}

- (void)test_ZooCreatedFromJSON_hasCorrectTopLevelMembers
{
    // Create a zoo from a dictionary
    NSDictionary *dict = @{ @"name": @"My Zoo", @"founding-date": @(1499548643), @"is-open-daily": @(YES) };
    ZooParams *zoo = [ZooParams paramsWithValuesFromDictionary:dict];
    
    // Transform it into JSON
    NSString *zooJSON = [zoo paramsForPOSTAsJSON];
    
    // Transform the JSON into a dictionary
    NSError *error;
    NSDictionary *zooFromJSONDict = [NSJSONSerialization safeJSONObjectWithData:[zooJSON dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    XCTAssertNil(error);
    
    // Create a new zoo from this dictionary
    ZooParams *zooFromJSON = [ZooParams paramsWithValuesFromDictionary:zooFromJSONDict];
    XCTAssertEqualObjects(zooFromJSON.name, @"My Zoo");
    XCTAssertEqual(zooFromJSON.openDaily, YES);
    XCTAssertEqualObjects(zooFromJSON.foundingDate, [[NSDate alloc] initWithTimeIntervalSince1970:1499548643]);
}

- (void)test_ZooWithCats_hasCorrectValues
{
    NSDictionary *dict = @{ @"name": @"Cat Zoo",
                            @"founding-date": @(1499548643),
                            @"is-open-daily": @(NO),
                            @"catExhibit": @{ @"name": @"Cats of Africa",
                                              @"is-indoors": @(NO),
                                              @"cats": @[ @{ @"name": @"Chester",
                                                             @"specie": @"Panthera pardus",
                                                             @"weightInKG": @(50),
                                                             @"likesWater": @(NO) },
                                                          @{ @"name": @"Tony",
                                                             @"specie": @"Panthera tigris",
                                                             @"weightInKG": @(180),
                                                             @"likesWater": @(YES) }
                                                          ]
                                              }
                            };
    ZooParams *zoo = [ZooParams paramsWithValuesFromDictionary:dict];
    XCTAssertEqualObjects(zoo.name, @"Cat Zoo");
    XCTAssertEqual(zoo.openDaily, NO);
    XCTAssertEqualObjects(zoo.foundingDate, [[NSDate alloc] initWithTimeIntervalSince1970:1499548643]);
    CatExhibitParams *catExhibit = zoo.catExhibit;
    XCTAssertNotNil(catExhibit);
    XCTAssertEqualObjects(catExhibit.name, @"Cats of Africa");
    XCTAssertEqualObjects(@(NO), catExhibit.indoorsNumber);
    NSArray<CatParams *>* cats = catExhibit.cats;
    XCTAssertNotNil(cats);
    XCTAssertEqual(cats.count, 2);
    CatParams *chester = cats[0];
    XCTAssertEqualObjects(chester.name, @"Chester");
    XCTAssertEqualObjects(chester.specie, @"Panthera pardus");
    XCTAssertEqualObjects(chester.weightInKG, @(50));
    XCTAssertEqual(chester.likesWater, NO);
    CatParams *tony = cats[1];
    XCTAssertEqualObjects(tony.name, @"Tony");
    XCTAssertEqualObjects(tony.specie, @"Panthera tigris");
    XCTAssertEqualObjects(tony.weightInKG, @(180));
    XCTAssertEqual(tony.likesWater, YES);
    NSLog(@"Cat Zoo: %@", zoo.paramsForPOSTAsJSON);
}


@end
