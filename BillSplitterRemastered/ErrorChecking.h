//
//  ErrorChecking.h
//  BillSplitterRemastered
//
//  Created by James VanBeverhoudt on 2/13/14.
//  Copyright (c) 2014 noOrg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ErrorChecking : NSObject

+(NSMutableArray *)checkName:(NSString *)nameIn; //Make sure name is in correct format
+(NSMutableArray *)checkName:(NSString *)nameIn andReusedNames:(NSMutableArray *)allPayersIn; //Verifies that there are no duplicates of names
+(NSMutableArray *)checkPositiveNonNegativeNonEmptyHasNonNumbers:(NSString *)costIn; //Check name
+(NSString *)formatNumberTo2DecimalPlaces:(NSString *) element; //formats and rounds to 2 decimal places
+(void)showErrorMessage:(NSMutableArray *)errorM; //Displays error messages
+(NSMutableArray *)readyToCalculate:(NSMutableArray *)itemsIn andPayers:(NSMutableArray *)payersIn andExtras:(NSMutableDictionary *)extrasIn; //Determines if there is at least 1 payer, 1 item and a connection between them

@end
