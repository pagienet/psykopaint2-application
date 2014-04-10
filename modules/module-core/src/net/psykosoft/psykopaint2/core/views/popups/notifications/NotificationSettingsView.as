package net.psykosoft.psykopaint2.core.views.popups.notifications
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;

	import net.psykosoft.psykopaint2.core.views.components.button.IconButtonAlt;

	import net.psykosoft.psykopaint2.core.views.components.checkbox.CheckBox;

	import net.psykosoft.psykopaint2.core.views.popups.base.PopUpViewBase;

	import org.osflash.signals.Signal;

	public class NotificationSettingsView extends PopUpViewBase
	{
		// Declared in Flash.
		public var bg:Sprite;
		public var checkbox:CheckBox;
		public var leftSide:Sprite;
		private var _backButton:IconButtonAlt;

		public var popUpWantsToCloseSignal:Signal = new Signal();

		public function NotificationSettingsView()
		{
			super();
			initUI();
			_backButton = leftSide.getChildByName( "btn" ) as IconButtonAlt;
			_backButton.addEventListener( MouseEvent.CLICK, onBackButtonClicked );
			_backButton.labelText = "OK";
			_backButton.iconType = ButtonIconType.BACK;
		}

		private function initUI():void
		{
			checkbox = createCheckbox(670, 254);
		}

		override protected function onDisabled():void
		{
			_backButton.removeEventListener(MouseEvent.CLICK, onBackButtonClicked);
		}

		private function onBackButtonClicked( event:MouseEvent ):void {
			popUpWantsToCloseSignal.dispatch();
		}

		private function createCheckbox(x : Number, y : Number):CheckBox
		{
			var checkbox : CheckBox = new CheckBox();
			checkbox.x = x;
			checkbox.y = y;
			checkbox.addEventListener(Event.CHANGE, onSettingsChange);
			addChild(checkbox);
			return checkbox;
		}

		private function onSettingsChange(event:Event):void
		{
			// dispatch new state and send to server
		}
	}
}
