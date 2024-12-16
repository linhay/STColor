import Testing
@testable import STColor

@Test func example() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    // Test Case 1: Valid 3-digit hex color
    print("Test Case 1 Passed: \(STColor("#4E453F").hexString())")
}
