package net.psykosoft.psykopaint2.core.views.navigation
{

	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;
	
	import flash.display.Sprite;
	import flash.text.TextField;

	public class NavigationHeader extends Sprite
	{
		// Declared in Flash.
		public var tf:TextField;
		public var bg:Sprite;
		public var lowerEdge:Number;
		
		public function NavigationHeader() {
			super();
		}

		public function setTitle( value:String ):void {

			TweenLite.killTweensOf( bg );
			y = lowerEdge + bg.height;

			if( value == "" ) {
				visible = false;
				return;
			}
			else {
				visible = true;
			}

			tf.text = value.toUpperCase();

			tf.height = 1.25 * tf.textHeight;
			tf.width = 15 + tf.textWidth;
			tf.x = -tf.width / 2;

			bg.width = tf.width + 50;
			bg.x = -bg.width / 2 + 5;

			animateHeaderIn();
		}

		private function animateHeaderIn():void {
			TweenLite.to( this, 0.5, { y: lowerEdge, ease: Strong.easeOut, onComplete: animateHeaderOut } );
		}

		private function animateHeaderOut():void {
			TweenLite.to( this, 0.25, { delay: 2, y: lowerEdge + bg.height, ease: Strong.easeIn, onComplete: onHeaderOutComplete } );
		}

		private function onHeaderOutComplete():void {
			visible = false;
		}
	}
}
