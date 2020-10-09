//
//  HomeView.swift
//  Interval WatchKit Extension
//
//  Created by Wes Moore on 10/9/20.
//  Copyright © 2020 Wes Moore. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    
    var counters: [WatchCounter]
    
    @State var complicationCounter: WatchCounter? {
        didSet {
            DataController.main.setComplicationCounter(complicationCounter!)
        }
    }
        
    var body: some View {
        
        VStack {
            
            List(counters) { counter in
                Button(action: { complicationCounter = counter }, label: {
                    HStack {
                        Text(counter.title)
                        
                        if counter == complicationCounter {
                            Text("⌚️")
                        }
                        
                    }
                    
                    
                })
            }
            
        }
        .padding(10)
    }
        
        
    
}

struct HomeView_Previews: PreviewProvider {
    
    static let counters = [WatchCounter(id: UUID(), date: Date(), title: "Counter 1", includeTime: false),
                    WatchCounter(id: UUID(), date: Date(), title: "Counter 2", includeTime: false)]
    
    static var complicationCounter: WatchCounter { return counters[0] }
    
    static var previews: some View {
        Group {
            HomeView(counters: counters, complicationCounter: complicationCounter)
        }
    }
}
