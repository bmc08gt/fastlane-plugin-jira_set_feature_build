require 'fastlane/action'
require_relative '../helper/jira_set_feature_build_helper'

module Fastlane
  module Actions
    module SharedValues
      CREATE_JIRA_VERSION_VERSION_ID = :CREATE_JIRA_VERSION_VERSION_ID
    end

    class JiraSetFeatureBuildAction < Action

      def self.run(params)
        puts "Running jira_set_feature_build Plugin"
        Actions.verify_gem!('jira-ruby')
        require "jira-ruby"

        site         = params[:url]
        context_path = ''
        auth_type    = :basic
        username     = params[:username]
        password     = params[:password]
        project_name = params[:project_name]
        name         = params[:name]
        description  = params[:description]
        archived     = params[:archived]
        released     = params[:released]
        start_date   = params[:start_date]

        options = {
          username:     username,
          password:     password,
          site:         site,
          context_path: context_path,
          auth_type:    auth_type,
          read_timeout: 120
        }

        client = JIRA::Client.new(options)
        puts "Client created: "
        puts client


        unless project_name.nil?


          puts "Looking for a Project cookie " + project_name
          begin
            project = client.Project.find(project_name)
          rescue JIRA::HTTPError => e
            puts "Error during accesing to Project"
            puts e.response.code
            puts e.response.message
          end

          puts "Project found!"
          project_id = project.id
          puts "Project ID found: " +  project_id
        end

        if start_date.nil?
          start_date = Date.today.to_s
        end

        ticket_numbers = Actions.lane_context[SharedValues::FL_CHANGELOG]
        puts "Received ticket numbers: "
        puts ticket_numbers

        ticket_numbers.each do |issue_id|
          begin
            issue = client.Issue.find(issue_id)
            fixVersions = [version]
            issue.save({"fields"=>{ "fixVersions" => fixVersions }})
          rescue JIRA::HTTPError
            "Skipping issue #{issue_id}"
          end
        end

        def self.description
          "Tags the provided JIRA issue with a feature build URL from parameter :url"
        end

        def self.authors
          ["Tommy Sadiq Hinrichsen", "Brandon McAnsh"]
        end

        def self.details
          "This action requires jira-ruby gem"
          
        end

        def self.available_options
          [
              FastlaneCore::ConfigItem.new(key: :username,
                env_name: "FL_CREATE_JIRA_VERSION_USERNAME",
                description: "Username for JIRA instance",
                type: String,
                verify_block: proc do |value|
                  UI.user_error!("No username given, pass using `username: 'jira_user'`") unless value and !value.empty?
                end),
                FastlaneCore::ConfigItem.new(key: :password,
                  env_name: "FL_CREATE_JIRA_VERSION_PASSWORD",
                  description: "Password for Jira",
                  type: String,
                  verify_block: proc do |value|
                    UI.user_error!("No password given, pass using `password: 'T0PS3CR3T'`") unless value and !value.empty?
                  end),
                  FastlaneCore::ConfigItem.new(key: :project_name,
                    env_name: "FL_CREATE_JIRA_VERSION_PROJECT_NAME",
                    description: "Project ID for the JIRA project. E.g. the short abbreviation in the JIRA ticket tags",
                    type: String,
                    optional: true,
                    conflicting_options: [:project_id],
                    conflict_block: proc do |value|
                      UI.user_error!("You can't use 'project_name' and '#{project_id}' options in one run")
                    end,
                    verify_block: proc do |value|
                      UI.user_error!("No Project ID given, pass using `project_id: 'PROJID'`") unless value and !value.empty?
                    end),
                    FastlaneCore::ConfigItem.new(key: :url,
                      env_name: "FL_CREATE_JIRA_FEATURE_BUILD_URL",
                      description: "The url of the feature build from the CI job",
                      type: String,
                      verify_block: proc do |value|
                        UI.user_error!("No version name given, pass using `url: 'http://someurl'`") unless value and !value.empty?
                      end),

                          def self.is_supported?(platform)
                            true
                          end
                        end
                      end
                    end
