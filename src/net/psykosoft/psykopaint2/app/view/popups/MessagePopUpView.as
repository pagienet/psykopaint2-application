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

		override protected function onStageAvailable():void {

			super.onStageAvailable();

			_label = new Label();
			_container.addChild( _label );
		}

		public function setMessage( value:String ):void {
			_label.text = value;
			onLayout();
		}

		override protected function onLayout():void {

			if( !stage ) return;

			if( _label ) {
				_label.validate();
				_label.x = _bg.width / 2 - _label.width / 2;
				_label.y = _bg.height / 2 - _label.height / 2;
			}

			super.onLayout();
		}
	}
}
