package net.psykosoft.psykopaint2.core.views.popups.notifications
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import net.psykosoft.psykopaint2.core.models.NotificationSubscriptionType;

	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;

	import net.psykosoft.psykopaint2.core.views.components.button.IconButtonAlt;

	import net.psykosoft.psykopaint2.core.views.components.checkbox.CheckBox;

	import net.psykosoft.psykopaint2.core.views.popups.base.PopUpViewBase;

	import org.osflash.signals.Signal;

	public class NotificationSettingsView extends PopUpViewBase
	{
		// Declared in Flash.
		public var bg:Sprite;
		public var leftSide:Sprite;

		public var likesCheckbox:CheckBox;
		public var newsCheckbox:CheckBox;
		private var _backButton:IconButtonAlt;

		public const popUpWantsToCloseSignal:Signal = new Signal();
		public const settingsChangedSignal:Signal = new Signal(int, Boolean);	// int: type of notification (NotificationSubscriptionType), Boolean: whether or not to subscribe

		// notification type, subscribed or not

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
			likesCheckbox = createCheckbox(653, 254, onLikeChanged);
			newsCheckbox = createCheckbox(653, 385, onNewsChanged);
		}

		override protected function onDisabled():void
		{
			_backButton.removeEventListener(MouseEvent.CLICK, onBackButtonClicked);
		}

		private function onBackButtonClicked( event:MouseEvent ):void {
			popUpWantsToCloseSignal.dispatch();
		}

		private function createCheckbox(x : Number, y : Number, callBack : Function):CheckBox
		{
			var checkbox : CheckBox = new CheckBox();
			checkbox.x = x;
			checkbox.y = y;
			checkbox.addEventListener(Event.CHANGE, callBack);
			addChild(checkbox);
			return checkbox;
		}

		private function onLikeChanged(event:Event):void
		{
			settingsChangedSignal.dispatch(NotificationSubscriptionType.FAVORITE_PAINTING, likesCheckbox.selected);
		}

		private function onNewsChanged(event:Event):void
		{
			settingsChangedSignal.dispatch(NotificationSubscriptionType.GLOBAL_NEWS, newsCheckbox.selected);
		}
	}
}
