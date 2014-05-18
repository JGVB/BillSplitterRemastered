//
//  DisplayExtraHelper.h
//  BillSplitterRemastered
//
//  Created by James VanBeverhoudt on 5/18/14.
//  Copyright (c) 2014 noOrg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DisplayExtraHelper : NSObject

@property(nonatomic, strong, readwrite)NSMutableArray *objectExtra;
@property(nonatomic, strong, readwrite)NSMutableArray *nameOfExtra;
@property(nonatomic, strong, readwrite)NSMutableArray *signOfExtra;

-(void)addObject:(double)objectIn withName:(NSString *)nameIn withSign:(NSString *)signIn;
-(NSNumber *)objectAtIndex:(NSInteger)indexIn;
-(NSString *)nameAtIndex:(NSInteger)indexIn;
-(NSString *)signAtIndex:(NSInteger)indexIn;
-(NSInteger)count;

@end
