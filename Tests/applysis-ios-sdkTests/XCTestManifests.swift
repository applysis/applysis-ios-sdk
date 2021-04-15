import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(applysis_ios_sdkTests.allTests),
    ]
}
#endif
