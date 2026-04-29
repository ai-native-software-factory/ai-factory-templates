import Flutter
import UIKit
import XCTest

class RunnerTests: XCTestCase {
    
    func testAppDelegate() {
        let appDelegate = AppDelegate()
        XCTAssertNotNil(appDelegate)
    }
}
