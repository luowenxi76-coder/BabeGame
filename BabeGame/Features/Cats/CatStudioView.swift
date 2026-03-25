import PhotosUI
import SwiftUI
import UIKit

struct CatStudioView: View {
    @EnvironmentObject private var store: GameStore
    @Environment(\.dismiss) private var dismiss

    let existingCat: CatProfile?

    @State private var name: String
    @State private var appearance: CatAppearance
    @State private var referenceImageData: Data?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isPresentingCamera = false
    @State private var isGenerating = false
    @State private var statusMessage = "上传照片后可以选择用 AI 提取造型，也可以直接手动调整。"
    @State private var saveErrorMessage: String?

    init(existingCat: CatProfile?) {
        self.existingCat = existingCat
        _name = State(initialValue: existingCat?.name ?? "")
        _appearance = State(initialValue: existingCat?.appearance ?? .starter)
        _referenceImageData = State(initialValue: nil)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                CozySectionTitle(
                    eyebrow: existingCat == nil ? "Creator" : "Editor",
                    title: existingCat == nil ? "创建猫咪档案" : GameText.appearanceWorkshop,
                    subtitle: "首版是轻捏猫系统。AI 负责提取基础参数，最后造型仍然由本地像素组件统一渲染。"
                )

                CozyCard(accent: CozyPalette.peach) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("猫咪名字")
                            .font(.headline)

                        TextField("给它起一个名字", text: $name)
                            .textFieldStyle(.roundedBorder)
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        Text("造型预览")
                            .font(.headline)

                        HStack(alignment: .center, spacing: 20) {
                            PixelCatView(
                                appearance: appearance,
                                outfit: GameContent.outfit(id: existingCat?.wardrobeState.equippedOutfitID),
                                accessory: GameContent.accessory(id: appearance.accessoryID),
                                scale: 9
                            )

                            if let referenceImageData, let uiImage = UIImage(data: referenceImageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 108, height: 108)
                                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            .stroke(CozyPalette.peach.opacity(0.6), lineWidth: 1)
                                    )
                            } else {
                                VStack(spacing: 8) {
                                    Image(systemName: "photo")
                                        .font(.system(size: 28))
                                    Text("还没有参考照片")
                                        .font(.footnote)
                                }
                                .foregroundStyle(CozyPalette.ink.opacity(0.48))
                                .frame(width: 108, height: 108)
                                .background(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .fill(CozyPalette.paper)
                                )
                            }
                        }

                        Text(statusMessage)
                            .font(.footnote)
                            .foregroundStyle(CozyPalette.ink.opacity(0.68))
                    }
                }

                CozyCard(accent: CozyPalette.mint) {
                    Text("参考照片")
                        .font(.headline)

                    HStack(spacing: 12) {
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            Label("从相册选图", systemImage: "photo.on.rectangle")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(CozyPrimaryButtonStyle(accent: CozyPalette.mint))

                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            Button {
                                isPresentingCamera = true
                            } label: {
                                Label("拍照", systemImage: "camera.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(CozyPrimaryButtonStyle(accent: CozyPalette.butter))
                        }
                    }

                    Button {
                        Task {
                            await generateAppearanceFromPhoto()
                        }
                    } label: {
                        HStack {
                            if isGenerating {
                                ProgressView()
                                    .progressViewStyle(.circular)
                            }
                            Text(isGenerating ? "正在提取猫咪参数..." : "根据照片生成造型")
                        }
                    }
                    .buttonStyle(CozyPrimaryButtonStyle(accent: CozyPalette.peach))
                    .disabled(referenceImageData == nil || isGenerating)

                    Text(store.hasConfiguredAPIKey
                         ? "当前已配置开发版 AI Key。只有点击“根据照片生成造型”时才会上传图片。"
                         : "当前还没配置 AI Key。你仍然可以跳过生成，直接手动捏猫。")
                        .font(.footnote)
                        .foregroundStyle(CozyPalette.ink.opacity(0.68))
                }

                CozyCard(accent: CozyPalette.berry) {
                    Text("轻捏猫")
                        .font(.headline)

                    presetPicker("毛色主色", selection: $appearance.primaryFur)
                    presetPicker("毛色辅色", selection: $appearance.secondaryFur)
                    presetPicker("花纹", selection: $appearance.pattern)
                    presetPicker("脸部花纹", selection: $appearance.facePattern)
                    presetPicker("眼睛", selection: $appearance.eyeColor)
                    presetPicker("耳朵", selection: $appearance.earShape)
                    presetPicker("体型", selection: $appearance.bodyType)
                    presetPicker("尾巴", selection: $appearance.tailShape)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("配饰位")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(CozyPalette.ink.opacity(0.76))

                        Picker("配饰位", selection: Binding<String>(
                            get: { appearance.accessoryID ?? "none" },
                            set: { appearance.accessoryID = $0 == "none" ? nil : $0 }
                        )) {
                            Text("不佩戴").tag("none")
                            ForEach(GameContent.accessories) { accessory in
                                Text(accessory.title).tag(accessory.id)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }

                if let saveErrorMessage {
                    CozyCard(accent: CozyPalette.berry) {
                        Text(saveErrorMessage)
                            .font(.footnote)
                            .foregroundStyle(Color.red.opacity(0.82))
                    }
                }

                Button(existingCat == nil ? "保存猫咪档案" : "保存新造型") {
                    saveCat()
                }
                .buttonStyle(CozyPrimaryButtonStyle(accent: CozyPalette.mint))
            }
            .padding(20)
        }
        .background(CozyBackground())
        .navigationTitle(existingCat == nil ? GameText.createCat : GameText.appearanceWorkshop)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("关闭") {
                    dismiss()
                }
            }
        }
        .task(id: selectedPhotoItem) {
            guard let selectedPhotoItem else { return }
            await loadPhoto(selection: selectedPhotoItem)
        }
        .task {
            guard referenceImageData == nil,
                  let existingFilename = existingCat?.referencePhotoFilename else { return }
            referenceImageData = store.loadReferencePhotoData(named: existingFilename)
        }
        .sheet(isPresented: $isPresentingCamera) {
            CameraPickerView(imageData: $referenceImageData)
        }
    }

    @ViewBuilder
    private func presetPicker<Value: CaseIterable & Identifiable & Hashable>(_ label: String, selection: Binding<Value>) -> some View where Value.AllCases: RandomAccessCollection, Value: CustomStringConvertible {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(CozyPalette.ink.opacity(0.76))

            Picker(label, selection: selection) {
                ForEach(Array(Value.allCases)) { option in
                    Text(option.description).tag(option)
                }
            }
            .pickerStyle(.menu)
        }
    }

    private func loadPhoto(selection: PhotosPickerItem) async {
        do {
            referenceImageData = try await PhotoPickerService.loadImageData(from: selection)
            statusMessage = "参考照片已准备好。只有点击生成时才会上传给 AI。"
        } catch {
            statusMessage = "照片读取失败，仍然可以继续手动捏猫。"
        }
    }

    private func generateAppearanceFromPhoto() async {
        guard let referenceImageData else { return }
        isGenerating = true
        defer { isGenerating = false }

        do {
            let seed = try await store.generateAppearanceSeed(from: referenceImageData)
            appearance = CatAppearance(seed: seed, accessoryID: appearance.accessoryID ?? "bell-collar")
            statusMessage = "AI 已根据照片生成初始造型，你还可以继续微调。"
        } catch {
            statusMessage = "\(error.localizedDescription) 现在已经自动切回纯手动模式。"
        }
    }

    private func saveCat() {
        saveErrorMessage = nil
        do {
            if existingCat == nil {
                try store.createCat(name: name, appearance: appearance, referencePhotoData: referenceImageData)
            } else {
                try store.updateCurrentCat(name: name, appearance: appearance, newReferencePhotoData: referenceImageData)
            }
            dismiss()
        } catch {
            saveErrorMessage = "保存失败：\(error.localizedDescription)"
        }
    }
}

extension FurColorPreset: CustomStringConvertible {
    var description: String { title }
}

extension CatPatternPreset: CustomStringConvertible {
    var description: String { title }
}

extension FacePatternPreset: CustomStringConvertible {
    var description: String { title }
}

extension EyeColorPreset: CustomStringConvertible {
    var description: String { title }
}

extension EarShapePreset: CustomStringConvertible {
    var description: String { title }
}

extension BodyTypePreset: CustomStringConvertible {
    var description: String { title }
}

extension TailShapePreset: CustomStringConvertible {
    var description: String { title }
}
