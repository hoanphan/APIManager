//
//  TSApiManager.swift
//  APIManager
//
//  Created by HOANDHTB on 3/5/21.
//  Copyright © 2021 HOANDHTB. All rights reserved.
//

import Foundation
import Alamofire
import Moya
import RxSwift

public class TSAPIManager {
    var timeoutIntervalForRequest: TimeInterval = 60
    
    public static let share:TSAPIManager = TSAPIManager()
    
    public init() {
    }
    
    public init(timeoutIntervalForRequest: TimeInterval) {
        self.timeoutIntervalForRequest = timeoutIntervalForRequest
    }
    
    fileprivate func getAlamofireManager() -> SessionManager {
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = timeoutIntervalForRequest
        return manager
    }
    
    func getEnpoint<API: BaseTargetType>(_ target: API) -> Endpoint {
        let endpoint: Endpoint = Endpoint(
            url: target.baseURL.absoluteString + target.path,
            sampleResponseClosure: {
                .networkResponse(204, target.sampleData)},
            method: target.method,
            task: target.task,
            httpHeaderFields: target.headers
        )
        return endpoint
    }
    
    fileprivate func getProvider<API: BaseTargetType>(_: API.Type) -> MoyaProvider<API> {
        return MoyaProvider<API>(endpointClosure: self.getEnpoint,
                                 manager: self.getAlamofireManager(),
                                 plugins: [NetworkLoggerPlugin(verbose: true,
                                                               responseDataFormatter: JSONResponseDataFormatter)])
    }
    
    fileprivate func JSONResponseDataFormatter(_ data: Data) -> Data {
        do {
            let dataAsJSON = try JSONSerialization.jsonObject(with: data)
            let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
            return prettyData
        } catch {
            return data
        }
    }
    
    public func request<API: BaseTargetType>(api: API, provider: MoyaProvider<API>? = nil, queue: DispatchQueue? = nil) -> Observable<Response> {
        let provider = provider ?? self.getProvider(API.self)
        return provider.request(api)
    }
}

extension MoyaProvider {
    open func request(_ token: Target, queue: DispatchQueue? = nil) -> Observable<Response> {
        // Creates an observable that starts a request each time it's subscribed to.
        return Observable.create { observer in
            let cancellableToken = self.request(token, callbackQueue: queue) { result in
                switch result {
                case let .success(response):
                    observer.onNext(response)
                    observer.onCompleted()
                case let .failure(error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                cancellableToken.cancel()
            }
        }
    }
}

