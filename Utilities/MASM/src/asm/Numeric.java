package asm;

public class Numeric {
	private int value;
	private int type;
	private boolean relocatable;
	
	public Numeric(int value, int type) {
		this.value = value;
		this.type = type;
		this.relocatable = false;
	}
	
	public Numeric(int value, int type, boolean relocatable) {
		this.value = value;
		this.type = type;
		this.relocatable = relocatable;
	}
	
	public int getValue() {
		return value;
	}
	
	public void setValue(int value) {
		this.value = value;
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
	
	
}
