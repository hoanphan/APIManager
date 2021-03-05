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

class APIManager<TSAPI: BaseTargetType> {
    var timeoutIntervalForRequest: Int = 60

    init() {
    }

    init(timeoutIntervalForRequest: Int) {
        self.timeoutIntervalForRequest = timeoutIntervalForRequest
    }

    let endpointClosure = { (target: TSAPI) -> Endpoint in

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

    func getAPiProvide() -> OnlineProvider<TSAPI> {
        return OnlineProvider<TSAPI>(endpointClosure: self.endpointClosure, plugins: [NetworkLoggerPlugin(verbose: true,
        responseDataFormatter: JSONResponseDataFormatter)])
    }

    private func JSONResponseDataFormatter(_ data: Data) -> Data {
        do {
            let dataAsJSON = try JSONSerialization.jsonObject(with: data)
            let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
            return prettyData
        } catch {
            return data
        }
    }

    class OnlineProvider<TSAPI>: MoyaProvider<TSAPI> where TSAPI: TargetType {

        static var AlamofireManager: SessionManager {
            // manager
            let manager = Alamofire.SessionManager.default
            manager.session.configuration.timeoutIntervalForRequest = 60
            return manager
        }

        override init(endpointClosure: @escaping EndpointClosure = MoyaProvider.defaultEndpointMapping,
                      requestClosure: @escaping RequestClosure = MoyaProvider<TSAPI>.defaultRequestMapping,
                      stubClosure: @escaping StubClosure = MoyaProvider.neverStub,
                      callbackQueue: DispatchQueue? = DispatchQueue.main,
                      manager: Manager = OnlineProvider.AlamofireManager,
                      plugins: [PluginType] = [],
                      trackInflights: Bool = false) {

            let managerAlamofire = OnlineProvider.AlamofireManager
            super.init(endpointClosure: endpointClosure,
                       requestClosure: requestClosure,
                       stubClosure: stubClosure,
                       manager: managerAlamofire, plugins: plugins, trackInflights: trackInflights)
        }
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
