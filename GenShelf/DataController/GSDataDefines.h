//
//  GSDataDefines.h
//  GenShelf
//
//  Created by Gen on 16/2/26.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#ifndef GSDataDefines_h
#define GSDataDefines_h

#define CheckError if (error) {\
NSLog(@"Parse html error : %@", error);\
return;\
}

#define CheckErrorC if (error) {\
NSLog(@"Parse html error : %@", error);\
continue;\
}

#define CheckErrorR(RET) if (error) {\
NSLog(@"Parse html error : %@", error);\
return RET;\
}

#define BookProcessIdentifier(BOOK) BOOK.pageUrl
#define BookDownloadIdentifier(BOOK) [NSString stringWithFormat:@"Download %@", BOOK.pageUrl]

#endif /* GSDataDefines_h */
