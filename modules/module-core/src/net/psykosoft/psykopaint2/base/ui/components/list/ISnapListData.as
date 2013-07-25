package net.psykosoft.psykopaint2.base.ui.components.list
{

	import flash.display.DisplayObject;

	public interface ISnapListData
	{
		function get itemRenderer():DisplayObject;
		function set itemRenderer( value:DisplayObject ):void;

		function get itemRendererType():Class;
		function set itemRendererType( value:Class ):void;

		function get itemRendererWidth():Number;
		function set itemRendererWidth( value:Number ):void;

		function get itemRendererPosition():Number;
		function set itemRendererPosition( value:Number ):void;

		function get isDataItemVisible():Boolean;
		function set isDataItemVisible( value:Boolean ):void;
	}
}
