//
//  Calculations.m
//  BillSplitterRemastered
//
//  Created by James VanBeverhoudt on 5/2/14.
//  Copyright (c) 2014 noOrg. All rights reserved.
//

#import "Calculations.h"
#import "Item.h"
#import "ErrorChecking.h"
#import "PayerTotalObj.h"
#import "DisplayExtraHelper.h"
#import "Payer.h"

@implementation Calculations


/**
 * performCalculationsWithPayersSplitEvenly andItems andExtras - Will calculate the even split of the payer's totals!
 **/
+(NSMutableArray *)performCalculationsWithPayersSplitEvenly:(NSMutableArray *)payersIn andItems:(NSMutableArray *)itemsIn andExtras:(NSMutableDictionary *)extrasIn
{
    //Calculate the raw totals from payer's items.
    NSNumber *subGrandTotal = [self calculatePreExtrasSubTotal:payersIn andItems:itemsIn splitEvenly:YES];
    
    //Add extras
    NSNumber *grandTotal = [self addExtraswithExtras:extrasIn andSubGrandTotal:[subGrandTotal doubleValue] andPayers:payersIn];
    
    return [[NSMutableArray alloc] initWithObjects:payersIn, grandTotal, nil];
}


/**
 * performCalculationsWithPayersSplitUnevenly:payersIn - Create objects with information.  Gets subtotal.
 **/
+(NSMutableArray *)performCalculationsWithPayersSplitUnevenly:payersIn andItems:itemsIn andExtras:extrasIn
{
    //Calculate the raw totals from payer's items.
    NSNumber *subGrandtotal = [self calculatePreExtrasSubTotal:payersIn andItems:itemsIn splitEvenly:NO];

    //Add extras;  index 0 has updated PTOs, index 1 has subGrandTotal
    NSNumber *grandTotal = [self addExtraswithExtras:extrasIn andSubGrandTotal:[subGrandtotal doubleValue] andPayers:payersIn];
    
    NSMutableArray *newReturnPayerObjects = [[NSMutableArray alloc] initWithObjects:payersIn, grandTotal, nil]; //Send back payers(just a precaution because it's already passed by reference so any changes here are made in TotalsDisplayViewController. However the code is more easily followed this way. Also send back the grand total
    
    return newReturnPayerObjects;
}


/**
 * clearPayerObjects: This function is needed to clear the PTOs when calculate is clicked so the numbers don't interfer with eachother if user goes back to extras or payers then to calculate again. Mainly for the total.
 **/
+(void)clearPayerObjects:(NSMutableArray *)payersIn
{
    for(Payer *payer in payersIn){
        payer.payerObjectInfo = [[PayerTotalObj alloc] initWithName:payer.name];
    }
}


/**
 * calculatePreExtrasSubTotal: Will get the subtotal of all payers before extras are applied as well as the subgrandtotal of all payers
 **/
+(NSNumber *)calculatePreExtrasSubTotal:(NSMutableArray *)payersIn andItems:(NSMutableArray *)itemsIn splitEvenly:(BOOL)evenly
{
    if(evenly){ //Bill is split evenly. everyone gets the same
        //Make everyone's subtotal the same to prepare to send to extras calculation
        //Get all item prices, add them up and divide by the nuber of payers
        NSInteger numberOfPayer = [payersIn count];
        double itemsCosts = 0;
        for(Item *item in itemsIn){ //Add up item prices
            if([item.payers count] > 0){ //only add to cost if item is owned by someone
                itemsCosts += item.cost;
            }
        }
        double subtotal = itemsCosts / numberOfPayer;
        for(Payer *payer in payersIn){//loop through and add the new subtotal to the pto. Everyone has the same subtotal. and shared
            payer.payerObjectInfo.subtotal = subtotal;
            NSMutableDictionary *sharedItems = [[NSMutableDictionary alloc] init];
            double key = 0;
            for(Item *item in itemsIn){ //Add all the items and number of payers to each payer's pto.sharedItemsAndSplitNumber
                if([item.payers count] > 0){ //only add item only if it is owned by someone
                    [sharedItems setObject:[[NSArray alloc] initWithObjects:[NSNumber numberWithInteger:payersIn.count], item, nil]  forKey:[NSNumber numberWithDouble:key]];
                    key += 1;
                }
            }
            payer.payerObjectInfo.sharedItemsAndSplitNumber = sharedItems;
        }
    } else { //Bill is split unevenly, based on what the payer bought.
        for(Payer *payer in payersIn){ //Loop through all the payers to calculate their individual payerObjects.
            NSMutableDictionary *sharedItems = [[NSMutableDictionary alloc] init];
            double subtotal = 0;//Keeps track of each payer's subtotal.
            double key = 0;
            for(Item *item in payer.items){//loops through items and find the subtotal - keep in mind splits
                [sharedItems setObject:[[NSArray alloc] initWithObjects:[NSNumber numberWithInteger:[item.payers count]], item, nil]  forKey:[NSNumber numberWithDouble:key]]; //Adds all the shared items to display later.  Key is item name, object is how many payers split with.  To display...Items:  1/2 of item2.
                double numCost = item.cost; //Get item's cost
                subtotal = subtotal + (numCost / [item.payers count]); //Take cost of item and divide by number of payers, add to subtotal.
                key +=1;
            }
            payer.payerObjectInfo.subtotal = subtotal;
            payer.payerObjectInfo.sharedItemsAndSplitNumber = sharedItems;
        }
    }
    //Calculate subGrandTotal - everyone's items before extras are applied.
    double subGrandTotal = 0;
    for(Payer *payer in payersIn){
        subGrandTotal = subGrandTotal + payer.payerObjectInfo.subtotal;
    }
    return [NSNumber numberWithDouble:subGrandTotal];
}


/**
 * addExtras: withExtras :andSubGrandTotal - This is a helper function that will calculate the extras the user chose. Will calculate for each person 
 **/
+(NSNumber *)addExtraswithExtras:(NSMutableDictionary *)extrasIn andSubGrandTotal:(double)subGrandTotalIn andPayers:(NSMutableArray *)payersIn
{
    //loop through all ptos and do extras
     //Extra charges
    double grandAfterExtraCharges = 0;
    for(Payer *payer in payersIn){
        double currentFlatPercentShareOfTotal = payer.payerObjectInfo.subtotal/ subGrandTotalIn;
        NSString *extraCharges = [extrasIn objectForKey:@"Extra Charges"];
        if(extraCharges == nil){
            extraCharges = @"0";
        } else {
            [payer.payerObjectInfo.listOfExtrasApplied addObject:(currentFlatPercentShareOfTotal * [extraCharges doubleValue]) withName:@"Extra Charges Applied" withSign:@"+"];
        }
        double tempSub = payer.payerObjectInfo.subtotal;
        tempSub = tempSub + (currentFlatPercentShareOfTotal * [extraCharges doubleValue]);
        payer.payerObjectInfo.total = tempSub;
        grandAfterExtraCharges = grandAfterExtraCharges + tempSub;
    }
    
    
    //Flat Discount
    double grandAfterDiscounts = 0;
    for(Payer *payer in payersIn){
        
        NSString *flatDiscount = [extrasIn objectForKey:@"Flat Discount"];
        double currentFlatPercentShareOfTotal = payer.payerObjectInfo.total/ grandAfterExtraCharges;
        double tempSub = payer.payerObjectInfo.total;
        
        if(flatDiscount == nil){
            flatDiscount = @"0";
        } else {
            [payer.payerObjectInfo.listOfExtrasApplied addObject:(currentFlatPercentShareOfTotal * [flatDiscount doubleValue]) withName:@"Flat Discount Applied" withSign:@"-"];
        }

        tempSub = tempSub - (currentFlatPercentShareOfTotal * [flatDiscount doubleValue]);
        
        //Percent Discount
        NSString *percentDiscount = [extrasIn objectForKey:@"Percent Discount"];
        if(percentDiscount == nil){
            percentDiscount = @"0";
        } else {
            [payer.payerObjectInfo.listOfExtrasApplied addObject:(tempSub * ([percentDiscount doubleValue] / 100)) withName:@"Percent Discount Applied" withSign:@"-"];
        }
        tempSub = tempSub - (tempSub * ([percentDiscount doubleValue] / 100));
      
        payer.payerObjectInfo.total = tempSub;
        grandAfterDiscounts = grandAfterDiscounts + tempSub;
    }
    
    
    //Tax
    double grandAfterTax = 0;
    for(Payer *payer in payersIn){
        double currentFlatPercentShareOfTotal = payer.payerObjectInfo.total/ grandAfterDiscounts;
        NSString *tax = [extrasIn objectForKey:@"Tax (Amount)"];
        if(tax == nil){
            tax = @"0";
        } else {
            [payer.payerObjectInfo.listOfExtrasApplied addObject:(currentFlatPercentShareOfTotal * [tax doubleValue]) withName:@"Tax Applied" withSign:@"+"];
        }

        double tempSub = payer.payerObjectInfo.total;
        tempSub = tempSub + (currentFlatPercentShareOfTotal * [tax doubleValue]);
        payer.payerObjectInfo.total = tempSub;
        grandAfterTax = grandAfterTax + tempSub;
    }
    
    //Tip
    double grandafterTip = 0;
    for(Payer *payer in payersIn){
        double currentFlatPercentShareOfTotal = payer.payerObjectInfo.total/ grandAfterTax;
        NSString *tipAmount = [extrasIn objectForKey:@"Tip"];
        NSString *tipByWhat = [extrasIn objectForKey:@"tipByWhat"];
        BOOL tipNull = YES;
        if(tipAmount == nil){
            tipAmount = @"0";
        } else {
            tipNull = NO;
        }
        double tempSub = payer.payerObjectInfo.total;
        double useAmount = 0;
        if([tipByWhat isEqualToString:@"tip_by_percent"] || tipByWhat == nil) {
            useAmount = (tempSub * ([tipAmount doubleValue]/100));
            tempSub = tempSub + (tempSub * ([tipAmount doubleValue]/100));
        } else { //Tip by value calculations
            tempSub = tempSub + (currentFlatPercentShareOfTotal * [tipAmount doubleValue]);
            useAmount = (currentFlatPercentShareOfTotal * [tipAmount doubleValue]);
        }
        
        if(!tipNull){
            [payer.payerObjectInfo.listOfExtrasApplied addObject:useAmount withName:@"Tip Applied" withSign:@"+"];
        }
        payer.payerObjectInfo.total = tempSub;
        grandafterTip = grandafterTip + tempSub;

    }
    
    //Percent share of total: has final subtotal, now calculate percent share of total.
    //Also check if subtotal is < 0
    for(Payer *payer in payersIn){
        payer.payerObjectInfo.percentShareOfTotal = payer.payerObjectInfo.total / grandafterTip;
        if(payer.payerObjectInfo.total < 0){
            if(payer.payerObjectInfo.subtotal < 0){
                payer.payerObjectInfo.subtotal = 0;
            }
            payer.payerObjectInfo.total = 0;
        }
    }
    if(grandafterTip < 0){
        grandafterTip = 0;
    }

    return  [NSNumber numberWithDouble:grandafterTip];
}

@end
