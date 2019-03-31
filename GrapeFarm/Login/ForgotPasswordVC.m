//
//  ForgotPasswordVC.m
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/3/26.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "ForgotPasswordVC.h"
#import "NetworkTask.h"
#import "UIColor+Utility.h"
#import "UIImage+Utility.h"
#import "DeviceInfo.h"
#import "LineView.h"
#import "NSString+Utility.h"
#import "CaptchaControl.h"
#import "FadePromptView.h"
#import "GetVerificationCodeBean.h"
#import "ForgotPasswordBean.h"
#import "AILoadingView.h"

@interface ForgotPasswordVC ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,NetworkTaskDelegate>

@property(nonatomic,strong)UITableView          *registerTableView;
@property(nonatomic,strong)UITextField          *codeTextField;
@property(nonatomic,strong)UITextField          *mailTextField;
@property(nonatomic,strong)UITextField          *pwdTextField;
@property(nonatomic,strong)UITextField          *pwd2TextField;
@property(nonatomic,strong)CaptchaControl       *codeBtn;
@property(nonatomic,strong)UIButton             *nextBtn;
@property(nonatomic,copy)NSString               *pwdNewString;

@end

@implementation ForgotPasswordVC

-(void)dealloc {
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:NSLocalizedString(@"ForgotPassword",nil)];
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
    [_nextBtn setTitle:NSLocalizedString(@"Reset", nil) forState:UIControlStateNormal];
    [_nextBtn setFrame:CGRectMake(11, 20, _registerTableView.frame.size.width-22, 45)];
    [_nextBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:_nextBtn];
    
    [_registerTableView setTableFooterView:view];
}

-(void)buttonAction:(UIButton *)sender {
    
    NSInteger tag = sender.tag;
    if (tag == 101) {
        //
        if (_mailTextField.text == nil || [_mailTextField.text length] <= 0) {
            [FadePromptView showPromptStatus:NSLocalizedString(@"InputEmail",nil) duration:1.0 positionY:self.view.frame.size.height/2.0 finishBlock:nil];
            [_mailTextField becomeFirstResponder];
            return;
        }
        
        if (_codeTextField.text == nil || [_codeTextField.text length] <= 0) {
            [FadePromptView showPromptStatus:NSLocalizedString(@"V-code",nil) duration:1.0 positionY:self.view.frame.size.height/2.0 finishBlock:nil];
            [_codeTextField becomeFirstResponder];
            return;
        }
        
        if (_pwdTextField.text == nil || [_pwdTextField.text length] <= 0) {
            [FadePromptView showPromptStatus:NSLocalizedString(@"InputPassword",nil) duration:1.0 positionY:self.view.frame.size.height/2.0 finishBlock:nil];
            [_pwdTextField becomeFirstResponder];
            return;
        }
        
        if (_pwdTextField.text == nil || [_pwdTextField.text length] < 6) {
            [FadePromptView showPromptStatus:NSLocalizedString(@"PasswordLengthError",nil) duration:1.0 positionY:self.view.frame.size.height/2.0 finishBlock:nil];
            [_pwdTextField becomeFirstResponder];
            return;
        }
        
        if (_pwd2TextField.text == nil || [_pwd2TextField.text length] <= 0) {
            [FadePromptView showPromptStatus:NSLocalizedString(@"ReInputPassword",nil) duration:1.0 positionY:self.view.frame.size.height/2.0 finishBlock:nil];
            [_pwd2TextField becomeFirstResponder];
            return;
        }
        
        if (![_pwd2TextField.text isEqualToString:_pwdTextField.text]) {
            [FadePromptView showPromptStatus:NSLocalizedString(@"PasswordsUnmatch",nil) duration:1.0 positionY:self.view.frame.size.height/2.0 finishBlock:nil];
            [_pwd2TextField becomeFirstResponder];
            return;
        }
        
        NSDictionary *parms = @{@"email":_mailTextField.text,
                                @"password":[_pwdTextField.text md5EncodeUpper:NO],
                                @"code":_codeTextField.text,
                                };
        
        [AILoadingView show:NSLocalizedString(@"Loading", nil)];
        [[NetworkTask sharedNetworkTask] startPOSTTaskApi:kAPIResetPassword
                                                 forParam:parms
                                                 delegate:self
                                                resultObj:[[ForgotPasswordBean alloc] init]
                                               customInfo:@"register"];
    }
}

// 获取手机验证码
- (void)phoneCodeStart:(CaptchaControl *)sender {
    if (_mailTextField.text == nil || [_mailTextField.text length] <= 0) {
        [FadePromptView showPromptStatus:NSLocalizedString(@"InputEmail",nil) duration:1.0 positionY:self.view.frame.size.height/2.0 finishBlock:nil];
        [_mailTextField becomeFirstResponder];
        return;
    }
    
    BOOL isMail = [_mailTextField.text isValidateEmail];
    if (!isMail) {
        [FadePromptView showPromptStatus:NSLocalizedString(@"InvalidEMail",nil) duration:1.0 positionY:self.view.frame.size.height/2.0 finishBlock:nil];
        [_mailTextField becomeFirstResponder];
        return;
    }
    
    NSDictionary *parms = @{@"email":_mailTextField.text,
                            @"sendType":@"forget",
                            };
    [AILoadingView show:NSLocalizedString(@"Loading", nil)];
    [[NetworkTask sharedNetworkTask] startPOSTTaskApi:kAPIGetRegiterCode
                                             forParam:parms
                                             delegate:self
                                            resultObj:[[GetVerificationCodeBean alloc] init]
                                           customInfo:@"registerCode"];
}


- (void)keyboardWillShow:(NSNotification *)note{
    [super keyboardWillShow:note];
}

- (void)keyboardWillHide:(NSNotification *)note{
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
    [AILoadingView dismiss];
    if ([customInfo isEqualToString:@"registerCode"]) {
        //
        [FadePromptView showPromptStatus:NSLocalizedString(@"CheckEmailCode", nil) duration:2.0 finishBlock:^{
            //
        }];
        
    } else if ([customInfo isEqualToString:@"register"]) {
        [FadePromptView showPromptStatus:NSLocalizedString(@"resetPassworkSuccess", nil) duration:2.0 finishBlock:^{
            //
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}


-(void)netResultFailBack:(NSString *)errorDesc errorCode:(NSInteger)errorCode forInfo:(id)customInfo {
    [AILoadingView dismiss];
    [FadePromptView showPromptStatus:errorDesc duration:2.0 finishBlock:^{
        //
    }];
    
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
        [_pwd2TextField becomeFirstResponder];
    } else if (textField == _pwd2TextField){
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
        
        if ([textString length] > 8) {
            return NO;
        }
    } else if (textField == _codeTextField ) {
        NSMutableString *textString = [NSMutableString stringWithString:textField.text];
        [textString replaceCharactersInRange:range withString:string];
        
        if ([textString length] > 6) {
            return NO;
        }
    }
    
    
    return YES;
    
}

- (void)inputChange:(id)sender {
    
    UITextField *textField = (UITextField *)sender;
    NSString *temp = [NSString stringWithFormat:@"%@",textField.text];
    if ([temp length] > 8) {
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

- (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font constraintSize:(CGSize)constraintSize
{
    CGSize stringSize = CGSizeZero;
    NSDictionary *attributes = @{NSFontAttributeName:font};
    NSInteger options = NSStringDrawingUsesLineFragmentOrigin;
    CGRect stringRect = [string boundingRectWithSize:constraintSize options:options attributes:attributes context:NULL];
    stringSize = stringRect.size;
    return stringSize;
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
            [textField setKeyboardType:UIKeyboardTypeDefault];
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
            
            NSInteger w = tableView.frame.size.width - 22;
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(11, 0, 3.15*w/5.0, 45)];
            self.codeTextField = textField;
            [textField setDelegate:self];
            [textField setFont:[UIFont systemFontOfSize:14]];
            [textField setReturnKeyType:UIReturnKeyNext];
            [textField setKeyboardType:UIKeyboardTypeDefault];
            [textField setTextColor:[UIColor blackColor]];
            [textField setClearButtonMode:UITextFieldViewModeAlways];
            [textField setPlaceholder:text];
            [cell.contentView addSubview:textField];
            
            LineView *line = [[LineView alloc] initWithFrame:CGRectMake(3.15*w/5.0 + 22,0, kLineHeight1px, 45)];
            [cell.contentView addSubview:line];
            
            self.codeBtn = [[CaptchaControl alloc] initWithFrame:CGRectMake(3.15*w/5.0 + 22, 0,tableView.frame.size.width - (3.15*w/5.0 + 22) , 45)];
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
            NSString *text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"InputPassword", nil),NSLocalizedString(@"Character", nil)];
            [textField setPlaceholder:text];
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
            [textField setReturnKeyType:UIReturnKeyDone];
            [textField setKeyboardType:UIKeyboardTypeDefault];
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
