/*
 Copyright (c) 2017, Joel Levin
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 Neither the name of JLRoutes nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "JLRoutes.h"
#import "JLRRouteDefinition.h"
#import "JLRParsingUtilities.h"


NSString *const JLRoutePatternKey = @"JLRoutePattern";
NSString *const JLRouteURLKey = @"JLRouteURL";
NSString *const JLRouteSchemeKey = @"JLRouteScheme";
NSString *const JLRouteWildcardComponentsKey = @"JLRouteWildcardComponents";
NSString *const JLRoutesGlobalRoutesScheme = @"JLRoutesGlobalRoutesScheme";

//保存一个全局的字典
static NSMutableDictionary *JLRGlobal_routeControllersMap = nil;

//全局属性
// global options (configured in +initialize)
static BOOL JLRGlobal_verboseLoggingEnabled;
static BOOL JLRGlobal_shouldDecodePlusSymbols;
static BOOL JLRGlobal_alwaysTreatsHostAsPathComponent;
static Class JLRGlobal_routeDefinitionClass;


@interface JLRoutes ()

@property (nonatomic, strong) NSMutableArray *mutableRoutes;
@property (nonatomic, strong) NSString *scheme;

- (JLRRouteRequestOptions)_routeRequestOptions;

@end


#pragma mark -

@implementation JLRoutes

+ (void)initialize
{
    if (self == [JLRoutes class]) {
        // Set default global options
        JLRGlobal_verboseLoggingEnabled = NO;
        JLRGlobal_shouldDecodePlusSymbols = YES;
        JLRGlobal_alwaysTreatsHostAsPathComponent = NO;
        JLRGlobal_routeDefinitionClass = [JLRRouteDefinition class];
    }
}

- (instancetype)init
{
    if ((self = [super init])) {
        self.mutableRoutes = [NSMutableArray array];
    }
    return self;
}

//重写方法，可以打印出当前的路由表
- (NSString *)description
{
    return [self.mutableRoutes description];
}

//获取所有类型scheme的路由
+ (NSDictionary <NSString *, NSArray <JLRRouteDefinition *> *> *)allRoutes;
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    for (NSString *namespace in [JLRGlobal_routeControllersMap copy]) {
        JLRoutes *routesController = JLRGlobal_routeControllersMap[namespace];
        dictionary[namespace] = [routesController.mutableRoutes copy];
    }
    
    return [dictionary copy];
}


#pragma mark - Routing Schemes

//初始化路由表的方法，scheme用来区分每一张路由表。（要与url的scheme相区分）
//常量JLRoutesGlobalRoutesScheme代表了一张默认的全局路由表，可由+ (instancetype)globalRoutes方法快速定义。也可以定义其他scheme路由表。
//实质是创建一个单例
+ (instancetype)globalRoutes
{
    return [self routesForScheme:JLRoutesGlobalRoutesScheme];
}

+ (instancetype)routesForScheme:(NSString *)scheme
{
    JLRoutes *routesController = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        JLRGlobal_routeControllersMap = [[NSMutableDictionary alloc] init];
    });
    
    if (!JLRGlobal_routeControllersMap[scheme]) {
        routesController = [[self alloc] init];
        routesController.scheme = scheme;
        JLRGlobal_routeControllersMap[scheme] = routesController;
    }
    
    routesController = JLRGlobal_routeControllersMap[scheme];
    return routesController;
}

+ (void)unregisterRouteScheme:(NSString *)scheme
{
    [JLRGlobal_routeControllersMap removeObjectForKey:scheme];
}

+ (void)unregisterAllRouteSchemes
{
    [JLRGlobal_routeControllersMap removeAllObjects];
}


#pragma mark - Registering Routes

- (void)addRoute:(JLRRouteDefinition *)routeDefinition
{
    [self _registerRoute:routeDefinition];
}


//为某一张路由表添加路由
- (void)addRoute:(NSString *)routePattern handler:(BOOL (^)(NSDictionary<NSString *, id> *parameters))handlerBlock
{
    [self addRoute:routePattern priority:0 handler:handlerBlock];
}

- (void)addRoutes:(NSArray<NSString *> *)routePatterns handler:(BOOL (^)(NSDictionary<NSString *, id> *parameters))handlerBlock
{
    for (NSString *routePattern in routePatterns) {
        [self addRoute:routePattern handler:handlerBlock];
    }
}

//增加路由的核心方法
- (void)addRoute:(NSString *)routePattern priority:(NSUInteger)priority handler:(BOOL (^)(NSDictionary<NSString *, id> *parameters))handlerBlock
{
    /* this method exists to take a route pattern that is known to contain optional params, such as:
    /path/:thing/(/a)(/b)(/c)
    and create the following paths:
    /path/:thing/a/b/c
    /path/:thing/a/b
    /path/:thing/a/c
    /path/:thing/b/a
    /path/:thing/a
    /path/:thing/b
    /path/:thing/c
    */
    //这个方法可以获得一些可选类型的url，并单独处理
    NSArray <NSString *> *optionalRoutePatterns = [JLRParsingUtilities expandOptionalRoutePatternsForPattern:routePattern];
    
    //将url包装成一个JLRRouteDefinition对象
    JLRRouteDefinition *route = [[JLRGlobal_routeDefinitionClass alloc] initWithPattern:routePattern priority:priority handlerBlock:handlerBlock];
    
    if (optionalRoutePatterns.count > 0) {
        // there are optional params, parse and add them
        for (NSString *pattern in optionalRoutePatterns) {
            JLRRouteDefinition *optionalRoute = [[JLRGlobal_routeDefinitionClass alloc] initWithPattern:pattern priority:priority handlerBlock:handlerBlock];
            //注册路由的方法
            [self _registerRoute:optionalRoute];
            [self _verboseLog:@"Automatically created optional route: %@", optionalRoute];
        }
        return;
    }
    
    [self _registerRoute:route];
}

- (void)removeRoute:(JLRRouteDefinition *)routeDefinition
{
    [self.mutableRoutes removeObject:routeDefinition];
}

- (void)removeRouteWithPattern:(NSString *)routePattern
{   
    NSInteger routeIndex = NSNotFound;
    NSInteger index = 0;
    
    for (JLRRouteDefinition *route in [self.mutableRoutes copy]) {
        if ([route.pattern isEqualToString:routePattern]) {
            routeIndex = index;
            break;
        }
        index++;
    }
    
    if (routeIndex != NSNotFound) {
        [self.mutableRoutes removeObjectAtIndex:(NSUInteger)routeIndex];
    }
}

- (void)removeAllRoutes
{
    [self.mutableRoutes removeAllObjects];
}

- (void)setObject:(id)handlerBlock forKeyedSubscript:(NSString *)routePatten
{
    [self addRoute:routePatten handler:handlerBlock];
}

- (NSArray <JLRRouteDefinition *> *)routes;
{
    return [self.mutableRoutes copy];
}

#pragma mark - Routing URLs

+ (BOOL)canRouteURL:(NSURL *)URL
{
    return [[self _routesControllerForURL:URL] canRouteURL:URL];
}

- (BOOL)canRouteURL:(NSURL *)URL
{
    return [self _routeURL:URL withParameters:nil executeRouteBlock:NO];
}

//解释路由表中url的入口。
//如果采用类方法，则默认使用全局的路由表来解释url
+ (BOOL)routeURL:(NSURL *)URL
{
    return [[self _routesControllerForURL:URL] routeURL:URL];
}

//上面的方法会进入到这个方法里面。
- (BOOL)routeURL:(NSURL *)URL
{
    return [self _routeURL:URL withParameters:nil executeRouteBlock:YES];
}

+ (BOOL)routeURL:(NSURL *)URL withParameters:(NSDictionary *)parameters
{
    return [[self _routesControllerForURL:URL] routeURL:URL withParameters:parameters];
}

- (BOOL)routeURL:(NSURL *)URL withParameters:(NSDictionary *)parameters
{
    return [self _routeURL:URL withParameters:parameters executeRouteBlock:YES];
}


#pragma mark - Private

+ (instancetype)_routesControllerForURL:(NSURL *)URL
{
    if (URL == nil) {
        return nil;
    }
    
    return JLRGlobal_routeControllersMap[URL.scheme] ?: [JLRoutes globalRoutes];
}

//
- (void)_registerRoute:(JLRRouteDefinition *)route
{
    if (route.priority == 0 || self.mutableRoutes.count == 0) {
        [self.mutableRoutes addObject:route];
    } else {
        NSUInteger index = 0;
        BOOL addedRoute = NO;
        
        // search through existing routes looking for a lower priority route than this one
        for (JLRRouteDefinition *existingRoute in [self.mutableRoutes copy]) {
            if (existingRoute.priority < route.priority) {
                // if found, add the route after it
                [self.mutableRoutes insertObject:route atIndex:index];
                addedRoute = YES;
                break;
            }
            index++;
        }
        
        // if we weren't able to find a lower priority route, this is the new lowest priority route (or same priority as self.routes.lastObject) and should just be added
        if (!addedRoute) {
            [self.mutableRoutes addObject:route];
        }
    }
    
    [route didBecomeRegisteredForScheme:self.scheme];
}

//核心方法的入口
- (BOOL)_routeURL:(NSURL *)URL withParameters:(NSDictionary *)parameters executeRouteBlock:(BOOL)executeRouteBlock
{
    if (!URL) {
        return NO;
    }
    
    [self _verboseLog:@"Trying to route URL %@", URL];
    
    BOOL didRoute = NO;
    
    JLRRouteRequestOptions options = [self _routeRequestOptions];
    JLRRouteRequest *request = [[JLRRouteRequest alloc] initWithURL:URL options:options additionalParameters:parameters];
    
    for (JLRRouteDefinition *route in [self.mutableRoutes copy]) {
        // check each route for a matching response
        JLRRouteResponse *response = [route routeResponseForRequest:request];
        if (!response.isMatch) {
            continue;
        }
        
        [self _verboseLog:@"Successfully matched %@", route];
        
        if (!executeRouteBlock) {
            // if we shouldn't execute but it was a match, we're done now
            return YES;
        }
        
        [self _verboseLog:@"Match parameters are %@", response.parameters];
        
        // Call the handler block
        didRoute = [route callHandlerBlockWithParameters:response.parameters];
        
        if (didRoute) {
            // if it was routed successfully, we're done - otherwise, continue trying to route
            break;
        }
    }
    
    if (!didRoute) {
        [self _verboseLog:@"Could not find a matching route"];
    }
    
    // if we couldn't find a match and this routes controller specifies to fallback and its also not the global routes controller, then...
    if (!didRoute && self.shouldFallbackToGlobalRoutes && ![self _isGlobalRoutesController]) {
        [self _verboseLog:@"Falling back to global routes..."];
        didRoute = [[JLRoutes globalRoutes] _routeURL:URL withParameters:parameters executeRouteBlock:executeRouteBlock];
    }
    
    // if, after everything, we did not route anything and we have an unmatched URL handler, then call it
    if (!didRoute && executeRouteBlock && self.unmatchedURLHandler) {
        [self _verboseLog:@"Falling back to the unmatched URL handler"];
        self.unmatchedURLHandler(self, URL, parameters);
    }
    
    return didRoute;
}

- (BOOL)_isGlobalRoutesController
{
    return [self.scheme isEqualToString:JLRoutesGlobalRoutesScheme];
}

//打印信息
- (void)_verboseLog:(NSString *)format, ...
{
    if (!JLRGlobal_verboseLoggingEnabled || format.length == 0) {
        return;
    }
    
    va_list argsList;
    va_start(argsList, format);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-nonliteral"
    NSString *formattedLogMessage = [[NSString alloc] initWithFormat:format arguments:argsList];
#pragma clang diagnostic pop
    
    va_end(argsList);
    NSLog(@"[JLRoutes]: %@", formattedLogMessage);
}

- (JLRRouteRequestOptions)_routeRequestOptions
{
    JLRRouteRequestOptions options = JLRRouteRequestOptionsNone;
    
    if (JLRGlobal_shouldDecodePlusSymbols) {
        options |= JLRRouteRequestOptionDecodePlusSymbols;
    }
    if (JLRGlobal_alwaysTreatsHostAsPathComponent) {
        options |= JLRRouteRequestOptionTreatHostAsPathComponent;
    }
    
    return options;
}

@end


#pragma mark - Global Options

//类的扩展，可以设置一些全局的属性
@implementation JLRoutes (GlobalOptions)

//设置可否打印对应的信息
+ (void)setVerboseLoggingEnabled:(BOOL)loggingEnabled
{
    JLRGlobal_verboseLoggingEnabled = loggingEnabled;
}

+ (BOOL)isVerboseLoggingEnabled
{
    return JLRGlobal_verboseLoggingEnabled;
}


+ (void)setShouldDecodePlusSymbols:(BOOL)shouldDecode
{
    JLRGlobal_shouldDecodePlusSymbols = shouldDecode;
}

+ (BOOL)shouldDecodePlusSymbols
{
    return JLRGlobal_shouldDecodePlusSymbols;
}

+ (void)setAlwaysTreatsHostAsPathComponent:(BOOL)treatsHostAsPathComponent
{
    JLRGlobal_alwaysTreatsHostAsPathComponent = treatsHostAsPathComponent;
}

+ (BOOL)alwaysTreatsHostAsPathComponent
{
    return JLRGlobal_alwaysTreatsHostAsPathComponent;
}

+ (void)setDefaultRouteDefinitionClass:(Class)routeDefinitionClass
{
    NSParameterAssert([routeDefinitionClass isSubclassOfClass:[JLRRouteDefinition class]]);
    JLRGlobal_routeDefinitionClass = routeDefinitionClass;
}

+ (Class)defaultRouteDefinitionClass
{
    return JLRGlobal_routeDefinitionClass;
}

@end


#pragma mark - Deprecated

NSString *const kJLRoutePatternKey = @"JLRoutePattern";
NSString *const kJLRouteURLKey = @"JLRouteURL";
NSString *const kJLRouteSchemeKey = @"JLRouteScheme";
NSString *const kJLRouteWildcardComponentsKey = @"JLRouteWildcardComponents";
NSString *const kJLRoutesGlobalRoutesScheme = @"JLRoutesGlobalRoutesScheme";
NSString *const kJLRouteNamespaceKey = @"JLRouteScheme";
NSString *const kJLRoutesGlobalNamespaceKey = @"JLRoutesGlobalRoutesScheme";


@implementation JLRoutes (Deprecated)

+ (void)addRoute:(NSString *)routePattern handler:(BOOL (^)(NSDictionary<NSString *, id> *parameters))handlerBlock
{
    [[self globalRoutes] addRoute:routePattern handler:handlerBlock];
}

+ (void)addRoute:(NSString *)routePattern priority:(NSUInteger)priority handler:(BOOL (^)(NSDictionary<NSString *, id> *parameters))handlerBlock
{
    [[self globalRoutes] addRoute:routePattern priority:priority handler:handlerBlock];
}

+ (void)addRoutes:(NSArray<NSString *> *)routePatterns handler:(BOOL (^)(NSDictionary<NSString *, id> *parameters))handlerBlock
{
    [[self globalRoutes] addRoutes:routePatterns handler:handlerBlock];
}

+ (void)removeRoute:(NSString *)routePattern
{
    [[self globalRoutes] removeRouteWithPattern:routePattern];
}

+ (void)removeAllRoutes
{
    [[self globalRoutes] removeAllRoutes];
}

+ (BOOL)canRouteURL:(NSURL *)URL withParameters:(NSDictionary *)parameters
{
    return [[self globalRoutes] canRouteURL:URL];
}

- (BOOL)canRouteURL:(NSURL *)URL withParameters:(NSDictionary *)parameters
{
    return [self canRouteURL:URL];
}

@end
