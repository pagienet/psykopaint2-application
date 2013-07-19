package com.quasimondo.color.colorspace
{
	public interface IRGB
	{
		function get red(): int;
		function set red( r: int ): void;
		function get green(): int;
		function set green( g: int ): void;
		function get blue(): int;
		function set blue( b: int ): void;
		function get color( ): uint;
		function set color( value: uint ): void;
		function clone( ): IRGB;
	}
}