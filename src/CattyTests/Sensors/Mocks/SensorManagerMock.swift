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

@testable import Pocket_Code

// this class is subject to change when CBSensorManager is no Singleton anymore
final class SensorManagerMock: SensorManagerProtocol {
    
    static var defaultValueForUndefinedSensor: Double = 0
    public var sensors: [CBSensor]
    private var isStarted = false
    
    init(sensors: [CBSensor]) {
        self.sensors = sensors
    }
    
    func exists(tag: String) -> Bool {
        return false
    }
    
    func sensor(tag: String) -> CBSensor? {
        return nil
    }
    
    func requiredResource(tag: String) -> ResourceType {
        return ResourceType.noResources
    }
    
    func unavailableResources(for requiredResources: NSInteger) -> NSInteger {
        return 0
    }
    
    func name(sensor: CBSensor) -> String {
        return ""
    }
    
    func name(tag: String) -> String? {
        return nil
    }
    
    func value(tag: String, spriteObject: SpriteObject?) -> AnyObject {
        return SensorManagerMock.defaultValueForUndefinedSensor as AnyObject
    }
    
    func phiroSensors() -> [PhiroSensor] {
        return [PhiroSensor]()
    }
    
    func setup(for program: Program, and scene: CBScene) {
        self.isStarted = true
    }
    
    func setup(for formula: Formula) {
        self.isStarted = true
    }
    
    func stop() {
        self.isStarted = false
    }
    
    func formulaEditorItems(for spriteObject: SpriteObject) -> [FormulaEditorItem] {
        var items = [FormulaEditorItem]()
        
        for sensor in sensors {
            items.append(FormulaEditorItem(sensor: sensor, spriteObject: spriteObject))
        }
        
        return items
    }
}
