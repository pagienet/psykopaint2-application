package net.psykosoft.psykopaint2.core.views.popups.error
{

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;

	import net.psykosoft.psykopaint2.core.views.components.button.IconButtonAlt;

	import net.psykosoft.psykopaint2.core.views.popups.base.PopUpViewBase;

	import org.osflash.signals.Signal;

	public class ErrorPopUpView extends PopUpViewBase
	{
		// Declared in Flash.
		public var bg:Sprite;
		public var main:TextField;
		public var extra:TextField;
		public var leftSide:Sprite;
		private var _backButton:IconButtonAlt;
		public var popUpWantsToCloseSignal:Signal = new Signal();

		public function ErrorPopUpView()
		{
			super();
			_backButton = leftSide.getChildByName("btn") as IconButtonAlt;
			_backButton.addEventListener(MouseEvent.CLICK, onBackButtonClicked);
			_backButton.labelText = "OK";
			_backButton.iconType = ButtonIconType.BACK;
		}

		private function onBackButtonClicked(event:MouseEvent):void
		{
			popUpWantsToCloseSignal.dispatch();
		}

		override protected function onEnabled():void
		{

			super.onEnabled();

			main.selectable = main.mouseEnabled = false;
			main.text = "";
			extra.selectable = extra.mouseEnabled = false;
			extra.text = "";

			// TODO: why the reparenting?
			_container.addChild(bg);
			_container.addChild(main);
			_container.addChild(extra);

			layout();
		}

		public function updateMessage(newTitle:String, newMessage:String):void
		{
			main.text = newTitle;
			if (newMessage != "") {
				extra.htmlText = newMessage;
			}
		}
	}
}
