/**
 *  Copyright (C) 2010-2018 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

import XCTest

@testable import Pocket_Code

final class PositionXSensorTest: XCTestCase {

    var spriteObject: SpriteObject!
    var spriteNode: CBSpriteNode!
    var sensor: PositionXSensor!

    override func setUp() {
        self.spriteNode = CBSpriteNode()
        // TODO setup SpriteNode and Scene
        
        self.spriteObject = SpriteObject()
        self.spriteObject.spriteNode = self.spriteNode
        
        self.sensor = PositionXSensor()
    }

    override func tearDown() {
        self.spriteObject = nil
        self.sensor = nil
    }

    func testReturnDefaultValue() {
        spriteObject.spriteNode.scenePosition = CGPoint(x: 12, y: 34)
        XCTAssertNotEqual(sensor.rawValue(for: spriteObject), PositionXSensor.defaultValue, accuracy: 0.0001)
        
        spriteObject.spriteNode = nil
        XCTAssertEqual(sensor.rawValue(for: spriteObject), PositionXSensor.defaultValue, accuracy: 0.0001)
        XCTAssertEqual(sensor.standardizedValue(for: spriteObject), PositionXSensor.defaultValue, accuracy: 0.0001)
    }
    
    func testStandardization() {
        spriteObject.spriteNode.scenePosition = CGPoint(x: 12, y: 34)
        XCTAssertEqual(self.sensor.rawValue(for: spriteObject), 12.3, accuracy: 0.0001)
        XCTAssertEqual(self.sensor.standardizedValue(for: spriteObject), 12.3, accuracy: 0.0001)

        // TODO: add more cases
    }

    // TODO: add more tests
}
