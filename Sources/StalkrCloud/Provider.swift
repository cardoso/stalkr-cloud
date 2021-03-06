//
//  Provider.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/10/17.
//
//

import Foundation
import Vapor
import Fluent

public class Provider: Vapor.Provider {
    /// Called before the Droplet begins serving
    /// which is @noreturn.
    public func beforeRun(_ drop: Droplet) throws { }

    /// Called after the provider has initialized
    /// in the `Config.addProvider` call.
    public func boot(_ config: Config) throws {
        config.preparations.append(User.self)
        config.preparations.append(UserToken.self)
        config.preparations.append(Team.self)
        config.preparations.append(TeamMembership.self)
        config.preparations.append(Role.self)
        config.preparations.append(RoleAssignment.self)
    }

    /// This should be the name of the actual repository
    /// that contains the Provider.
    /// 
    /// this will be used for things like providing
    /// resources
    ///
    /// this will default to stripped camel casing, 
    /// for example MyProvider will become `my-provider`
    /// if your Provider is providing resources
    /// it is HIGHLY recommended to provide a static let
    /// for performance considerations
    public static let repositoryName: String = "stalkr-cloud"
    
    required public init(config: Config) throws {

    }
    
    public func boot(_ drop: Droplet) throws {
        try setup(drop)
    }

    
    func setup(_ drop: Droplet) throws {
        // Preparations
        if let _ = drop.database {
            let admin = User(name: "admin", password: try "123456".hashed(by: drop))
            
            try admin.save()
            
            let adminRoleId = try Role.withName("admin")?.id
            try RoleAssignmentBuilder().build {
                $0.roleId = adminRoleId
                $0.userId = admin.id
            }?.save()
            
            let userRoleId = try Role.withName("user")?.id
            try RoleAssignmentBuilder().build {
                $0.roleId = userRoleId
                $0.userId = admin.id
            }?.save()
        }
        
        // Init Controllers
        let userController = UserController(drop: drop)
        let teamController = TeamController(drop: drop)
        let roleController = RoleController(drop: drop)
        
        let teamMembershipController = TeamMembershipController(drop: drop)
        let roleAssignmentController = RoleAssignmentController(drop: drop)

        // Add Routes
        userController.addRoutes()
        teamController.addRoutes()
        roleController.addRoutes()
        
        teamMembershipController.addRoutes()
        roleAssignmentController.addRoutes()
    }
}
