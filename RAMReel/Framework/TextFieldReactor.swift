//
//  RAMReel.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/2/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import Foundation
import UIKit

infix operator <&> { precedence 175 }

/** 
    Links text field to data flow

    - parameter left: text field

    - parameter right: DataFlow object

    - returns: TextFieldReactor object
*/
public func <&>
    <
    DS: FlowDataSource,
    DD: FlowDataDestination
    where
    DS.ResultType == DD.DataType,
    DS.QueryType  == String
    >
    (left: UITextField, right: DataFlow<DS, DD>) -> TextFieldReactor<DS, DD>
{
    return TextFieldReactor(textField: left, dataFlow: right)
}

/**
    Implements reactive handling text field editing and passes editing changes to data flow
*/
public class TextFieldReactor
    <
    DS: FlowDataSource,
    DD: FlowDataDestination
    where
    DS.ResultType == DD.DataType,
    DS.QueryType  == String
    >
{    
    let textField : UITextField
    let dataFlow  : DataFlow<DS, DD>
    
    private let editingTarget:TextFieldTarget
    
    private init(textField: UITextField, dataFlow: DataFlow<DS, DD>) {
        self.textField = textField
        self.dataFlow  = dataFlow
        
        self.editingTarget = TextFieldTarget(controlEvents: UIControlEvents.EditingChanged) {
            let _ = $0.text.map {
                dataFlow.transport($0)
            }
        }
        self.editingTarget.beTargetFor(textField)
    }
    
}

final class TextFieldTarget: NSObject {
    
    static let actionSelector = Selector("action:")
    
    let controlEvents: UIControlEvents
    
    typealias HookType = (UITextField) -> Void
    var hook: HookType?
    
    init(controlEvents:UIControlEvents, hook: HookType? = nil) {
        self.controlEvents = controlEvents
        self.hook = hook
        
        super.init()
    }
    
    var textField: UITextField?
    func beTargetFor(textField: UITextField) {
        self.textField = textField
        self.textField?.addTarget(self, action: TextFieldTarget.actionSelector, forControlEvents: controlEvents)
    }
    
    deinit {
        textField?.removeTarget(self, action: TextFieldTarget.actionSelector, forControlEvents: controlEvents)
    }
    
    func action(textField: UITextField) {
        hook?(textField)
    }

}
