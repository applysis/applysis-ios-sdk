import XCTest
@testable import applysis_ios_sdk

final class applysis_ios_sdkTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(applysis_ios_sdk().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
