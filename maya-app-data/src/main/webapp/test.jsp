<%@ page language="java" contentType="text/html; charset=UTF-8"   pageEncoding="UTF-8"%>



<%@include file="header2.jsp"%>



<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html lang="en">
<head>
  <meta charset="utf-8">
  <title>jQuery UI Datepicker - Default functionality</title>

  <script src="style/bootstrap/js/jquery-1.11.1.js"></script>
    <script src="style/bootstrap/js/joint.js"></script>
    <script src="style/bootstrap/js/bootstrap.js"></script>
    <script src="style/bootstrap/js/bootbox.js"></script>
    <script src="style/bootstrap/js/fileinput.js"></script>
    
    <script src="style/bootstrap/js/jquery.hotkeys.js"></script>
    <script src="style/bootstrap/js/prettify.js"></script>
    <script src="style/bootstrap/js/bootstrap-wysiwyg.js"></script>
        
     <script src="jslib/tdmapp.js"></script>
    
    
    
    <link href="style/bootstrap/css/joint.css" rel="stylesheet">
    <link href="style/bootstrap/css/bootstrap.css" rel="stylesheet">
    <link href="style/bootstrap/css/fileinput.css" rel="stylesheet">
    <link href="style/bootstrap/css/prettify.css" rel="stylesheet">
 
  

 
 
</head>
<body >

  <input type=hidden id="numerical_input_1" value="13234.380" min_val="0" max_val="999999.55">
 
  <table border=0 cellspacing=0 cellpadding=0>
  <tr>
  <td>
  	<input type="text" id="numerical_input_1_fixed" value="0" maxlength=15 style="width:150px; text-align: right;" grouping=","  onfocus=onNumericFieldEnter(this,'fixed') onblur=onNumericFieldExit(this,'fixed') >
  </td>
  <td>
  <b>.</b>
  </td>
  <td>
  <input type="text" id="numerical_input_1_decimal" value="0" maxlength=8 style="width:50px; text-align: right;"    onfocus=onNumericFieldEnter(this,'decimal') onblur=onNumericFieldExit(this,'decimal')>
  </td>
  <td>
  <span class="badge">$</span>
  </td>
  </tr>
  </table>
  <!--  Execute default script -->
  <script>
  setNumericFieldParts("numerical_input_1");
  </script>
	
</body>
</html>