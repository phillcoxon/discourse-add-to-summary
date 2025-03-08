# frozen_string_literal: true

# name: DiscourseAddToSummary
# about:
# version: 0.1
# authors: pfaffman
# url: https://github.com/pfaffman

# register the locales
register_locale("en", name: "English", fallbackLocale: "en")
register_locale("es", name: "Spanish", nativeName: "Español", fallbackLocale: "en")

register_asset "stylesheets/common/discourse-add-to-summary.scss"

enabled_site_setting :discourse_add_to_summary_enabled

PLUGIN_NAME ||= "DiscourseAddToSummary".freeze

Rails.configuration.paths['app/views'].unshift(Rails.root.join('plugins', 'discourse-add-to-summary', 'app/views'))

if enabled_site_setting
  after_initialize do

    # Register the translation as site custom text
    #register_editable_site_customization(
    #  "plugin_name.hello_world",
    #  default: "Hello World"
    #)

    # see lib/plugin/instance.rb for the methods available in this context

    require_dependency 'user_notifications'
    module ::UserNotificationsOverride
      def digest(user, opts = {})
        @add_to_data = {}
        if SiteSetting.discourse_add_to_summary_enabled
          @add_to_data = {}
          base = Discourse.base_url
          base.gsub!(/localhost/, "localhost:3000") # make this work for development
          before_id = SiteSetting.discourse_add_to_summary_before_header_topic_id
          if before_id.to_i > 0
            btopic = Topic.find(before_id)
            before_post_list = Post.where(topic_id: before_id, post_number: btopic.highest_post_number)
            before_text = "".dup
            if before_post_list.length > 0
              before_text = before_post_list.first.cooked
            end
            before_text.gsub!(/\/\/localhost/, base)
            @add_to_data[:before_text] = before_text
            @add_to_data[:before_css] = SiteSetting.discourse_add_to_summary_before_header_css
            @add_to_data[:before] = before_text.length > 0
          end

          after_id = SiteSetting.discourse_add_to_summary_after_header_topic_id
          if after_id.to_i > 0
            atopic = Topic.find(after_id)
            after_post_list = Post.where(topic_id: after_id, post_number: atopic.highest_post_number) unless !atopic
            after_text = ""
            if after_post_list.length > 0
              after_text = after_post_list.first.cooked
            end
            after_text.gsub!(/\/\/localhost/, base)
            @add_to_data[:after_text] = after_text
            @add_to_data[:after_css] = SiteSetting.discourse_add_to_summary_after_header_css
            @add_to_data[:after] = after_text.length > 0
          end
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
