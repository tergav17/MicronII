package main;

import java.io.File;
import java.util.Scanner;

import h8.H8Packer;

public class Main {
	
	private static Scanner sc = new Scanner(System.in);
	private static H8Packer h8 = new H8Packer();
	
	public static void main(String args[]) {
		System.out.println("MICRON Packer V0.0");

		String arch = "";
		String sfkern = "";
		
		if (args.length != 2) {
			System.out.println("Architecture? (h8_17)");
			arch = sc.nextLine();
			System.out.println("Kernel Binary?");
			sfkern = sc.nextLine();
		} else {
			arch = args[0];
			sfkern = args[1]; 
		}

		File fkern = new File(sfkern);
		
		if (!fkern.exists()) {
			System.out.println("Invalid Kernel Binary");
			return;
		}
		
		if(arch.equalsIgnoreCase("h8_17")) {
			if (h8.pack(arch, fkern) == 0) {
				System.out.println("H8 Package Success");
			} else {
				System.out.println("H8 Package Failure");
			}
		} else {
			System.out.println("Unknown Architecture");
		}
	}
		
}
