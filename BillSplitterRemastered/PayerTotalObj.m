//
//  PayerTotalObj.m
//  BillSplitterRemastered
//
//  Created by James VanBeverhoudt on 5/2/14.
//  Copyright (c) 2014 noOrg. All rights reserved.
//

#import "PayerTotalObj.h"

@implementation PayerTotalObj

@synthesize total = _total;
@synthesize subtotal = _subtotal;
@synthesize name = _name;
@synthesize sharedItemsAndSplitNumber = _sharedItemsAndSplitNumber;
@synthesize listOfExtrasApplied = _listOfExtrasApplied;
@synthesize percentShareOfTotal = _percentShareOfTotal;

-(id)init
{
    if(self = [super init]){
        self.name = @"no name";
        self.total = 0;
        self.sharedItemsAndSplitNumber = [[NSMutableDictionary alloc] init];
        self.listOfExtrasApplied = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(id)initWithName:(NSString *)nameIn
{
    if(self = [super init]){
        self.name = nameIn;
        self.total = 0;
        self.subtotal = 0;
        self.percentShareOfTotal = 0;
        self.sharedItemsAndSplitNumber = [[NSMutableDictionary alloc] init];
        self.listOfExtrasApplied = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)addExtraApplied:(double)extraIn withKey:(NSString *)keyNameIn
{
    [self.listOfExtrasApplied setObject:[NSNumber numberWithDouble:extraIn] forKey:keyNameIn];
}


@end
