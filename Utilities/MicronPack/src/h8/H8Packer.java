package h8;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.util.Arrays;

public class H8Packer {
	
	public int pack(String arch, File binary) {
		byte[] image;
		
		//The H8 computer system has many different configurations, most importantly is what drive controller is used 
		if (arch.equalsIgnoreCase("h8_17")) {
			System.out.println("Packing distribution for Heathkit H8 with H17 controller");
			System.out.println("Will generate a SS/SD .H8D image");
			
			//Generate a 400 sector long image, with 256 byte sectors
			image = new byte[400 * 256];
			Arrays.fill(image, (byte) 0xff);
			
			//Read the kernel binary into a byte array
			byte[] kernel = readFileToArray(binary);
			
			
			if (kernel == null) return -1;
			
			//During boot, sectors 1-9 on track 0 are read into memory at 0X2280
			int i = 0;
			while (i != (256 * 9) && i != kernel.length) {
				image[i] = kernel[i];
				i++;
			}
			
			writeArrayToFile(new File("out.h8d"), image);
			
			return 0;
		}
		
		return -1;
	}
	
	private byte[] readFileToArray(File f) {
		try {
			return Files.readAllBytes(f.toPath());
		} catch (IOException e) {
			return null;
		}
	}
	
	private void writeArrayToFile(File out, byte[] s) {
		try { 
			OutputStream f = new FileOutputStream(out);
			int i = 0;
			while (s.length != i) {
				f.write(s[i]);
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
