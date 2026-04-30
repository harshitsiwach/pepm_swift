import Foundation

struct DailyTips {
    static let all: [Tip] = [
        Tip(icon: "snowflake", title: "Storage Matters", body: "Most reconstituted peptides should be stored at 2-8°C (refrigerator). Never freeze reconstituted peptides.", color: "0984E3"),
        Tip(icon: "syringe.fill", title: "Injection Technique", body: "Pinch the skin, insert needle at 45° angle for subcutaneous injections. Rotate sites to prevent tissue buildup.", color: "FF2D55"),
        Tip(icon: "drop.fill", title: "Reconstitution Tips", body: "Use bacteriostatic water (BAC water) for reconstitution. Gently swirl — never shake — the vial.", color: "00B894"),
        Tip(icon: "clock.fill", title: "Timing is Key", body: "Many GH secretagogues are most effective when taken on an empty stomach, ideally before bed.", color: "6C5CE7"),
        Tip(icon: "shield.checkered", title: "Sterile Practice", body: "Always swab injection sites and vial tops with alcohol. Use a fresh needle for every injection.", color: "E17055"),
        Tip(icon: "scalemass.fill", title: "Start Low", body: "Begin with the lowest effective dose and titrate up. This minimizes side effects and helps gauge tolerance.", color: "FDCB6E"),
        Tip(icon: "figure.run", title: "Synergy with Exercise", body: "Peptides like BPC-157 and TB-500 work best when combined with appropriate physical rehabilitation.", color: "55E6C1"),
        Tip(icon: "moon.fill", title: "Sleep Optimization", body: "GH secretagogues peak during deep sleep. Maintaining good sleep hygiene amplifies their effects.", color: "786FA6"),
        Tip(icon: "heart.fill", title: "Monitor Your Body", body: "Keep a symptom journal alongside your injection log. Track energy, sleep quality, and recovery.", color: "FF6B82"),
        Tip(icon: "cross.case.fill", title: "Consult Professionals", body: "Always discuss peptide protocols with a knowledgeable healthcare provider, especially if on other medications.", color: "C44569"),
        Tip(icon: "thermometer.medium", title: "Temperature Check", body: "Peptide solutions should be at room temperature before injection to minimize injection site discomfort.", color: "F97F51"),
        Tip(icon: "calendar.badge.clock", title: "Consistency Wins", body: "Peptides require consistent dosing schedules. Set reminders and stick to your protocol for best results.", color: "A29BFE"),
        Tip(icon: "bandage.fill", title: "Site Rotation", body: "Alternate injection sites between abdomen, thighs, and upper arms to prevent lipodystrophy.", color: "58B19F"),
        Tip(icon: "flame.fill", title: "Fasting Window", body: "Avoid eating 30-60 minutes before and after GH peptide injections. Food (especially carbs) blunts GH release.", color: "FF6B6B"),
    ]
    
    static var todaysTip: Tip {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return all[dayOfYear % all.count]
    }
    
    struct Tip: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let body: String
        let color: String
    }
}
