//
//  HomeView.swift
//  Nugget
//
//  Created by lemin on 9/9/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct HomeView: View {
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    
    @State var showRevertPage = false
    @State var showPairingFileImporter = false
    @State var showErrorAlert = false
    @State var lastError: String?
    @State var path = NavigationPath()
    
    // Prefs
    @AppStorage("AutoReboot") var autoReboot: Bool = true
    @AppStorage("PairingFile") var pairingFile: String?
    @AppStorage("SkipSetup") var skipSetup: Bool = true
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                // MARK: Tweak Options
                Section {
                    VStack {
                        // apply all tweaks button
                        HStack {
                            Rectangle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 330, height: 48)
                                .mask { RoundedRectangle(cornerRadius: 12, style: .continuous) }
                                .overlay {
                                    HStack {
                                        Image(systemName: "plus")
                                            .foregroundStyle(.blue)
                                        Button("Apply") {
                                            applyChanges(reverting: false)
                                        }
                                    }
                                }
                        }
                        // remove all tweaks button
                        HStack {
                            Rectangle()
                                .fill(Color.red.opacity(0.1))
                                .frame(width: 330, height: 48)
                                .mask { RoundedRectangle(cornerRadius: 12, style: .continuous) }
                                .overlay {
                                    HStack {
                                        Image(systemName: "xmark")
                                            .foregroundStyle(.red)
                                        Button("Remove") {
                                            showRevertPage.toggle()
                                        }
                                        .foregroundStyle(.red)
                                    }
                                }
                        }
                        // select pairing file button
                        if !ApplyHandler.shared.trollstore {
                                if pairingFile == nil {
                                HStack {
                                    Rectangle()
                                        .fill(Color.green.opacity(0.1))
                                        .frame(width: 330, height: 48)
                                        .mask { RoundedRectangle(cornerRadius: 12, style: .continuous) }
                                        .overlay {
                                            HStack {
                                                Image(systemName: "document.fill")
                                                    .foregroundStyle(.green)
                                                Button("Select Pairing File") {
                                                    showPairingFileImporter.toggle()
                                                }
                                                .foregroundStyle(.green)
                                            }
                                        }
                                }
                            } else {
                                Button("Reset pairing file") {
                                    pairingFile = nil
                                }
                                .buttonStyle(TintedButton(color: .green, fullwidth: true))
                            }
                        }
                    }
                    .padding(16)
                    .listRowInsets(EdgeInsets())
                } header: {
                    Label("Tweak Options", systemImage: "wrench.and.screwdriver.fill")
                }
                Section {
                    // auto reboot option
                    HStack {
                        Toggle(isOn: $autoReboot) {
                            HStack {
                                Image(systemName: "power")
                                Text("Reboot when Applied")
                                    .minimumScaleFactor(0.5)
                            }
                        }
                    }
                    // skip setup
                    Toggle(isOn: $skipSetup) {
                        HStack {
                            HStack {
                                Image(systemName: "restart.circle")
                                Text("Traditional Skip Setup")
                                    .minimumScaleFactor(0.5)
                            }
                        }
                    }
                }  header: {
                    Label("Application Tools", systemImage: "plus.diamond.fill")
                }  footer: {
                    Text("If you use configuration profiles, it is recommended to turn off **Traditional Skip Setup**. This will not be applied if you are only applying SparseRestore-based tweaks.")
                }
                .listStyle(InsetGroupedListStyle())
                .listRowInsets(EdgeInsets())
                .padding()
                .fileImporter(isPresented: $showPairingFileImporter, allowedContentTypes: [UTType(filenameExtension: "mobiledevicepairing", conformingTo: .data)!, UTType(filenameExtension: "mobiledevicepair", conformingTo: .data)!], onCompletion: { result in
                                switch result {
                                case .success(let url):
                                    do {
                                        pairingFile = try String(contentsOf: url)
                                        startMinimuxer()
                                    } catch {
                                        lastError = error.localizedDescription
                                        showErrorAlert.toggle()
                                    }
                                case .failure(let error):
                                    lastError = error.localizedDescription
                                    showErrorAlert.toggle()
                                }
                            })
                            .alert("Error", isPresented: $showErrorAlert) {
                                Button("OK") {}
                            } message: {
                                Text(lastError ?? "???")
                            }
                
            }
            .onOpenURL(perform: { url in
                // for opening the mobiledevicepairing file
                if url.pathExtension.lowercased() == "mobiledevicepairing" {
                    do {
                        pairingFile = try String(contentsOf: url)
                        startMinimuxer()
                    } catch {
                        lastError = error.localizedDescription
                        showErrorAlert.toggle()
                    }
                }
            })
            .onAppear {
                _ = start_emotional_damage("127.0.0.1:51820")
                if let altPairingFile = Bundle.main.object(forInfoDictionaryKey: "ALTPairingFile") as? String, altPairingFile.count > 5000, pairingFile == nil {
                    pairingFile = altPairingFile
                } else if pairingFile == nil, FileManager.default.fileExists(atPath: URL.documents.appendingPathComponent("pairingfile.mobiledevicepairing").path) {
                    pairingFile = try? String(contentsOf: URL.documents.appendingPathComponent("pairingfile.mobiledevicepairing"))
                }
                startMinimuxer()
            }
            .navigationTitle("Nugget Revamped")
            .navigationDestination(for: String.self) { view in
                if view == "ApplyChanges" {
                    LogView(resetting: false, autoReboot: autoReboot, skipSetup: skipSetup)
                } else if view == "RevertChanges" {
                    LogView(resetting: true, autoReboot: autoReboot, skipSetup: skipSetup)
                }
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK") {}
            } message: {
                Text(lastError ?? "???")
            }
        }
    }
    
    init() {
        // Fix file picker
        if let fixMethod = class_getInstanceMethod(UIDocumentPickerViewController.self, Selector(("fix_initForOpeningContentTypes:asCopy:"))), let origMethod = class_getInstanceMethod(UIDocumentPickerViewController.self, #selector(UIDocumentPickerViewController.init(forOpeningContentTypes:asCopy:))) {
            method_exchangeImplementations(origMethod, fixMethod)
        }
    }
    
    func applyChanges(reverting: Bool) {
        if ApplyHandler.shared.trollstore || ready() {
            if !reverting && ApplyHandler.shared.allEnabledTweaks().isEmpty {
                // if there are no enabled tweaks then tell the user
                UIApplication.shared.alert(body: "You do not have any tweaks enabled! Go to the tools page to select some.")
            } else if ApplyHandler.shared.isExploitOnly() {
                path.append(reverting ? "RevertChanges" : "ApplyChanges")
            } else if !ApplyHandler.shared.trollstore {
                // if applying non-exploit files, warn about setup
                UIApplication.shared.confirmAlert(title: "Warning!", body: "You are applying non-exploit related files. This will make the setup screen appear. Click Cancel if you do not wish to proceed.\n\nWhen setting up, you MUST click \"Do not transfer apps & data\".\n\nIf you see a screen that says \"iPhone Partially Set Up\", DO NOT tap the big blue button. You must click \"Continue with Partial Setup\".", onOK: {
                    path.append(reverting ? "RevertChanges" : "ApplyChanges")
                }, noCancel: false)
            }
        } else if pairingFile == nil {
            lastError = "Please select your pairing file to continue."
            showErrorAlert.toggle()
        } else {
            lastError = "minimuxer is not ready. Ensure you have WiFi and WireGuard VPN set up."
            showErrorAlert.toggle()
        }
    }
    
    func startMinimuxer() {
        guard pairingFile != nil else {
            return
        }
        target_minimuxer_address()
        do {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].absoluteString
            try start(pairingFile!, documentsDirectory)
        } catch {
            lastError = error.localizedDescription
            showErrorAlert.toggle()
        }
    }
    
    public func withArrayOfCStrings<R>(
        _ args: [String],
        _ body: ([UnsafeMutablePointer<CChar>?]) -> R
    ) -> R {
        var cStrings = args.map { strdup($0) }
        cStrings.append(nil)
        defer {
            cStrings.forEach { free($0) }
        }
        return body(cStrings)
    }
}
