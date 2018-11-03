package com.mayatech.baseLibs;


import java.io.IOException;
import java.io.OutputStream;
import java.io.Writer;
  
/** 
 * Adapter for a Writer to behave like an OutputStream.  
 *
 * Bytes are converted to chars using the platform default encoding.
 * If this encoding is not a single-byte encoding, some data may be lost.
 */
public class WriterOutputStream extends OutputStream {
  
    private  StringBuilder sb;
    private final Writer writer;
  
    
    
    public WriterOutputStream() {
        this.writer=new Writer() {
			
			@Override
			public void write(char[] cbuf, int off, int len) throws IOException {
				//this.write(cbuf, off, len);
				System.out.println();
				sb.append(new String(cbuf, off, len));
				
			}
			
			@Override
			public void flush() throws IOException {
				// TODO Auto-generated method stub
				this.flush();
			}
			
			@Override
			public void close() throws IOException {
				// TODO Auto-generated method stub
				this.close();
			}
		};
		
        sb=new StringBuilder();
    }
  
    @Override
	public void write(int b) throws IOException {
        // It's tempting to use writer.write((char) b), but that may get the encoding wrong
        // This is inefficient, but it works
        write(new byte[] {(byte) b}, 0, 1);
    }
  
    @Override
	public void write(byte b[], int off, int len) throws IOException {
        //writer.write(new String(b, off, len));
    	sb.append(new String(b, off, len));
    	//System.out.println("..."+new String(b, off, len));
    }

    public String getOutput() {
    	return sb.toString();
    }

  
}
