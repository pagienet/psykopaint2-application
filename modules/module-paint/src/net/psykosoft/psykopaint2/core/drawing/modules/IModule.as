package net.psykosoft.psykopaint2.core.drawing.modules
{
	import flash.display.BitmapData;

	public interface IModule
	{
		function activate(bitmapData : BitmapData) : void;
		function deactivate() : void;
		function type():String;

		function render() : void;

		function get stateType() : String;
	}
}
