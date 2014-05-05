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
		public static const ID_BUY:String = "Upgrade";
		private var _upgradePrice:String = "$???";
	
		public function UpgradeSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			
			setBgType( NavigationBg.BG_TYPE_WOOD_LOW );
			setHeader( "Try or Buy" );
			
			createCenterButton( ID_CANCEL,ID_CANCEL, ButtonIconType.CANCEL_UPGRADE, IconButton, null, true, true, false );
			createCenterButton( ID_BUY,ID_BUY, ButtonIconType.BUY_UPGRADE, IconButton, null, true, true, false, MouseEvent.MOUSE_UP, this, onUpgradeIconReady );
			validateCenterButtons();
		
		}

		private function onUpgradeIconReady(renderer:Sprite):void {
			var btn:IconButton = renderer as IconButton;
			btn.addEventListener(Event.ADDED_TO_STAGE, onUpgradeBtnAddedToStage);
		}

		private function onUpgradeBtnAddedToStage( event:Event ):void {
			var btn:IconButton = event.target as IconButton;
			btn.removeEventListener(Event.ADDED_TO_STAGE, onUpgradeBtnAddedToStage);
			var upgradeSpr:Sprite = btn.icon.getChildByName("upgrade") as Sprite;
			var lbl:TextField = upgradeSpr.getChildByName("upgradePrice_txt") as TextField;
			lbl.text = _upgradePrice;
		}

		public function get upgradePrice():String
		{
			return _upgradePrice;
		}

		public function set upgradePrice(value:String):void
		{
			_upgradePrice = value;
		}

	}
}
