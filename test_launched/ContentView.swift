//
//  ContentView.swift
//  test_launched
//
//  Created by Alexandra Brovko on 25/07/2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VendorsView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct VendorsView: View {
    
    @StateObject var viewModel = VendorsViewModel()
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .trailing) {
                TextField("Search...", text: $viewModel.searchText)
                    .padding(.horizontal, 8) // Padding between image and text field
                    .padding(.vertical, 10)
                    .background(.white)
                    .cornerRadius(18)
                    .font(.custom("OpenSans-Light", size: 16))
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                
                Image(uiImage: UIImage(named: "search")!)
                    .foregroundColor(Color(.systemBlue))
                    .padding(.trailing, 8)
            }
            .padding(.horizontal, 15)
            
            if viewModel.searchText.count >= 3 && viewModel.filteredVendors.isEmpty {
                    EmptyView()
                } else  {
                    List(viewModel.filteredVendors.isEmpty ? viewModel.vendors : viewModel.filteredVendors) { vendor in
                            VStack(alignment: .leading) {
                                AsyncImage(url: URL(string: vendor.coverPhoto!.mediaURL)) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .aspectRatio(1.8, contentMode: .fill)
                                .cornerRadius(12)
                                .overlay(favoriteView(for: vendor))
                                .overlay(areaServedView(for: vendor))
                                Text(vendor.companyName)
                                    .font(.custom("OpenSans-SemiBold", size: 16))
                                HStack {
                                    ForEach(vendor.categories) { category in
                                        AsyncImage(url: URL(string: category.imageUrl)){ image in
                                            image.resizable()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        CategoryView(category: category)
                                    }
                                }
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(vendor.tags) { tag in
                                            TagView(tag: tag)
                                        }
                                    }
                                }
                            }
                            .listRowSeparator(.hidden)
                }
        
            }
        }
    }
    
    private func favoriteView(for item: Vendor) -> some View {
        Image(item.favorited ? "active" : "inactive")
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }
    
    private func areaServedView(for item: Vendor) -> some View {
            Text(item.areaServed)
                .foregroundColor(.black)
                .font(.custom("OpenSans-Light", size: 14))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.white)
                .cornerRadius(20)
                .padding(8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
}

struct CategoryView: View {
    let category: Category
    
    var body: some View {
        VStack {
            Text(category.name)
                .font(.custom("OpenSans-Light", size: 14))
        }
    }
}

struct TagView: View {
    let tag: Tag
    
    var body: some View {
        Text("・ \(tag.name)")
            .padding(0)
            .font(.custom("OpenSans-Light", size: 14))
    }
}

struct EmptyView: View {
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Sorry! No results found...")
                .font(.custom("OpenSans-SemiBold", size: 24))
                .foregroundColor(.green)
                .multilineTextAlignment(.center)
            Text("Please try a different search request or browse businesses from the list")
                .font(.custom("OpenSans-Light", size: 16))
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

import Combine

final class VendorsViewModel: ObservableObject {
    @Published var vendors: [Vendor] = []
    @Published var filteredVendors: [Vendor] = []
    @Published var count = 1
    @Published var searchText = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadMockData()
        
        $searchText
            .receive(on: RunLoop.main)
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] text in
                guard let self else { return }
                
                if text.count >= 3 {
                    self.filteredVendors = self.vendors.filter { $0.companyName.localizedCaseInsensitiveContains(text) }
                } else {
                    self.filteredVendors = []
                }
            }
            .store(in: &cancellables)
    }
    
    func loadMockData() {
        guard let url = Bundle.main.url(forResource: "vendors", withExtension: "json"),
              let data = try? Data(contentsOf: url, options: .mappedIfSafe) else {
            return
        }

        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(VendorsResponse.self, from: data)
            vendors = response.vendors
            return
        } catch {
            print("Error decoding JSON: \(error)")
            return
        }
    }
}

