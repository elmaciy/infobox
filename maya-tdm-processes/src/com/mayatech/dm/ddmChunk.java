package com.mayatech.dm;

public class ddmChunk {
	
	public String text=null;
	
	public boolean isComma=false;
	public boolean isOperator=false;
	public boolean isSingleWord=false;
	public boolean isLineComment=false;
	public boolean isMultiLineComment=false;
	public boolean isBlock=false;
	
	public int startPosInText=-1;



	
	public ddmChunk() {
		// TODO Auto-generated constructor stub
	}
	
	public ddmChunk(String text) {
		this.text=text;
	}

}
