import SwiftUI

struct HomeRoomView: View {
    @EnvironmentObject private var store: GameStore

    var body: some View {
        ZStack {
            CozyBackground()

            if let cat = store.currentCat {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        header(for: cat)
                        roomSceneCard(for: cat)
                        interactionCard(for: cat)
                        taskCard(for: cat)
                        travelCard(for: cat)
                        quickLinks

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
            } else {
                NavigationLink("先创建猫咪档案", destination: CatProfilesView())
                    .buttonStyle(CozyPrimaryButtonStyle(accent: CozyPalette.mint))
                    .padding(20)
            }
        }
        .navigationTitle(GameText.homeTab)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    CatProfilesView()
                } label: {
                    Image(systemName: "cat.fill")
                }
            }
        }
        .onAppear {
            store.refreshTripStates()
        }
    }

    private func header(for cat: CatProfile) -> some View {
        HStack(alignment: .top) {
            CozySectionTitle(
                eyebrow: "Home",
                title: "\(cat.name) 的房间",
                subtitle: cat.lastInteractionMessage
            )

            Spacer(minLength: 16)
            CurrencyBadge(coins: store.saveState.coins)
        }
    }

    private func roomSceneCard(for cat: CatProfile) -> some View {
        CozyCard(accent: CozyPalette.accent(for: accentKey(for: cat.homeState.wallpaper))) {
            Text("3D 主房间")
                .font(.headline)
                .foregroundStyle(CozyPalette.ink)

            InteractiveHomeScene3DView(cat: cat) { target in
                switch target {
                case .cat:
                    store.petCurrentCat()
                case .bowl:
                    store.feedCurrentCat()
                case .toy:
                    store.playWithCurrentCat()
                }
            }
            .frame(height: 340)

            HStack(spacing: 8) {
                TagPill(label: cat.mood.title, accent: CozyPalette.peach)
                TagPill(label: "亲密度 \(cat.intimacy)", accent: CozyPalette.butter)
                if cat.tripState.status == .traveling {
                    TagPill(label: "旅行中", accent: CozyPalette.mint)
                } else if cat.tripState.status == .readyToClaim {
                    TagPill(label: "已归来", accent: CozyPalette.berry)
                }
            }

            Text("直接点 3D 场景里的猫咪、饭盆和毛线球就能互动。下面的按钮只是快捷入口。")
                .font(.footnote)
                .foregroundStyle(CozyPalette.ink.opacity(0.66))
        }
    }

    private func interactionCard(for cat: CatProfile) -> some View {
        CozyCard(accent: CozyPalette.mint) {
            Text("快捷互动")
                .font(.headline)

            HStack(spacing: 12) {
                Button {
                    store.petCurrentCat()
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: "hand.tap.fill")
                        Text("摸摸")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(CozyPrimaryButtonStyle(accent: CozyPalette.peach))

                Button {
                    store.feedCurrentCat()
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: "cup.and.saucer.fill")
                        Text(store.currentCatFeedCooldown > 0 ? store.currentCatFeedCooldown.cooldownText : "喂食")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(CozyPrimaryButtonStyle(accent: CozyPalette.butter))

                Button {
                    store.playWithCurrentCat()
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: "balloon.2.fill")
                        Text(store.currentCatPlayCooldown > 0 ? store.currentCatPlayCooldown.cooldownText : "玩耍")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(CozyPrimaryButtonStyle(accent: CozyPalette.mint))
            }

            Text("摸摸、喂食和玩耍都会给金币与亲密度。喂食和玩耍带有简单冷却，避免第一版被无限刷。")
                .font(.footnote)
                .foregroundStyle(CozyPalette.ink.opacity(0.66))
        }
    }

    private func taskCard(for cat: CatProfile) -> some View {
        CozyCard(accent: CozyPalette.butter) {
            Text("今日小任务")
                .font(.headline)

            TaskRow(label: "摸摸 1 次", isDone: cat.dailyTasks.pettedToday)
            TaskRow(label: "喂食 1 次", isDone: cat.dailyTasks.fedToday)
            TaskRow(label: "开始或领取 1 次旅行", isDone: cat.dailyTasks.traveledToday)

            Text("完成 \(cat.dailyTasks.completedCount) / 3")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(CozyPalette.ink.opacity(0.72))
        }
    }

    private func travelCard(for cat: CatProfile) -> some View {
        CozyCard(accent: CozyPalette.berry) {
            Text("旅行角落")
                .font(.headline)

            switch cat.tripState.status {
            case .idle:
                Text("准备好后可以带它去外面转一圈。旅程结束会带回金币、收藏品和照片卡。")
                    .font(.subheadline)
                    .foregroundStyle(CozyPalette.ink.opacity(0.68))

                NavigationLink {
                    TripPlannerView()
                } label: {
                    Text(GameText.tripPlanner)
                }
                .buttonStyle(CozyPrimaryButtonStyle(accent: CozyPalette.berry))

            case .traveling:
                if let plan = cat.tripState.currentPlan {
                    LabelValueRow(label: "目的地", value: GameContent.destination(id: plan.destinationID)?.title ?? "旅行地")
                    LabelValueRow(label: "时长", value: "\(plan.durationMinutes) 分钟")
                    LabelValueRow(label: "倒计时", value: countdownString(for: plan))
                }

                Text("这段时间不用盯着它，回来再看会更有惊喜。")
                    .font(.footnote)
                    .foregroundStyle(CozyPalette.ink.opacity(0.66))

            case .readyToClaim:
                Text("它已经回来了，口袋里鼓鼓的。")
                    .font(.subheadline)
                    .foregroundStyle(CozyPalette.ink.opacity(0.68))

                NavigationLink {
                    TripResultsView()
                } label: {
                    Text(GameText.tripResults)
                }
                .buttonStyle(CozyPrimaryButtonStyle(accent: CozyPalette.peach))
            }
        }
    }

    private var quickLinks: some View {
        CozyCard(accent: CozyPalette.pearl) {
            Text("继续整理小房间")
                .font(.headline)

            NavigationLink {
                WardrobeView()
            } label: {
                Label("换装", systemImage: "tshirt.fill")
            }
            .buttonStyle(CozyPrimaryButtonStyle(accent: CozyPalette.pearl))

            NavigationLink {
                HomeDecorView()
            } label: {
                Label(GameText.decorTitle, systemImage: "sofa.fill")
            }
            .buttonStyle(CozyPrimaryButtonStyle(accent: CozyPalette.mint))

            NavigationLink {
                AlbumView()
            } label: {
                Label("查看图鉴", systemImage: "books.vertical.fill")
            }
            .buttonStyle(CozyPrimaryButtonStyle(accent: CozyPalette.butter))
        }
    }

    private func countdownString(for plan: TripPlan) -> String {
        let remaining = max(0, Int(plan.endsAt.timeIntervalSince(Date())))
        let hours = remaining / 3600
        let minutes = (remaining % 3600) / 60
        let seconds = remaining % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func accentKey(for wallpaper: WallpaperStyle) -> String {
        switch wallpaper {
        case .sunny: "peach"
        case .mint: "mint"
        case .berry: "berry"
        }
    }
}

private struct TaskRow: View {
    let label: String
    let isDone: Bool

    var body: some View {
        HStack {
            Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isDone ? CozyPalette.mint : CozyPalette.ink.opacity(0.28))
            Text(label)
                .foregroundStyle(CozyPalette.ink.opacity(0.76))
            Spacer()
        }
        .font(.subheadline)
    }
}
