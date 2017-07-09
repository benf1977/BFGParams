//
//  BFGParams.m
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

#import "BFGParams.h"

#import "NSString+BFG.h"
#import "NSJSONSerialization+BFG.h"

#import <objc/runtime.h>

@interface BFGParams()

@property (nonatomic, strong) NSArray *setterNames;
@property (nonatomic, strong) NSMutableArray *paramsIncludedInGET;
@property (nonatomic, strong) NSMutableArray *paramsIncludedInPOST;


- (NSObject *)paramForName:(NSString *)paramName;

@end



@implementation BFGParams

#pragma mark - Instance lifecycle

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.paramsIncludedInGET = [NSMutableArray array];
        self.paramsIncludedInPOST = [NSMutableArray array];
        self.externalNameMap = [NSMutableDictionary dictionary];
        
        // Grab a list of all the setter names in the class to use in deserialization
        unsigned int count;
        Method *methodList = class_copyMethodList(object_getClass(self), &count);
        NSMutableArray *names = [NSMutableArray array];
        for (int i = 0; i < count; i++)
        {
            NSString *name = [NSString stringWithUTF8String:sel_getName(method_getName(methodList[i]))];
            if ([name hasPrefix:@"set"])
            {
                [names addObject:name];
            }
        }
        free(methodList); // Per class_copyMethodList docs
        methodList = NULL;
        self.setterNames = [NSArray arrayWithArray:names];

    }
    return self;
}

+ (instancetype)paramsWithValuesFromDictionary:(NSDictionary *)dictionary
{
    BFGParams *params = [[self alloc] init];
    [params setValuesFromDictionary:dictionary];
    return params;
}

+ (instancetype)paramsWithDefaultValues
{
    BFGParams *params = [[self alloc] init];
    [params populateWithDefaultValues];
    return params;
}


#pragma mark - Public instance methods

- (NSString *)paramsForGET
{
    NSMutableString *paramsForGET = [NSMutableString string];
    BOOL first = YES;
    for (NSString *paramName in self.paramsIncludedInGET)
    {
        id param = [self paramForName:paramName];
        NSString *paramString;
        if (param == nil)
        {
            continue;
        }
        if ([paramName hasPrefix:@"subParams_"])
        {
            // Sub-params can sub-classes of bfgParams, or arrays of sub-classes of bfgParams
            if ([param isKindOfClass:[NSArray class]])
            {
                NSMutableString *arrayString = [NSMutableString stringWithString:@"["];
                BOOL arrayFirst = YES;
                for (id member in param)
                {
                    if (![member isKindOfClass:[BFGParams class]])
                    {
                        NSAssert(NO, @"Array intended to contain only %@ children does not", [BFGParams class]);
                        continue;
                    }
                    if (!arrayFirst)
                    {
                        [arrayString appendString:@","];
                    }
                    [arrayString appendString:[member paramsForGET]];
                    arrayFirst = NO;
                }
                [arrayString appendString:@"]"];
                paramString = arrayString;
            }
            else
            {
                if (![param isKindOfClass:[BFGParams class]])
                {
                    NSAssert(NO, @"Param %@ is not an NSArray or %@", paramName, [BFGParams class]);
                    continue;
                }
                paramString = [param paramsForGET];
            }
        }
        else
        {
            // Convert NSNumbers backed by booleans into true / false
            if ([param isKindOfClass:[NSNumber class]])
            {
                if ([param objCType][0] == 'c')
                {
                    paramString = ( [param boolValue] ? @"true" : @"false" );
                }
                else
                {
                    paramString = [NSString stringWithFormat:@"%@", param];
                }
            }
            else if ([param isKindOfClass:[NSArray class]])
            {
                NSMutableString *arrayString = [NSMutableString stringWithString:@"["];
                BOOL arrayFirst = YES;
                for (id member in param)
                {
                    if (!arrayFirst)
                    {
                        [arrayString appendString:@","];
                    }
                    [arrayString appendString:[member description]];
                    arrayFirst = NO;
                }
                [arrayString appendString:@"]"];
                paramString = arrayString;
            }
            else
            {
                paramString = [NSString stringWithFormat:@"%@", param];
            }
        }
        if (!first)
        {
            [paramsForGET appendString:@"&"];
        }
        NSString *externalName = ([self.externalNameMap objectForKey:paramName] ? [self.externalNameMap objectForKey:paramName] : paramName);
        [paramsForGET appendFormat:@"%@=%@", externalName, [paramString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        first = NO;
    }
    return paramsForGET;
}


- (NSString *)paramsForPOSTAsJSON
{
    return [NSString stringWithUTF8Data:[NSJSONSerialization safeDataWithJSONObject:self.paramsForPOST options:0 error:0]];
}


- (NSMutableDictionary *)paramsForPOST
{
    NSMutableDictionary *paramsForPOST = [NSMutableDictionary dictionary];

    for (NSString *paramName in self.paramsIncludedInPOST)
    {
        id param = [self paramForName:paramName];
        if (param == nil)
        {
            continue;
        }
        if ([paramName hasPrefix:@"subParams_"])
        {            
            // Either the paramName is fully mapped to a special external name, or we just grab the part after the prefix
            NSInteger index = [paramName rangeOfString:@"^[^_]*_[^_]*_" options:NSRegularExpressionSearch].length;
            NSString *externalName = ([self.externalNameMap objectForKey:paramName] ? [self.externalNameMap objectForKey:paramName] : [paramName substringFromIndex:index]);
            if ([param isKindOfClass:[NSArray class]])
            {
                NSMutableArray *array = [NSMutableArray array];
                for (id member in param)
                {
                    if (![member isKindOfClass:[BFGParams class]])
                    {
                        NSAssert(NO, @"Array intended to contain only bfgParam children does not");
                        continue;
                    }
                    [array addObject:[member paramsForPOST]];
                }
                [paramsForPOST setObject:array forKey:externalName];
            }
            else
            {
                if (![param isKindOfClass:[BFGParams class]])
                {
                    NSAssert(NO, @"Prefix 'subParams_' used but value type is not an NSArray or subclass of %@ for %@/%@ (it's a %@)",  [BFGParams class], paramName, externalName,[param class]);
                    continue;
                }
                [paramsForPOST setObject:[param paramsForPOST] forKey:externalName];
            }
        }
        else
        {
            if ([param isKindOfClass:[BFGParams class]])
            {
                NSAssert(NO, @"Contained instances of %@ must use name prefix 'subParams_'", [BFGParams class]);
                continue;
            }
            NSString *externalName = ([self.externalNameMap objectForKey:paramName] ? [self.externalNameMap objectForKey:paramName] : paramName);
            [paramsForPOST setObject:param forKey:externalName];
        }
    }
    return paramsForPOST;
}


- (void)populateWithDefaultValues
{
    // Nothing by default!
}


- (void)setValuesFromJSON:(NSString *)json
{
    NSError *error;
    id jsonValue = [NSJSONSerialization safeJSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if (error)
    {
        BFGLog(@"Error parsing %@ (%@)", json, error);
    }
    
    // Don't crash if JSONValue is an array
    if ([jsonValue isKindOfClass:[NSDictionary class]])
    {
        [self setValuesFromDictionary:jsonValue];
    }
}


- (void)setValuesFromDictionary:(NSDictionary *)dictionary
{
    if (![dictionary isKindOfClass:[NSDictionary class]])
    {
        BFGLog(@"'dictionary' is not an NSDictionary");
        return;
    }
    for (NSString *originalKey in [dictionary allKeys])
    {
        // No empty keys
        if ([originalKey length] == 0)
        {
            continue;
        }
        
        // Translate an external name back to a local variable name, if necessary.
        NSString *modifiedKey = nil;
        for (NSString *mapKey in [self.externalNameMap allKeys])
        {
            if ([[self.externalNameMap objectForKey:mapKey] isEqualToString:originalKey])
            {
                modifiedKey = mapKey;
                // Because our mapping contains the full property name, we need to strip the subParams part for the rest of this method to work
                // Example: "device-info" -> "subParams_bfgDeviceInfoParams_deviceInfo" -> "deviceInfo"
                modifiedKey =  [modifiedKey substringFromIndex:[modifiedKey rangeOfString:@"^subParams_[^_]*_" options:NSRegularExpressionSearch].length];
                break;
            }
        }
        if (!modifiedKey)
        {
            modifiedKey = originalKey;
        }
        
        // A setter uppercases the first letter of the key (e.g. appName -> setAppName)
        NSString *uppercaseKey;
        if ([modifiedKey length] == 1)
        {
            uppercaseKey = [modifiedKey uppercaseString];
        }
        else
        {
            uppercaseKey = [NSString stringWithFormat:@"%@%@", [[modifiedKey substringToIndex:1] uppercaseString], [modifiedKey substringFromIndex:1]];
        }
        
        SEL setterSelector = NSSelectorFromString([NSString stringWithFormat:@"set%@:", uppercaseKey]);
        if ([self respondsToSelector:setterSelector])
        {
            // This code can't doesn't type check the sent type against the expected type, so you could
            // easily end up pointing what you want to be array at a string. Need to fix or swap this
            // code out with RestKit.
            
            // The simplest case where we have a setter for the key
            [self performSelector:setterSelector onThread:[NSThread currentThread] withObject:[dictionary objectForKey:originalKey] waitUntilDone:YES];
        }
        else
        {
            // If we don't have a setter in the basic format, we may have a setter for a sub-class of bfgParams (or an array of them)
            id value = [dictionary objectForKey:originalKey];
            
            // Is there a setter of the form setSubParams_<className>_<key>?
            NSString *foundName = nil;
            for (NSString *setterName in self.setterNames)
            {
                NSString *pattern = [NSString stringWithFormat:@"^[^_]*_[^_]*_%@:", modifiedKey];
                if ([setterName rangeOfString:pattern options:NSRegularExpressionSearch].location != NSNotFound)
                {
                    foundName = setterName;
                }
            }
            if (!foundName)
            {
                // There is no setter that matches the bfgParams subclass pattern
                continue;
            }
            
            // Split the setter name to inspect the first two components
            NSArray *parts = [foundName componentsSeparatedByString:@"_"];
            if ([parts count] <= 2)
            {
                // Should not be possible to get here due to the name check, but just in case...
                continue;
            }
            if (![[parts objectAtIndex:0] isEqualToString:@"setSubParams"])
            {
                // Could not verify the setSubParams token
                continue;
            }
            
            // Create an instance of the subclass type
            NSString *subClassName = [parts objectAtIndex:1];
            Class subClass = NSClassFromString(subClassName);
            if (!subClass)
            {
                // There is no class of the specified type. Should never happen.
                BFGLog(@"WARNING: No class of type %@ specified parameter %@", subClassName, [NSString stringWithFormat:@"subParams_%@_%@", subClassName, modifiedKey]);
                continue;
            }
            
            // At this point we either have dictionary representing one object, or an array representing many            
            if ([value isKindOfClass:[NSDictionary class]])
            {
                id subClassObject = [[subClass alloc] init];
                if (![subClassObject isKindOfClass:[BFGParams class]])
                {
                    // The specified class is not a subclass of bfgParams. Should never happen.
                    BFGLog(@"WARNING: Class %@ of specified parameter %@ is not a subclass of %@", subClassName, [NSString stringWithFormat:@"subParams_%@_%@", subClassName, modifiedKey], [self class]);
                    continue;
                }
                
                // Call setValuesFromDictionary on instance of subClass
                [subClassObject setValuesFromDictionary:[dictionary objectForKey:originalKey]];
                
                // We are guaranteed to have this selector
                setterSelector = NSSelectorFromString(foundName);

                // Set the bfgParams property
                [self performSelector:setterSelector onThread:[NSThread currentThread] withObject:subClassObject waitUntilDone:YES];
            }
            else if ([value isKindOfClass:[NSArray class]])
            {
                NSMutableArray *array = [NSMutableArray arrayWithCapacity:[value count]];
                for (id member in value)
                {
                    // Array must contain dictionaries
                    if (![member isKindOfClass:[NSDictionary class]])
                    {
                        continue;
                    }
                    id subClassObject = [[subClass alloc] init];
                    if (![subClassObject isKindOfClass:[BFGParams class]])
                    {
                        // The specified class is not a subclass of bfgParams. Should never happen.
                        BFGLog(@"WARNING: Class %@ of specified parameter %@ is not a subclass of %@", subClassName, [NSString stringWithFormat:@"subParams_%@_%@", subClassName, modifiedKey], [self class]);
                        continue;
                    }
                    
                    // Call setValuesFromDictionary on instance of subClass
                    [subClassObject setValuesFromDictionary:member];
                    
                    // Add to the array
                    [array addObject:subClassObject];
                }
                // Ignore empty arrays
                if ([array count] > 0)
                {
                    // We are guaranteed to have this selector
                    setterSelector = NSSelectorFromString(foundName);
                    
                    // Set the bfgParams property
                    [self performSelector:setterSelector onThread:[NSThread currentThread] withObject:[NSArray arrayWithArray:array] waitUntilDone:YES];
                }
            }
            
        }
    }
}

- (BOOL)conformsToRequirements:(NSError *__autoreleasing *)error
{
    return YES;
}

#pragma mark - Private instance methods

// Use introsprection to get a property value by name
- (NSObject *)paramForName:(NSString *)paramName
{
    NSObject *param;
    SEL paramSelector = NSSelectorFromString(paramName);
    
    if (![self respondsToSelector:paramSelector])
    {
        NSAssert(NO, @"Parameter '%@' is not a property of class '%@'", paramName, [self class]);
        return nil;
    }
    
    NSMethodSignature *paramSignature = [[self class] instanceMethodSignatureForSelector:paramSelector];
    NSString *typeName = [NSString stringWithUTF8String:[paramSignature methodReturnType]];
    
    if (![typeName isEqualToString:@"@"])
    {
        NSAssert(NO, @"Parameter '%@' must return Objective-C type (returned '%@')", paramName, typeName);
        return nil;
    }
    
    NSInvocation *paramInvocation = [NSInvocation invocationWithMethodSignature:paramSignature];
    paramInvocation.selector = paramSelector;
    paramInvocation.target = self;
    [paramInvocation invoke];
    __unsafe_unretained id rawReturn;
    [paramInvocation getReturnValue:&rawReturn];
    param = rawReturn;
    
    return param;
}

@end
