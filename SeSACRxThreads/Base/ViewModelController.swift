//
//  ViewModelController.swift
//  SeSACRxThreads
//
//  Created by 원태영 on 4/2/24.
//

protocol ViewModelController: AnyObject {
  associatedtype ViewModelType = ViewModel
  
  var viewModel: ViewModelType { get }
}
