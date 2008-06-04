require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe Rugalytics::Report do

  describe "creating report from csv" do

    describe "when setting report attributes" do
      before :all do
        csv = %Q|# ----------------------------------------
theyworkforyou.co.nz
Top Content,
26 May 2008,31 May 2008
# ----------------------------------------|
        @report = Rugalytics::Report.new(csv)
      end

      it "should set base url from second line of text" do
        @report.base_url.should == 'theyworkforyou.co.nz'
      end

      it "should set report name from third line of text" do
        @report.report_name.should == 'Top Content'
      end

      it "should set start date from fourth line of text" do
        @report.start_date.should == '26 May 2008'
      end

      it "should set end date from fourth line of text" do
        @report.end_date.should == '31 May 2008'
      end
    end

    describe "when creating items from 'Table'" do
      before :all do
        @base_url = %Q|theyworkforyou.co.nz|
        @attributes = %Q|URL,Page Views,Unique Page Views,Time on Page,Bounce Rate,% Exit,$ Index|
        @values1 = %Q|/,189,157,54.94957983193277,0.4862385392189026,0.37037035822868347,0.0|
        @values2 = %Q|/bills,60,38,54.17307692307692,0.0,0.13333334028720856,0.0|
        @csv = %Q|# ----------------------------------------
#{@base_url}
Top Content,
26 May 2008,31 May 2008
# ----------------------------------------
# ----------------------------------------
# Table
# ----------------------------------------
#{@attributes}
#{@values1}
#{@values2}
# --------------------------------------------------------------------------------
|
      end

      it 'should create item for each data row in "Table"' do
        item1 = mock('item1')
        item2 = mock('item2')
        Rugalytics::Item.should_receive(:new).with(@attributes.split(','), @values1.split(','), @base_url).and_return item1
        Rugalytics::Item.should_receive(:new).with(@attributes.split(','), @values2.split(','), @base_url).and_return item2

        report = Rugalytics::Report.new(@csv)
        report.items.should == [item1, item2]
      end
    end

    describe "when creating items from '.*MiniTableTable'" do
      before :all do
        @base_url = %Q|theyworkforyou.co.nz|
        @browser_attributes = %Q|Browser,Visits,% visits|
        @browser_values = %Q|Firefox,1529,0.17185568809509277|
        @connection_speed_attributes = %Q|Connection Speed,Visits,% visits|
        @connection_speed_values = %Q|Unknown,3987,0.4481285810470581|
        @csv = %Q|# ----------------------------------------
#{@base_url}
Visitors Overview,
3 May 2008,2 June 2008
# ----------------------------------------
# ----------------------------------------
# BrowserMiniTable
# ----------------------------------------
#{@browser_attributes}
#{@browser_values}

# ----------------------------------------
# ConnectionSpeedMiniTable
# ----------------------------------------
#{@connection_speed_attributes}
#{@connection_speed_values}
# --------------------------------------------------------------------------------|
      end
      it 'should create item for each data row in "XxxMiniTable"' do
        browser_item = mock('browser_item')
        connection_item = mock('item')
        Rugalytics::Item.should_receive(:new).with(@browser_attributes.split(','), @browser_values.split(','), @base_url).and_return browser_item
        Rugalytics::Item.should_receive(:new).with(@connection_speed_attributes.split(','), @connection_speed_values.split(','), @base_url).and_return connection_item

        report = Rugalytics::Report.new(@csv)
        report.browser_items.should == [browser_item]
        report.connection_speed_items.should == [connection_item]
      end
    end

    describe "when creating graph points from 'Graph'" do
      before :all do
        @period = %Q|1 May 2008 - 31 May 2008|
        @name = %Q|Page Views|
        @csv = %Q|# ----------------------------------------
theyworkforyou.co.nz
Top Content,
26 May 2008,31 May 2008
# ----------------------------------------

# ----------------------------------------
# Graph
# ----------------------------------------
#{@period}
#{@name}
5360
4330|
      end

      it 'should create graph with data under "Graph"' do
        graph = mock('graph')
        Rugalytics::Graph.should_receive(:new).with(@name, @period, [5360, 4330]).and_return graph

        report = Rugalytics::Report.new(@csv)
        report.page_views_graph.should == graph
      end
    end
  end
end