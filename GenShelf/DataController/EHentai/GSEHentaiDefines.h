//
//  GSLofiDefines.h
//  GenShelf
//
//  Created by Gen on 16/3/14.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#ifndef GSLofiDefines_h
#define GSLofiDefines_h

#import "GSGlobals.h"

#define URL_HOST @"http://g.e-hentai.org/"
#define FILTER_STR @"?f_doujinshi={{adult}}&f_manga={{adult}}&f_artistcg=0&f_gamecg=0&f_western=0&f_non-h=1&f_imageset=0&f_cosplay=0&f_asianporn=0&f_misc=0&f_apply=Apply+Filter"

NSString *EHentaiFilterString(BOOL adult);

#endif /* GSLofiDefines_h */
