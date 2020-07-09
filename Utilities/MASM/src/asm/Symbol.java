package asm;

public class Symbol {
	private String name;
	private int type;
	private boolean relocatable;
	private int value;
	
	public Symbol(String name, int type, boolean relocatable, int value) {
		this.name = name;
		this.type = type;
		this.relocatable = relocatable;
		this.value = value;
	}
	
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public int getType() {
		return type;
	}
	public void setType(int type) {
		this.type = type;
	}
	public boolean isRelocatable() {
		return relocatable;
	}
	public void setRelocatable(boolean relocatable) {
		this.relocatable = relocatable;
	}
	public int getValue() {
		return value;
	}
	public void setValue(int value) {
		this.value = value;
	}
	
	
}
