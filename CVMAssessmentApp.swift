//
//  CVMAssessmentApp.swift
//  CVM Assessment
//
//  Native iOS shell for the CVM Maturity Assessment.
//  The assessment itself lives in Web/index.html, bundled into the app,
//  so the app is fully self-contained and works with no network access.
//

import SwiftUI

@main
struct CVMAssessmentApp: App {
    var body: some Scene {
        WindowGroup {
            AssessmentView()
                .ignoresSafeArea()          // the web layout handles its own safe-area insets
                .preferredColorScheme(nil)  // follow the system Light/Dark setting
        }
    }
}
