//
//  DisplayExtraHelper.m
//  BillSplitterRemastered
//
//  Created by James VanBeverhoudt on 5/18/14.
//  Copyright (c) 2014 noOrg. All rights reserved.
//
//This object will help store all the necessary data for the extras to be displayed on the payer details page.  

#import "DisplayExtraHelper.h"

@implementation DisplayExtraHelper

@synthesize objectExtra = _objectExtra;
@synthesize nameOfExtra = _nameOfExtra;
@synthesize signOfExtra = _signOfExtra;


-(id)init
{
    if(self = [super init]){
        //initialize
        self.objectExtra = [[NSMutableArray alloc] init];
        self.nameOfExtra = [[NSMutableArray alloc] init];
        self.signOfExtra = [[NSMutableArray alloc] init];
    }
    return self;
}

/**
 * addObject withName: adds to list of extras
 **/
-(void)addObject:(double)objectIn withName:(NSString *)nameIn withSign:(NSString *)signIn
{
    [self.objectExtra addObject:[NSNumber numberWithDouble:objectIn]];
    [self.nameOfExtra addObject:nameIn];
    [self.signOfExtra addObject:signIn];
}

/**
 * objectAtIndex: - Will return an the extra value object at index...
 **/
-(NSNumber *)objectAtIndex:(NSInteger)indexIn
{
    return [self.objectExtra objectAtIndex:indexIn];
}

/**
 * nameAtIndex: - will return the name of the extra at index...
 **/
-(NSString *)nameAtIndex:(NSInteger)indexIn
{
    return [self.nameOfExtra objectAtIndex:indexIn];
}

/**
 * signAtIndex: - returns the + or - sign at selected index.
 **/
-(NSString *)signAtIndex:(NSInteger)indexIn
{
    return [self.signOfExtra objectAtIndex:indexIn];
}

/**
 * count: will return the count of the "multi dimensional array"
 **/
-(NSInteger)count
{
    return [self.objectExtra count];
}

/**
 * getPayerTip: This function will return the double valiue of the tip extra if there is, otherwise will return -1
 **/
-(double)getPayerTip
{
    //find tip
    double tipVal = -1;
    int x = 0;
    for(NSString * name in self.nameOfExtra){
        if([name isEqualToString:@"Tip Applied"]){
            tipVal = [[self.objectExtra objectAtIndex:x] doubleValue];
        }
        x++;
    }
    return tipVal;
    
}

@end
