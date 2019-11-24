RSpec.describe CodeRay do
  describe 'version' do
    it "returns the Gem's version" do
      expect(CodeRay::VERSION).to match(/\A\d\.\d\.\d?\z/)
    end
  end
end
