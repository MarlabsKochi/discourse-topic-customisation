# name: discourse-topics-customization
# about: customizimg topics for normal user and admin
# version: 1.0.0
# authors: Jijo Thomas(jijo1198), marlabskochi
# url: https://github.com/MarlabsKochi/discourse-topic-customisation.git

register_asset 'javascripts/script.js'
register_asset 'javascripts/initializers/nav-item.js.es6'
gem 'ember-rails', '0.18.2'
gem 'ember-source', '1.12.2', require: false

after_initialize do
  require_dependency File.expand_path('../lib/topic_query.rb', __FILE__)
  require_dependency File.expand_path('../app/controllers/topics_controller.rb', __FILE__)
end



