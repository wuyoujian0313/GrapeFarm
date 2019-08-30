//
//  LoginVC.m
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/3/25.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "LoginVC.h"
#import "UIColor+Utility.h"
#import "NetworkTask.h"
#import "LineView.h"
#import "UIImage+Utility.h"
#import "DeviceInfo.h"
#import "RegisterVC.h"
#import "ForgotPasswordVC.h"
#import "AILoadingView.h"
#import "FadePromptView.h"
#import "LoginBean.h"
#import "AppDelegate.h"
#import "SaveSimpleDataManager.h"

@interface LoginVC ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,NetworkTaskDelegate>
@property(nonatomic,strong)UITableView          *loginTableView;
@property(nonatomic,strong)UITextField          *nameTextField;
@property(nonatomic,strong)UITextField          *pwdTextField;
@property(nonatomic,strong)UIButton             *loginBtn;
@end

@implementation LoginVC

-(void)dealloc {
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self layoutLoginTableView];
    [self layoutToRegisterView];
}

- (void)layoutToRegisterView {
    
    NSInteger xfooter = 36;
    if ([DeviceInfo detectModel] == MODEL_IPHONE_X) {
        xfooter += 34;
    }
    
    UIView *rootview = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - xfooter, self.view.frame.size.width, xfooter)];
    rootview.backgroundColor = [UIColor clearColor];
    
    NSString *noteString1= NSLocalizedString(@"PleaseRegister_1",nil);
    NSString *noteString2= NSLocalizedString(@"PleaseRegister_2",nil);
    NSString *tempString = [NSString stringWithFormat:@"%@%@",noteString1,noteString2];
    NSRange range1 = [tempString rangeOfString:noteString1];
    NSRange range2 = [tempString rangeOfString:noteString2];
    NSDictionary *attributes1 = @{ NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:[UIColor colorWithHex:kTextGrayColor]};
    NSDictionary *attributes2 = @{ NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:[UIColor blackColor]};

    NSMutableAttributedString *attrStr1 = [[NSMutableAttributedString alloc] initWithString:tempString];
    [attrStr1 addAttributes:attributes1 range:range1];
    [attrStr1 addAttributes:attributes2 range:range2];
    
    NSMutableAttributedString *attrStr2 = [[NSMutableAttributedString alloc] initWithString:tempString];
    [attrStr2 addAttributes:attributes1 range:range1];
    [attrStr2 addAttributes:attributes1 range:range2];
    
    UIButton *registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [registerBtn setFrame:CGRectMake(0,0, rootview.frame.size.width, xfooter)];
    [registerBtn setAttributedTitle:attrStr1 forState:UIControlStateNormal];
    [registerBtn setAttributedTitle:attrStr2 forState:UIControlStateHighlighted];
    [registerBtn setTag:103];
    [registerBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [rootview addSubview:registerBtn];
    
    [self.view addSubview:rootview];
}

- (void)layoutLoginTableView {
    
    NSInteger xfooter = 36;
    if ([DeviceInfo detectModel] == MODEL_IPHONE_X) {
        xfooter += 34;
    }
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-xfooter) style:UITableViewStylePlain];
    [self setLoginTableView:tableView];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableView setBounces:NO];
    [self.view addSubview:tableView];
    
    [self setTableViewHeaderView:self.view.frame.size.height/3];
    [self setTableViewFooterView:120];
}

-(void)setTableViewHeaderView:(NSInteger)height {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _loginTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    
    CGFloat left = (_loginTableView.frame.size.width - 120)/2.0;
    CGFloat top = (height-120)/2.0;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(left, top, 120, 120)];
    imageView.image = [UIImage imageNamed:@"logo"];
    [imageView.layer setCornerRadius:22.0];
    [imageView.layer setMasksToBounds:YES];
    
    [view addSubview:imageView];
    
    LineView *line1 = [[LineView alloc] initWithFrame:CGRectMake(0, height - kLineHeight1px, view.frame.size.width, kLineHeight1px)];
    [view addSubview:line1];
    
    [_loginTableView setTableHeaderView:view];
}


-(void)setTableViewFooterView:(NSInteger)height {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _loginTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginBtn setBackgroundImage:[UIImage imageFromColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [loginBtn setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithHex:kButtonTapColor]] forState:UIControlStateHighlighted];
    [loginBtn.layer setBorderColor:[UIColor colorWithHex:kBoundaryColor].CGColor];
    [loginBtn.layer setBorderWidth:kLineHeight1px];
    [loginBtn.layer setCornerRadius:kButtonCornerRadius];
    [loginBtn setTag:101];
    [loginBtn setClipsToBounds:YES];
    [loginBtn setTitle:NSLocalizedString(@"Login",nil) forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [loginBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [loginBtn setFrame:CGRectMake(11, 15, _loginTableView.frame.size.width - 22, 45)];
    [loginBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:loginBtn];
    
    
    UIButton *forgetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    forgetBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    forgetBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    [forgetBtn setTag:102];
    
    [forgetBtn setTitle:NSLocalizedString(@"ForgotPassword",nil) forState:UIControlStateNormal];
    [forgetBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [forgetBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [forgetBtn setTitleColor:[UIColor colorWithHex:kButtonTapColor] forState:UIControlStateHighlighted];
    [forgetBtn setFrame:CGRectMake(11, 15 + 45 + 10, _loginTableView.frame.size.width - 22, 40)];
    [forgetBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:forgetBtn];
    
    [_loginTableView setTableFooterView:view];
}

-(void)buttonAction:(UIButton *)sender {
    
    NSInteger tag = sender.tag;
    if (tag == 101) {
        // 登录
        if (_nameTextField.text == nil || [_nameTextField.text length] <= 0) {
            [FadePromptView showPromptStatus:NSLocalizedString(@"InputAccount", nil) duration:1.0 positionY:self.view.frame.size.height/2.0 finishBlock:nil];
            [_nameTextField becomeFirstResponder];
            return;
        }
        
        if (_pwdTextField.text == nil || [_pwdTextField.text length] <= 0) {
            [FadePromptView showPromptStatus:NSLocalizedString(@"InputPassword", nil) duration:1.0 positionY:self.view.frame.size.height/2.0 finishBlock:nil];
            [_pwdTextField becomeFirstResponder];
            return;
        }
        
        [_nameTextField resignFirstResponder];
        [_pwdTextField resignFirstResponder];

        NSDictionary *parms = @{@"username":_nameTextField.text,
                                @"rememberMe":[NSNumber numberWithInteger:1],
                                @"password":[_pwdTextField.text md5EncodeUpper:NO],
                                };

        [AILoadingView show:NSLocalizedString(@"Loading", nil)];
        [[NetworkTask sharedNetworkTask] startPOSTTaskApi:kAPILogin
                                                 forParam:parms
                                                 delegate:self
                                                resultObj:[[LoginBean alloc] init]
                                               customInfo:@"login"];
    } else if (tag == 102) {
        // 忘记密码
        ForgotPasswordVC *vc = [[ForgotPasswordVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (tag == 103) {
        // 注册
        RegisterVC *vc = [[RegisterVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


-(void)keyboardWillShow:(NSNotification *)note{
    [super keyboardWillShow:note];
}

-(void)keyboardWillHide:(NSNotification *)note{
    [super keyboardWillHide:note];
    
    [_loginTableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
}

-(void)keyboardDidShow:(NSNotification *)note{
    
    [super keyboardDidShow:note];
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    [_loginTableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - keyboardBounds.size.height)];
    
    [_loginTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


#pragma mark - NetworkTaskDelegate
-(void)netResultSuccessBack:(NetResultBase *)result forInfo:(id)customInfo {
    [AILoadingView dismiss];
    if ([customInfo isEqualToString:@"login"]) {
        LoginBean *bean = (LoginBean *)result;
        
        SaveSimpleDataManager *manager = [[SaveSimpleDataManager alloc] init];
        [manager setObject:bean.token forKey:kLoginTokenUserdefaultKey];
        //
        AppDelegate *app = [AppDelegate shareMyApplication];
        [app switchToHomePage];
    }
}


-(void)netResultFailBack:(NSString *)errorDesc errorCode:(NSInteger)errorCode forInfo:(id)customInfo {
    [AILoadingView dismiss];
    [FadePromptView showPromptStatus:errorDesc duration:2.0 finishBlock:^{
        //
    }];
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldClear:(UITextField *)textField  {
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == _nameTextField) {
        [_pwdTextField becomeFirstResponder];
    } else if (textField == _pwdTextField){
        [textField resignFirstResponder];
    }
    
    return YES;
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 不使用重用机制
    NSInteger row = [indexPath row];
    NSInteger curRow = 0;
    
    if (row == curRow) {
        static NSString *reusedCellID = @"loginCell1";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedCellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedCellID];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.contentView.backgroundColor = [UIColor whiteColor];
            
            //
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(11, 0, tableView.frame.size.width - 22, 45)];
            self.nameTextField = textField;
//            textField.text = @"wuyoujian0313@qq.com";
            [textField setDelegate:self];
            [textField setTextColor:[UIColor blackColor]];
            [textField setFont:[UIFont systemFontOfSize:14]];
            [textField setReturnKeyType:UIReturnKeyNext];
            [textField setClearButtonMode:UITextFieldViewModeAlways];
            [textField setTextAlignment:NSTextAlignmentCenter];
            [textField setClearsOnBeginEditing:YES];
            [textField setPlaceholder:NSLocalizedString(@"InputAccount",nil)];
            
            [cell.contentView addSubview:textField];
            
            LineView *line1 = [[LineView alloc] initWithFrame:CGRectMake(0, 45 - kLineHeight1px, tableView.frame.size.width, kLineHeight1px)];
            [cell.contentView addSubview:line1];
        }
        
        return cell;
    }
    
    curRow ++;
    if (row == curRow) {
        static NSString *reusedCellID = @"loginCell2";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedCellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedCellID];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.contentView.backgroundColor = [UIColor whiteColor];
            
            //
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(11,0, tableView.frame.size.width - 22, 45)];
            self.pwdTextField = textField;
//            textField.text = @"123456";
            [textField setDelegate:self];
            [textField setSecureTextEntry:YES];
            [textField setTextColor:[UIColor blackColor]];
            [textField setFont:[UIFont systemFontOfSize:14]];
            [textField setTextAlignment:NSTextAlignmentCenter];
            [textField setClearButtonMode:UITextFieldViewModeAlways];
            [textField setClearsOnBeginEditing:YES];
            [textField setReturnKeyType:UIReturnKeyDone];
            [textField setPlaceholder:NSLocalizedString(@"InputPassword",nil)];
            [cell.contentView addSubview:textField];
            
            LineView *line1 = [[LineView alloc] initWithFrame:CGRectMake(0, 45 - kLineHeight1px, tableView.frame.size.width, kLineHeight1px)];
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

@end
