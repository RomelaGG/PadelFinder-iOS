//
//  AuthCopy.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

/// Every user-visible string in the account surface, in one place.
///
/// Kept together so the whole set can be lifted into a String Catalog in one
/// move when Georgian arrives, and so the tone stays consistent: plain words,
/// say what happened and what to do next, never blame the user, never name an
/// HTTP status. Property names mirror the keys in `AUTH-UI-SPEC.md` §8.
///
/// Error text that the *server* writes is deliberately absent — for a wrong
/// 6-digit code the remaining-attempt count exists only inside the server's
/// own sentence, so it is shown verbatim rather than rewritten here.
enum AuthCopy {

    enum Welcome {
        static let title = "Book a court in seconds"
        static let subtitle = "Every padel court in Tbilisi, in one app."
        static let apple = "Continue with Apple"
        static let google = "Continue with Google"
        static let email = "Sign up with email"
        static let legalPrefix = "By continuing you agree to our "
        static let haveAccount = "Already have an account?"
    }

    enum Common {
        static let signIn = "Sign in"
        static let createAccount = "Create an account"
        static let or = "or"
        static let terms = "Terms of Service"
        static let privacy = "Privacy Policy"
        static let tryAgain = "Try again"
        static let cancel = "Cancel"
    }

    enum SignUp {
        static let title = "Create your account"
        static let subtitle = "We'll email you a 6-digit code to confirm it's you."
        static let termsPrefix = "I agree to the "
        static let submit = "Create account"
    }

    enum SignIn {
        static let title = "Welcome back"
        static let subtitle = "Sign in to book and manage your courts."
        static let forgot = "Forgot password?"
        static let newHere = "New here?"
        static let submit = "Sign in"
        static let sendCode = "Send code"
    }

    enum Field {
        static let nickname = "Nickname"
        static let nicknameHelper = "How other players will see you"
        static let email = "Email"
        static let password = "Password"
        static let newPassword = "New password"
        static let confirmPassword = "Confirm password"
    }

    enum OTP {
        static let title = "Check your email"
        static let titleReset = "Enter your code"
        static func subtitle(_ email: String) -> String { "We sent a 6-digit code to \(email)." }
        static let resent = "New code sent."
        static let changeEmail = "Wrong email? Change it"
        static let haveAccount = "Already have an account?"
    }

    enum Forgot {
        static let title = "Reset your password"
        static let subtitle = "Enter your email and we'll send you a 6-digit code."
        static let submit = "Send code"
    }

    enum NewPassword {
        static let title = "Choose a new password"
        static let subtitle = "You'll be signed in once it's saved."
        static let submit = "Save and sign in"
        static let startOver = "Start over"
    }

    enum Success {
        static let title = "You're all set"
        static func subtitle(_ email: String) -> String { "Signed in as \(email)" }
        static let subtitleFallback = "You're signed in."
    }

    enum Gate {
        static let title = "Sign in to book"
        static let subtitle = "Takes a few seconds. Browsing stays free."
        static let email = "Continue with email"
        static let notNow = "Not now"
    }

    enum Account {
        static let title = "Account"
        static let promoTitle = "Sign in to book courts"
        static let promoBody = "Save your clubs, pay in a tap, and keep every booking in one place."
        static let promoCTA = "Sign in or create account"
        static let rowBookings = "My bookings"
        static let rowPayment = "Payment methods"
        static let rowNotifications = "Notifications"
        static let rowLanguage = "Language"
        static let rowLanguageValue = "English"
        static let rowHelp = "Help"
        static let rowSignOut = "Sign out"
        static let rowDelete = "Delete account"
        static let signOutConfirm = "Sign out of PadelFinder?"
        static let deleteConfirmTitle = "Delete account"
        static let deleteConfirmMessage =
            "This permanently deletes your account and booking history. This cannot be undone."
    }

    enum Bookings {
        static let title = "Bookings"
        static let emptyTitle = "No bookings yet"
        static let emptySignedOut = "Sign in to book a court and see it here."
        static let emptySignedIn = "Courts you book will show up here."
    }

    enum Error {
        static let invalidEmail = "Enter a valid email address."
        static let emptyEmail = "Enter your email address."
        static let emptyPassword = "Enter your password."
        static let passwordMismatch = "Passwords don't match."
        static let weakPassword =
            "Choose a password with at least 8 characters, a letter and a number."
        static let incompleteCode = "Enter all 6 digits."
        static let generic = "Something went wrong. Please try again."
    }
}
