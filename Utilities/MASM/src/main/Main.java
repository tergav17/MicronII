package main;

import java.io.File;
import java.io.IOException;
import java.util.Scanner;

import asm.Assembler;


public class Main {
	
	private static Scanner sc = new Scanner(System.in);
	private static Assembler as = new Assembler();
	
	public static void main(String args[]) {
		System.out.println("MICRON Assembler/80 V1.0");
		

		String sfin = "";
		String sfout = "";
		
		if (args.length != 2) {
			System.out.println("Input File?");
			sfin = sc.nextLine();
			System.out.println("Output File?");
			sfout = sc.nextLine();
		} else {
			sfin = args[0];
			sfout = args[1]; 
		}
		File fin = new File(sfin);
		File fout = new File(sfout);
		
		if (!fout.exists()) {
			try {
				fout.createNewFile();
			} catch (IOException e) {
				System.out.println("Cannot Create File!");
			}
		}
		
		if (fin.exists() && fin.isFile() && fout.exists() && fout.isFile()) {
			System.out.println("Assembly Complete, Exited With " + as.assemble(fin, fout));
		} else {
			System.out.println("Invalid Files");
		}
		
		sc.close();
	}
}
