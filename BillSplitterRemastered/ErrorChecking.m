//
//  ErrorChecking.m
//  BillSplitterRemastered
//
//  Created by James VanBeverhoudt on 2/13/14.
//  Copyright (c) 2014 noOrg. All rights reserved.
//

#import "ErrorChecking.h"
#import "Payer.h"
#import "PayersTabViewController.h"
#import "ItemsTabViewController.h"
#import "ExtrasTabViewController.h"

@interface ErrorChecking ()

@end

@implementation ErrorChecking

NSString *ERR1 = @"Enter name.";
NSString *ERR2 = @"Please enter a unique name.";
NSString *ERR3 = @"Enter a number.";
NSString *ERR4 = @"Must be a number.";
NSString *ERR5 = @"Please enter a positive number.";
NSString *ERR6 = @"Please enter at least 1 payer's name on the Payers Tab.";
NSString *ERR7 = @"Please enter at least 1 item on the Items Tab.";
NSString *ERR8 = @"Each payer must have at least one item. If not, please delete the payer on the Payers Tab.";
NSString *ERR9 = @"Please enter a quantity between 0 and 21.";



/**
 * checkName: Make sure name is in correct format
 **/
+(NSMutableArray *)checkName:(NSString *)nameIn
{
    NSMutableArray *errorMessages = [[NSMutableArray alloc] init];
    
    //Check if no name entered
    if([nameIn isEqualToString:@""] || nameIn.length <1 || nameIn == nil){
        [errorMessages addObject:ERR1];
    }
    return errorMessages;
}


/**
 * checkNameandResusedNames: Verifies that there are no duplicates of names
 **/
+(NSMutableArray *)checkName:(NSString *)nameIn andReusedNames:(NSMutableArray *)allPayersIn
{
    NSMutableArray *errorMessages = [[NSMutableArray alloc] init];
    
    //Check if no name entered
    if([nameIn isEqualToString:@""] || nameIn.length <1 || nameIn == nil){
        [errorMessages addObject:ERR1];
    }
    
    //Check to see if name is already in payer list
    for(Payer *payer in allPayersIn){
        if([payer.name caseInsensitiveCompare:nameIn] == NSOrderedSame){ //Name already in payer list, no repeats
            [errorMessages addObject:ERR2];
        }
    }
    return errorMessages;
}


+(NSMutableArray *)checkQuantity:(NSString *)quantityIn
{
    NSMutableArray *errorMessages = [[NSMutableArray alloc] init];
    //Check Number, positive
    [errorMessages addObjectsFromArray:[self checkPositiveNonNegativeNonEmptyHasNonNumbers:quantityIn]];
    //Check below 31
    NSString *newestSaved = @"";
    if([errorMessages count] == 0){ //if no errors, check if below 31
        NSInteger newVal = [quantityIn integerValue];
        if(newVal > 20 || newVal < 1){
            newestSaved = [NSString stringWithFormat:@"%lu", newVal];
            [errorMessages addObject:ERR9];
        } else { //Error and reset input
            newestSaved = quantityIn;
        }
    }
    
    return [[NSMutableArray alloc] initWithObjects:errorMessages, newestSaved, nil];
}


/**
 * checkPositiveNonNegativeNonEmptyHasNonNumbers: ...
 **/
+(NSMutableArray *)checkPositiveNonNegativeNonEmptyHasNonNumbers:(NSString *)costIn
{
    NSMutableArray *errorMessages = [[NSMutableArray alloc] init];
    
    if(costIn == nil || costIn.length < 1 || [costIn isEqualToString:@""]){//Check if empty
        [errorMessages addObject:ERR3];
    } else { //item is not empty, continue checking
        if([self hasNonNumbers:costIn]){//value is not a number
            [errorMessages addObject:ERR4];
        } else { //Entered price is a number and is not empty, continue checking
            double theNumFromString = [costIn doubleValue];
            if(theNumFromString < 0){ //Check if intered number is NEGATIVE
                [errorMessages addObject:ERR5];
            } else {
                //value is a number, not empty, and non negative, continue checking?
                
            }
        }
    }
    return errorMessages;
}


/**
 * formatNumberTo2DecimalPlaces: formats and rounds to 2 decimal places
 **/
+(NSString *)formatNumberTo2DecimalPlaces:(NSString *) element
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *number = [formatter numberFromString:element];
    NSString *itemCostStringRounded = [NSString stringWithFormat: @"%.2f", number.doubleValue];
    return itemCostStringRounded;
}


/**
 * hasNonNumbers: Helper method to determine if there are non numbers in string(element)
 **/
+(BOOL)hasNonNumbers:(NSString *)element
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *number = [formatter numberFromString:element];
    BOOL isNumber = !!number;
    if(isNumber == 0) return YES; //Value has non numbers in it
    else return NO; //value is a good number
}


/**
 * readyToCalculateAndPayers: Determines if there is at least 1 payer, 1 item and a connection between them
 */
+(NSMutableArray *)readyToCalculate:(NSMutableArray *)itemsIn andPayers:(NSMutableArray *)payersIn andExtras:(NSMutableDictionary *)extrasIn
{
    NSMutableArray *errorMessages = [[NSMutableArray alloc] init];
    //Must check and see if there are any items and extras
    //if no items, must cancel segue and state to enter items,
    //if no extras, instantiate empty extra array.
    //If user clicks on calculate before visiting those pages can have unitialized array.
    
    //If there are no payers, ask to enter
    if([payersIn count] < 1){
        [errorMessages addObject:ERR6];
    } else { //There is a payer.
        if([itemsIn count] < 1){//Check if no items
            //Show error
            [errorMessages addObject:ERR7];
        } else { //There are items, and payers, continue to check if any items have payers.
            bool hasItem = YES;
            for(Payer *payer in payersIn){//loop through payers and make sure each one has at least one item.
                if([payer.items count] < 1){
                    hasItem = NO;
                } else { //All payers have at least an item.

                }
            }
            if(!hasItem){
                [errorMessages addObject:ERR8];
            }
        }
    }
    return errorMessages;
}


/**
 * showErrorMessage: display error messages
 **/
+(void)showErrorMessage:(NSMutableArray *)errorM
{
    NSString *errorComplete = @"";
    for(NSString *message in errorM){
        errorComplete = [errorComplete stringByAppendingString:message];
        errorComplete = [errorComplete stringByAppendingString:@"\n"];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:errorComplete
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
@end
