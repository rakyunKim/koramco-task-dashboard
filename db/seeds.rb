# Skip if data already exists
if Member.any?
  puts "Data already exists. Skipping seed. Run `rails db:seed:replant` to force reseed."
  return
end

current_monday = Date.current.beginning_of_week(:monday)
last_monday = current_monday - 7.days
two_weeks_ago = current_monday - 14.days

# Members
members = %w[이건우 이희수 서지우 김락윤].map do |name|
  Member.create!(name: name)
end

# WIG
wig = Wig.create!(
  title: "Q1 매출 목표 달성",
  description: "1분기 매출 15억 달성을 위한 핵심 활동 추진",
  target_value: 15,
  deadline: Date.new(2026, 3, 31),
  active: true
)

# --- 2주 전 선행지표 + 작업 (import 테스트용) ---
lm_old1 = LeadMeasure.create!(
  wig: wig, title: "신규 고객 미팅 5건", weekly_target: 5, week_start_date: two_weeks_ago
)
Task.create!(lead_measure: lm_old1, member: members[0], title: "A사 미팅 준비", week_start_date: two_weeks_ago, completed: false)
Task.create!(lead_measure: lm_old1, member: members[1], title: "B사 미팅 일정 확인", week_start_date: two_weeks_ago, completed: false)

lm_old2 = LeadMeasure.create!(
  wig: wig, title: "기존 고객 리텐션 콜 10건", weekly_target: 10, week_start_date: two_weeks_ago
)
Task.create!(lead_measure: lm_old2, member: members[2], title: "C사 팔로업 전화", week_start_date: two_weeks_ago, completed: false)
Task.create!(lead_measure: lm_old2, member: members[3], title: "D사 계약 갱신 확인", week_start_date: two_weeks_ago, completed: false)

# --- 지난주 선행지표 + 작업 (import 테스트용) ---
lm_last1 = LeadMeasure.create!(
  wig: wig, title: "제안서 발송 3건", weekly_target: 3, week_start_date: last_monday
)
Task.create!(lead_measure: lm_last1, member: members[0], title: "E사 제안서 작성", week_start_date: last_monday, completed: false)
Task.create!(lead_measure: lm_last1, member: members[1], title: "F사 견적서 발송", week_start_date: last_monday, completed: false)
Task.create!(lead_measure: lm_last1, member: members[3], title: "G사 RFP 대응", week_start_date: last_monday, completed: false)

# --- 이번 주 선행지표 + 작업 ---
lm1 = LeadMeasure.create!(
  wig: wig, title: "핵심 고객 미팅 4건", weekly_target: 4, week_start_date: current_monday
)
Task.create!(lead_measure: lm1, member: members[0], title: "H사 미팅 참석", week_start_date: current_monday, completed: false)
Task.create!(lead_measure: lm1, member: members[2], title: "I사 데모 준비", week_start_date: current_monday, completed: false)

lm2 = LeadMeasure.create!(
  wig: wig, title: "마케팅 콘텐츠 발행 2건", weekly_target: 2, week_start_date: current_monday
)
Task.create!(lead_measure: lm2, member: members[3], title: "블로그 포스트 작성", week_start_date: current_monday, completed: false)
Task.create!(lead_measure: lm2, member: members[1], title: "뉴스레터 발송", week_start_date: current_monday, completed: false)

# Recalculate lead measure values
LeadMeasure.find_each(&:recalculate_current_value!)

puts "Seed complete: #{Member.count} members, #{Wig.count} WIG, #{LeadMeasure.count} lead measures, #{Task.count} tasks"
