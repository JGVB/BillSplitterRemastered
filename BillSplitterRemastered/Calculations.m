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
#import "Payer.h"

@implementation Calculations

//extrasDatasource now has how_to_split in it.  So calculate accordingly.  Don't forget to split it all evenly.(change the tax, tip,...etc for each person.


+(NSMutableArray *)performCalculationsWithPayersSplitEvenly:(NSMutableArray *)payersIn andItems:(NSMutableArray *)itemsIn andExtras:(NSMutableDictionary *)extrasIn
{
    //Calculate the raw totals from payer's items. 0 has the objects, 1 has the subgrandtotal
    NSMutableArray *returnedCalc = [self calculatePreExtrasSubTotal:payersIn andItems:itemsIn];

    //Make everyone's subtotal the same to prepare to send to extras calculation
    //Get all item prices, add them up and divide by the nuber of payers
    NSInteger numberOfPayer = [payersIn count];
    double itemsCosts = 0;
    for(Item *item in itemsIn){ //Add up item prices
        itemsCosts += item.cost;
    }
    double newSubTotals = itemsCosts / numberOfPayer;
    for(Payer *payer in payersIn){//loop through and add the new subtotal to the pto.
        
    }
    
    //Add extras
    
    //WTF   do even split calculations
    
    return [[NSMutableArray alloc] init];
}


/**
 * performCalculationsWithPayersSplitUnevenly:payersIn - Create objects with information.  Gets subtotal.
 **/
+(NSMutableArray *)performCalculationsWithPayersSplitUnevenly:payersIn andItems:itemsIn andExtras:extrasIn
{
    //Calculate the raw totals from payer's items. 0 has the objects, 1 has the subgrandtotal
    NSNumber *subGrandtotal = [self calculatePreExtrasSubTotal:payersIn andItems:itemsIn];

    //Add extras;  index 0 has updated PTOs, index 1 has subGrandTotal
    NSNumber *grandTotal = [self addExtraswithExtras:extrasIn andSubGrandTotal:[subGrandtotal doubleValue] andPayers:payersIn];
    
    NSMutableArray *newReturnPayerObjects = [[NSMutableArray alloc] initWithObjects:payersIn, grandTotal, nil]; //Send back payers(just a precaution because it's already passed by reference so any changes here are made in TotalsDisplayViewController. However the code is more easily followed this way. Also send back the grand total
    
    return newReturnPayerObjects;
}


/**
 * calculatePreExtrasSubTotal: Will get the subtotal of all payers before extras are applied as well as the subgrandtotal of all payers
 **/
+(NSNumber *)calculatePreExtrasSubTotal:(NSMutableArray *)payersIn andItems:(NSMutableArray *)itemsIn
{
    for(Payer *payer in payersIn){ //Loop through all the payers to calculate their individual payerObjects.
        PayerTotalObj *tempPTO = [[PayerTotalObj alloc] initWithName:payer.name];
        NSMutableDictionary *sharedItems = [[NSMutableDictionary alloc] init];
        double subtotal = 0;//Keeps track of each payer's subtotal.
        for(Item *item in payer.items){//loops through items and find the subtotal - keep in mind splits
            NSInteger numberOfPayers = [ item.payers count];
            if(numberOfPayers > 1){
                [sharedItems setObject:[NSNumber numberWithInteger:numberOfPayers] forKey:item.name]; //Adds all the shared items to display later.  Key is item name, object is how many payers split with.  To display...Items:  1/2 of item2.
            }
            double numCost = item.cost; //Get item's cost
            subtotal = subtotal + (numCost / numberOfPayers); //Take cost of item and divide by number of payers, add to subtotal.
        }
        tempPTO.subtotal = subtotal;
        tempPTO.sharedItemsAndSplitNumber = sharedItems;
        payer.payerObjectInfo = tempPTO;
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
    
    double grandAfterDiscounts = 0;
    for(Payer *payer in payersIn){
        
        //Flat Discount
        NSString *flatDiscount = [extrasIn objectForKey:@"Flat Discount"];
        double currentFlatPercentShareOfTotal = payer.payerObjectInfo.subtotal/ subGrandTotalIn;
        double tempSub = payer.payerObjectInfo.subtotal;
        
        if(flatDiscount == nil){
            flatDiscount = @"0";
        } else {
            [payer.payerObjectInfo addExtraApplied:(currentFlatPercentShareOfTotal * [flatDiscount doubleValue]) withKey:@"Flat Discount Applied"];
        }

        tempSub = tempSub - (currentFlatPercentShareOfTotal * [flatDiscount doubleValue]);
        
        //Percent Discount
        NSString *percentDiscount = [extrasIn objectForKey:@"Percent Discount"];
        if(percentDiscount == nil){
            percentDiscount = @"0";
        } else {
            [payer.payerObjectInfo addExtraApplied:(tempSub * ([percentDiscount doubleValue] / 100)) withKey:@"Percent Discount Applied"];
        }
        tempSub = tempSub - (tempSub * ([percentDiscount doubleValue] / 100));
        payer.payerObjectInfo.total = tempSub;
        grandAfterDiscounts = grandAfterDiscounts + tempSub;
    }
    
    //Extra charges
    double grandAfterExtraCharges = 0;
        for(Payer *payer in payersIn){
        double currentFlatPercentShareOfTotal = payer.payerObjectInfo.total/ grandAfterDiscounts;
        NSString *extraCharges = [extrasIn objectForKey:@"Extra Charges"];
        if(extraCharges == nil){
            extraCharges = @"0";
        } else {
            [payer.payerObjectInfo addExtraApplied:(currentFlatPercentShareOfTotal * [extraCharges doubleValue]) withKey:@"Extra Charges Applied"];
        }
        double tempSub = payer.payerObjectInfo.total;
        tempSub = tempSub + (currentFlatPercentShareOfTotal * [extraCharges doubleValue]);
        payer.payerObjectInfo.total = tempSub;
        grandAfterExtraCharges = grandAfterExtraCharges + tempSub;

    }
    
    //Tax
    double grandAfterTax = 0;
    for(Payer *payer in payersIn){
        double currentFlatPercentShareOfTotal = payer.payerObjectInfo.total/ grandAfterExtraCharges;
        NSString *tax = [extrasIn objectForKey:@"Tax (Amount)"];
        if(tax == nil){
            tax = @"0";
        } else {
            [payer.payerObjectInfo addExtraApplied:(currentFlatPercentShareOfTotal * [tax doubleValue]) withKey:@"Tax Applied"];
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
            tempSub = tempSub + (tempSub * ([tipAmount doubleValue]/100));
            useAmount = (tempSub * ([tipAmount doubleValue]/100));
        } else {
            tempSub = tempSub + (currentFlatPercentShareOfTotal * [tipAmount doubleValue]);
            useAmount = (currentFlatPercentShareOfTotal * [tipAmount doubleValue]);
        }
        
        if(!tipNull){
            [payer.payerObjectInfo addExtraApplied:useAmount withKey:@"Tip Applied"];
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
