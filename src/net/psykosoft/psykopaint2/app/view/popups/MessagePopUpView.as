package net.psykosoft.psykopaint2.app.view.popups
{

	import feathers.controls.Label;

	import net.psykosoft.psykopaint2.app.view.popups.base.PopUpViewBase;

	public class MessagePopUpView extends PopUpViewBase
	{
		private var _label:Label;

		public function MessagePopUpView() {
			super();
		}

		override protected function onEnabled():void {

			super.onEnabled();

			_label = new Label();
			_label.validate();
			_label.x = _bg.width / 2 - _label.width / 2;
			_label.y = _bg.height / 2 - _label.height / 2;
			_container.addChild( _label );
		}

		override protected function onDisabled():void {

			_container.removeChild( _label );
			_label.dispose();
			_label = null;

			super.onDisabled();
		}

		public function setMessage( value:String ):void {
			_label.text = value;
		}
	}
}
