RSpec.describe CodeRay::Scanners::SimpleScanner do
  let(:scanner) { described_class }

  describe '#scan_tokens_code' do
    subject { scanner.send :scan_tokens_code }
    it 'throws an error' do
      expect { subject }.to raise_error(CodeRay::Scanners::SimpleScannerDSL::NoStatesError)
    end
  end

  describe 'with one state' do
    let(:scanner) do
      Class.new described_class do
        state :somepony do
          on %r/rainbow/, :dash
        end
      end
    end

    describe '#scan_tokens_code' do
      subject { scanner.send :scan_tokens_code }
      it 'returns an scanner with one states' do
        is_expected.to eq <<-RUBY
state = options[:state] || @state
states = [state]

until eos?
  case state
  when :somepony
    if match = scan(/rainbow/)
      encoder.text_token match, :dash
    else
      encoder.text_token getch, :error
    end
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
end
