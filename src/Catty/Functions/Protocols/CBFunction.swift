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

protocol CBFunction { // TODO remove CB prefix
    
    // Tag for serialization
    static var tag: String { get }
    
    // Resources required in order to get value of this function (e.g. Aceelerometer)
    static var requiredResource: ResourceType { get }
    
    // Name for formula editor
    static func name() -> String
    
    // Return the section to show sensor in formula editor (FormulaEditorSection) and the position within that section (Int)
    // Use .hidden to not show the sensor at all
    static func formulaEditorSection() -> FormulaEditorSection
}

protocol SingleParameterFunction: CBFunction {
    static func firstParameter() -> FunctionParameter
    
    func value(parameter: AnyObject?) -> AnyObject
}

protocol DoubleParameterFunction: CBFunction {
    static func firstParameter() -> FunctionParameter
    static func secondParameter() -> FunctionParameter
    
    func value(firstParameter: AnyObject?, secondParameter: AnyObject?) -> AnyObject
}
