import SwiftUI

struct EncyclopediaView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.isDarkMode) private var isDarkMode
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var showFavoritesOnly = false
    
    private var theme: LiquidGlassTheme { isDarkMode ? .dark : .light }
    
    private var filteredPeptides: [Peptide] {
        var result = store.peptides
        
        if showFavoritesOnly {
            result = result.filter { store.isFavorite($0) }
        }
        
        if selectedCategory != "All" {
            result = result.filter { $0.category == selectedCategory }
        }
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.category.localizedCaseInsensitiveContains(searchText) ||
                $0.mechanism.localizedCaseInsensitiveContains(searchText)
            }
        }
        return result
    }
    
    private var categories: [String] {
        ["All"] + store.uniqueCategories
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Encyclopedia")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(theme.text)
                            Text("\(store.peptides.count) peptides")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(theme.textMuted)
                        }
                        Spacer()
                        
                        // Favorites toggle
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                showFavoritesOnly.toggle()
                                Haptics.selection()
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(showFavoritesOnly ? theme.primary.opacity(0.15) : Color.white.opacity(isDarkMode ? 0.06 : 0.5))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(showFavoritesOnly ? theme.primary.opacity(0.4) : theme.glassBorder, lineWidth: 1)
                                    }
                                    .frame(width: 44, height: 44)
                                Image(systemName: showFavoritesOnly ? "heart.fill" : "heart")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(showFavoritesOnly ? theme.primary : theme.textMuted)
                            }
                            .shadow(color: showFavoritesOnly ? theme.primary.opacity(0.2) : .clear, radius: 8)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Search
                    GlassSearchBar(text: $searchText)
                    
                    // Category filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(categories, id: \.self) { cat in
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedCategory = cat
                                        Haptics.selection()
                                    }
                                } label: {
                                    GlassPill(text: cat, color: cat == "All" ? theme.primary : CategoryColors.color(for: cat), isSelected: selectedCategory == cat)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    // Results count + favorites count
                    HStack {
                        Text("\(filteredPeptides.count) results")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(theme.textMuted)
                        Spacer()
                        if !store.favoritePeptideNames.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(theme.primary)
                                Text("\(store.favoritePeptideNames.count)")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(theme.primary)
                            }
                        }
                    }
                    
                    // Peptide list
                    LazyVStack(spacing: 10) {
                        ForEach(filteredPeptides) { peptide in
                            NavigationLink(destination: PeptideDetailView(peptide: peptide)) {
                                peptideRow(peptide)
                            }
                            .buttonStyle(.plain)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button {
                                    store.toggleFavorite(peptide)
                                } label: {
                                    Label(
                                        store.isFavorite(peptide) ? "Unfavorite" : "Favorite",
                                        systemImage: store.isFavorite(peptide) ? "heart.slash.fill" : "heart.fill"
                                    )
                                }
                                .tint(theme.primary)
                            }
                            .contextMenu {
                                Button {
                                    store.toggleFavorite(peptide)
                                } label: {
                                    Label(
                                        store.isFavorite(peptide) ? "Remove from Favorites" : "Add to Favorites",
                                        systemImage: store.isFavorite(peptide) ? "heart.slash" : "heart"
                                    )
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .background(theme.background.ignoresSafeArea())
        }
    }
    
    private func peptideRow(_ peptide: Peptide) -> some View {
        GlassCard(padding: 14) {
            HStack(spacing: 14) {
                // Category icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(CategoryColors.color(for: peptide.category).opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: CategoryColors.icon(for: peptide.category))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(CategoryColors.color(for: peptide.category))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(peptide.name)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(theme.text)
                            .lineLimit(1)
                        
                        // Favorite indicator
                        if store.isFavorite(peptide) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(theme.primary)
                        }
                    }
                    
                    Text(peptide.mechanism.components(separatedBy: ";").first ?? peptide.mechanism)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(theme.textMuted)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        // Category pill
                        Text(peptide.category)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(CategoryColors.color(for: peptide.category))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background {
                                Capsule().fill(CategoryColors.color(for: peptide.category).opacity(0.12))
                            }
                        
                        // Status
                        Text(peptide.clinicalStatus)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color(hex: peptide.statusColor))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background {
                                Capsule().fill(Color(hex: peptide.statusColor).opacity(0.12))
                            }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(theme.textMuted)
            }
        }
    }
}
