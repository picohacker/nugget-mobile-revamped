//
//  CreditsView.swift
//  Nugget
//
//  Created by lunginspector on 3/7/25.
//

import SwiftUI

struct CreditsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Spacer()
                        VStack {
                            Text("Nugget Revamped")
                                .font(.system(size: 35, weight: .bold))
                                .lineLimit(1)
                            Text("Originally built by **leminlimez**, improved\nby **lunginspector**")
                                .font(.system(size: 15, weight: .regular))
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                        Spacer()
                    }
                } header: {
                    Text("Version 1.0")
                }
                Section {
                    // app credits
                    LinkCell(imageName: "LeminLimez", url: "https://x.com/leminlimez", title: "leminlimez", contribution: NSLocalizedString("Original Developer", comment: "leminlimez's contribution"), circle: true)
                    LinkCell(imageName: "lunginspector", url: "https://x.com/lunginspector", title: "lunginspector", contribution: NSLocalizedString("Improved Nugget", comment: "lunginspector's contribution"), circle: true)
                    LinkCell(imageName: "khanhduytran", url: "https://github.com/khanhduytran0/SparseBox", title: "khanhduytran0", contribution: "SparseBox", circle: true)
                    LinkCell(imageName: "jjtech", url: "https://github.com/JJTech0130/TrollRestore", title: "JJTech0130", contribution: "SparseRestore", circle: true)
                    LinkCell(imageName: "disfordottie", url: "https://x.com/disfordottie", title: "disfordottie", contribution: "Some Global Flag Features", circle: true)
                    LinkCell(imageName: "f1shy-dev", url: "https://gist.github.com/f1shy-dev/23b4a78dc283edd30ae2b2e6429129b5#file-eligibility-plist", title: "f1shy-dev", contribution: "AI Enabler", circle: true)
                    LinkCell(imageName: "plus.circle.dashed", url: "https://sidestore.io/", title: "SideStore", contribution: "em_proxy and minimuxer", systemImage: true, circle: true)
                    LinkCell(imageName: "cable.connector", url: "https://libimobiledevice.org", title: "libimobiledevice", contribution: "Restore Library", systemImage: true, circle: true)
                } header: {
                    Label("Credits", systemImage: "wrench.and.screwdriver")
                }
            }
        }
    }
}

struct LinkCell: View {
    var imageName: String
    var url: String
    var title: String
    var contribution: String
    var systemImage: Bool = false
    var circle: Bool = false
    
    var body: some View {
        HStack(alignment: .center) {
            Group {
                if systemImage {
                    Image(systemName: imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    if imageName != "" {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
            }
            .cornerRadius(circle ? .infinity : 0)
            .frame(width: 24, height: 24)
            
            VStack {
                HStack {
                    Button(action: {
                        if url != "" {
                            UIApplication.shared.open(URL(string: url)!)
                        }
                    }) {
                        Text(title)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal, 6)
                    Spacer()
                }
                HStack {
                    Text(contribution)
                        .padding(.horizontal, 6)
                        .font(.footnote)
                    Spacer()
                }
            }
        }
        .foregroundColor(.blue)
    }
}

#Preview {
    CreditsView()
}
