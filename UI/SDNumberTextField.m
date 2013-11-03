//
//  SDNumberTextField.m
//
//  Created by Brandon Sneed on 11/2/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "SDNumberTextField.h"

@interface NSString (SDNumberTextField)
- (NSString *)stringWithNumberFormat:(NSString *)format;
@end

@interface SDNumberTextField ()
@property (nonatomic, copy) NSString *currentFormattedText;
@end

@implementation SDNumberTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:(CGRect)frame];
    if (self) {
        self.keyboardType = UIKeyboardTypeNumberPad;
        self.format = @"#";
        [self addTarget:self action:@selector(formatInput:) forControlEvents:UIControlEventEditingChanged];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.keyboardType = UIKeyboardTypeNumberPad;
    self.format = @"#";
    [self addTarget:self action:@selector(formatInput:) forControlEvents:UIControlEventEditingChanged];
}

- (NSString *)string:(NSString *)string withNumberFormat:(NSString *)format
{
    if (!string)
        return @"";

    return [string stringWithNumberFormat:format];
}

- (void)formatInput:(UITextField *)textField
{
    if (![textField.text isEqualToString:self.currentFormattedText])
    {
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            textField.text = [self.unformattedText stringWithNumberFormat:self.format];
            self.currentFormattedText = textField.text;
        });
    }
}

- (void)deleteBackward
{
    NSInteger decimalPosition = -1;
    for (NSInteger i = (NSInteger)self.text.length - 1; i > 0; i--)
    {
        NSString *c = [self.text substringWithRange:NSMakeRange((NSUInteger)i - 1, 1)];

        BOOL valid;
        NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
        NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:c];
        valid = [alphaNums isSupersetOfSet:inStringSet];

        if (valid)
        {
            decimalPosition = i;
            break;
        }
    }

    if (decimalPosition == -1)
        self.text = @"";
    else
        self.text = [self.text substringWithRange:NSMakeRange(0, decimalPosition)];

    self.currentFormattedText = self.text;
    [self sendActionsForControlEvents:UIControlEventEditingChanged];
}

- (NSString *)unformattedText
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\D" options:NSRegularExpressionCaseInsensitive error:NULL];
    return [regex stringByReplacingMatchesInString:self.text options:0 range:NSMakeRange(0, self.text.length) withTemplate:@""];
}

@end

#pragma mark - NSString helper category

@implementation NSString(SDNumberTextField)

- (NSString *)stringWithNumberFormat:(NSString *)format
{
    if (self.length == 0 || format.length == 0)
        return self;

    format = [format stringByAppendingString:@"#"];
    NSString *string = [self stringByAppendingString:@"0"];

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\D" options:NSRegularExpressionCaseInsensitive error:NULL];
    NSString *stripped = [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, string.length) withTemplate:@""];

    NSMutableArray *patterns = [[NSMutableArray alloc] init];
    NSMutableArray *separators = [[NSMutableArray alloc] init];
    [patterns addObject:@0];

    NSInteger maxLength = 0;
    for (NSInteger i = 0; i < [format length]; i++)
    {
        NSString *character = [format substringWithRange:NSMakeRange((NSUInteger)i, 1)];
        if ([character isEqualToString:@"#"])
        {
            maxLength++;
            NSNumber *number = [patterns objectAtIndex:patterns.count - 1];
            number = @(number.integerValue + 1);
            [patterns replaceObjectAtIndex:patterns.count - 1 withObject:number];
        }
        else
        {
            [patterns addObject:@0];
            [separators addObject:character];
        }
    }

    if (stripped.length > maxLength)
        stripped = [stripped substringToIndex:(NSUInteger)maxLength];

    NSString *match = @"";
    NSString *replace = @"";

    NSMutableArray *expressions = [[NSMutableArray alloc] init];

    for (NSInteger i = 0; i < patterns.count; i++)
    {
        NSString *currentMatch = [match stringByAppendingString:@"(\\d+)"];
        match = [match stringByAppendingString:[NSString stringWithFormat:@"(\\d{%ld})", (long)((NSNumber *)[patterns objectAtIndex:i]).integerValue]];

        NSString *template;
        if (i == 0)
            template = [NSString stringWithFormat:@"$%li", (long)i+1];
        else
            template = [NSString stringWithFormat:@"%@$%li", [separators objectAtIndex:(NSUInteger)i-1], (long)i+1];

        replace = [replace stringByAppendingString:template];
        [expressions addObject:@{@"match": currentMatch, @"replace": replace}];
    }

    NSString *result = [stripped copy];

    for (NSDictionary *exp in expressions)
    {
        NSString *localMatch = [exp objectForKey:@"match"];
        NSString *localReplace = [exp objectForKey:@"replace"];
        NSString *modifiedString = [stripped stringByReplacingOccurrencesOfString:localMatch withString:localReplace options:NSRegularExpressionSearch range:NSMakeRange(0, stripped.length)];

        if (![modifiedString isEqualToString:stripped])
            result = modifiedString;
    }

    return [result substringWithRange:NSMakeRange(0, result.length - 1)];
}

@end
