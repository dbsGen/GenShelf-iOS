//
//  GSSelectCell.m
//  GenShelf
//
//  Created by Gen on 16-2-17.
//  Copyright (c) 2016年 AirRaidClub. All rights reserved.
//

#import "GSSelectCell.h"

@interface GSSelectCell ()

- (void)updateValue;

@end

@implementation GSSelectCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect bounds = self.contentView.bounds;
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(bounds.size.width/2, 10,
                                                                  bounds.size.width/2-10,
                                                                  bounds.size.height-20)];
        [_contentLabel setTextAlignment:NSTextAlignmentRight];
        [_contentLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [self.contentView addSubview:_contentLabel];
        _opetionSelected = 0;
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (void)setOptions:(NSArray *)options {
    if (_options != options) {
        _options = options;
        [self updateValue];
    }
}

- (void)setOpetionSelected:(NSInteger)opetionSelected {
    if (_opetionSelected != opetionSelected) {
        _opetionSelected = opetionSelected;
        [self updateValue];
    }
}

- (void)updateValue {
    if (_options && _options.count > _opetionSelected) {
        _contentLabel.text = [_options objectAtIndex:_opetionSelected];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        [self performSelector:@selector(restore:)
                   withObject:[NSNumber numberWithBool:animated]
                   afterDelay:0];
    }
}

- (void)restore:(NSNumber*)animated {
    [self setSelected:NO animated:[animated boolValue]];
}

- (GSSelectView *)makePickView {
    GSSelectView *pickerView = [[GSSelectView alloc] init];
    pickerView.pickerView.delegate = self;
    pickerView.pickerView.dataSource = self;
    [pickerView.pickerView selectRow:_opetionSelected
                         inComponent:0
                            animated:NO];
    return pickerView;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _options.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [_options objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.opetionSelected = row;
}

@end
