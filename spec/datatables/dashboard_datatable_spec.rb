require 'rails_helper'

# Idea of testing Datatable class
# https://gist.github.com/antillas21/9a326abfb690d0c26306

RSpec.describe DashboardDatatable do
  describe '#initialize' do
    params = {
      sSortDir_0: 'asc', iSortCol_0: '4', iDisplayStart: '0',
      iDisplayLength: '25', sSearch: '', sEcho: '1'
    }
    let(:view) { double('view', params: params) }
    let(:datatable) { DashboardDatatable.new(view) }

    it 'receives a view as context' do
      expect(datatable.view).to eq(view)
    end
  end

  describe 'delegations' do
    params = {
      sSortDir_0: 'asc', iSortCol_0: '4', iDisplayStart: '0',
      iDisplayLength: '25', sSearch: '', sEcho: '1'
    }
    let(:view) { double('view', params: params) }
    let(:datatable) { DashboardDatatable.new(view) }

    it 'delegates params call to view' do
      expect(datatable).to delegate_method(:params).to(:view)
    end
  end

  describe '#as_json' do
    params = {
      sSortDir_0: 'asc', iSortCol_0: '4', iDisplayStart: '0',
      iDisplayLength: '25', sSearch: '', sEcho: '1'
    }
    let(:view) { double('view', params: params) }
    let(:datatable) { DashboardDatatable.new(view) }

    it 'returns a json hash' do
      expect(datatable.as_json).to be_a(Hash)
    end

    it 'returns jquery.dataTables required keys' do
      expect(datatable.as_json).to include(:sEcho, :iTotalRecords, :iTotalDisplayRecords, :data)
    end
  end

  context 'helper methods' do
    params = {
      sSortDir_0: 'asc', iSortCol_0: '4', iDisplayStart: '0',
      iDisplayLength: '25', sSearch: '', sEcho: '1'
    }
    let(:view) { double('view', params: params) }
    let(:datatable) { DashboardDatatable.new(view) }

    describe '#data' do
      it 'returns an Array' do
        expect(datatable.send(:data)).to be_a(Array)
      end

      it 'returns elements that have necessary keys' do
        create(:work)
        allow(view).to receive(:work_checkbox)
        allow(view).to receive(:work_status)
        allow(view).to receive(:work_detail_link)
        allow(view).to receive(:ocr_date)
        allow(view).to receive(:ocr_engine)
        allow(view).to receive(:ocr_batch)
        allow(view).to receive(:accuracy_links)
        element = datatable.send(:data).first
        expect(element).to include(:work_select, :status, :detail_link, :collection,
                                   :id, :tcp_number, :title, :author, :font, :ocr_date,
                                   :ocr_engine, :ocr_batch, :juxta_url, :retas_url)
      end
    end

    describe '#works' do
      it 'calls fetch_works the first time' do
        expect(datatable).to receive(:fetch_works)
        datatable.send(:works)
      end

      it 'caches the value and does not call fetch_works if nothing changed' do
        datatable.send(:works)
        expect(datatable).to_not receive(:fetch_works)
        datatable.send(:works)
      end
    end

    describe '#fetch_works' do
      it 'returns an ActiveRecord::Relation of Work objects' do
        expect(datatable.send(:works)).to be_a(ActiveRecord::Relation)
      end
    end

    describe '#sort_column' do
      it 'returns wks_work_id' do
        expect(datatable.send(:sort_column)).to eq('wks_work_id')
      end

      it 'returns wks_tcp_number' do
        datatable.params[:iSortCol_0] = '5'
        expect(datatable.send(:sort_column)).to eq('wks_tcp_number')
      end

      it 'sets default column when iSortCol_0 is absent' do
        datatable.params.delete(:iSortCol_0)
        expect(datatable.send(:sort_column)).to eq('wks_work_id')       
      end

      it 'sets default column when ocr_sched' do
        datatable.params[:iSortCol_0] = '9'
        datatable.params[:ocr] = 'ocr_sched'
        expect(datatable.send(:sort_column)).to eq('wks_work_id')
      end

      it 'sets default column when ocr_none' do
        datatable.params[:iSortCol_0] = '9'
        datatable.params[:ocr] = 'ocr_none'
        expect(datatable.send(:sort_column)).to eq('wks_work_id')
      end
    end

    describe '#sort_direction' do
      it 'returns value of sSortDir_0' do
        expect(datatable.send(:sort_direction)).to eq('asc')
      end
    end

    describe '#page' do
      it 'returns value of params[:iDisplayStart]' do
        expect(datatable.send(:page)).to eq('0')
      end
    end

    describe '#per_page' do
      it 'returns value of params[:iDisplayLength]' do
        expect(datatable.send(:per_page)).to eq('25')
      end
    end
  end
end
