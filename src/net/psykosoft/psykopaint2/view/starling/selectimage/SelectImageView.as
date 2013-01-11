package net.psykosoft.psykopaint2.view.starling.selectimage
{

	import feathers.controls.Label;

	import net.psykosoft.psykopaint2.view.starling.base.StarlingViewBase;

	public class SelectImageView extends StarlingViewBase
	{
		public function SelectImageView() {
			super();
		}

		override protected function onStageAvailable():void {

			var label:Label = new Label();
			label.text = "Displays images the user can load to start painting on.\nPlease select an image bank source.";
			addChild( label );
			label.validate();
			label.x = stage.stageWidth / 2 - label.width / 2;
			label.y = stage.stageHeight / 2 - label.height / 2;

			super.onStageAvailable();
		}
	}
}
