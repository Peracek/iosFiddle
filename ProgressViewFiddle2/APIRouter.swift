//
//  APIRouter.swift
//  ProgressViewFiddle2
//
//  Created by Pavel Peroutka on 26/09/2017.
//  Copyright © 2017 Pavel Peroutka. All rights reserved.
//

import Foundation
import Alamofire

enum APIRouter: URLRequestConvertible {
    
    static let baseURL = "http://konap.pavelperoutka.cz"
    
    case Skill(id: Int)
    case Skills
    
    // MARK: - implementation of URLRequestConvertible protocol
    
    func asURLRequest() throws -> URLRequest {
        let path: String = {
            switch self {
            case .Skill(let id):
                return "skill/\(id)"
            case .Skills:
                return "skills"
            }
        }()
        
        var url = URL(string: APIRouter.baseURL)!
        url.appendPathComponent(path)
        return URLRequest(url: url)
    }
    
}
