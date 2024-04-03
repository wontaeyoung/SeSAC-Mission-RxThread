//
//  ShopItem.swift
//  SeSACRxThreads
//
//  Created by 원태영 on 4/2/24.
//

import Foundation

struct ShopItem {
  
  let id: UUID
  var name: String
  var isDone: Bool
  var bookmark: Bool
  
  init(name: String) {
    self.id = UUID()
    self.name = name
    self.isDone = false
    self.bookmark = false
  }
}
