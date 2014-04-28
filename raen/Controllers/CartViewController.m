//
//  CartViewController.m
//  raenapp
//
//  Created by Alexey Ivanov on 12.02.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "CartViewController.h"
#import "AppDelegate.h"
#import "CartItemModel.h"
#import "CartItemParamsModel.h"
#import "RaenAPICommunicator.h"
#import "CartCell.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"


@interface CartViewController () <RaenAPICommunicatorDelegate,UITextFieldDelegate,UIAlertViewDelegate>
{
    UIAlertView *_checkOutAlertView;
    BOOL _checkOutAlertViewShown;
    NSArray *_items;
    UITextField *_activeTextField;
}
@end



@implementation CartViewController
@synthesize tabBarItem;


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //User Interface
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [RaenAPICommunicator sharedManager].delegate = self;
    [self updateDataFromAPI];

}

-(void)updateDataFromAPI{
    //[self.tableView setHidden:YES];
    [self.subView setHidden:YES];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[RaenAPICommunicator sharedManager] getItemsFromCart];
}

-(void)updateTabbarBadge
{
    [self.tabBarController.tabBar.items[3] setBadgeValue:[self itemsCount]];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.subView.layer setCornerRadius:10.0];
}

-(NSString*)itemsCount{
    int itemsCount = 0;
    for (int i=0; i<_items.count; i++) {
        CartItemModel *currentItem = _items[i];
        itemsCount = itemsCount + [currentItem.qty intValue];
    }
    return [NSString stringWithFormat:@"%i",itemsCount];
}

#pragma mark - RaenAPICommunicationDelegate
-(void)didReceiveCartItems:(NSArray *)items{
    _items = items;
    [self.tableView reloadData];
    [self.tableView setHidden:NO];
    [self.subView setHidden:NO];
    [self.subTotalLabel setText:[self subtotal]];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [self updateTabbarBadge];
}

-(void)fetchingFailedWithError:(JSONModelError *)error
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:error.localizedDescription delegate:self cancelButtonTitle:@"ОК" otherButtonTitles: nil];
    [alert show];
}

-(void)didChangeCartItemQTYWithResponse:(NSDictionary *)response
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if (![response objectForKey:@"success"]) {
        UIAlertView *alert  =[[UIAlertView alloc] initWithTitle:@"Ошибка" message:response[@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    [[RaenAPICommunicator sharedManager] getItemsFromCart];
    
}
-(void)didFailureChangeCartItemQTYWithError:(JSONModelError *)error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

-(void)didCheckoutWithResponse:(NSDictionary *)response{
    NSLog(@"didCheckoutWithResponse %@",response);
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if (response[@"error"]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:response[@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }else{
      
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                        message:response[@"text"]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
        //we have to reload view
        //[self viewWillAppear:YES];
    }
    [self updateDataFromAPI];
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _items.count;
}
-(UITableViewCell *)tableView:(UITableView *)tb cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"CartCell";
    CartCell *cell = [tb dequeueReusableCellWithIdentifier:cellIdentifier];
    CartItemModel *itemInCart = _items[indexPath.row];
    cell.titleLabel.text = [NSString stringWithFormat:@"%@, %@",itemInCart.category,itemInCart.name];
    [cell.spinner startAnimating];
    cell.qtyTextField.tag = indexPath.row;
    cell.qtyTextField.text = itemInCart.qty;
    [cell.itemImageView setImageWithURL:[NSURL URLWithString:itemInCart.image]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                  [cell.spinner stopAnimating];
                              }];
    cell.priceLabel.text = [NSString stringWithFormat:@"%@ руб.",itemInCart.price];
    cell.textView.text = itemInCart.params;

    return cell;
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    [_activeTextField resignFirstResponder];
    return YES;
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"Удалить";
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (_items.count==0) {
        return @"Нет товаров в корзине";
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        CartItemModel *cartItem = _items[indexPath.row];
        [[RaenAPICommunicator sharedManager] changeCartItemQTY:@"0" byRowID:cartItem.rowid];
    }
}

#pragma mark - Helpers
-(NSString*)allParamsToString:(NSArray*)params{
    NSString *fullstring =@"";
    for (CartItemParamsModel *param in params) {
        if (param.title) {
            fullstring = [fullstring stringByAppendingString:[NSString stringWithFormat:@"\n%@",param.title]];
        }
    }
    return fullstring;
}
-(NSString*)subtotal{
    NSInteger total=0;
    for (CartItemModel *cartItem in _items) {
        total = total + [cartItem.subtotal intValue];
    };
    return [NSString stringWithFormat:@"Итого: %ld руб.",(long)total];
}

#pragma mark - IBActions
- (IBAction)loginButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"toLoginVC" sender:nil];
}

- (IBAction)checkOutButtonPressed:(id)sender {
    NSLog(@"checkOutButtonPressed");
    if (_items.count>0) {
        NSString* firstName = [Socializer sharedManager].socialUsername;
        NSString* phone = [Socializer sharedManager].userPhone;
        [self showCheckOutAlertViewWithFirstName:firstName andPhone:phone message:@"Введите Ваше имя и телефон для оформления заказа."];
    }
}


#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"prepareForSegue %@",segue.identifier);
}

#pragma mark - Memory Warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Checkout AlertView

-(void)showCheckOutAlertViewWithFirstName:(NSString*)firstName andPhone:(NSString*)phone message:(NSString*)message{
    _checkOutAlertView = [[UIAlertView alloc] initWithTitle:@"Оформление заказа" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Отмена", nil];
    _checkOutAlertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [_checkOutAlertView textFieldAtIndex:0].text = firstName;
    [_checkOutAlertView textFieldAtIndex:0].placeholder = @"Введите Ваше имя";
    
    [_checkOutAlertView textFieldAtIndex:1].secureTextEntry = NO;
    [_checkOutAlertView textFieldAtIndex:1].keyboardType = UIKeyboardTypeDecimalPad;
    [_checkOutAlertView textFieldAtIndex:1].placeholder = @"Введите номер телефона";
    [_checkOutAlertView textFieldAtIndex:1].text = phone;
    [_checkOutAlertView show];
    _checkOutAlertViewShown = YES;
}
#pragma mark - UIAlertView Delegation methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"alertView clicked button %i",buttonIndex);
    _checkOutAlertView = NO;
    if (buttonIndex == 0) {
        NSString *firstName  = [alertView textFieldAtIndex:0].text;
        NSString* phone =[alertView textFieldAtIndex:1].text;
        if (firstName.length>1 && firstName.length<20 && phone.length>7 && phone.length<20)
        {
            [[RaenAPICommunicator sharedManager]checkoutFastWithFirstName:firstName andPhone:phone];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];

        }else{
#warning check!
            if (firstName.length<=1 && !_checkOutAlertView) {
                [self showCheckOutAlertViewWithFirstName:nil andPhone:nil message:@"Имя слишком короткое! Попробуйте еще раз"];
            }
            if (firstName.length>20 && !_checkOutAlertView) {
                [self showCheckOutAlertViewWithFirstName:nil andPhone:nil message:@"Имя должно быть меньше 20 символов! Попробуйте еще раз"];
            }
            if (phone.length<=1 && !_checkOutAlertView) {
                 [self showCheckOutAlertViewWithFirstName:nil andPhone:nil message:@"Слишком короткий номер телефона! Попробуйте еще раз"];
            }
            if (phone.length>20 && !_checkOutAlertView) {
                [self showCheckOutAlertViewWithFirstName:nil andPhone:nil message:@"Слишком длинный номер телефона! Попробуйте еще раз"];
            }
            
        }
        
    }
}
#pragma mark - UITextField Delegate methods
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString* resultString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (resultString.length <= 2) {
        NSCharacterSet* charSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        
        if ([resultString rangeOfCharacterFromSet:charSet].location == NSNotFound) {
            return YES;
        }
    }
    return NO;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.tableView setEditing:NO];
    _activeTextField = textField;
    [textField setInputAccessoryView:[self keyboardToolBar]];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    CartItemModel *cartItem = _items[textField.tag];
    if (textField.text.length==0) {
        textField.text = @"1";
        return;
    }
    if (![cartItem.qty isEqualToString:textField.text]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[RaenAPICommunicator sharedManager] changeCartItemQTY:textField.text byRowID:cartItem.rowid];
    }
    _activeTextField = nil;
}

-(UIToolbar*)keyboardToolBar{
    //portrait toolbar only
    UIToolbar* keyboardToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 40.0)];
    [keyboardToolBar setBarStyle:UIBarStyleBlack];
    [keyboardToolBar setTranslucent:YES];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(keyboardDonePressed)];
    keyboardToolBar.items = @[flexSpace,doneButton];
    [keyboardToolBar.layer setCornerRadius:3.0];
    return keyboardToolBar;
    
}
#pragma mark - Keyboard hide / show helpers
- (void)keyboardDonePressed{
    [self.tableView endEditing:YES];
}
- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
   
    UIEdgeInsets contentInsets;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        contentInsets = UIEdgeInsetsMake(64.0, 0.0, (kbSize.height), 0.0);
    } else {
        contentInsets = UIEdgeInsetsMake(64.0, 0.0, (kbSize.width), 0.0);
    }
    
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_activeTextField.tag inSection:0]
                          atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self.tableView setContentInset:UIEdgeInsetsMake(64, 0, 44, 0)];
    [self.tableView setScrollIndicatorInsets:UIEdgeInsetsMake(64, 0, 44, 0)];
}

@end
