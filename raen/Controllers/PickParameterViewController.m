//
//  PickParameterViewController.m
//  raenapp
//
//  Created by Alexey Ivanov on 26.03.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "PickParameterViewController.h"
#import "ParametersModel.h"
#import "BrandModel.h"
#import "ColorModel.h"
#import "FiltersViewController.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"


static NSString * RAENAPP_CURRENT_FILTER_DEFAULTS_KEY = @"RAENAPP_CURRENT_FILTER_DEFAULTS_KEY";

@interface PickParameterViewController (){
    NSMutableArray *_pickedParameters;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *savePickedParamsButton;

@end

@implementation PickParameterViewController

-(void)viewDidAppear:(BOOL)animated{
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Pick parameter Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}



- (void)viewDidLoad
{
    [super viewDidLoad];

    if (self.brands|| self.colors) {
        [self.navigationItem setRightBarButtonItems:nil animated:YES];
    }else{
        [self.navigationController.navigationItem setRightBarButtonItem:self.savePickedParamsButton animated:YES];
        _pickedParameters = [NSMutableArray array];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if (self.colors) return self.colors.count;
    if (self.brands) return self.brands.count;
    else return self.parameter.values.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    // Configure the cell...
    if (self.colors) {
        ColorModel *color = _colors[indexPath.row];
        cell.textLabel.text = color.name;
    }
    if (self.brands) {
        BrandModel *brand = _brands[indexPath.row];
        cell.textLabel.text = brand.name;
    }
    if (self.parameter) {
        cell.textLabel.text = _parameter.values[indexPath.row];
    }
    return cell;
}
#pragma mark - UItableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //picked brand
    if (self.brands) {
        BrandModel *brand = _brands[indexPath.row];
        [self.delegate didSelectBrand:brand];
        [self SavePickedParams:nil];
    }
    //picked color
    if (self.colors) {
        ColorModel *color = _colors[indexPath.row];
        [self.delegate didSelectColor:color];
        [self SavePickedParams:nil];
    }
    if (self.parameter) {
        //picked values of parameter
        if(cell.accessoryType == UITableViewCellAccessoryNone) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [_pickedParameters addObject:self.parameter.values[indexPath.row]];
        }else if (cell.accessoryType == UITableViewCellAccessoryCheckmark){
            cell.accessoryType = UITableViewCellAccessoryNone;
            [_pickedParameters removeObject:self.parameter.values[indexPath.row]];
        }
    }
    
}

- (IBAction)SavePickedParams:(id)sender {
    if (self.parameter) {
        NSString *longString = [_pickedParameters componentsJoinedByString:@","];
        [self.delegate didSelectValues:longString ofParameter:_parameter];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
