/*
 * Copyright 2009 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0

 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*/

#import "FBLoginButton.h"
#import "FBLoginDialog.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation FBLoginButton

@synthesize session = _session, style = _style;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (UIImage*)buttonImage {
  if (_session.isConnected) {
    return [UIImage imageNamed:@"FBConnect.bundle/images/logout.png"];
  } else {
    if (_style == FBLoginButtonStyleNormal) {
      return [UIImage imageNamed:@"FBConnect.bundle/images/login.png"];
    } else if (_style == FBLoginButtonStyleWide) {
      return [UIImage imageNamed:@"FBConnect.bundle/images/login2.png"];
    } else {
      return nil;
    }
  }
}

- (UIImage*)buttonHighlightedImage {
  if (_session.isConnected) {
    return [UIImage imageNamed:@"FBConnect.bundle/images/logout_down.png"];
  } else {
    if (_style == FBLoginButtonStyleNormal) {
      return [UIImage imageNamed:@"FBConnect.bundle/images/login_down.png"];
    } else if (_style == FBLoginButtonStyleWide) {
      return [UIImage imageNamed:@"FBConnect.bundle/images/login2_down.png"];
    } else {
      return nil;
    }
  }
}

- (void)updateImage {
  if (self.highlighted) {
    _imageView.image = [self buttonHighlightedImage];
  } else {
    _imageView.image = [self buttonImage];
  }
}

- (void)touchUpInside {
  if (_session.isConnected) {
    [_session logout];
  } else {
    FBLoginDialog* dialog = [[[FBLoginDialog alloc] initWithSession:_session] autorelease];
    [dialog show];
  }
}

- (void)initButton {
  _style = FBLoginButtonStyleNormal;

  _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
  _imageView.contentMode = UIViewContentModeCenter;
  [self addSubview:_imageView];

  self.backgroundColor = [UIColor clearColor];
  [self addTarget:self action:@selector(touchUpInside)
    forControlEvents:UIControlEventTouchUpInside];

  self.session = [FBSession session];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
  if (self) {
    [self initButton];
    if (CGRectIsEmpty(frame)) {
      [self sizeToFit];
    }
  }
  return self;
}

- (void)awakeFromNib {
  [self initButton];
}

- (void)dealloc {
  [_session.delegates removeObject:self];
  [_session release];
  [_imageView release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (CGSize)sizeThatFits:(CGSize)size {
  return _imageView.image.size;
}

- (void)layoutSubviews {
  _imageView.frame = self.bounds;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIControl

- (void)setHighlighted:(BOOL)highlighted {
  [super setHighlighted:highlighted];
  [self updateImage];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// FBSessionDelegate

- (void)session:(FBSession*)session didLogin:(FBUID)uid {
  [self updateImage];
}

- (void)sessionDidLogout:(FBSession*)session {
  [self updateImage];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setSession:(FBSession*)session {
  if (session != _session) {
    [_session.delegates removeObject:self];
    [_session release];
    _session = [session retain];
    [_session.delegates addObject:self];
    
    [self updateImage];
  }
}

- (void)setStyle:(FBLoginButtonStyle)style {
  _style = style;
  
  [self updateImage];
}

@end
