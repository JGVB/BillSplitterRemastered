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
+(void)clearPayerObjects:(NSMutableArray *)payersIn; //clearPayerObjects: This function is needed to clear the PTOs when calculate is clicked so the numbers don't interfer with eachother if user goes back to extras or payers then to calculate again. Mainly for the total.


@end
