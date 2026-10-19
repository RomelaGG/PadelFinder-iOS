//
//  LegalLinks.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import Foundation

/// Where "Terms of Service" and "Privacy Policy" point.
///
/// Both are `nil` until the pages exist. While they are nil the names still
/// appear in the copy and still carry the accent colour — they simply are not
/// tappable, which is honest about there being nothing to open yet. Fill these
/// in and the links become live with no other change.
public enum LegalLinks {
    public static let termsOfService: URL? = nil
    public static let privacyPolicy: URL? = nil
}
