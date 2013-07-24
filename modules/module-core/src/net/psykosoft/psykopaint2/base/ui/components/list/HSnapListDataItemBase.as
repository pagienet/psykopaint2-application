package net.psykosoft.psykopaint2.base.ui.components.list
{

	import flash.display.DisplayObject;

	public class HSnapListDataItemBase
	{
		public var itemRenderer:DisplayObject;
		public var itemRendererType:Class;
		public var itemRendererWidth:Number;
		public var itemRendererPosition:Number;
		public var isDataItemVisible:Boolean; // TODO: remove

		public function HSnapListDataItemBase() {
			super();
		}
	}
}
