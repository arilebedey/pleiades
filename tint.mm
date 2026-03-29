#import <AppKit/AppKit.h>

#include "tint.h"

#define CONTENT_EFFECT_VIEW_TAG 100022
#define INSPECTOR_EFFECT_VIEW_TAG 100023
#define TITLEBAR_BACKGROUND_VIEW_TAG 100024
#define TITLEBAR_EFFECT_VIEW_TAG 100025

@interface PleiadesTaggedVisualEffectView : NSVisualEffectView
@property(readwrite) NSInteger tag;
@end

@implementation PleiadesTaggedVisualEffectView
@synthesize tag = _tag;
@end

@interface PleiadesTaggedView : NSView
@property(readwrite) NSInteger tag;
@end

@implementation PleiadesTaggedView
@synthesize tag = _tag;
@end

napi_value setWindowLayout(napi_env env, napi_callback_info info) {
  napi_status status;

  size_t argc = 4;
  napi_value args[4];
  status = napi_get_cb_info(env, info, &argc, args, 0, 0);
  if (status != napi_ok) {
    napi_throw_error(env, nullptr, "setWindowLayout(): failed to get arguments");
    return nullptr;
  } else if (argc < 3) {
    napi_throw_error(env, nullptr, "setWindowLayout(): wrong number of arguments");
    return nullptr;
  }

  void *windowBuffer;
  size_t windowBufferLength;
  status = napi_get_buffer_info(env, args[0], &windowBuffer, &windowBufferLength);
  if (status != napi_ok) {
    napi_throw_error(env, nullptr, "setWindowLayout(): cannot read window handle");
    return nullptr;
  } else if (windowBufferLength == 0) {
    napi_throw_error(env, nullptr, "setWindowLayout(): empty window handle");
    return nullptr;
  }

  NSView *mainWindowView = *static_cast<NSView **>(windowBuffer);
  if (![mainWindowView respondsToSelector:@selector(window)] || mainWindowView.window == nil) {
    napi_throw_error(env, nullptr, "setWindowLayout(): NSView doesn't contain window");
    return nullptr;
  }

  int sidebarWidth;
  status = napi_get_value_int32(env, args[1], &sidebarWidth);
  if (status != napi_ok) {
    napi_throw_error(env, nullptr, "setWindowLayout(): cannot read sidebarWidth from args");
    return nullptr;
  }

  int titlebarHeight;
  status = napi_get_value_int32(env, args[2], &titlebarHeight);
  if (status != napi_ok) {
    napi_throw_error(env, nullptr, "setWindowLayout(): cannot read titlebarHeight from args");
    return nullptr;
  }

  int titlebarMarginRight = 0;
  if (argc >= 4) {
    status = napi_get_value_int32(env, args[3], &titlebarMarginRight);
    if (status != napi_ok) {
      napi_throw_error(env, nullptr, "setWindowLayout(): cannot read titlebarMarginRight from args");
      return nullptr;
    }
  }

  NSWindow *window = mainWindowView.window;
  int viewIndex = 0;
  for (int i = 0; i < [window.contentView.subviews count]; i++) {
    NSView *testView = [window.contentView.subviews objectAtIndex:i];
    if ([testView isKindOfClass:[NSVisualEffectView class]]) {
      viewIndex = i;
    }
  }
  NSView *view = window.contentView.subviews[viewIndex];

  PleiadesTaggedVisualEffectView *contentEffectView =
      (PleiadesTaggedVisualEffectView *)[view viewWithTag:CONTENT_EFFECT_VIEW_TAG];
  if (contentEffectView) {
    contentEffectView.frame = CGRectMake(sidebarWidth, 0, [view frame].size.width - sidebarWidth - titlebarMarginRight,
                                         [view frame].size.height - titlebarHeight);
  } else {
    contentEffectView = [[PleiadesTaggedVisualEffectView alloc]
        initWithFrame:CGRectMake(sidebarWidth, 0, [view frame].size.width - sidebarWidth - titlebarMarginRight,
                                 [view frame].size.height - titlebarHeight)];
    [contentEffectView setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
    [contentEffectView setMaterial:NSVisualEffectMaterialWindowBackground];
    [contentEffectView setTag:CONTENT_EFFECT_VIEW_TAG];
    if ([[view subviews] count] > 0) {
      [view addSubview:contentEffectView positioned:NSWindowAbove relativeTo:[[view subviews] objectAtIndex:0]];
    } else {
      [view addSubview:contentEffectView];
    }
    contentEffectView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  }

  PleiadesTaggedVisualEffectView *inspectorEffectView =
      (PleiadesTaggedVisualEffectView *)[view viewWithTag:INSPECTOR_EFFECT_VIEW_TAG];
  if (inspectorEffectView) {
    inspectorEffectView.frame =
        CGRectMake([view frame].size.width - titlebarMarginRight, 0, titlebarMarginRight, [view frame].size.height);
  } else {
    inspectorEffectView = [[PleiadesTaggedVisualEffectView alloc]
        initWithFrame:CGRectMake([view frame].size.width - titlebarMarginRight, 0, titlebarMarginRight,
                                 [view frame].size.height)];
    [inspectorEffectView setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
    [inspectorEffectView setMaterial:NSVisualEffectMaterialWindowBackground];
    [inspectorEffectView setTag:INSPECTOR_EFFECT_VIEW_TAG];
    [view addSubview:inspectorEffectView positioned:NSWindowAbove relativeTo:contentEffectView];
    inspectorEffectView.autoresizingMask = NSViewHeightSizable | NSViewMinXMargin;
  }

  PleiadesTaggedView *titlebarBackgroundView = (PleiadesTaggedView *)[view viewWithTag:TITLEBAR_BACKGROUND_VIEW_TAG];
  if (titlebarBackgroundView) {
    titlebarBackgroundView.frame = CGRectMake(sidebarWidth, [view frame].size.height - titlebarHeight,
                                              [view frame].size.width - sidebarWidth - titlebarMarginRight,
                                              titlebarHeight);
  } else {
    titlebarBackgroundView = [[PleiadesTaggedView alloc]
        initWithFrame:CGRectMake(sidebarWidth, [view frame].size.height - titlebarHeight,
                                 [view frame].size.width - sidebarWidth - titlebarMarginRight, titlebarHeight)];
    [titlebarBackgroundView setTag:TITLEBAR_BACKGROUND_VIEW_TAG];
    [view addSubview:titlebarBackgroundView positioned:NSWindowAbove relativeTo:inspectorEffectView];
    titlebarBackgroundView.autoresizingMask = NSViewWidthSizable | NSViewMinYMargin;

    NSBox *box = [[NSBox alloc] initWithFrame:CGRectMake(0, 0, [titlebarBackgroundView frame].size.width,
                                                         [titlebarBackgroundView frame].size.height)];
    [box setBackgroundColor:[NSColor textBackgroundColor]];
    [box setBoxType:NSBoxCustom];
    [box setBorderType:NSNoBorder];
    [titlebarBackgroundView addSubview:box];
    box.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  }

  PleiadesTaggedVisualEffectView *titlebarEffectView =
      (PleiadesTaggedVisualEffectView *)[view viewWithTag:TITLEBAR_EFFECT_VIEW_TAG];
  if (titlebarEffectView) {
    titlebarEffectView.frame = CGRectMake(sidebarWidth, [view frame].size.height - titlebarHeight,
                                          [view frame].size.width - sidebarWidth - titlebarMarginRight,
                                          titlebarHeight);
  } else {
    titlebarEffectView = [[PleiadesTaggedVisualEffectView alloc]
        initWithFrame:CGRectMake(sidebarWidth, [view frame].size.height - titlebarHeight,
                                 [view frame].size.width - sidebarWidth - titlebarMarginRight, titlebarHeight)];
    [titlebarEffectView setBlendingMode:NSVisualEffectBlendingModeWithinWindow];
    [titlebarEffectView setMaterial:NSVisualEffectMaterialTitlebar];
    [titlebarEffectView setTag:TITLEBAR_EFFECT_VIEW_TAG];
    [view addSubview:titlebarEffectView positioned:NSWindowAbove relativeTo:titlebarBackgroundView];
    titlebarEffectView.autoresizingMask = NSViewWidthSizable | NSViewMinYMargin;
  }

  return nullptr;
}

napi_value setWindowAnimationBehavior(napi_env env, napi_callback_info info) {
  napi_status status;

  size_t argc = 2;
  napi_value args[2];
  status = napi_get_cb_info(env, info, &argc, args, 0, 0);
  if (status != napi_ok) {
    napi_throw_error(env, nullptr, "setWindowAnimationBehavior(): failed to get arguments");
    return nullptr;
  } else if (argc < 2) {
    napi_throw_error(env, nullptr, "setWindowAnimationBehavior(): wrong number of arguments");
    return nullptr;
  }

  void *windowBuffer;
  size_t windowBufferLength;
  status = napi_get_buffer_info(env, args[0], &windowBuffer, &windowBufferLength);
  if (status != napi_ok) {
    napi_throw_error(env, nullptr, "setWindowAnimationBehavior(): cannot read window handle");
    return nullptr;
  } else if (windowBufferLength == 0) {
    napi_throw_error(env, nullptr, "setWindowAnimationBehavior(): empty window handle");
    return nullptr;
  }

  bool isDocument;
  status = napi_get_value_bool(env, args[1], &isDocument);
  if (status != napi_ok) {
    napi_throw_error(env, nullptr, "setWindowAnimationBehavior(): cannot read isDocument from args");
    return nullptr;
  }

  NSView *mainWindowView = *static_cast<NSView **>(windowBuffer);
  if (![mainWindowView respondsToSelector:@selector(window)] || mainWindowView.window == nil) {
    napi_throw_error(env, nullptr, "setWindowAnimationBehavior(): NSView doesn't contain window");
    return nullptr;
  }

  NSWindow *window = mainWindowView.window;
  if (window) {
    window.animationBehavior =
        isDocument ? NSWindowAnimationBehaviorDocumentWindow : NSWindowAnimationBehaviorDefault;
  }

  return nullptr;
}
