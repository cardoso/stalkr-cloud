//
//  TeamController.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/5/17.
//
//

import HTTP
import Vapor
import Foundation

class TeamController {
    
    func create(request: Request) throws -> ResponseRepresentable {
        
        guard let name = request.data["name"]?.string else {
            throw Abort(Status.badRequest, metadata: "Missing name")
        }
        
        let team = Team(name: name)
        try team.save()
        
        return JSON(["success": true])
    }
    
    func memberships(request: Request) throws -> ResponseRepresentable {
        
        guard let teamid = request.data["teamid"]?.uint else {
            throw Abort(Status.badRequest, metadata: "Missing teamid")
        }
        
        let memberships = try TeamMembership.makeQuery().filter("teamid", teamid).all()
        
        return try JSON(node: memberships)
    }
}
