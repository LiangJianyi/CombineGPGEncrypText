import XCTest
import JanyeeUtilty
@testable import CombineGPGEncrypText

class CombineGPGTest: XCTestCase {
    let readDirPath = "/Users/\(NSUserName())/Desktop/tmp/"
    let sourceFilePath = "/Users/\(NSUserName())/Documents/Xcode/Swift/CombineGPGEncrypText/test2.txt"
    let writeFilePath = "/Users/\(NSUserName())/Desktop/combine.txt"
    
    func testCombine1() {
        XCTAssertNoThrow(try CombineGPGEncrypText.run(arguments: ["CombineGPGEncrypText", readDirPath, writeFilePath]))
        let sourceUrl = URL(fileURLWithPath: sourceFilePath)
        let combineUrl = URL(fileURLWithPath: writeFilePath)
        XCTAssertTrue((try! String(contentsOf: sourceUrl)) == (try! String(contentsOf: combineUrl)))
    }
    
    func testCombine2() {
        // 执行 ShellCommand 加密并切割文件，文件碎片保存到指定目录 tmp
        // 对 tmp 执行 CombineGPGEncrypText 操作，输出 combine 文件
        // 判断原始文件和 combine 文件是否相同
        
        let sourcePath1 = "/Users/\(NSUserName())/Documents/Xcode/Swift/CombineGPGEncrypText/SourceFileTest/循环播放天鹅湖的性爱.mp4"
        let sourcePath2 = "/Users/\(NSUserName())/Documents/Xcode/Swift/CombineGPGEncrypText/SourceFileTest/Phoebe Kilminster, 106 - Prix de Lausanne 2018, classical.mp4"
        let sourcePath3 = "/Users/\(NSUserName())/Documents/Xcode/Swift/CombineGPGEncrypText/SourceFileTest/黑丝女教师抠阴.mp4"
        let sourcePath4 = "/Users/\(NSUserName())/Documents/Xcode/Swift/CombineGPGEncrypText/SourceFileTest/a.png"
        let sourcePath5 = "/Users/\(NSUserName())/Documents/Xcode/Swift/CombineGPGEncrypText/SourceFileTest/b.png"
        let moviePath1 = "/Users/\(NSUserName())/Movies/循环播放天鹅湖的性爱.mp4"
        let moviePath2 = "/Users/\(NSUserName())/Movies/Phoebe Kilminster, 106 - Prix de Lausanne 2018, classical.mp4"
        let moviePath3 = "/Users/\(NSUserName())/Movies/黑丝女教师抠阴.mp4"
        
        XCTAssertTrue(FileManager.default.contentsEqual(atPath: sourcePath1, andPath: moviePath1))
        XCTAssertTrue(FileManager.default.contentsEqual(atPath: sourcePath2, andPath: moviePath2))
        XCTAssertTrue(FileManager.default.contentsEqual(atPath: sourcePath3, andPath: moviePath3))
        XCTAssertFalse(FileManager.default.contentsEqual(atPath: sourcePath2, andPath: moviePath1))
        XCTAssertFalse(FileManager.default.contentsEqual(atPath: sourcePath2, andPath: moviePath3))
        XCTAssertFalse(FileManager.default.contentsEqual(atPath: sourcePath3, andPath: moviePath1))
        XCTAssertTrue(FileManager.default.contentsEqual(atPath: sourcePath4, andPath: sourcePath5))
    }
    
    func testCombine3() {
        let readFilePath = "/Users/\(NSUserName())/Documents/Xcode/Swift/CombineGPGEncrypText/demo.txt"
        let writeDirPath = "/Users/\(NSUserName())/Desktop/tmp"
        _ = ShellCommands.run("SplitGPGEncrypText \(readFilePath) \(writeDirPath) 3000")
        XCTAssertNoThrow(try CombineGPGEncrypText.run(arguments: ["CombineGPGEncrypText", readDirPath, writeFilePath]))
        let sourceUrl = URL(fileURLWithPath: readFilePath)
        let combineUrl = URL(fileURLWithPath: writeFilePath)
        XCTAssertTrue((try! String(contentsOf: sourceUrl)) == (try! String(contentsOf: combineUrl)))
    }
    
    func testCombine4() {
        let readFilePath = "/Users/\(NSUserName())/Documents/Xcode/Swift/CombineGPGEncrypText/en.txt"
        let writeDirPath = "/Users/\(NSUserName())/Desktop/tmp"
        _ = ShellCommands.run("SplitGPGEncrypText \(readFilePath) \(writeDirPath) 3000")
        XCTAssertNoThrow(try CombineGPGEncrypText.run(arguments: ["CombineGPGEncrypText", readDirPath, writeFilePath]))
        let sourceUrl = URL(fileURLWithPath: readFilePath)
        let combineUrl = URL(fileURLWithPath: writeFilePath)
        XCTAssertTrue((try! String(contentsOf: sourceUrl)) == (try! String(contentsOf: combineUrl)))
    }
}
