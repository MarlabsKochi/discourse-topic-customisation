# name: discourse-topics-customization
# about: Uses omniauth-ldap gem for ladp login from local login UI
# version: 1.0.0
# authors: Jijo Thomas(jijo1198), marlabskochi
# url: https://github.com/MarlabsKochi/ldap-dll

after_initialize do
  require_dependency File.expand_path('../lib/topic_query.rb', __FILE__)
  require_dependency File.expand_path('../app/controllers/topics_controller.rb', __FILE__)
end


