

#import "RNCustomKeyboard.h"
#import "React/RCTBridge+Private.h"
#import "React/RCTUIManager.h"

#define UI_IS_IPHONE            ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define UI_IS_IPHONEX           (UI_IS_IPHONE && ([[UIScreen mainScreen] bounds].size.height == 812.0) || [[UIScreen mainScreen] bounds].size.height == 896.0)

@implementation RNCustomKeyboard

@synthesize bridge = _bridge;

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE(CustomKeyboard)

RCT_EXPORT_METHOD(install:(nonnull NSNumber *)reactTag withType:(nonnull NSString *)keyboardType)
{
  UIView* inputView = [[RCTRootView alloc] initWithBridge:(_bridge).parentBridge moduleName:@"CustomKeyboard" initialProperties:
    @{
      @"tag": reactTag,
      @"type": keyboardType
    }
  ];
    int disTance = UI_IS_IPHONEX ? (252 + 34) : 252;
  //inputView.frame = CGRectMake(-1000, -1000, 0, 252);
    inputView.frame = CGRectMake(0, -disTance, 0,disTance);
  UITextView *view = (UITextView*)[_bridge.uiManager viewForReactTag:reactTag];
  view = [self getRealTextView:view];
  view.inputView = inputView;
  [view reloadInputViews];
}

RCT_EXPORT_METHOD(uninstall:(nonnull NSNumber *)reactTag)
{
  UITextView *view = (UITextView*)[_bridge.uiManager viewForReactTag:reactTag];
  view = [self getRealTextView:view];
  view.inputView = nil;
  [view reloadInputViews];
}

RCT_EXPORT_METHOD(insertText:(nonnull NSNumber *)reactTag withText:(NSString*)text) {
  UITextView *view = (UITextView*)[_bridge.uiManager viewForReactTag:reactTag];
  view = [self getRealTextView:view];
  [view replaceRange:view.selectedTextRange withText:text];
}

RCT_EXPORT_METHOD(backSpace:(nonnull NSNumber *)reactTag) {
  UITextView *view = (UITextView*)[_bridge.uiManager viewForReactTag:reactTag];
  view = [self getRealTextView:view];
  UITextRange* range = view.selectedTextRange;
  if ([view comparePosition:range.start toPosition:range.end] == 0) {
    range = [view textRangeFromPosition:[view positionFromPosition:range.start offset:-1] toPosition:range.start];
  }
  [view replaceRange:range withText:@""];
}

RCT_EXPORT_METHOD(doDelete:(nonnull NSNumber *)reactTag) {
  UITextView *view = (UITextView*)[_bridge.uiManager viewForReactTag:reactTag];
  view = [self getRealTextView:view];
  UITextRange* range = view.selectedTextRange;
  if ([view comparePosition:range.start toPosition:range.end] == 0) {
    range = [view textRangeFromPosition:view.beginningOfDocument toPosition:[view positionFromPosition: range.start offset: 0]];
  }
  [view replaceRange:range withText:@""];
}

RCT_EXPORT_METHOD(moveLeft:(nonnull NSNumber *)reactTag) {
  UITextView *view = (UITextView*)[_bridge.uiManager viewForReactTag:reactTag];
  view = [self getRealTextView:view];
  UITextRange* range = view.selectedTextRange;
  UITextPosition* position = range.start;

//  if ([view comparePosition:range.start toPosition:range.end] == 0) {
//    position = [view positionFromPosition: position, offset: -1];
//  }

  view.selectedTextRange = [view textRangeFromPosition: position toPosition:position];
}

RCT_EXPORT_METHOD(moveRight:(nonnull NSNumber *)reactTag) {
  UITextView *view = (UITextView*)[_bridge.uiManager viewForReactTag:reactTag];
  view = [self getRealTextView:view];
  UITextRange* range = view.selectedTextRange;
  UITextPosition* position = range.end;

//  if ([view comparePosition:range.start toPosition:range.end] == 0) {
//    position = [view positionFromPosition: position, offset: 1];
//  }

  view.selectedTextRange = [view textRangeFromPosition: position toPosition:position];
}

RCT_EXPORT_METHOD(switchSystemKeyboard:(nonnull NSNumber*) reactTag) {
  UITextView *view = (UITextView*)[_bridge.uiManager viewForReactTag:reactTag];
  view = [self getRealTextView:view];
  UIView* inputView = view.inputView;
  view.inputView = nil;
  [view reloadInputViews];
  view.inputView = inputView;
}

- (UITextView*)getRealTextView:(UITextView*)reactView {
    if ([self canInputText:reactView]) {
        return reactView;
    }
    // RN 0.50 后 RCTTextField 不是继承自 UITextField 了，多包了一层，这里遍历一下去查找
    for (UITextView *aView in reactView.subviews) {
        if ([self canInputText:aView]) {
            return (UITextView*)aView;
        }
    }
    return nil;
}

- (BOOL)canInputText:(UIView*)view {
    return [view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]];
}

@end
  
