module Typekit
  describe Authentication do
    subject { described_class }
    let(:auth_token) { 'abcd1234' }
    let(:token_writer) { double(:file) }
    let(:token_path) { subject::TOKEN_FILE }

    before(:each) do
      allow(subject).to receive(:token_path).and_return(token_path)
    end

    describe '.authenticated?' do
      context 'true' do
        before(:each) do
          allow(subject).to receive(:get_token).and_return(auth_token)
        end

        it 'returns true' do
          expect(subject.authenticated?).to be_truthy
        end
      end

      context 'false' do
        before(:each) do
          allow(subject).to receive(:get_token).and_return(nil)
        end

        it 'returns false' do
          expect(subject.authenticated?).to be_falsey
        end
      end
    end

    describe '.get_token' do
      context 'token file exists' do
        before(:each) do
          allow(token_writer).to receive(:gets).and_return(auth_token)
          allow(File).to receive(:exist?).and_return(true)
          allow(File).to receive(:open).with(token_path, 'r').and_return(token_writer)
        end

        it 'returns the stored auth token' do
          expect(subject.get_token).to eq(auth_token)
        end
      end

      context 'token file does not exist' do
        before(:each) do
          allow(File).to receive(:exist?).and_return(false)
        end

        it 'returns nil' do
          expect(subject.get_token).to eq(nil)
        end
      end
    end

    describe '.clear_token' do
      before(:each) do
        allow(File).to receive(:exist?).and_return(true)
      end

      it 'removes the file' do
        expect(File).to receive(:unlink).with(token_path)

        subject.clear_token
      end
    end

    describe '.prompt_for_token' do
      before(:each) do
        allow(Formatador).to receive(:display)
        allow(STDIN).to receive_message_chain(:gets, :chomp).and_return(auth_token)
        allow(File).to receive(:open).with(token_path, 'w').and_yield(token_writer)
      end

      it 'writes the token to the file' do
        expect(token_writer).to receive(:write).with(auth_token)

        subject.prompt_for_token
      end
    end
  end
end
