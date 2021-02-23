# frozen_string_literal: true
require 'rails_helper'

describe DiscourseAddToSummary::ActionsController do
  fab!(:newuser) { Fabricate(:user, trust_level: TrustLevel[0]) }
  let(:topic) { Fabricate(:topic) }
  let(:post_args) do
    { user: topic.user, topic: topic }
  end

  let(:user) { Fabricate(:admin) }
    # Help us build a post with a raw body
    def post_with_body(body, user = nil)
      args = post_args.merge(raw: body)
      args[:user] = user if user.present?
      Fabricate.build(:post, args)
    end

  before do
    SiteSetting.queue_jobs = false
  end
  context "with new topics" do

    subject { UserNotifications.digest(user) }

    after do
      Discourse.redis.keys('summary-new-users:*').each { |key| Discourse.redis.del(key) }
    end

    # these are from discourse/spec/mailers/user_notifications_spec.rb
    it "works" do
      SiteSetting.discourse_add_to_summary_enabled = true
      expect(subject.to).to eq([user.email])
      expect(subject.subject).to be_present
      expect(subject.from).to eq([SiteSetting.notification_email])
      expect(subject.html_part.body.to_s).to be_present
      expect(subject.text_part.body.to_s).to be_present
      expect(subject.header["List-Unsubscribe"].to_s).to match(/\/email\/unsubscribe\/\h{64}/)
      expect(subject.html_part.body.to_s).to include('New Users')
    end

    it "supports subfolder" do
      SiteSetting.discourse_add_to_summary_enabled = true
      set_subfolder "/forum"
      html = subject.html_part.body.to_s
      text = subject.text_part.body.to_s
      expect(html).to be_present
      expect(text).to be_present
      expect(html).to_not include("/forum/forum")
      expect(text).to_not include("/forum/forum")
      expect(subject.header["List-Unsubscribe"].to_s).to match(/http:\/\/test.localhost\/forum\/email\/unsubscribe\/\h{64}/)

      topic_url = "http://test.localhost/forum/t/#{popular_topic.slug}/#{popular_topic.id}"
      expect(html).to include(topic_url)
      expect(text).to include(topic_url)
    end

    # these are for the plugin
    let!(:popular_topic) { Fabricate(:topic, user: Fabricate(:coding_horror), created_at: 1.hour.ago) }
    ad_text = 'This is an important ad'

    let(:before_topic) { Fabricate(:topic) }
    let!(:ad_post) { Fabricate(:post, topic: before_topic, raw: ad_text) }

    it "includes a in before header ad" do
      SiteSetting.discourse_add_to_summary_enabled = true
      SiteSetting.discourse_add_to_summary_before_header_topic_id = before_topic.id
      puts "TopicID: #{before_topic.id}. Raw: #{ad_post.raw}"
      expect(subject.html_part.body.to_s).to include(ad_text)
    end

    it "includes a in discourse_add_to_summary_after_header_topic_id ad" do
      SiteSetting.discourse_add_to_summary_enabled = true
      SiteSetting.discourse_add_to_summary_before_header_topic_id = nil
      SiteSetting.discourse_add_to_summary_after_header_topic_id = before_topic.id
      puts "TopicID: #{before_topic.id}. Raw: #{ad_post.raw}"
      expect(subject.html_part.body.to_s).to include(ad_text)
    end

    # TODO: add tests for CSS.

    it "is up to date with current discourse html template" do
      discourse_digest = File.read('./app/views/user_notifications/digest.html.erb')
      discourse_md5 = Digest::MD5.hexdigest(discourse_digest)
      reference_md5 = "f955a3fb6967873f1d563fa5ba59b7ff"
      expect(discourse_md5).to eq(reference_md5)
    end
  end

end
