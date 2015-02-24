# TSROptionsView

Options view like the one seen in the Spotify app for iOS.

## CocoaPods

Simply add the following in your Podfile:

```ruby
pod "TSROptionsView", :git => "https://github.com/tonsser/ios-options-selector"
```

We'll publish it to the CocoaPods repo once we feel it's stable enough for production use.

## Usage

```objective-c
@implementation YourViewController

// ...

- (void)askTheUser {
  TSROptionsView *options = [TSROptionsView withTitle:@"Will it blend?" delegate:self otherButtonTitles:@"Yes", @"No", @"Maybe ...", nil];
  
  options.tintColor   = [UIColor yellowColor];
  options.choicesFont = [UIFont fontWithName:@"Georgia" size:17.f];
  
  [self presentOptionsView:options];
}

// ...

@end
```

## Methods

```objective-c
+ (TSROptionsView *)withTitle:(NSString *)title delegate:(id<TSROptionsViewDelegate>)delegate otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

+ (TSROptionsView *)withTitle:(NSString *)title delegate:(id<TSROptionsViewDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

- (void)addOptionWithTitle:(NSString *)title;
- (void)addOptionWithTitle:(NSString *)title icon:(UIImage *)icon;
- (void)addOptionWithTitle:(NSString *)title icon:(UIImage *)icon selected:(BOOL)selected;

- (NSString *)titleForButtonWithIndex:(NSInteger)index;
```

## Properties

<table>
  <tr><th colspan="3" style="text-align:center;">TSROptionsView</th></tr>
  <tr>
    <td>cancelButtonTitle</td>
    <td><code>NSString*</code></td>
    <td>Set or get the title of the cancel button. <code>nil</code> will hide the cancel button.</td>
  </tr>
  <tr>
    <td>tintColor</td>
    <td><code>UIColor*</code></td>
    <td>Set or get the tint color.</td>
  </tr>
  <tr>
    <td>textColor</td>
    <td><code>UIColor*</code></td>
    <td>Set or get the text color.</td>
  </tr>
  <tr>
    <td>checkmarkColor</td>
    <td><code>UIColor*</code></td>
    <td>Set or get the checkmark color.</td>
  </tr>
  <tr>
    <td>titleFont</td>
    <td><code>UIFont*</code></td>
    <td>Set or get the font of the title.</td>
  </tr>
  <tr>
    <td>choicesFont</td>
    <td><code>UIFont*</code></td>
    <td>Set or get the font of the choices.</td>
  </tr>
  <tr>
    <td>tintColorAlphaModifier</td>
    <td><code>CGFloat</code></td>
    <td>Set or get the alpha modifier used for the blurring. Default is <code>.85f</code>.</td>
  </tr>
  <tr>
    <td>animationDuration</td>
    <td><code>CGFloat</code></td>
    <td>Duration of the animation in seconds (<i>per</i> animation, there's a total of 2).</td>
  </tr>
  <tr>
    <td>animationDelay</td>
    <td><code>CGFloat</code></td>
    <td>Delay, in number of seconds, between the two animations.</td>
  </tr>
  <tr>
    <td>startOffsetPercentage</td>
    <td><code>CGFloat</code></td>
    <td>The start offset/inset of the first button, in percents. (1 = 100%, 0.5 = 50%, 0 = 0%).</td>
  </tr>
</table>

## Credits

TSROptionsView is brought to you by Nicolai Persson and the Tonsser team.

* Nicolai Persson ([GitHub](http://www.github.com/spookd))

Support is provided by the following organizations:

* [Tonsser](http://www.github.com/tonsser)

## License

TSROptionsView is licensed under the terms of the [Apache License, version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html). Please see the [LICENSE](LICENSE) file for full details.
