//
//  FiltersViewController.m
//  raenapp
//
//  Created by Alexey Ivanov on 25.03.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "FiltersViewController.h"
#import "RaenAPICommunicator.h"
#import "AppDelegate.h"
#import "FilterModel.h"
#import "ParametersModel.h"
#import "PickParameterViewController.h"
#import "MBProgressHUD.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"


@interface FiltersViewController ()<RaenAPICommunicatorDelegate>{
    RaenAPICommunicator* _communicator;
    FilterModel *_filter;
    NSMutableDictionary *_filterDictionary;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *acceptFilterButton;

@end

@implementation FiltersViewController


-(void)viewDidAppear:(BOOL)animated
{
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Filters Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _communicator = [[RaenAPICommunicator alloc] init];
    _communicator.delegate = self;
    
    _filterDictionary = [NSMutableDictionary dictionary];
    if (self.subcategoryID)
    {
        [_communicator getParamsOfCategoryWithId:self.subcategoryID];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }else{
        NSLog(@"there is NOT subcategory ID!");
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Ошибка"
                                                              action:@"Фильтры"
                                                               label:@"there is NOT subcategory ID!"
                                                               value:nil] build]];

    }
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelFilterButtonPressed:(id)sender {
    [_filterDictionary removeAllObjects];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Raen api communicator delegate
-(void)fetchingFailedWithError:(JSONModelError *)error{

    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Проверьте подключение к интернету" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
    
}
-(void)didReceiveFilter:(id)filter{
    if ([filter isKindOfClass:[FilterModel class]]) {
        _filter= filter;
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.tableView reloadData];
}

#pragma mark - PickParameterViewControllerDelegate methods 
-(void)didSelectBrand:(BrandModel *)brand{
  
    [_filterDictionary setObject:brand forKey:@"brand"];
    [self.tableView reloadData];
}
-(void)didSelectColor:(ColorModel *)color{
   
    [_filterDictionary setObject:color forKey:@"color"];
    [self.tableView reloadData];
}
-(void)didSelectValues:(NSString *)values ofParameter:(ParametersModel *)parameter{
  
    [_filterDictionary setObject:values forKey:parameter.name];
    [self.tableView reloadData];
    
}
#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section==0) {
        return 2;
    }
    return _filter.parameters.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *CellIdentifier = @"defaultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    }
    cell.detailTextLabel.text = nil;
    if (indexPath.section ==0) {
        if (indexPath.row==0) {
            cell.textLabel.text = @"Брэнд";
            BrandModel *brand = [_filterDictionary objectForKey:@"brand"];
            cell.detailTextLabel.text = brand.name;
        }if (indexPath.row ==1) {
            cell.textLabel.text = @"Цвет";
            ColorModel *color = [_filterDictionary objectForKey:@"color"];
            cell.detailTextLabel.text = color.name;
        }
        //[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }else{
        
        ParametersModel *currentParameter = _filter.parameters[indexPath.row];
        cell.textLabel.text = currentParameter.title;
        for (NSString *name in [_filterDictionary allKeys]) {
            if ([name isEqualToString:currentParameter.name]) {
                cell.detailTextLabel.text = [_filterDictionary objectForKey:currentParameter.name];
            }
        }
       
    }

    return cell;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"Основные параметры";
            break;
        case 1:
            return @"Дополнительные параметры";
            break;
        default:
            break;
    }
    return @"";
}
#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id sender = nil;
    if (indexPath.section == 0 && indexPath.row==0) {
        //brands
        sender = _filter.brands;
    }
    if (indexPath.section == 0 && indexPath.row ==1) {
        //colors
        sender = _filter.colors;
    }
    if (indexPath.section ==1) {
        ParametersModel *parameter =_filter.parameters[indexPath.row];
 
        sender = parameter;
    }
    [self performSegueWithIdentifier:@"toPickParameterVC" sender:sender];
}
#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"prepare segue %@",segue.identifier);
    if ([segue.identifier isEqualToString:@"toPickParameterVC"]) {
        PickParameterViewController *pickParameterVC = segue.destinationViewController;
        pickParameterVC.delegate = self;
        if ([sender isKindOfClass:[NSArray class]]) {
            if ([sender[0] isKindOfClass:[BrandModel class]]) {
                pickParameterVC.brands = sender;
            }
            if ([sender[0] isKindOfClass:[ColorModel class]]) {
                pickParameterVC.colors = sender;
            }
        }
        if ([sender isKindOfClass:[ParametersModel class]]) {
            
            pickParameterVC.parameter = sender;
        }
        
    }
}

- (IBAction)acceptFilterButtonPressed:(id)sender {
    NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
    BrandModel *brand = _filterDictionary[@"brand"];
    if (brand) {
        [newDict setObject:brand.id forKey:@"brand"];
    }
    ColorModel *color = _filterDictionary[@"color"];
    if(color){
        [newDict setObject:color.id forKey:@"color"];
    }
    NSArray *paramNames = @[@"param1",@"param2",@"param3",@"param4",@"param5"];
    for (NSString*paramName in paramNames) {
        if ([_filterDictionary objectForKey:paramName]) {
            NSString *value = [_filterDictionary objectForKey:paramName];
            NSString *newValue = [value stringByReplacingOccurrencesOfString:@"," withString:@"_"];
            [newDict setObject:newValue forKey:paramName];
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate didSelectFilter:newDict];
    }];
    
}


@end
