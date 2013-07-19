package net.psykosoft.psykopaint2.core.views.popups
{

	import flash.display.Sprite;
	import flash.text.TextField;

	import net.psykosoft.psykopaint2.core.views.popups.base.PopUpViewBase;

	public class MessagePopUpView extends PopUpViewBase
	{
		// Declared in Flash.
		public var popup:Sprite;
		public var main:TextField;
		public var extra:TextField;

		public function MessagePopUpView() {
			super();
		}

		override protected function onEnabled():void {
			super.onEnabled();

			main.selectable = main.mouseEnabled = false;
			main.text = "";
			extra.selectable = extra.mouseEnabled = false;
			extra.text = "";

			// TODO: why the reparenting?
			_container.addChild( popup );
			_container.addChild( main );
			_container.addChild( extra );

			layout();
		}

		public function updateMessage( newTitle:String, newMessage:String ):void {
			main.text = newTitle;
			if( newMessage != "" ) {
				extra.htmlText = '" ' + newMessage + ' "';
			}
		}
	}
}
