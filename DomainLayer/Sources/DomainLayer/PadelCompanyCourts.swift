//
//  PadelCompanyCourts.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 02.06.26.
//

public struct PadelCompany {
    public let companyName: String
    public let companyID: String
    public let companyCourts: [PadelCourt]
    
    public init(companyName: String, companyID: String, companyCourts: [PadelCourt]) {
        self.companyName = companyName
        self.companyID = companyID
        self.companyCourts = companyCourts
    }
}

