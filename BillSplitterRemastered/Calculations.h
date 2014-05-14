//
//  Calculations.h
//  BillSplitterRemastered
//
//  Created by James VanBeverhoudt on 5/2/14.
//  Copyright (c) 2014 noOrg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Calculations : NSObject

+(NSMutableArray *)performCalculationsWithPayersSplitUnevenly:(NSMutableArray *)payersIn andItems:(NSMutableArray *)itemsIn andExtras:(NSMutableDictionary *)extrasIn;
+(NSMutableArray *)performCalculationsWithPayersSplitEvenly:(NSMutableArray *)payersIn andItems:(NSMutableArray *)itemsIn andExtras:(NSMutableDictionary *)extrasIn;


@end
