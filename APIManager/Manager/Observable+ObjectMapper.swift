//
//  Observable+ObjectMapper.swift
//
//  Created by Ivan Bruel on 09/12/15.
//  Copyright © 2015 Ivan Bruel. All rights reserved.
//
import Foundation
import Moya
import ObjectMapper

public extension Response {

    /// Maps data received from the signal into an object which implements the Mappable protocol.
    /// If the conversion fails, the signal errors.
    public func mapObject<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil) throws -> T {
        guard let object = Mapper<T>(context: context).map(JSONObject: try mapJSON()) else {
            throw MoyaError.jsonMapping(self)
        }
        return object
    }

    /// Maps data received from the signal into an array of objects which implement the Mappable
    /// protocol.
    /// If the conversion fails, the signal errors.
    public func mapArray<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil) throws -> [T] {
        guard let array = try mapJSON() as? [[String: Any]] else {
            throw MoyaError.jsonMapping(self)
        }
        return Mapper<T>(context: context).mapArray(JSONArray: array)
    }
}
