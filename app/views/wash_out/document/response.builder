xml.instruct!
xml.tag! "soap:Envelope", "xmlns:soap" => 'http://schemas.xmlsoap.org/soap/envelope/',
                          "xmlns:xsd" => 'http://www.w3.org/2001/XMLSchema',
                          "xmlns:xsi" => @namespace do
  if !header.nil?
    xml.tag! "soap:Header" do
      xml.tag! "#{@response_tag.present? ? @response_tag : 'tns:'}#{@action_spec[:response_tag]}", 'xmlns="http://www.epagoinc.com/biller-transaction-service/1.0"' do
        wsdl_data xml, header
      end
    end
  end
  xml.tag! "soap:Body" do
    xml.tag! "#{@response_tag.present? ? @response_tag : 'tns:'}#{@action_spec[:response_tag]}", 'xmlns="http://www.epagoinc.com/biller-transaction-service/1.0"' do
      wsdl_data xml, result
    end
  end
end
