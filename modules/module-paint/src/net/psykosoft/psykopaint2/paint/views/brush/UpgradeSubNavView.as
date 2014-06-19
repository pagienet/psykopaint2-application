package net.psykosoft.psykopaint2.paint.views.brush
{


	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.components.button.IconButton;
	import net.psykosoft.psykopaint2.core.views.navigation.NavigationBg;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class UpgradeSubNavView extends SubNavigationViewBase
	{
		public static const ID_CANCEL:String = "Cancel";
		public static const ID_BUY_PACKAGE:String = "Buy Package";
		public static const ID_BUY_SINGLE:String = "Buy Brush";
		private var _packagePrice:String = "$???";
		private var _singlePrice:String = "$???";
		private var _singleBrushName:String;
		private var _singleBrushIconID:String;
		
		public function UpgradeSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			
			setBgType( NavigationBg.BG_TYPE_WOOD_LOW );
			setHeader( "Try or Buy" );
			
			createCenterButton( ID_CANCEL,ID_CANCEL, ButtonIconType.CANCEL_UPGRADE, IconButton, null, true, true, false );
			createCenterButton( ID_BUY_PACKAGE,"Buy Package", ButtonIconType.BUY_UPGRADE, IconButton, null, true, true, false, MouseEvent.MOUSE_UP, this, onPackageIconReady );
			createCenterButton( ID_BUY_SINGLE,"Buy "+_singleBrushName, _singleBrushIconID, IconButton, null, true, true, false, MouseEvent.MOUSE_UP, this, onSingleIconReady );
			
			validateCenterButtons();
		
		}

		private function onPackageIconReady(renderer:Sprite):void {
			var btn:IconButton = renderer as IconButton;
			btn.addEventListener(Event.ADDED_TO_STAGE, onPackageBtnAddedToStage);
		}

		private function onPackageBtnAddedToStage( event:Event ):void {
			var btn:IconButton = event.target as IconButton;
			btn.removeEventListener(Event.ADDED_TO_STAGE, onPackageBtnAddedToStage);
			var upgradeSpr:Sprite = btn.icon.getChildByName("upgrade") as Sprite;
			var lbl:TextField = upgradeSpr.getChildByName("upgradePrice_txt") as TextField;
			lbl.text = _packagePrice;
		}

		public function get packagePrice():String
		{
			return _packagePrice;
		}

		public function set packagePrice(value:String):void
		{
			_packagePrice = value;
		}
		
		
		private function onSingleIconReady(renderer:Sprite):void {
			var btn:IconButton = renderer as IconButton;
			btn.addEventListener(Event.ADDED_TO_STAGE, onSingleBtnAddedToStage);
		}
		
		private function onSingleBtnAddedToStage( event:Event ):void {
			var btn:IconButton = event.target as IconButton;
			btn.removeEventListener(Event.ADDED_TO_STAGE, onSingleBtnAddedToStage);
			var upgradeSpr:Sprite = btn.icon.getChildByName("upgrade") as Sprite;
			var lbl:TextField = upgradeSpr.getChildByName("upgradePrice_txt") as TextField;
			lbl.text = _singlePrice;
		}
		
		public function get singlePrice():String
		{
			return _singlePrice;
		}
		
		public function set singlePrice(value:String):void
		{
			_singlePrice = value;
		}

		public function get singleBrushName():String
		{
			return _singleBrushName;
		}

		public function set singleBrushName(value:String):void
		{
			_singleBrushName = value;
		}

		public function get singleBrushIconID():String
		{
			return _singleBrushIconID;
		}

		public function set singleBrushIconID(value:String):void
		{
			_singleBrushIconID = value;
		}


	}
}
