//
//  BFGParams.h
//
//  Created by Benjamin Flynn on 2/28/13.
//  Copyright (c) 2016 Big Fish Games, Inc.
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

#import <Foundation/Foundation.h>

//
// This is a helpful macro for subclasses of BFGParams. The macro checks the
// type of the object being set and prevents a type mismatch.
//
#define BFG_SAFE_SETTER(SETTER_NAME, SETTER_TYPE_NAME, IVAR, COPY) \
- (void)SETTER_NAME:(SETTER_TYPE_NAME *)value \
{ \
    if ([value isKindOfClass:[SETTER_TYPE_NAME class]]) \
    { \
        if (COPY) \
        { \
            IVAR = [value copy]; \
        } \
        else \
        { \
            IVAR = value; \
        } \
    } \
}

#ifdef DEBUG
#define BFGLog NSLog
#else
#define BFGLog
#endif

@interface BFGParams : NSObject

///
/// Sub-classing note:
/// If a parameter is a subclass of bfgParams, it must be declared in the following form:
///
/// @property (nonatomic, strong) bfgMyParams *subParams_bfgMyParams_someParam;
///
/// In this case, bfgMyParams is the name of a class that sub-classes bfgParams. subParams is a string literal.
/// The resulting paramForGET will have the name someParam (without the prefix).
///

///
/// This class provides objectification of many but NOT ALL possible JSON constructs. Notably, because
/// sub-classes of bfgParams need explicit typing hints in their declarations, there are limitations as
/// to where they can be placed in collections. Notably, they cannot be placed in dictionaries nor in
/// Arrays of Arrays (but they can be placed in top level arrays that are named using the sub-classing
/// note convention above). Not being allowed in generic dictionaries should not be a major limitation
/// since sub-classes are effectively dictionary wrappers so rather than using a dictionary, use a sub-class
/// of bfgParams.
///
/// See the unit-tests for examples.
///

///
/// All properties desired in the GET string should be added to this array.
///
@property (nonatomic, readonly) NSMutableArray *paramsIncludedInGET;

///
/// All properties desired in the POST dictionary should be added to this array.
///
@property (nonatomic, readonly) NSMutableArray *paramsIncludedInPOST;

///
/// JSON allows string keys that are illegal as variable names (e.g. "purchase-info")
/// Map the local variable name to its external JSON key (e.g. @{ @"purchaseInfo" : @"purchase-info" })
/// Note: Always use the true variable name for the key and the final desired external name
///       for the value. (e.g. @{ @"subParams_bfgMyParams_someParam" : @"some-param" })
///
@property (nonatomic, strong) NSMutableDictionary *externalNameMap;

///
/// Convenience factory method
///
+ (instancetype)paramsWithValuesFromDictionary:(NSDictionary *)dictionary;

///
/// Convenience factory method
///
+ (instancetype)paramsWithDefaultValues;

///
/// Some standard logic for assigning values to properties.
///
- (void)populateWithDefaultValues;

///
/// Returns a list of parameters and values of the form X[&Y...]. Values are URL-encoded.
///
- (NSString *)paramsForGET;

///
/// Returns a dictionary of parameters for conversion to JSON
///
- (NSMutableDictionary *)paramsForPOST;

///
/// Convenience method returns the post dictionary as a JSON
///
- (NSString *)paramsForPOSTAsJSON;

///
/// Given a dictionary, set any param values that match. This method is forgiving of malformed dictionaries.
///
- (void)setValuesFromDictionary:(NSDictionary *)dictionary;

///
/// Convenience method creates dictionary from json and calls setValuesFromDictionary
///
- (void)setValuesFromJSON:(NSString *)json;

///
/// Check params value against contract. Error contains violations.
///
- (BOOL)conformsToRequirements:(NSError *__autoreleasing *)error;

@end
