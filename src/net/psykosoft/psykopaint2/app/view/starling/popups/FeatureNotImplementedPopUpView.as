package net.psykosoft.psykopaint2.app.view.starling.popups
{

	import feathers.controls.Label;

	import net.psykosoft.psykopaint2.app.view.starling.popups.base.PopUpViewBase;

	public class FeatureNotImplementedPopUpView extends PopUpViewBase
	{
		public function FeatureNotImplementedPopUpView() {
			super();
		}

		override protected function onStageAvailable():void {

			super.onStageAvailable();

			var label:Label = new Label();
			label.text = "Feature not yet implemented.\nClick outside this pop up to dismiss it.";
			_container.addChild( label );
			label.validate();
			label.x = _bg.width / 2 - label.width / 2;
			label.y = _bg.height / 2 - label.height / 2;

		}
	}
}
