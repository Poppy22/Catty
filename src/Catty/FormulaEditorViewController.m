/**
 *  Copyright (C) 2010-2014 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

#import "FormulaEditorViewController.h"
#import "FormulaEditorTextField.h"
#import "UIDefines.h"
#import "Brick.h"
#import "LanguageTranslationDefines.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "StartScriptCell.h"
#import "WhenScriptCell.h"
#import "IfLogicElseBrickCell.h"
#import "IfLogicEndBrickCell.h"
#import "ForeverBrickCell.h"
#import "IfLogicBeginBrickCell.h"
#import "RepeatBrickCell.h"
#import "BroadcastScriptCell.h"
#import "CellMotionEffect.h"
#import "BrickCell.h"
#import "FormulaElement.h"
#import "LanguageTranslationDefines.h"

NS_ENUM(NSInteger, ButtonIndex) {
    kButtonIndexDelete = 0,
    kButtonIndexCopyOrCancel = 1,
    kButtonIndexAnimate = 2,
    kButtonIndexEdit = 3,
    kButtonIndexCancel = 4
};

@interface FormulaEditorViewController ()

@property (nonatomic, strong) NSMutableArray *redoStack; // of NSString
@property (nonatomic, strong) NSMutableArray *undoStack; // of NSString

@property (strong, nonatomic) UITapGestureRecognizer *recognizer;
@property (strong, nonatomic) UIMotionEffectGroup *motionEffects;
@property (strong, nonatomic) FormulaEditorTextField *formulaEditorTextField;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property (weak, nonatomic) IBOutlet UIButton *undoButton;
@property (weak, nonatomic) IBOutlet UIButton *redoButton;
@property (weak, nonatomic) IBOutlet UIButton *computeButton;
@property (weak, nonatomic) IBOutlet UIButton *divisionButton;
@property (weak, nonatomic) IBOutlet UIButton *multiplicationButton;
@property (weak, nonatomic) IBOutlet UIButton *substractionButton;
@property (weak, nonatomic) IBOutlet UIButton *additionButton;


@end

@implementation FormulaEditorViewController

@synthesize formulaEditorTextField;

const float TEXT_FIELD_HEIGHT = 45;

- (id)initWithBrickCell:(BrickCell*)brickCell AndFormulaButton:(FormulaEditorButton*)formulaButton
{
    self = [super init];
    
    if(self) {
        self.brickCell = brickCell;
        self.formulaEditorButton = formulaButton;
        self.internFormula = [[InternFormula alloc] initWithInternTokenList:[[formulaButton getFormula].formulaTree getInternTokenList]];
    }
    
    return self;
}

- (void)updateFormulaButton:(FormulaEditorButton*)formulaButton
{
    self.formulaEditorButton = formulaButton;
    self.internFormula = [[InternFormula alloc] initWithInternTokenList:[[formulaButton getFormula].formulaTree getInternTokenList]];
    [self update];
}

- (InternFormula *)internFormula
{
    if(!_internFormula) {
        _internFormula = [[InternFormula alloc]init];
    }
    return _internFormula;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.clearColor;
    [CellMotionEffect addMotionEffectForView:self.brickCell withDepthX:0.0f withDepthY:25.0f withMotionEffectGroup:self.motionEffects];
    
    [self showFormulaEditor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    self.recognizer.numberOfTapsRequired = 1;
    self.recognizer.cancelsTouchesInView = NO;
    [self.view.window addGestureRecognizer:self.recognizer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [CellMotionEffect removeMotionEffect:self.motionEffects fromView:self.brickCell];
    self.motionEffects = nil;
    if ([self.view.window.gestureRecognizers containsObject:self.recognizer]) {
        [self.view.window removeGestureRecognizer:self.recognizer];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(formulaEditorViewController:withBrickCell:)]) {
        [self.delegate formulaEditorViewController:self withBrickCell:self.brickCell];
    }
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if ([sender isKindOfClass:UITapGestureRecognizer.class]) {
        //[self dismissFormulaEditorViewController];
    }
}

- (UIMotionEffectGroup *)motionEffects {
    if (!_motionEffects) {
        _motionEffects = [UIMotionEffectGroup new];
    }
    return _motionEffects;
}

#pragma mark - helper methods
- (void)dismissFormulaEditorViewController
{
    if (! self.presentingViewController.isBeingDismissed) {
        [self.formulaEditorTextField removeFromSuperview];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (BOOL)canUndo
{
    return [self.undoStack count] > 0;
}

- (BOOL)canRedo
{
    return [self.redoStack count] > 0;
}

#pragma mark - Getters
- (NSArray*)redoStack
{
    if(!_redoStack) _redoStack = [[NSMutableArray alloc] init];
    return _redoStack;
}

- (NSArray*)undoStack
{
    if(!_undoStack) _undoStack = [[NSMutableArray alloc] init];
    return _undoStack;
}

#pragma mark - TextField Actions
- (IBAction)buttonPressed:(id)sender
{
    if([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        NSString *title = button.titleLabel.text;
//        self.formulaEditorTextField.text = [self.formulaEditorTextField.text stringByAppendingString:number];
        [self inputDidChange:self.formulaEditorTextField];
        if(PLUS == [sender tag])
        {
            NSLog(@"Plus: %@", title);
        }else{
            NSLog(@"Beschreibung: %ld", (long)[sender tag]);
        }
        
        
        [self.internFormula handleKeyInputWithName:title butttonType:(int)[sender tag]];
        NSLog(@"InternFormulaString: %@",[self.internFormula getExternFormulaString]);
        [self update];
        
        
    }
}

- (void)inputDidChange:(id)sender
{
    FormulaEditorTextField *textField = (FormulaEditorTextField*)sender;
    [self.undoStack addObject:textField.text];
    [self.redoStack removeAllObjects];
    [self update];
}

- (IBAction)undo:(id)sender
{
    [self.redoStack addObject:[self.undoStack lastObject]];
    [self.undoStack removeLastObject];
    self.formulaEditorTextField.text = [self.undoStack lastObject];
    [self update];
}

- (IBAction)redo:(id)sender
{
    [self.undoStack addObject:[self.redoStack lastObject]];
    self.formulaEditorTextField.text = [self.redoStack lastObject];
    [self.redoStack removeLastObject];
    [self update];
}

- (IBAction)done:(id)sender
{
    [self dismissFormulaEditorViewController];
}

- (IBAction)compute:(id)sender {
    float result = [[[self.internFormula getInternFormulaParser] parseFormula] interpretRecursiveForSprite:nil];
    NSString *computedString = [NSString stringWithFormat:@"Computed result is %f", result];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Result"
                                                   message: computedString
                                                  delegate: self
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil,nil];
    [alert show];
}

#pragma mark - UI
- (void)showFormulaEditor
{
    UIView *textFieldPadding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, TEXT_FIELD_HEIGHT)];
    
    self.formulaEditorTextField = [[FormulaEditorTextField alloc] initWithFrame: CGRectMake(1, self.brickCell.frame.size.height + 50, self.view.frame.size.width - 2, TEXT_FIELD_HEIGHT) AndFormulaEditorViewController:self];
    [self.formulaEditorTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.formulaEditorTextField setLeftViewMode:UITextFieldViewModeAlways];
    [self.formulaEditorTextField setLeftView:textFieldPadding];
    self.formulaEditorTextField.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.formulaEditorTextField];
    
    for(int i = 0; i < [self.buttons count]; i++) {
        [[self.buttons objectAtIndex:i] setTitleColor:UIColor.lightOrangeColor forState:UIControlStateNormal];
    }
    
    [self update];
    [self.formulaEditorTextField becomeFirstResponder];
}

- (void)update
{
    [self.formulaEditorTextField update];
    [self.formulaEditorButton updateFormula:self.internFormula];
    [self.undoButton setEnabled:[self canUndo]];
    [self.redoButton setEnabled:[self canRedo]];
}

@end
