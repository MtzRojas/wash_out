xml.instruct!
xml[:wsdl].definitions 'xmlns:xsi'       => @namespace,
                       'xmlns:soap'      => 'http://schemas.xmlsoap.org/wsdl/soap/',
                       'xmlns:tm'        => 'http://microsoft.com/wsdl/mime/textMatching/',
                       'xmlns:soapenc'   => 'http://schemas.xmlsoap.org/soap/encoding/',
                       'xmlns:mime'      => 'http://schemas.xmlsoap.org/wsdl/mime/',
                       'xmlns:tns'       => 'http://www.epagoinc.com/biller-transaction-service/1.0',
                       'xmlns:s'         => 'http://www.w3.org/2001/XMLSchema',
                       'xmlns:soap12'    => 'http://schemas.xmlsoap.org/wsdl/soap12/',
                       'xmlns:http'      => 'http://schemas.xmlsoap.org/wsdl/http/',
                       'targetNamespace' => @namespace,
                       'xmlns:wsdl'      => 'http://schemas.xmlsoap.org/wsdl/' do

  xml[:wsdl].types do
    xml[:s].tag! "schema", :targetNamespace => @namespace, :xmlns => 'http://www.w3.org/2001/XMLSchema' do
      defined = []
      @map.each do |operation, formats|
        (formats[:in] + formats[:out]).each do |p|
          wsdl_type xml, p, defined
        end
      end
    end
  end

  @map.each do |operation, formats|
    xml[:wsdl].message :name => "#{operation}" do
      formats[:in].each do |p|
        xml.part wsdl_occurence(p, false, :name => p.name, :type => p.namespaced_type)
      end
    end
    xml[:wsdl].message :name => formats[:response_tag] do
      formats[:out].each do |p|
        xml.part wsdl_occurence(p, false, :name => p.name, :type => p.namespaced_type)
      end
    end
  end

  xml.portType :name => "#{@name}_port" do
    @map.each do |operation, formats|
      xml.operation :name => operation do
        xml.input :message => "#{operation}"
        xml.output :message => "#{formats[:response_tag]}"
      end
    end
  end

  xml.binding :name => "#{@name}_binding", :type => "#{@name}_port" do
    xml.tag! "soap:binding", :style => 'document', :transport => 'http://schemas.xmlsoap.org/soap/http'
    @map.keys.each do |operation|
      xml.operation :name => operation do
        xml.tag! "soap:operation", :soapAction => operation
        xml.input do
          xml.tag! "soap:body",
            :use => "literal",
            :namespace => @namespace
        end
        xml.output do
          xml.tag! "soap:body",
            :use => "literal",
            :namespace => @namespace
        end
      end
    end
  end

  xml.service :name => @service_name do
    xml.port :name => "#{@name}_port", :binding => "#{@name}_binding" do
      xml.tag! "soap:address", :location => WashOut::Router.url(request, @name)
    end
  end
end
