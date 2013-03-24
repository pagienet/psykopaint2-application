package net.psykosoft.psykopaint2.app.view.popups
{

	import feathers.controls.Label;

	import net.psykosoft.psykopaint2.app.view.popups.base.PopUpViewBase;

	public class FeatureNotImplementedPopUpView extends PopUpViewBase
	{
		private var _label:Label;

		public function FeatureNotImplementedPopUpView() {
			super();
		}

		override protected function onEnabled():void {

			super.onEnabled();

			_label = new Label();
			_label.text = "Feature not yet implemented.\nClick outside this pop up to dismiss it.";
			_container.addChild( _label );
			_label.validate();
			_label.x = _bg.width / 2 - _label.width / 2;
			_label.y = _bg.height / 2 - _label.height / 2;
		}

		override protected function onDisabled():void {

			_container.removeChild( _label );
			_label.dispose();
			_label = null;

			super.onDisabled();
		}
	}
}
