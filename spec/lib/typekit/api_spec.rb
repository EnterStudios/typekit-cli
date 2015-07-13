module Typekit
  describe API do
    let(:auth_token) { 'abc123' }

    let(:kit_id) { 'abcd123' }
    let(:list_uri) { "#{API::API_URI}/kits" }
    let(:kit_uri) { "#{list_uri}/#{kit_id}"}
    let(:publish_uri) { "#{kit_uri}/publish" }

    let(:list_response) {
      { 'kits' => [{'id'=>kit_id, 'link'=>kit_uri}] }
    }
    let(:empty_list_response) {
      { 'kits' => [] }
    }
    let(:kit_response) {
      {
        'kit' => {
          'id'=>kit_id,
          'name'=>'test kit 1',
          'analytics'=>false,
          'domains'=>['a.com', 'b.com', 'c.com'],
          'families'=>[]
        }
      }
    }
    let(:error_response) {
      { 'errors' => ['Not authenticated'] }
    }

    before(:each) do
      # silence formatador output for errors
      allow(Formatador).to receive(:display_line)
    end

    describe '#get_kits' do
      subject { described_class.new(auth_token).get_kits }

      context 'returns list of kits' do
        let(:formatted_response) {
          [{
            'name' => 'test kit 1',
            'id' => kit_id,
            'analytics' => 'false',
            'domains' => 'a.com,b.com,c.com'
          }]
        }

        before(:each) do
          stub_request(:get, list_uri).
            to_return(body: list_response.to_json,
                      status: 200,
                      headers: {content_type: 'application/json'})
          stub_request(:get, kit_uri).
            to_return(body: kit_response.to_json,
                      status: 200,
                      headers: {content_type: 'application/json'})
        end

        it 'returns display information about each kit' do
          expect(subject).to eq(formatted_response)
        end
      end

      context 'returns no kits' do
        before(:each) do
          stub_request(:get, list_uri).
            to_return(body: empty_list_response.to_json,
                      status: 200,
                      headers: {content_type: 'application/json'})
        end

        it 'returns no kits to be displayed' do
          expect(subject).to eq([])
        end
      end

      context 'returns an error' do
        before(:each) do
          stub_request(:get, list_uri).
            to_return(body: error_response.to_json,
                      status: 401,
                      headers: {content_type: 'application/json'})
        end

        it 'should exit with a status code of 1' do
          begin
            subject
          rescue SystemExit => e
            expect(e.status).to eq(1)
          end
        end
      end

    end

    describe '#get_kit' do
      subject { described_class.new(auth_token).get_kit(kit_id) }

      context 'returns a kit' do
        before(:each) do
          stub_request(:get, kit_uri).
            to_return(body: kit_response.to_json,
                      status: 200,
                      headers: {content_type: 'application/json'})
        end

        it 'should return the kit information' do
          expect(subject).to eq(kit_response['kit'])
        end
      end

      context 'invalid kit id specified' do
        before(:each) do
          stub_request(:get, kit_uri).
            to_return(body: error_response.to_json,
                      status: 401,
                      headers: {content_type: 'application/json'})
        end

        it 'should exit with a status code of 1' do
          begin
            subject
          rescue SystemExit => e
            expect(e.status).to eq(1)
          end
        end
      end
    end

    describe '#create_kit' do
      let(:name) { 'test kit 1' }
      let(:domains) { ['a.com', 'b.com', 'c.com'] }
      let(:request) { "name=test%20kit%201&domains[]=a.com&domains[]=b.com&domains[]=c.com" }
      subject { described_class.new(auth_token).create_kit(name, domains) }

      context 'succesfully created new kit' do
        before(:each) do
          stub_request(:post, list_uri).
            with(body: request).
            to_return(body: kit_response.to_json,
                      status: 200,
                      headers: {content_type: 'application/json'})

          subject
        end

        it 'should POST to the api with the correct information' do
          expect(WebMock).to have_requested(:post, "#{API::API_URI}/kits").
            with(body: request)
        end

        it 'should return the name and ID of the created kit' do
          expect(subject.parsed_response).to eq(kit_response)
        end
      end

      context 'unable to create more kits' do
        before(:each) do
          stub_request(:post, list_uri).
            with(body: request).
            to_return(body: error_response.to_json,
                      status: 400,
                      headers: {content_type: 'application/json'})
        end

        it 'should exit with a status code of 1' do
          begin
            subject
          rescue SystemExit => e
            expect(e.status).to eq(1)
          end
        end
      end
    end

    describe '#publish_kit' do
      subject { described_class.new(auth_token).publish_kit(kit_id) }

      context 'succesfully publish kit' do
        before(:each) do
          stub_request(:post, publish_uri)
            .to_return(body: {'published' => '2015-07-12T22:04:53Z'}.to_json,
                       status: 200,
                       headers: {content_type: 'application/json'})

          subject
        end

        it 'should POST to the api' do
          expect(WebMock).to have_requested(:post, publish_uri)
        end
      end

      context 'unable to publish kit' do
        before(:each) do
          stub_request(:post, publish_uri).
            to_return(body: error_response.to_json,
                      status: 400,
                      headers: {content_type: 'application/json'})
        end

        it 'should exit with a status code of 1' do
          begin
            subject
          rescue SystemExit => e
            expect(e.status).to eq(1)
          end
        end
      end
    end

    describe '#remove_kit' do
      subject { described_class.new(auth_token).remove_kit(kit_id) }

      context 'successfully remove kit' do
        before(:each) do
          stub_request(:delete, kit_uri)
            .to_return(body: "{}",
                       status: 200,
                       headers: {content_type: 'application/json'})

          subject
        end

        it 'should DELETE the specified kit' do
          expect(WebMock).to have_requested(:delete, "#{API::API_URI}/kits/abcd123")
        end
      end

      context 'unable to remove kit' do
        before(:each) do
          stub_request(:delete, kit_uri)
            .to_return(body: error_response.to_json,
                       status: 400,
                       headers: {content_type: 'application/json'})

        end

        it 'should exit with a status code of 1' do
          begin
            subject
          rescue SystemExit => e
            expect(e.status).to eq(1)
          end
        end
      end
    end
  end
end
