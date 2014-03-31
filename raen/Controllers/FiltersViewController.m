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
#import "HUD.h"

@interface FiltersViewController ()<RaenAPICommunicatorDelegate>{
    RaenAPICommunicator *_communicator;
    FilterModel *_filter;
    NSMutableDictionary *_filterDictionary;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *acceptFilterButton;

@end

@implementation FiltersViewController


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_filterDictionary.count>0) {
        /*
        UIBarButtonItem *revokeFilterButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"]
                                                                           style:UIBarButtonItemStyleBordered target:self
                                                                        action:@selector(revokeFilter)];
        [self.navigationItem setRightBarButtonItem:revokeFilterButton animated:YES];
         */
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _communicator = [[AppDelegate instance] communicator];
    _communicator.delegate = self;
    _filterDictionary = [NSMutableDictionary dictionary];
    if (self.subcategoryID) {
        // _communicator get params of category
        [_communicator getParamsOfCategoryWithId:self.subcategoryID];
        [HUD showUIBlockingIndicator];
    }else{
        NSLog(@"there is NOT subcategory ID!");
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
    [HUD hideUIBlockingIndicator];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
    
}
-(void)didReceiveFilter:(id)filter{
    if ([filter isKindOfClass:[FilterModel class]]) {
        _filter= filter;
    }
    [HUD hideUIBlockingIndicator];
    [self.tableView reloadData];
}

#pragma mark - PickParameterViewControllerDelegate methods 
-(void)didSelectBrand:(BrandModel *)brand{
    NSLog(@"didSelectBrand %@",brand);
    [_filterDictionary setObject:brand forKey:@"brand"];
    [self.tableView reloadData];
}
-(void)didSelectColor:(ColorModel *)color{
    NSLog(@"didSelectColor %@",color);
    [_filterDictionary setObject:color forKey:@"color"];
    [self.tableView reloadData];
}
-(void)didSelectValues:(NSString *)values ofParameter:(ParametersModel *)parameter{
    NSLog(@"didSelectValues %@ ofParameter name %@",values,parameter.name);
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
        NSLog(@"sender.class %@",parameter.class);
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
            NSLog(@"currentValue %@",value);
            NSString *newValue = [value stringByReplacingOccurrencesOfString:@"," withString:@"_"];
            NSLog(@"newValue %@",newValue);
            [newDict setObject:newValue forKey:paramName];
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate didSelectFilter:newDict];
    }];
    
}


@end
