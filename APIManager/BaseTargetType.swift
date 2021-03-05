//
//  BaseTargetType.swift
//  APIManager
//
//  Created by HOANDHTB on 3/5/21.
//  Copyright © 2021 HOANDHTB. All rights reserved.
//

import Moya

protocol BaseTargetType: TargetType {
    var parameters: [String: Any]? {get}
    var parameterEncoding: ParameterEncoding {get}
}

extension BaseTargetType {
    public var sampleData: Data {
        return Data()
    }
}
