package net.psykosoft.psykopaint2.core.views.popups.notifications
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import net.psykosoft.psykopaint2.core.views.components.button.IconButtonAlt;

	import net.psykosoft.psykopaint2.core.views.components.checkbox.CheckBox;

	import net.psykosoft.psykopaint2.core.views.popups.base.PopUpViewBase;

	import org.osflash.signals.Signal;

	public class NotificationSettingsView extends PopUpViewBase
	{
		// Declared in Flash.
		public var bg:Sprite;
		public var lovedCheckbox:CheckBox;
		public var commentCheckbox:CheckBox;
		public var replyCheckbox:CheckBox;
		public var rightSide:Sprite;
		private var _rightButton:IconButtonAlt;

		public var popUpWantsToCloseSignal:Signal = new Signal();

		public function NotificationSettingsView()
		{
			super();
			initUI();
			_rightButton = rightSide.getChildByName( "btn" ) as IconButtonAlt;
			_rightButton.addEventListener( MouseEvent.CLICK, onRightBtnClick );
			_rightButton.labelText = "OK";
			_rightButton.iconType = "continue";
		}

		private function initUI():void
		{
			lovedCheckbox = createCheckbox(670, 254);
			commentCheckbox = createCheckbox(670, 385);
			replyCheckbox = createCheckbox(670, 515);
		}

		override protected function onDisabled():void
		{
			_rightButton.removeEventListener(MouseEvent.CLICK, onRightBtnClick);
		}

		private function onRightBtnClick( event:MouseEvent ):void {
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
