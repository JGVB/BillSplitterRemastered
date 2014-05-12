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
    NSMutableArray *payerTotalObjects = [returnedCalc objectAtIndex:0];
    double subGrandTotal = [[returnedCalc objectAtIndex:1] doubleValue];
    
    //WTF   do even split calculations
    
    return [[NSMutableArray alloc] init];
}


/**
 * performCalculationsWithPayersSplitUnevenly:payersIn - Create objects with information.  Gets subtotal.
 **/
+(NSMutableArray *)performCalculationsWithPayersSplitUnevenly:payersIn andItems:itemsIn andExtras:extrasIn
{
    //Calculate the raw totals from payer's items. 0 has the objects, 1 has the subgrandtotal
    NSMutableArray *returnedCalc = [self calculatePreExtrasSubTotal:payersIn andItems:itemsIn];
    NSMutableArray *payerTotalObjects = [returnedCalc objectAtIndex:0];
    double subGrandTotal = [[returnedCalc objectAtIndex:1] doubleValue];
    
    //Add extras
    payerTotalObjects = [self addExtras:payerTotalObjects withExtras:extrasIn andSubGrandTotal:(double)subGrandTotal];
    
    //Go through and assign pto's to payers to more easily associate later
    for(PayerTotalObj *ptoOb in [payerTotalObjects objectAtIndex:0]){
        for(Payer *payerObj in payersIn){
            if([payerObj.name isEqualToString:ptoOb.name]){
                payerObj.payerObjectInfo = ptoOb;
            }
        }
    }
    NSMutableArray *newReturnPayerObjects = [[NSMutableArray alloc] initWithObjects:payersIn, [payerTotalObjects objectAtIndex:1], nil];
    
    return newReturnPayerObjects;
}


/**
 * calculatePreExtrasSubTotal: Will get the subtotal of all payers before extras are applied as well as the subgrandtotal of all payers
 **/
+(NSMutableArray *)calculatePreExtrasSubTotal:(NSMutableArray *)payersIn andItems:(NSMutableArray *)itemsIn
{
    NSMutableArray *payerTotalObjects = [[NSMutableArray alloc] init];
    for(Payer *payer in payersIn){ //Loop through all the payers to calculate their individual payerObjects.
        PayerTotalObj *tempPTO = [[PayerTotalObj alloc] initWithName:payer.name];
        NSMutableDictionary *sharedItems = [[NSMutableDictionary alloc] init];
        double subtotal = 0;//Keeps track of each payer's subtotal.
        for(Item *item in payer.items){//loops through items and find the subtotal - keep in mind splits
            NSInteger numberOfPayers = [ item.payers count];
            if(numberOfPayers > 1){
                [sharedItems setObject:[NSNumber numberWithInteger:numberOfPayers] forKey:item.name]; //Adds all the shared items to display later.  Key is item name, object is how many payers split with.  To display...Items:  1/2 of item2.
            }
            double numCost = [item.cost doubleValue]; //Get item's cost
            subtotal = subtotal + (numCost / numberOfPayers); //Take cost of item and divide by number of payers, add to subtotal.
        }
        tempPTO.subtotal = subtotal;
        tempPTO.sharedItemsAndSplitNumber = sharedItems;
        [payerTotalObjects addObject:tempPTO];
    }
    
    //Calculate subGrandTotal - everyone's items before extras are applied.
    double subGrandTotal = 0;
    for(PayerTotalObj *pto in payerTotalObjects){
        subGrandTotal = subGrandTotal + pto.subtotal;
    }
    return [[NSMutableArray alloc] initWithObjects:payerTotalObjects, [NSNumber numberWithDouble:subGrandTotal], nil];
}


/**
 * addExtras: withExtras :andSubGrandTotal - This is a helper function that will calculate the extras the user chose. Will calculate for each person 
 **/
+(NSMutableArray *)addExtras:(NSMutableArray *)ptosIn  withExtras:(NSMutableDictionary *)extrasIn andSubGrandTotal:(double)subGrandTotalIn
{
    //loop through all ptos and do extras
    
    double grandAfterDiscounts = 0;
    for(PayerTotalObj *ptoItem in ptosIn){
        
        //Flat Discount
        NSString *flatDiscount = [extrasIn objectForKey:@"Flat Discount"];
        double currentFlatPercentShareOfTotal = ptoItem.subtotal/ subGrandTotalIn;
        double tempSub = ptoItem.subtotal;
        
        if(flatDiscount == nil){
            flatDiscount = @"0";
        } else {
            [ptoItem addExtraApplied:(currentFlatPercentShareOfTotal * [flatDiscount doubleValue]) withKey:@"Flat Discount Applied"];
        }

        tempSub = tempSub - (currentFlatPercentShareOfTotal * [flatDiscount doubleValue]);
        
        //Percent Discount
        NSString *percentDiscount = [extrasIn objectForKey:@"Percent Discount"];
        if(percentDiscount == nil){
            percentDiscount = @"0";
        } else {
            [ptoItem addExtraApplied:(tempSub * ([percentDiscount doubleValue] / 100)) withKey:@"Percent Discount Applied"];
        }
        tempSub = tempSub - (tempSub * ([percentDiscount doubleValue] / 100));
        ptoItem.total = tempSub;
        grandAfterDiscounts = grandAfterDiscounts + tempSub;
    }
    
    //Extra charges
    double grandAfterExtraCharges = 0;
        for(PayerTotalObj *ptoItem in ptosIn){
        double currentFlatPercentShareOfTotal = ptoItem.total/ grandAfterDiscounts;
        NSString *extraCharges = [extrasIn objectForKey:@"Extra Charges"];
        if(extraCharges == nil){
            extraCharges = @"0";
        } else {
            [ptoItem addExtraApplied:(currentFlatPercentShareOfTotal * [extraCharges doubleValue]) withKey:@"Extra Charges Applied"];
        }
        double tempSub = ptoItem.total;
        tempSub = tempSub + (currentFlatPercentShareOfTotal * [extraCharges doubleValue]);
        ptoItem.total = tempSub;
        grandAfterExtraCharges = grandAfterExtraCharges + tempSub;

    }
    
    //Tax
    double grandAfterTax = 0;
    for(PayerTotalObj *ptoItem in ptosIn){
        double currentFlatPercentShareOfTotal = ptoItem.total/ grandAfterExtraCharges;
        NSString *tax = [extrasIn objectForKey:@"Tax (Amount)"];
        if(tax == nil){
            tax = @"0";
        } else {
            [ptoItem addExtraApplied:(currentFlatPercentShareOfTotal * [tax doubleValue]) withKey:@"Tax Applied"];
        }
        double tempSub = ptoItem.total;
        tempSub = tempSub + (currentFlatPercentShareOfTotal * [tax doubleValue]);
        ptoItem.total = tempSub;
        grandAfterTax = grandAfterTax + tempSub;
    }
    
    //Tip
    double grandafterTip = 0;
    for(PayerTotalObj *ptoItem in ptosIn){
        double currentFlatPercentShareOfTotal = ptoItem.total/ grandAfterTax;
        NSString *tipAmount = [extrasIn objectForKey:@"Tip"];
        NSString *tipByWhat = [extrasIn objectForKey:@"tipByWhat"];
        BOOL tipNull = YES;
        if(tipAmount == nil){
            tipAmount = @"0";
        } else {
            tipNull = NO;
        }
        double tempSub = ptoItem.total;
        double useAmount = 0;
        if([tipByWhat isEqualToString:@"tip_by_percent"] || tipByWhat == nil) {
            tempSub = tempSub + (tempSub * ([tipAmount doubleValue]/100));
            useAmount = (tempSub * ([tipAmount doubleValue]/100));
        } else {
            tempSub = tempSub + (currentFlatPercentShareOfTotal * [tipAmount doubleValue]);
            useAmount = (currentFlatPercentShareOfTotal * [tipAmount doubleValue]);
        }
        
        if(!tipNull){
            [ptoItem addExtraApplied:useAmount withKey:@"Tip Applied"];
        }
        ptoItem.total = tempSub;
        grandafterTip = grandafterTip + tempSub;

    }
    
    //Percent share of total: has final subtotal, now calculate percent share of total.
    //Also check if subtotal is < 0
    for(PayerTotalObj *ptoItem in ptosIn){
        ptoItem.percentShareOfTotal = ptoItem.subtotal / grandafterTip;
        if(ptoItem.total < 0){
            if(ptoItem.subtotal < 0){
                ptoItem.subtotal = 0;
            }
            ptoItem.total = 0;
        }
    }
    if(grandafterTip < 0){
        grandafterTip = 0;
    }
    
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    [returnArray addObject:ptosIn];
    [returnArray addObject:[NSNumber numberWithDouble:grandafterTip]];
    return  returnArray;
}



@end
