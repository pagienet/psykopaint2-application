package net.psykosoft.psykopaint2.core.views.popups
{

	import flash.text.TextField;

	import net.psykosoft.psykopaint2.core.views.popups.base.PopUpViewBase;

	public class SavingPopUpView extends PopUpViewBase
	{
		public function SavingPopUpView() {
			super();
		}

		override protected function onEnabled():void {
			super.onEnabled();

			_container.graphics.beginFill( 0xCCCCCC, 1.0 );
			_container.graphics.drawRect( 0, 0, 128, 64 );
			_container.graphics.endFill();

			var tf:TextField = new TextField();
			tf.selectable = tf.mouseEnabled = false;
			tf.width = 128;
			tf.height = 64;
			tf.text = "saving...";
			_container.addChild( tf );

			layout();
		}
	}
}
