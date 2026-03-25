import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: GameStore
    @State private var isPresentingProfiles = false
    @State private var isPresentingEditor = false
    @State private var apiKey = ""
    @State private var modelName = "gpt-4.1-mini"

    var body: some View {
        ZStack {
            CozyBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    CozySectionTitle(
                        eyebrow: "Settings",
                        title: GameText.settingsTab,
                        subtitle: "这里集中放猫咪档案切换、本地开发版 AI 配置和原型阶段的说明。"
                    )

                    if let cat = store.currentCat {
                        CozyCard(accent: CozyPalette.peach) {
                            HStack {
                                PixelCatView(
                                    appearance: cat.appearance,
                                    outfit: GameContent.outfit(id: cat.wardrobeState.equippedOutfitID),
                                    accessory: GameContent.accessory(id: cat.activeAccessoryID),
                                    scale: 8
                                )
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(cat.name)
                                        .font(.title3.weight(.bold))
                                    Text("当前使用中的猫咪档案")
                                        .font(.subheadline)
                                        .foregroundStyle(CozyPalette.ink.opacity(0.65))
                                }
                                Spacer()
                            }

                            Button(GameText.manageCats) {
                                isPresentingProfiles = true
                            }
                            .buttonStyle(CozyPrimaryButtonStyle(accent: CozyPalette.mint))

                            Button("重生成 / 调整造型") {
                                isPresentingEditor = true
                            }
                            .buttonStyle(CozyPrimaryButtonStyle(accent: CozyPalette.butter))
                        }
                    }

                    CozyCard(accent: CozyPalette.mint) {
                        Text("开发版 AI 配置")
                            .font(.headline)

                        SecureField("输入 OpenAI API Key", text: $apiKey)
                            .textFieldStyle(.roundedBorder)

                        TextField("模型名", text: $modelName)
                            .textFieldStyle(.roundedBorder)

                        HStack(spacing: 12) {
                            Button("保存 Key") {
                                store.saveOpenAIKey(apiKey)
                                store.updatePreferredAIModel(modelName)
                                apiKey = ""
                            }
                            .buttonStyle(CozyPrimaryButtonStyle(accent: CozyPalette.mint))

                            Button("清除 Key") {
                                store.clearOpenAIKey()
                            }
                            .buttonStyle(CozyPrimaryButtonStyle(accent: CozyPalette.peach))
                        }

                        Text(store.hasConfiguredAPIKey ? "当前设备已保存开发版 API Key。" : "当前设备还没有保存 API Key。")
                            .font(.footnote)
                            .foregroundStyle(CozyPalette.ink.opacity(0.66))

                        if let lastError = store.saveState.developerSettings.lastGenerationError {
                            Text("最近一次生成错误：\(lastError)")
                                .font(.footnote)
                                .foregroundStyle(Color.red.opacity(0.78))
                        }
                    }

                    CozyCard(accent: CozyPalette.berry) {
                        Text("原型说明")
                            .font(.headline)

                        Text("1. 现在的 AI 生成功能仅用于内部开发版直连。")
                        Text("2. 原图只会保存在本地，只有你主动点生成时才会上传。")
                        Text("3. 真正上架前，需要改为后端代理或关闭直连功能。")
                        Text("4. 除 AI 造型生成外，其余系统都支持离线运行。")
                    }

                    if !store.transientNotice.isEmpty {
                        CozyCard(accent: CozyPalette.butter) {
                            Text(store.transientNotice)
                                .font(.footnote)
                                .foregroundStyle(CozyPalette.ink.opacity(0.76))
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle(GameText.settingsTab)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            modelName = store.preferredAIModel
        }
        .sheet(isPresented: $isPresentingProfiles) {
            NavigationStack {
                CatProfilesView()
            }
            .environmentObject(store)
        }
        .sheet(isPresented: $isPresentingEditor) {
            if let currentCat = store.currentCat {
                NavigationStack {
                    CatStudioView(existingCat: currentCat)
                }
                .environmentObject(store)
            }
        }
    }
}
