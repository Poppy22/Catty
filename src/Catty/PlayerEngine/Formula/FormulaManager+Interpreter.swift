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

extension FormulaManager {
    
    @objc(interpretDouble: forSpriteObject:)
    func interpretDouble(_ formula: Formula, for spriteObject: SpriteObject) -> Double {
        let value = interpretRecursive(formulaElement: formula.formulaTree, for: spriteObject)
        if let doubleValue = value as? Double {
            return Double(doubleValue)
        }
        return Double(0)
    }
    
    @objc(interpretFloat: forSpriteObject:)
    func interpretFloat(_ formula: Formula, for spriteObject: SpriteObject) -> Float {
        return Float(interpretDouble(formula, for: spriteObject))
    }
    
    @objc(interpretInteger: forSpriteObject:)
    func interpretInteger(_ formula: Formula, for spriteObject: SpriteObject) -> Int {
        return Int(interpretDouble(formula, for: spriteObject))
    }
    
    @objc(interpretBool: forSpriteObject:)
    func interpretBool(_ formula: Formula, for spriteObject: SpriteObject) -> Bool {
        let value = interpretInteger(formula, for: spriteObject)
        return Bool(value == 1)
    }
    
    @objc(interpretString: forSpriteObject:)
    func interpretString(_ formula: Formula, for spriteObject: SpriteObject) -> String {
        let value = interpretRecursive(formulaElement: formula.formulaTree, for: spriteObject)
        if let doubleValue = value as? Double {
            return String(format: "%lf", doubleValue)
        } else if let intValue = value as? Int {
            return String(format: "%ld", intValue)
        } else if let stringValue = value as? String {
            return stringValue
        }
        return String("")
    }
    
    @objc(interpret: forSpriteObject:)
    func interpret(_ formula: Formula, for spriteObject: SpriteObject) -> AnyObject {
        return interpretRecursive(formulaElement: formula.formulaTree, for: spriteObject)
    }
    
    private func interpretRecursive(formulaElement: FormulaElement?, for spriteObject: SpriteObject) -> AnyObject {
        guard let formulaElement = formulaElement else { return 0 as AnyObject }
        
        switch (formulaElement.type) {
        case .OPERATOR:
            return interpretOperator(formulaElement, for: spriteObject)
        case .FUNCTION:
            return interpretFunction(formulaElement, for: spriteObject)
        case .NUMBER:
            return interpretDouble(formulaElement, for: spriteObject)
        case .SENSOR:
            return interpretSensor(formulaElement, for: spriteObject)
        case .USER_VARIABLE:
            return interpretVariable(formulaElement, for: spriteObject)
        case .USER_LIST:
            return interpretList(formulaElement, for: spriteObject)
        case .BRACKET:
            return self.interpretRecursive(formulaElement: formulaElement.rightChild, for: spriteObject)
        case .STRING:
            return formulaElement.value as AnyObject
        }
    }
    
    private func interpretDouble(_ formulaElement: FormulaElement, for spriteObject: SpriteObject) -> AnyObject {
        return Double(formulaElement.value) as AnyObject
    }
    
    private func interpretOperator(_ formulaElement: FormulaElement, for spriteObject: SpriteObject) -> AnyObject {
        if formulaElement.leftChild != nil {
            return interpretBinaryOperator(formulaElement: formulaElement, spriteObject: spriteObject) as AnyObject
        }
        return interpretUnaryOperator(formulaElement: formulaElement, spriteObject: spriteObject) as AnyObject
    }
    
    private func interpretUnaryOperator(formulaElement: FormulaElement, spriteObject: SpriteObject) -> Double {
        let op = Operators.getOperatorByValue(formulaElement.value)
        
        let right = interpretRecursive(formulaElement: formulaElement.rightChild, for: spriteObject)
        let rightDouble = doubleParameter(object: right)
        
        switch (op) {
        case .MINUS:
            return rightDouble * -1
        case .LOGICAL_NOT:
            return boolResult(value: rightDouble == 0.0)
        default:
            return Double(0)
        }
    }
    
    private func interpretBinaryOperator(formulaElement: FormulaElement, spriteObject: SpriteObject) -> Double {
        let op = Operators.getOperatorByValue(formulaElement.value)
        
        let left = interpretRecursive(formulaElement: formulaElement.leftChild, for: spriteObject)
        let right = interpretRecursive(formulaElement: formulaElement.rightChild, for: spriteObject)
        let leftDouble = doubleParameter(object: left)
        let rightDouble = doubleParameter(object: right)
        
        switch (op) {
        case .LOGICAL_AND:
            return boolResult(value: leftDouble * rightDouble != 0.0)
        case .LOGICAL_OR:
            return boolResult(value: leftDouble != 0.0 || rightDouble != 0.0)
        case .SMALLER_OR_EQUAL:
            return boolResult(value: leftDouble <= rightDouble)
        case .GREATER_OR_EQUAL:
            return boolResult(value: leftDouble >= rightDouble)
        case .SMALLER_THAN:
            return boolResult(value: leftDouble < rightDouble)
        case .GREATER_THAN:
            return boolResult(value: leftDouble > rightDouble)
        case .PLUS:
            return leftDouble + rightDouble
        case .MINUS:
            return leftDouble - rightDouble
        case .MULT:
            return leftDouble * rightDouble
        case .DIVIDE:
            return leftDouble / rightDouble
        case .EQUAL:
            if let leftString = left as? String, let rightString = right as? String {
                return boolResult(value: leftString == rightString)
            }
            if let leftInt = left as? Int, let rightInt = right as? Int {
                return boolResult(value: leftInt == rightInt)
            }
            if let leftDouble = left as? Double, let rightDouble = right as? Double {
                return boolResult(value: leftDouble == rightDouble)
            }
            return boolResult(value: leftDouble == rightDouble)
        case .NOT_EQUAL:
            if let leftString = left as? String, let rightString = right as? String {
                return boolResult(value: leftString != rightString)
            }
            if let leftInt = left as? Int, let rightInt = right as? Int {
                return boolResult(value: leftInt != rightInt)
            }
            if let leftDouble = left as? Double, let rightDouble = right as? Double {
                return boolResult(value: leftDouble != rightDouble)
            }
            return boolResult(value: leftDouble != rightDouble)
        default:
            return Double(0)
        }
    }
    
    private func boolResult(value: Bool) -> Double {
        return Double(value ? 1.0 : 0.0)
    }
    
    private func interpretVariable(_ formulaElement: FormulaElement, for spriteObject: SpriteObject) -> AnyObject {
        guard let program = spriteObject.program,
              let variable = program.variables.getUserVariableNamed(formulaElement.value, for: spriteObject),
              let value = variable.value else { return 0 as AnyObject }
        
        return value as AnyObject
    }
    
    private func interpretList(_ formulaElement: FormulaElement, for spriteObject: SpriteObject) -> AnyObject {
        guard let program = spriteObject.program,
              let list = program.variables.getUserListNamed(formulaElement.value, for: spriteObject),
              let value = list.value,
              let listElements = value as? [Any] else { return 0 as AnyObject }
        
        var stringElements = [String]()
        
        for listElement in listElements {
            if let stringElem = listElement as? String {
                stringElements.append(stringElem)
            } else if let intElem = listElement as? Int {
                stringElements.append(String(intElem))
            } else if let doubleElem = listElement as? Double {
                stringElements.append(String(doubleElem))
            }
        }
        
        return stringElements.joined(separator: " ") as AnyObject
    }
    
    private func interpretSensor(_ formulaElement: FormulaElement, for spriteObject: SpriteObject) -> AnyObject {
        return sensorManager.value(tag: formulaElement.value, spriteObject: spriteObject)
    }
    
    private func interpretFunction(_ formulaElement: FormulaElement, for spriteObject: SpriteObject) -> AnyObject {
        let leftParam = functionParameter(formulaElement: formulaElement.leftChild, spriteObject: spriteObject)
        let rightParam = functionParameter(formulaElement: formulaElement.rightChild, spriteObject: spriteObject)
        
        return functionManager.value(tag: formulaElement.value, firstParameter: leftParam, secondParameter: rightParam)
    }
    
    private func functionParameter(formulaElement: FormulaElement?, spriteObject: SpriteObject) -> AnyObject? {
        guard let formulaElement = formulaElement else { return nil }
        
        if formulaElement.type == .USER_LIST {
            return spriteObject.program.variables.getUserListNamed(formulaElement.value, for: spriteObject)
        }
        
        return interpretRecursive(formulaElement: formulaElement, for: spriteObject)
    }
    
    private func doubleParameter(object: AnyObject) -> Double {
        if let double = object as? Double {
            return double
        } else if let int = object as? Int {
            return Double(int)
        } else if let string = object as? String {
            guard let double = Double(string) else { return 0 }
            return double
        }
        return 0
    }
}
