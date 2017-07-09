//
//  NSJSONSerialization+BFG.m
//
//  Created by Benjamin Flynn on 8/29/13.
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

#import "NSJSONSerialization+BFG.h"

@implementation NSJSONSerialization (BFG)

+ (id)safeJSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error
{
    id result;
    @try
    {
        result = [NSJSONSerialization JSONObjectWithData:data options:opt error:error];
    }
    @catch (NSException *exception)
    {
        if (error)
        {
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey :
                                           [NSString stringWithFormat:@"exception: %@", exception]
                                       };
            *error = [NSError errorWithDomain:@"com.bigfishgames.bfgparams.jsonexception" code:-1 userInfo:userInfo];
            
        }
    }
    return result;
}

+ (NSData *)safeDataWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error
{
    NSData *data;
    if ([NSJSONSerialization isValidJSONObject:obj])
    {
        @try
        {
            data = [NSJSONSerialization dataWithJSONObject:obj options:opt error:error];
        }
        @catch (NSException *exception)
        {
            if (error)
            {
                NSDictionary *userInfo = @{ NSLocalizedDescriptionKey :
                                                [NSString stringWithFormat:@"exception: %@", exception]
                                            };
                *error = [NSError errorWithDomain:@"com.bigfishgames.bfgparams.jsonexception" code:-2 userInfo:userInfo];
            }
        }
    }
    else
    {
        if (error)
        {
            *error = [NSError errorWithDomain:@"com.bigfishgames.bfgparams.invalidjson" code:-3 userInfo:nil];
        }
    }
    return data;
}


@end
