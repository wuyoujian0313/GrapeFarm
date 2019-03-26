//
//  RegisterVC.m
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/3/26.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "RegisterVC.h"
#import "NetworkTask.h"
#import "UIColor+Utility.h"
#import "UIImage+Utility.h"
#import "DeviceInfo.h"
#import "LineView.h"
#import "NSString+Utility.h"
#import "CaptchaControl.h"

@interface RegisterVC ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,NetworkTaskDelegate>

@property(nonatomic,strong)UITableView          *registerTableView;
@property(nonatomic,strong)UITextField          *codeTextField;
@property(nonatomic,strong)UITextField          *mailTextField;
@property(nonatomic,strong)UITextField          *pwdTextField;
@property(nonatomic,strong)UITextField          *pwd2TextField;
@property(nonatomic,strong)CaptchaControl       *codeBtn;
@property(nonatomic,strong)UIButton             *nextBtn;
@property(nonatomic,copy)NSString               *pwdNewString;

@end

@implementation RegisterVC

-(void)dealloc {
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:NSLocalizedString(@"Register",nil)];
    [self layoutRegisterTableView];
}

- (void)layoutRegisterTableView {
    
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    [self setRegisterTableView:tableView];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setBounces:NO];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
    
    [self setTableViewHeaderView:10];
    [self setTableViewFooterView:180];
}

-(void)setTableViewHeaderView:(NSInteger)height {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _registerTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    LineView *line1 = [[LineView alloc] initWithFrame:CGRectMake(0, height - kLineHeight1px, view.frame.size.width, kLineHeight1px)];
    [view addSubview:line1];
    [_registerTableView setTableHeaderView:view];
}

-(void)setTableViewFooterView:(NSInteger)height {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _registerTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    
    self.nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_nextBtn setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithHex:kTextGrayColor]] forState:UIControlStateHighlighted];
    [_nextBtn setBackgroundImage:[UIImage imageFromColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [_nextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_nextBtn.layer setBorderColor:[UIColor colorWithHex:kBoundaryColor].CGColor];
    [_nextBtn.layer setBorderWidth:kLineHeight1px];
    [_nextBtn.layer setCornerRadius:kButtonCornerRadius];
    [_nextBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_nextBtn setTag:101];
    [_nextBtn setClipsToBounds:YES];
    
    [_nextBtn setTitle:NSLocalizedString(@"Register", nil) forState:UIControlStateNormal];
    [_nextBtn setFrame:CGRectMake(11, 20, _registerTableView.frame.size.width-22, 45)];
    [_nextBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:_nextBtn];
    
    [_registerTableView setTableFooterView:view];
}

-(void)buttonAction:(UIButton *)sender {
    
    NSInteger tag = sender.tag;
    if (tag == 101) {
        //
        
        if (_codeTextField.text == nil || [_codeTextField.text length] <= 0) {
            [_codeTextField becomeFirstResponder];
            return;
        }
        
        if (_mailTextField.text == nil || [_mailTextField.text length] <= 0) {
            [_mailTextField becomeFirstResponder];
            return;
        }
        
        
        if (_pwdTextField.text == nil || [_pwdTextField.text length] <= 0) {
            [_pwdTextField becomeFirstResponder];
            return;
        }
        
        
        BOOL isPhone = [_mailTextField.text isValidateEmail];
        if (!isPhone) {
            
//            [FadePromptView showPromptStatus:@"输入的不是手机号码" duration:0.6 positionY:screenHeight- 300 finishBlock:^{
//                //
//            }];
            [_mailTextField becomeFirstResponder];
            return;
        }
        
        if ([_pwdTextField.text length] < 6 || [_pwdTextField.text length] > 18) {
//            [FadePromptView showPromptStatus:@"密码长度限制在6-18位" duration:0.6 positionY:screenHeight- 300 finishBlock:^{
//                //
//            }];
            
            [_pwdTextField becomeFirstResponder];
            return;
        }
        
        //
        
    }
}

// 获取手机验证码
- (void)phoneCodeStart:(CaptchaControl *)sender {
    [sender start];
}


-(void)keyboardWillShow:(NSNotification *)note{
    [super keyboardWillShow:note];
}

-(void)keyboardWillHide:(NSNotification *)note{
    [super keyboardWillHide:note];
    
//    [_registerTableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height )];
}

-(void)keyboardDidShow:(NSNotification *)note{
    
    [super keyboardDidShow:note];
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
//    [_registerTableView setFrame:CGRectMake(0, [DeviceInfo navigationBarHeight], self.view.frame.size.width, self.view.frame.size.height - keyboardBounds.size.height - [DeviceInfo navigationBarHeight])];
//
    [_registerTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


#pragma mark - NetworkTaskDelegate
-(void)netResultSuccessBack:(NetResultBase *)result forInfo:(id)customInfo {
    if ([customInfo isEqualToString:@"registerCode"]) {
        //
        
    } else if ([customInfo isEqualToString:@"register"]) {
//        [FadePromptView showPromptStatus:@"谢谢您，注册成功！" duration:1.0 positionY:screenHeight- 300 finishBlock:^{
//            //
//
//        }];
    }
}


-(void)netResultFailBack:(NSString *)errorDesc errorCode:(NSInteger)errorCode forInfo:(id)customInfo {

//    [FadePromptView showPromptStatus:errorDesc duration:1.0 finishBlock:^{
//        //
//    }];
    
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _mailTextField) {
        [_codeTextField becomeFirstResponder];
    } else if(textField == _codeTextField) {
        [_pwdTextField becomeFirstResponder];
    } else if (textField == _pwdTextField){
        [textField resignFirstResponder];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    
    if (textField == _mailTextField) {
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == _mailTextField) {
        //
    } else if(textField == _pwdTextField) {
        NSMutableString *textString = [NSMutableString stringWithString:textField.text];
        [textString replaceCharactersInRange:range withString:string];
        
        if ([textString length] > 18) {
            return NO;
        }
    }
    
    
    return YES;
    
}

- (void)inputChange:(id)sender {
    
    UITextField *textField = (UITextField *)sender;
    NSString *temp = [NSString stringWithFormat:@"%@",textField.text];
    if ([temp length] > 18) {
        textField.text = _pwdNewString;
        return;
    }
    
    self.pwdNewString = [NSString stringWithFormat:@"%@",textField.text];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 不使用重用机制
    NSInteger row = [indexPath row];
    NSInteger curRow = 0;
    
    if (row == curRow) {
        static NSString *reusedCellID = @"registerCellf1";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedCellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedCellID];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(11, 0, tableView.frame.size.width - 22, 45)];
            self.mailTextField = textField;
            [textField setDelegate:self];
            [textField setFont:[UIFont systemFontOfSize:14]];
            [textField setReturnKeyType:UIReturnKeyNext];
            [textField setKeyboardType:UIKeyboardTypePhonePad];
            //[textField setTextAlignment:NSTextAlignmentCenter];
            [textField setTextColor:[UIColor blackColor]];
            [textField setClearButtonMode:UITextFieldViewModeAlways];
            [textField setPlaceholder:NSLocalizedString(@"InputEmail",nil)];
            [cell.contentView addSubview:textField];
            
            LineView *line1 = [[LineView alloc] initWithFrame:CGRectMake(0, 45-kLineHeight1px, tableView.frame.size.width, kLineHeight1px)];
            [cell.contentView addSubview:line1];
        }
        
        return cell;
    }
    
    curRow ++;
    if (row == curRow) {
        static NSString *reusedCellID = @"registerCell2";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedCellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedCellID];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            NSString *text = NSLocalizedString(@"InputV-code",nil);
            CGSize size =  [text sizeWithFontCompatible:[UIFont systemFontOfSize:14]];
    
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(11, 0, size.width, 45)];
            self.codeTextField = textField;
            [textField setDelegate:self];
            [textField setFont:[UIFont systemFontOfSize:14]];
            [textField setReturnKeyType:UIReturnKeyNext];
            [textField setKeyboardType:UIKeyboardTypeDefault];
            //[textField setTextAlignment:NSTextAlignmentCenter];
            [textField setTextColor:[UIColor blackColor]];
            [textField setClearButtonMode:UITextFieldViewModeAlways];
            [textField setPlaceholder:NSLocalizedString(@"InputV-code",nil)];
            [cell.contentView addSubview:textField];
            
            LineView *line = [[LineView alloc] initWithFrame:CGRectMake(size.width + 22,0, kLineHeight1px, 45)];
            [cell.contentView addSubview:line];
            
            self.codeBtn = [[CaptchaControl alloc] initWithFrame:CGRectMake(size.width + 22 + 5, 0, tableView.frame.size.width -(size.width + 22 + 5) - 11 , 45)];
            [_codeBtn addTarget:self action:@selector(phoneCodeStart:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:_codeBtn];
            
            LineView *line1 = [[LineView alloc] initWithFrame:CGRectMake(0, 45-kLineHeight1px, tableView.frame.size.width, kLineHeight1px)];
            [cell.contentView addSubview:line1];
        }
        
        return cell;
    }
    
    curRow ++;
    if (row == curRow) {
        static NSString *reusedCellID = @"registerCellf3";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedCellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedCellID];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(11, 0, tableView.frame.size.width - 22, 45)];
            self.pwdTextField = textField;
            [textField setDelegate:self];
            [textField setFont:[UIFont systemFontOfSize:14]];
            [textField setSecureTextEntry:YES];
            [textField setReturnKeyType:UIReturnKeyNext];
            [textField setKeyboardType:UIKeyboardTypeDefault];
            //[textField setTextAlignment:NSTextAlignmentCenter];
            [textField setTextColor:[UIColor blackColor]];
            [textField addTarget:self action:@selector(inputChange:) forControlEvents:UIControlEventEditingChanged];
            [textField setClearButtonMode:UITextFieldViewModeAlways];
            [textField setPlaceholder:NSLocalizedString(@"InputPassword", nil)];
            [textField setClearsOnBeginEditing:YES];
            [cell.contentView addSubview:textField];
            
            LineView *line1 = [[LineView alloc] initWithFrame:CGRectMake(0, 45-kLineHeight1px, tableView.frame.size.width, kLineHeight1px)];
            [cell.contentView addSubview:line1];
        }
        
        return cell;
    }
    
    curRow ++;
    if (row == curRow) {
        static NSString *reusedCellID = @"registerCellf4";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedCellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedCellID];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(11, 0, tableView.frame.size.width - 22, 45)];
            self.pwd2TextField = textField;
            [textField setDelegate:self];
            [textField setFont:[UIFont systemFontOfSize:14]];
            [textField setSecureTextEntry:YES];
            [textField setReturnKeyType:UIReturnKeyNext];
            [textField setKeyboardType:UIKeyboardTypeDefault];
            //[textField setTextAlignment:NSTextAlignmentCenter];
            [textField setTextColor:[UIColor blackColor]];
            [textField addTarget:self action:@selector(inputChange:) forControlEvents:UIControlEventEditingChanged];
            [textField setClearButtonMode:UITextFieldViewModeAlways];
            [textField setPlaceholder:NSLocalizedString(@"ReInputPassword", nil)];
            [textField setClearsOnBeginEditing:YES];
            [cell.contentView addSubview:textField];
            
            LineView *line1 = [[LineView alloc] initWithFrame:CGRectMake(0, 45-kLineHeight1px, tableView.frame.size.width, kLineHeight1px)];
            [cell.contentView addSubview:line1];
        }
        
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
