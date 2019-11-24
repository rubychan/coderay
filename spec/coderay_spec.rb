require File.expand_path('../spec_helper', __FILE__)

RSpec.describe CodeRay do
  describe '::VERSION' do
    it "returns the Gem's version" do
      expect(CodeRay::VERSION).to match(/\A\d\.\d\.\d?\z/)
    end
  end

  describe '.coderay_path' do
    it 'returns an absolute file path to the given code file' do
      base = File.expand_path('../..', __FILE__)
      expect(CodeRay.coderay_path('file')).to eq("#{base}/lib/coderay/file")
    end
  end

  describe '.scan' do
    let(:code) { 'puts "Hello, World!"' }
    let(:tokens) do
      [
        ['puts', :ident],
        [' ', :space],
        [:begin_group, :string],
          ['"', :delimiter],
          ['Hello, World!', :content],
          ['"', :delimiter],
        [:end_group, :string]
      ].flatten
    end

    it 'returns tokens' do
      expect(CodeRay.scan(code, :ruby).tokens).to eq(tokens)
    end
  end
end
