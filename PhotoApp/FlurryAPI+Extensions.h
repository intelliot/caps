/*
 *  FlurryAPI+Extensions.h
 *  copied from Whiteboard copied from Flashlight
 *
 *  Created by Elliot on 6/30/10.
 *  Copyright 2012. All rights reserved.
 *
 */

#import "FlurryAnalytics.h"

#define START_TIMED_EVENT(x) ([FlurryAnalytics logEvent:x timed:YES])

#define START_TIMED_EVENT_PARAMS(event, parameters) ([FlurryAnalytics logEvent:(event) withParameters:(parameters) timed:YES])

#define END_TIMED_EVENT(x) ([FlurryAnalytics endTimedEvent:x withParameters:nil]) // updated for v2.7 (withParameters:)

#define LOG_EVENT(x) ([FlurryAnalytics logEvent:x])

#define LOG_EVENT_PARAMS(x, y) ([FlurryAPI logEvent:x withParameters:y])
