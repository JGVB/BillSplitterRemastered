//
//  AppDelegate.h
//  BillSplitterRemastered
//
//  Created by James VanBeverhoudt on 2/12/14.
//  Copyright (c) 2014 noOrg. All rights reserved.
//

//TODO:

//Unit testing!
//If you respond to the the selection of a cell by pushing a new view controller onto the navigation controller’s stack, you should deselect the cell (with animation) when the view controller is popped off the stack.
//handle all the states - foreground, background, exit
//core data?
//add payers from contacts
//default tips /section to just be a tip calculator?
//local currencies
//locales?
//remember users(show up while typing?)
//Instruction page - maybe put it on the splash or menu? - put in own tab

//set splash screen(jonathan)
//set icon (jonathan)

//GPS tax rate

//Add total features. When you click grand total. displays grand: 1) Extra Charges  2)Flat discount  3) Percent discount  4) Tax  5) tip

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end