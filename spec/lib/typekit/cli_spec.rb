module Typekit
  describe CLI do
    subject { described_class.new }
    let(:authentication) { double(:authentication) }
    let(:api) { double(:api) }
    let(:kit_id) { 'abcd123' }
    let(:name) { 'test kit 1' }
    let(:domains) { 'a.com b.com c.com' }

    before(:each) do
      allow(Typekit::API).to receive(:new).and_return(api)
    end

    describe '#logout' do
      before(:each) do
        allow(Formatador).to receive(:display_line)
      end

      it 'should clear the existing token' do
        expect(Typekit::Authentication).to receive(:clear_token)

        subject.logout
      end
    end

    describe '#list' do
      before(:each) do
        allow(api).to receive(:get_kits).and_return(kits)
      end

      context 'server returns one or more kits' do
        let(:analytics) { 'false' }
        let(:parsed_domains) { domains.split("\s").join(',') }
        let(:kits) {
          [{
            'name' => name,
            'id' => kit_id,
            'analytics' => analytics,
            'domains' => parsed_domains
          }]
        }
        let(:output) { capture(:stdout) { subject.list } }

        it 'should display a table of results' do
          expect(Formatador).to receive(:display_compact_table).with(kits, kits.first.keys)

          subject.list
        end

        it 'should display the returned name' do
          expect(output).to include(name)
        end

        it 'should display the returned id' do
          expect(output).to include(kit_id)
        end

        it 'should display the returned analytics flag' do
          expect(output).to include(analytics)
        end

        it 'should display the returned domain list' do
          expect(output).to include(parsed_domains)
        end
      end

      context 'server returns no kits' do
        let(:kits) { [] }
        let(:output) { capture(:stdout) { subject.list } }

        it 'should display a message indicating no results' do
          expect(output).to include('No kits found')
        end
      end
    end

    describe '#create' do
      let(:args) { ['create', '--name', name, '--domains', domains.split("\s")] }
      let(:output) { capture(:stdout) { described_class.start(args) } }
      let(:response) {
        {
          'kit' => {
            'id'=>kit_id,
            'name'=>name,
            'analytics'=>false,
            'domains'=> domains.split('\s'),
            'families'=>[]
          }
        }
      }

      before(:each) do
        allow(api).to receive(:create_kit).with(name, domains.split("\s")).and_return(response)
      end

      it 'should display a message indicating success' do
        expect(output).to include('Successfully created kit')
      end

      it 'should display the created kit id' do
        expect(output).to include(kit_id)
      end
    end

    describe '#show' do
      let(:args) { ['show', '--id', kit_id] }
      let(:output) { capture(:stdout) { described_class.start(args) } }
      let(:family1_name) { 'test family 1' }
      let(:family2_name) { 'test family 2' }
      let(:family1_id) { 'zxcv1234' }
      let(:family2_id) { 'mnbv0987' }
      let(:family1_slug) { 'family1-web' }
      let(:family2_slug) { 'family2-web' }
      let(:family1_css) { ['family1-1', 'family1-2'] }
      let(:family2_css) { ['family2-1', 'family2-2'] }
      let(:kit) {
        {
          'id'=>kit_id,
          'name'=>name,
          'analytics'=>false,
          'domains'=>domains.split("\s"),
          'families'=>
            [
              {
                'id'=>family1_id,
                'name'=>family1_name,
                'slug'=>family1_slug,
                'css_names'=>family1_css,
                'css_stack'=>'\'family1-1\',\'family1-2\',serif',
                'subset'=>'default',
                'variations'=>['n4', 'i4', 'n7', 'i7']
              },
              {
                'id'=>family2_id,
                'name'=>family2_name,
                'slug'=>family2_slug,
                'css_names'=>family2_css,
                'css_stack'=>'\'family2-1\',\'family2-2\',serif',
                'subset'=>'default',
                'variations'=>['n4', 'i4', 'n7', 'i7']
              },
            ]
        }
      }

      before(:each) do
        allow(api).to receive(:get_kit).with(kit_id).and_return(kit)
      end

      it 'should display the kit name' do
        expect(output).to include(name)
      end

      it 'should display the kit id' do
        expect(output).to include(kit_id)
      end

      it 'should display the analytics flag' do
        expect(output).to include('false')
      end

      it 'should display the domain list' do
        expect(output).to include(domains.split("\s").join(','))
      end

      it 'should display the family names' do
        expect(output).to include(family1_name)
        expect(output).to include(family2_name)
      end

      it 'should display the family ids' do
        expect(output).to include(family1_id)
        expect(output).to include(family2_id)
      end

      it 'should display the family slugs' do
        expect(output).to include(family1_slug)
        expect(output).to include(family2_slug)
      end

      it 'should display the family css selectors' do
        expect(output).to include(family1_css.join(','))
        expect(output).to include(family2_css.join(','))
      end
    end

    describe '#publish' do
      let(:args) { ['publish', '--id', kit_id] }
      let(:output) { capture(:stdout) { described_class.start(args) } }

      before(:each) do
        allow(api).to receive(:publish_kit).with(kit_id)
      end

      it 'should display a message indicating success' do
        expect(output).to include('Successfully published kit')
      end

      it 'should display the published kit id' do
        expect(output).to include(kit_id)
      end
    end

    describe '#remove' do
      let(:args) { ['remove', '--id', kit_id] }
      let(:output) { capture(:stdout) { described_class.start(args) } }

      before(:each) do
        allow(api).to receive(:remove_kit).with(kit_id)
      end

      it 'should display a message indicating success' do
        expect(output).to include('Successfully removed kit')
      end

      it 'should display the removed kit id' do
        expect(output).to include(kit_id)
      end
    end
  end
end
