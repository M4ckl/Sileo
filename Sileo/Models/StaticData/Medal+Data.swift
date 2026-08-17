import Foundation

extension Medal {
    static let all: [Medal] = [
        Medal(id: "first_step", name: "First Step", description: "Complete your first 10 minutes", icon: "figure.step.training", requiredMinutes: 10),
        Medal(id: "thinker", name: "Thinker", description: "Accumulate 60 minutes of focus", icon: "brain.head.profile", requiredMinutes: 60),
        Medal(id: "zen_master", name: "Zen Master", description: "Reach 300 minutes total (5 hours)", icon: "mountain.2.fill", requiredMinutes: 300),
        Medal(id: "week_streak", name: "Week Streak", description: "Pause for 7 days in a row", icon: "flame.fill", requiredMinutes: 0),
        Medal(id: "early_bird", name: "Early Bird", description: "Complete a pause between 6 AM and 9 AM", icon: "sunrise.fill", requiredMinutes: 0),
        Medal(id: "night_owl", name: "Night Owl", description: "Complete a pause after 10 PM", icon: "moon.stars.fill", requiredMinutes: 0),
        Medal(id: "supporter", name: "Supporter", description: "Thank you for supporting Sileo.", icon: "heart.fill", requiredMinutes: 0),
        Medal(id: "marathoner", name: "Marathoner", description: "Complete a single 30-minute session", icon: "figure.run", requiredMinutes: 0),
        Medal(id: "guru", name: "Guru", description: "Reach 1000 minutes of total peace", icon: "star.circle.fill", requiredMinutes: 1000),
        Medal(id: "consistent", name: "Consistent", description: "Pause for 3 days in a row", icon: "checkmark.seal.fill", requiredMinutes: 0)
    ]
}
