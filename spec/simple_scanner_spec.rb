RSpec.describe CodeRay::Scanners::SimpleScanner do
  let(:scanner) { Class.new described_class }

  describe '#scan_tokens_code' do
    subject { scanner.send :scan_tokens_code }
    it 'lets you define states' do
      is_expected.to eq <<-RUBY
state = options[:state] || @state
states = [state]


until eos?
  case state
    
  else
    raise_inspect 'Unknown state: %p' % [state], encoder
  end
end

@state = state if options[:keep_state]

close_groups(encoder, states)

encoder
      RUBY
    end
  end
end
