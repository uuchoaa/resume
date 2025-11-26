puts "Seeding database..."

puts "Clearing existing records..."
Deal.destroy_all
Recruter.destroy_all
Agency.destroy_all

puts "Creating agencies, recruters, and deals..."
# bin/rails g scaffold Agency name
tech_teems = Agency.create({
  name: '@TechTeams'
})

Agency.create({ name: 'Hirely' })
Agency.create({ name: 'TalentPro' })
Agency.create({ name: 'Staffing Solutions' })
Agency.create({ name: 'RecruitRight' })


camila = Recruter.create({
  agency: tech_teems,
  name: 'Camila Felippo',
  linkedin_chat_url: 'https://www.linkedin.com/messaging/thread/2-YzQ2OWYzOTQtNWI0ZS00MzUxLWFjOGYtNzVkMzNjNWIyNjUwXzEwMA==/'
})

description = <<~DESC
Opportunity @TechTeems - Engineering Manager
Hi!

Hope you’re doing well!
We’re currently hiring for an Engineering Manager, and your background caught our attention.

You can find all the details about the role here: Engineering Manager

If it sounds like a good fit, feel free to apply directly through the link, and we’ll reach out soon with the next steps!

Best regards,

Camila Filippo
Recruiting Manager
DESC

Deal.create({
  agency: tech_teems,
  recruter: camila,
  description: description,
  stage: :open
})

puts "Seeded #{Agency.count} agencies, #{Recruter.count} recruters, and #{Deal.count} deals."
