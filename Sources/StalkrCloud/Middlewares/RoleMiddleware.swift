//
//  AuthMiddleware.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/6/17.
//
//

import JWT
import HTTP
import Vapor
import Fluent
import Foundation

class RoleMiddleware: Middleware {
    
    static var admin: RoleMiddleware = RoleMiddleware(roleNames: ["admin"])
    static var user: RoleMiddleware = RoleMiddleware(roleNames: ["user"])
    
    let roleNames: Set<String>
    
    init(roleNames: Set<String>) {
        self.roleNames = roleNames
    }
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        
        guard let token = request.headers["token"]?.string else {
            throw Abort(Status.badRequest, metadata: "missing token")
        }
        
        guard let user = try User.first(with: [("token", token)]) else {
            throw Abort(Status.badRequest, metadata: "invalid token")
        }
        
        let assignments = try RoleAssignment.all(with: [("userid", user.id)])
        
        guard roleNames.isSubset(of: try assignments.map { try $0.role()! }.map { $0.name }) else {
            throw Abort(Status.unauthorized, metadata: "unauthorized")
        }
        
        //request.user = user
        
        return try next.respond(to: request)
    }
}