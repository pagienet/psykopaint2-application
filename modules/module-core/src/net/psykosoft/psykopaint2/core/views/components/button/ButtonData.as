package net.psykosoft.psykopaint2.core.views.components.button
{

	import flash.display.Bitmap;
	import flash.events.MouseEvent;

	import net.psykosoft.psykopaint2.base.ui.components.list.HSnapListDataItemBase;
	import net.psykosoft.psykopaint2.base.ui.components.list.ISnapListData;

	public class ButtonData extends HSnapListDataItemBase implements ISnapListData
	{
		public var labelText:String;
		public var defaultLabelText:String;
		public var iconType:String;
		public var iconBitmap:Bitmap;
		public var selectable:Boolean;
		public var selected:Boolean;
		public var id:String;
		public var value:Number;
		public var minValue:Number;
		public var maxValue:Number;
		public var previewID:String;
		public var enabled:Boolean;
		public var disableMouseInteractivityWhenSelected:Boolean;
		public var clickType:String = MouseEvent.MOUSE_UP;
		public var readyCallbackObject:Object;
		public var readyCallbackMethod:Function;

		public function ButtonData() {
			super();
		}
	}
}
