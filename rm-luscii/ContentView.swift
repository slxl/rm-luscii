//
//  ContentView.swift
//  rm-luscii
//
//  Created by Slava Khlichkin on 19/06/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        EpisodeListView(viewModel: EpisodeListViewModel())
    }
}

#Preview {
    ContentView()
}
