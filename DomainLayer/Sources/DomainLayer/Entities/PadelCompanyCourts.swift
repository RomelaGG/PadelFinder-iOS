//
//  PadelCompanyCourts.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 02.06.26.
//

public struct PadelCompany: Sendable {
    public let companyName: String
    public let companyID: String
    public let companyWebsite: String?
    public let companyCourts: [PadelCourt]
    
    public init(
        companyName: String,
        companyID: String,
        companyWebsite: String? = nil,
        companyCourts: [PadelCourt]
    ) {
        self.companyName = companyName
        self.companyID = companyID
        self.companyWebsite = companyWebsite
        self.companyCourts = companyCourts
    }
}
