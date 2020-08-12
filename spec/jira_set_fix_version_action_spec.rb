describe Fastlane::Actions::JiraSetFeatureBuildAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The jira_set_feature_build plugin is working!")

      Fastlane::Actions::JiraSetFeatureBuildAction.run(nil)
    end
  end
end
