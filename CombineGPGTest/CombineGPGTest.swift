import XCTest
@testable import CombineGPGEncrypText

class CombineGPGTest: XCTestCase {
    let readDirPath = "/Users/\(NSUserName())/Desktop/tmp2/"
    let sourceFilePath = "/Users/\(NSUserName())/Documents/Xcode/Swift/CombineGPGEncrypText/test2.txt"
    let writeFilePath = "/Users/\(NSUserName())/Desktop/combine.txt"
    
    func testCombine1() {
        XCTAssertNoThrow(try CombineGPGEncrypText.run(arguments: ["CombineGPGEncrypText", readDirPath, writeFilePath]))
    }
}
