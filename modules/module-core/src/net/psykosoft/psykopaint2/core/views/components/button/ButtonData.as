package net.psykosoft.psykopaint2.core.views.components.button
{

	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	
	import net.psykosoft.psykopaint2.base.ui.components.ICopyableData;
	import net.psykosoft.psykopaint2.base.ui.components.list.HSnapListDataItemBase;
	import net.psykosoft.psykopaint2.base.ui.components.list.ISnapListData;

	public class ButtonData extends HSnapListDataItemBase implements ISnapListData, ICopyableData
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
		public var clickType:String = MouseEvent.MOUSE_DOWN;
		public var readyCallbackObject:Object;
		public var readyCallbackMethod:Function;

		public function ButtonData() {
			super();
		}
		
		public function copyData( data:Object ):void
		{
			disableMouseInteractivityWhenSelected = data.disableMouseInteractivityWhenSelected;
			iconBitmap = data.iconBitmap;
			selectable = data.selectable;
			id = data.id;
			enabled = data.enabled;
			selected = data.selected;
			labelText = data.labelText;
			iconType = data.iconType;
		}
		
		public function copyDataProperty( data:Object, propertyID:String ):void
		{
			switch ( propertyID )
			{
				case "disableMouseInteractivityWhenSelected":
					disableMouseInteractivityWhenSelected = data.disableMouseInteractivityWhenSelected;
					break;
				case "iconBitmap":
					iconBitmap = data.iconBitmap;
					break;
				case "selectable":
					selectable = data.selectable;
					break;
				case "id":
					id = data.id;
					break;
				case "enabled":
					enabled = data.enabled;
					break;
				case "selected":
					selected = data.selected;
					break;
				case "labelText":
					labelText = data.labelText;
					break;
				case "iconType":
					iconType = data.iconType;
					break;
				default:
					throw("Error: "+propertyID+" not handled in NavigationButton.setButtonDataProperty");
					break;
			}
			
		}
	}
}
