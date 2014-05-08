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

		protected function matchBackgroundWidthToText( plus:Number = 30 ):void {
			_background.width = Math.max( _textfield.width + plus, 100 );
		}

		public function randomizeLabelColor():void {
			var randomHue:int = Math.random() * 360;
//			var randomSat:Number = Math.random() + 1;
			TweenLite.to( _background, 0, { colorMatrixFilter: { hue: randomHue } } );
		}

		public function colorizeBackground( color:uint ):void {

//			trace("BackgroundLabel - colorizeBackground: " + color);

			// Hex -> RGB
			var r:uint = ((color & 0xFF0000) >> 16) / 255;
			var g:uint = ((color & 0x00FF00) >> 8) / 255;
			var b:uint = ((color & 0x0000FF)) / 255;

			// RGB -> HSV
			var luminance:Number =  r * 0.299 + g * 0.587 + b * 0.114;
			var u:Number = - r * 0.1471376975169300226 - g * 0.2888623024830699774 + b * 0.436;
			var v:Number =   r * 0.615 - g * 0.514985734664764622 - b * 0.100014265335235378;
			var hue:Number = Math.atan2( v, u );
			var saturation:Number = Math.sqrt( u*u + v*v );

			TweenLite.to( _background, 0.1, { colorMatrixFilter: { hue: hue, saturation: saturation, luminance: luminance } } );
		}
	}
}
