#
# Helps us find topics.
# Returns a TopicList object containing the topics found.
#

require_dependency 'topic_list'
require_dependency 'suggested_topics_builder'
require_dependency 'topic_query_sql'

class TopicQuery

  def create_list(filter, options={}, topics = nil)
    if @user.admin or filter == :private_messages
      topics ||= default_results(options)
      if ["activity","default"].include?(options[:order] || "activity") && !options[:unordered]
      	topics = prioritize_pinned_topics(topics, options)
      end 
		  else
        topics = send("query_#{filter}").distinct.order(order_topics_by).offset(offset_topic).limit(per_page_setting)
  	end
  	topics = topics.to_a.each do |t|
      t.allowed_user_ids = filter == :private_messages ? t.allowed_users.map{|u| u.id} : []
    end
    options = options.merge(@options)
    list = TopicList.new(filter, @user, topics.to_a, options.merge(@options))
    list.per_page = per_page_setting
    list
  end

  def query_latest
  	cat_id =  @options[:category_id]
  	cat_condition = cat_id ?  " and topics.category_id = #{cat_id}" : ""
		Topic.includes(:posts, :category).joins('left join users on topics.user_id = users.id 
			left join notifications on topics.id = notifications.topic_id')
			.where("(users.id=#{@user.id} or notifications.user_id=#{@user.id}) #{cat_condition}")
	end

	def query_new
		Topic.includes(:posts, :category).joins('left join users on topics.user_id = users.id 
			left join notifications on topics.id = notifications.topic_id')
			.where("(users.id=#{@user.id} or notifications.user_id=#{@user.id}) and topics.created_at >= '#{(Date.today - 2).to_datetime.utc.to_s}'")
	end

	def query_unread
		Topic.includes(:posts, :category).joins("inner join notifications on topics.id = notifications.topic_id")
			.where("(notifications.user_id=#{@user.id} and topics.id not in 
			(select topic_users.topic_id from topic_users inner join notifications on notifications.topic_id = topic_users.topic_id
	    where topic_users.topic_id = notifications.topic_id and topic_users.user_id = #{@user.id}) and notifications.user_id = #{@user.id})")  
	end

	def query_suggested
		query_latest
	end

  def query_top
  	score = "weekly_score"
  	topics = Topic.includes(:posts, :category).joins('left join users on topics.user_id = users.id 
  		left join notifications on topics.id = notifications.topic_id 
  		inner join top_topics on topics.id = top_topics.topic_id')
		  .where("(users.id=#{@user.id} or notifications.user_id=#{@user.id}) and top_topics.#{score} > 0")

      topics.order(TopicQuerySQL.order_top_for(score))
  end

	def order_topics_by
		order = ""
		if @options[:order] == "category"
			order = "categories.name"
		elsif @options[:order] == "views"
			order = "topics.views"
		elsif @options[:order] == "posts"
			order = "posts.reply_count"
		elsif @options[:order] == 'activity'
	    order = "topics.bumped_at"
		end
		@options[:ascending]  ? order + " desc" : order + " asc" unless order.blank?
	end

  protected

    def per_page_setting
      @options[:slow_platform] ? 15 : 30
    end

    def offset_topic
    	@options[:page].to_i * per_page_setting
    end
end
