package com.quasimondo.color.colorspace
{
	public interface IRGB
	{
		function get red(): Number;
		function set red( r: Number ): void;
		function get green(): Number;
		function set green( g: Number ): void;
		function get blue(): Number;
		function set blue( b: Number ): void;
		function get color( ): uint;
		function set color( value: uint ): void;
		function clone( ): IRGB;
	}
}