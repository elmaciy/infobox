package com.mayatech.Test;

import java.io.DataInputStream;
import java.util.ArrayList;

import org.apache.http.Header;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.HttpConnectionParams;
import org.apache.http.params.HttpParams;
import org.apache.http.protocol.HTTP;

public class testJavaScript {
	/**
	 * @param args
	 */

	
	@SuppressWarnings({ "deprecation", "resource" })
	public static void main(String[] args) {

		String method="POST";
		String serviceURL="http://www.w3schools.com/webservices/tempconvert.asmx";
		String content_type="text/xml; charset=utf-8";
		String soapAction="FahrenheitToCelsius";
		String request_String="<?xml version=\"1.0\" encoding=\"utf-8\"?>  \n"+
				"<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" \n"+
				"  		<soap:Body> \n"+
				"			<CelsiusToFahrenheit xmlns=\"http://www.w3schools.com/webservices/\"><Celsius>50</Celsius></CelsiusToFahrenheit> "+
				"  		</soap:Body> \n"+
				"</soap:Envelope>";	
		
		
		method="POST";
		serviceURL="http://www.w3schools.com/webservices/tempconvert.asmx/CelsiusToFahrenheit";
		content_type="application/x-www-form-urlencoded";
		soapAction="";
		request_String="Celsius=22";
		
		method="POST";
		serviceURL="http://www.webservicex.com/stockquote.asmx";
		content_type="text/xml; charset=utf-8";
		soapAction="GetQuote";
		request_String="<?xml version=\"1.0\" encoding=\"utf-8\"?>  \n"+
				"<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" \n"+
				"  		<soap:Body> \n"+
				"			<GetQuote xmlns='http://www.webserviceX.NET/'><symbol>IBM</symbol></GetQuote> "+
				"  		</soap:Body> \n"+
				"</soap:Envelope>";	
		
		method="POST";
		serviceURL="http://www.webservicex.com/stockquote.asmx/GetQuote";
		content_type="application/x-www-form-urlencoded";
		soapAction="";
		request_String="symbol=IBM";	
		
		ArrayList<String[]> addHeaders=new ArrayList<String[]>();
		addHeaders.add(new String[]{"Content-Type", content_type});
		if (soapAction.length()>0)
			addHeaders.add(new String[]{"SOAPAction", soapAction});

		
		
		
		
		try {
			HttpParams httpParameters = new BasicHttpParams();
		    int timeoutConnection = 15000;
		    HttpConnectionParams.setConnectionTimeout(httpParameters, timeoutConnection);
		    int timeoutSocket = 35000;
		    HttpConnectionParams.setSoTimeout(httpParameters, timeoutSocket);

		    DefaultHttpClient httpclient = new DefaultHttpClient(httpParameters);
		    
		    HttpPost httpcall = new HttpPost(serviceURL );
		   
		    for (int i=0;i<addHeaders.size();i++) {
				String property_name=addHeaders.get(i)[0];
				String property_value=addHeaders.get(i)[1];
				System.out.println("Adding header "+property_name+ ": "  + property_value);
				httpcall.setHeader(property_name, property_value );
			}


		    System.out.println("executing request : " + httpcall.getRequestLine());
		    
		    
		    final StringBuffer soap = new StringBuffer();
		    
		    if (request_String.length()>0) {
		    	
		    	soap.append(request_String);

			    System.out.println("Request String to br Sent : \n" + soap.toString());
			    
			    HttpEntity entity = new StringEntity(soap.toString(),HTTP.UTF_8);
		        httpcall.setEntity(entity); 
		    }
		    
		    
		   
	        
	        HttpResponse response = httpclient.execute(httpcall);// calling server
	        HttpEntity r_entity = response.getEntity();  //get response
	        
	        System.out.println("Reponse Header"+"Begin...");          // response headers
	        System.out.println("Reponse Header"+"StatusLine:"+response.getStatusLine());
	        System.out.println("--------------------------------");
	        Header[] headers = response.getAllHeaders();
	        for(Header h:headers){
	        	System.out.println("Reponse Header "+h.getName() + ": " + h.getValue());
	        }
	        System.out.println("Reponse Header : END...");
	        
	        byte[] result = null;
	        
	        if (r_entity != null) {       
	            result = new byte[(int) r_entity.getContentLength()];  
	            if (r_entity.isStreaming()) {
	                DataInputStream is = new DataInputStream( r_entity.getContent());
	                is.readFully(result);
	            }
	        }
	        
	        String str="";
	        
	        if (result!=null) {
	        	System.out.println("Result length : " + result.length);
	        	 str=new String(result);
	        }
	        
	        
	        System.out.println(str);
	        
	        
			  
		} catch(Exception e)  {
			e.printStackTrace();
		} finally {
			 
		}

		
	}
	
}
