# name: DiscourseAddToSummary
# about:
# version: 0.1
# authors: pfaffman
# url: https://github.com/pfaffman


register_asset "stylesheets/common/discourse-add-to-summary.scss"

enabled_site_setting :discourse_add_to_summary_enabled

PLUGIN_NAME ||= "DiscourseAddToSummary".freeze

Rails.configuration.paths['app/views'].unshift(Rails.root.join('plugins', 'discourse-add-to-summary', 'app/views'))

if enabled_site_setting
  puts "WE ARE ENABLED!!!!!!#{'-'*50}"
  after_initialize do

    # see lib/plugin/instance.rb for the methods available in this context

    require_dependency 'user_notifications'
    module ::UserNotificationsOverride
      def digest(user, opts = {})
        puts "LOOKING TO MAILER!!!!!!#{'-'*50}"
        @add_to_data = {}
        if SiteSetting.discourse_add_to_summary_enabled
          puts "ADDING TO MAILER!!!!!!#{'-'*50}"
          @add_to_data = {}
          base = Discourse.base_url
          base.gsub!(/localhost/,"localhost:3000") # make this work for development
          before_id=SiteSetting.discourse_add_to_summary_before_header_topic_id
          puts "LOOKING FOR BEFORE POST: #{before_id}"
          btopic=Topic.find(before_id)
          before_post_list = Post.where(topic_id: before_id, post_number: btopic.highest_post_number) unless !btopic
          before_text = ""
          if before_post_list.length > 0
            before_text = before_post_list.first.cooked
          end
          before_text.gsub!(/\/\/localhost/,base)
          @add_to_data[:before_text] = before_text
          @add_to_data[:before_css] = SiteSetting.discourse_add_to_summary_before_header_css
          @add_to_data[:before] = before_text.length>0

          puts "ADD! #{@add_to_data}\n#{'-'*50}"

          after_id=SiteSetting.discourse_add_to_summary_after_header_topic_id
          atopic=Topic.find(after_id)
          after_post_list = Post.where(topic_id: after_id, post_number: atopic.highest_post_number) unless !atopic
          after_text = ""
          if after_post_list.length > 0
            after_text = after_post_list.first.cooked
          end
          after_text.gsub!(/\/\/localhost/,base)
          @add_to_data[:after_text] = after_text
          @add_to_data[:after_css] = SiteSetting.discourse_add_to_summary_after_header_css
          @add_to_data[:after] = after_text.length>0
          puts "LOOKING FOR AFTER POST: #{@add_to_data}"
        end
        super(user, opts)
      end
    end

    class ::UserNotifications
      prepend ::UserNotificationsOverride
    end

    module ::DiscourseAddToSummary
      class Engine < ::Rails::Engine
        engine_name PLUGIN_NAME
        #      isolate_namespace DiscourseAddToSummary
      end
    end


    # require_dependency 'user_notifications'
    # class ::UserNotifications
    #   if SiteSetting.discourse_add_to_summary_enabled
    #     prepend AddToMailerExtension
    #   end
    # end

    require_dependency "application_controller"
    class DiscourseAddToSummary::ActionsController < ::ApplicationController
      requires_plugin PLUGIN_NAME

      before_action :ensure_logged_in

      def list
        render json: success_json
      end
    end

    DiscourseAddToSummary::Engine.routes.draw do
      get "/list" => "actions#list"
    end

    Discourse::Application.routes.append do
      mount ::DiscourseAddToSummary::Engine, at: "/discourse-add-to-summary"
    end
  end
end
