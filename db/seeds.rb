# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding database..."

# Create sample messages
messages = [
  "Hello from Railway! 🚀",
  "Database connection is working perfectly! ✅",
  "This is a test message from PostgreSQL 🐘"
]

messages.each do |content|
  Message.find_or_create_by!(content: content)
  puts "Created message: #{content}"
end

puts "Seeding completed! Created #{Message.count} messages."
