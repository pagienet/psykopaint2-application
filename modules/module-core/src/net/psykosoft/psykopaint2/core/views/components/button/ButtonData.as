package net.psykosoft.psykopaint2.core.views.components.button
{

	import flash.display.Bitmap;

	import net.psykosoft.psykopaint2.base.ui.components.list.HSnapListDataItemBase;
	import net.psykosoft.psykopaint2.base.ui.components.list.ISnapListData;

	public class ButtonData extends HSnapListDataItemBase implements ISnapListData
	{
		public var labelText:String;
		public var iconType:String;
		public var iconBitmap:Bitmap;
		public var selectable:Boolean;
		public var selected:Boolean;

		public function ButtonData() {
			super();
		}
	}
}
