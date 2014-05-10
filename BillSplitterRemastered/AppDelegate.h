//
//  AppDelegate.h
//  BillSplitterRemastered
//
//  Created by James VanBeverhoudt on 2/12/14.
//  Copyright (c) 2014 noOrg. All rights reserved.
//
//give custom classes initial initializers - init
//Make sure there are no retain cycles - strong pointer to strong pointer (use Leaks tool)
// Extras
//Add model aspect to flow chart(data)
//Unit testing!
//Cool graphics - tableview background image
//Background
//Splash screen - bill getting split by a zipper
//If you respond to the the selection of a cell by pushing a new view controller onto the navigation controller’s stack, you should deselect the cell (with animation) when the view controller is popped off the stack.
//handle all the states - foreground, background, exit
//core data?
//add from contacts payers
//default tips?
//Change calculate button to split?
//split type section? - split bill equally/unequally
//local currencies
//locales?
//section to just be a tip calculator?
//remember users(show up while typing?)
//3 of same item - make easier to copy item. - OR could do when you're adding an item - have quanity signifying that different steak for each payer who wants their own.
//Make it so when you select an item with a payer already(split/shared), show..quantity..1, or split with??
//need name property in payer total object? - re think design. 
//Make display good - auto layout - struts..etc

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end