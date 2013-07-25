package net.psykosoft.psykopaint2.base.ui.components
{

	import com.greensock.TweenLite;

	import flash.display.Sprite;

	public class BackgroundLabel extends PsykoLabel
	{
		protected var _background:Sprite;

		public function BackgroundLabel() {
			super();
		}

		protected function setBackground( background:Sprite ):void {
			_background = background;
		}

		override public function set text( value:String ):void {
			super.text = value;
			randomizeLabelColor();
		}

		override protected function validateDimensions():void {
			super.validateDimensions();
			matchBackgroundWidthToText();
			_background.x = -_background.width / 2;
		}

		protected function matchBackgroundWidthToText():void {
			_background.width = Math.max( _textfield.width + 30, 100 );
		}

		private function randomizeLabelColor():void {
			var randomHue:int = Math.random() * 360;
			var randomSat:Number = Math.random() + 1;
			TweenLite.to( _background, 0, { colorMatrixFilter: { hue: randomHue, saturation: randomSat } } );
		}
	}
}
