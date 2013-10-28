//
//  ISProductsViewController.m
//  InStock
//
//  Created by Ahmet Alp Balkan on 10/26/13.
//  Copyright (c) 2013 Luminous Apps. All rights reserved.
//

#import "ISProductsViewController.h"
#import "ISAvailabilityViewController.h"
#import "ISProducts.h"
#import <FlatUIKit/UITableViewCell+FlatUI.h>


@implementation ISProductsViewController

bool wasCancel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.products = @[
                      @[
                          [ISiPhone4s class],
                          [ISiPhone5s class],
                          [ISiPhone5c class],
                        ],
                      @[
                          [ISiPad2 class],
                          [ISiPadMini class],
                          [ISiPadMiniRetina class],
                          [ISiPadAir class],
                        ]
                      ];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.isNewProductRequested){
        self.isNewProductRequested = NO; // reset
        return;
    } else if ([ISProductsStore lastUsedProduct]){
        NSLog(@"Last used product record found...");
        [self performSegueWithIdentifier:kSegueAvailability sender:self];
    } else {
        NSLog(@"No last used product found. Pick one.");
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.products count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self.products objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ProductCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    id product = [[self.products objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    NSString* name;
    if ([product respondsToSelector:@selector(fullName)]){
        name = [product fullName];
    } else {
        name = [product name];
    }
    [[cell textLabel] setText: name];
    UIImage* icon = [self imageForProduct:product];
    if (icon){
        [[cell imageView] setImage:icon];
    }
    return cell;
}

-(UIImage*)imageForProduct:(id)product{
    if ([product respondsToSelector:@selector(iconImageName)]){
        return [UIImage imageNamed:[product iconImageName]];
    }
    return nil;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    id product = [[self.products objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (!product){
        NSLog(@"Cannot find selected device");
        return;
    }
    NSLog(@"Chosen: %@", [product name]);
    NSArray* idioms = [product applicableIdioms];
    
    self.selectedProduct = product;
    self.currentIdioms = idioms;
    self.currentIdiomIndex = 0;
    self.currentDeviceIdioms = [NSMutableDictionary dictionary];
    self.currentName = [product name];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!idioms || [idioms count] == 0){
        [self performSegueWithIdentifier:kSegueAvailability sender:self];
    } else {
        [self showActionSheetForIdiom:self.currentIdiomIndex];
    }
}

#pragma mark - Action sheet operations and delegation

-(void) showActionSheetForIdiom:(NSInteger)idiomIndex {
    self.currentIdiomIndex = idiomIndex;
    
    if (self.currentIdiomIndex + 1 > [[self currentIdioms] count]){
        // FINISHED ASKING?
        self.currentSku = [self.selectedProduct skuNameForIdiomsAndValues:self.currentDeviceIdioms];
        NSLog(@"finished. SKU = %@, Name = %@", self.currentSku, self.currentName);
        
        // Save device
        [ISProductsStore saveProductWithName:self.currentName sku:self.currentSku];
        [ISProductsStore setLastUsedProductName:self.currentName];
        [self performSegueWithIdentifier:kSegueAvailability sender:self];
        return;
    } else {
        // SHOW IDIOM
        ISIdiom idiom = [[[self currentIdioms] objectAtIndex:idiomIndex] integerValue];
        
        if ([self.selectedProduct respondsToSelector:@selector(shouldAskIdiom:forIdiomsAndValues:)]){
            BOOL showThisIdioom = [self.selectedProduct shouldAskIdiom:idiom forIdiomsAndValues:self.currentDeviceIdioms];
            if (!showThisIdioom){
                [self showActionSheetForIdiom:self.currentIdiomIndex + 1]; // show next idiom
                return;
            }
        }
        
        NSArray* options = [self.selectedProduct applicableOptionsForIdiom:idiom];
        NSMutableArray* optionTitles = [NSMutableArray arrayWithCapacity:[options count]];
        for (id opt in options) {
            [optionTitles addObject:[ISIdioms nameForOption:[opt integerValue] inIdiom:idiom]];
        }
        
        UIActionSheet* sheet = [[UIActionSheet alloc] init];
        sheet.title = [ISIdioms titleForIdiom:idiom];
        sheet.delegate = self;
        for (NSString* optionTitle in optionTitles) {
            [sheet addButtonWithTitle:optionTitle];
        }
        sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
        [sheet showInView:self.tableView];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    ISIdiom idiom = [[[self currentIdioms] objectAtIndex:self.currentIdiomIndex] integerValue];
    NSArray* options = [self.selectedProduct applicableOptionsForIdiom:idiom];
    
    if (buttonIndex == [options count]){
        NSLog(@"cancel");
        wasCancel = YES;
    } else {
        wasCancel = NO;
        NSArray* options = [self.selectedProduct applicableOptionsForIdiom:idiom];
        NSInteger option = [[options objectAtIndex:buttonIndex] integerValue];
        NSLog(@"%@: %@", [ISIdioms titleForIdiom:idiom], [ISIdioms nameForOption:option inIdiom:idiom]);
        
        [self setCurrentName: [[self.currentName stringByAppendingString:@" "] stringByAppendingString:[ISIdioms nameForOption:option inIdiom:idiom]]];
        [self.currentDeviceIdioms setValue:N(option) forKey:[N(idiom) stringValue]];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (wasCancel)
        return;
    
    [self showActionSheetForIdiom:self.currentIdiomIndex + 1];
}

#pragma mark - Segue methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:kSegueAvailability]){
        NSLog(@"Performing segue...");
    } else {
        NSLog(@"unprepared segue %@", [segue identifier]);
    }
}

@end
