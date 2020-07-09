package h8;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

public class H8Packer {
	
	public int pack(String arch, File binary) {
		
		//The H8 computer system has many different configurations, most importantly is what drive controller is used 
		if (arch.equalsIgnoreCase("h8_17")) {
			System.out.println("Packing distribution for Heathkit H8 with H17 controller");
			System.out.println("Will generate a SS/SD .H8D image");
		}
		
		return 1;
	}
	
	
	
	private void writeStringToFile(File out, String s) {
		try {
			OutputStream f = new FileOutputStream(out);
			int i = 0;
			while (s.length() != i) {
				f.write(s.charAt(i));
				i++;
			}
			f.close();
		} catch (IOException e) {
			System.out.println("Invalid File");
			return;
		}
		return;
	}
}