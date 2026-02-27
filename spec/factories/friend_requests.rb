FactoryBot.define do
  factory :friend_request do
    from
    to

    sequence :status, %i[pending accepted ignored].cycle
  end
end
