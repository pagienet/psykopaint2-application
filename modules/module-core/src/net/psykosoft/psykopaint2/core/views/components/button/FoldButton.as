package net.psykosoft.psykopaint2.core.views.components.button
{

	import com.greensock.TweenLite;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class FoldButton extends Sprite
	{
		// Declared in Flash.
		public var bg:MovieClip;
		public var tf:TextField;
		public var spinner:Sprite;

		public var foldParameter:Number;

		private var _defaultTfY:Number;

		public function FoldButton() {
			super();

			bg.stop();

			tf.mouseEnabled = tf.selectable = false;

			foldParameter = 1;

			_defaultTfY = tf.y;

			spinner.visible = false;

			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		public function dispose():void {

			TweenLite.killTweensOf( this );

			if( hasEventListener( Event.ADDED_TO_STAGE ) )	removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			if( hasEventListener( MouseEvent.MOUSE_DOWN ) )	removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			if( stage && stage.hasEventListener( MouseEvent.MOUSE_UP ) ) stage.removeEventListener( MouseEvent.MOUSE_UP, onMouseUp );

			dontSpin();
		}

		public function set labelText( value:String ):void {
			tf.text = value;
			tf.width = tf.textWidth + 10;
			tf.height = 1.25 * tf.textHeight;
			tf.x = 65 - tf.width / 2;
		}

		// -----------------------
		// Spin animation.
		// -----------------------

		public function spin():void {
			TweenLite.killTweensOf( this );
			spinner.visible = true;
			tf.visible = false;
			addEventListener( Event.ENTER_FRAME, onEnterFrame );
			bg.gotoAndStop( 4 );
		}

		public function dontSpin():void {
			TweenLite.killTweensOf( this );
			bg.gotoAndStop( 1 );
			spinner.visible = false;
			tf.visible = true;
			if( hasEventListener( Event.ENTER_FRAME ) ) removeEventListener( Event.ENTER_FRAME, onEnterFrame );
		}

		// -----------------------
		// Fold animation.
		// -----------------------

		private function foldDown():void {
			if( bg.currentFrame == 4 ) return;
			TweenLite.killTweensOf( this );
			TweenLite.to( this, 0.1, { foldParameter: 0, onUpdate: onFoldUpdate } );
		}

		private function foldUp():void {
			if( bg.currentFrame == 4 ) return;
			TweenLite.killTweensOf( this );
			TweenLite.to( this, 0.05, { foldParameter: 1, onUpdate: onFoldUpdate } );
		}

		private function onFoldUpdate():void {
			if( bg.currentFrame == 4 ) return;
			if( foldParameter == 1 ) {
				bg.gotoAndStop( 1 );
				tf.y = _defaultTfY;
			}
			else if( foldParameter >= 0.5 ) {
				bg.gotoAndStop( 2 );
				tf.y = _defaultTfY + 2;
			}
			else {
				bg.gotoAndStop( 3 );
				tf.y = _defaultTfY + 5;
			}
		}

		// -----------------------
		// Event handlers.
		// -----------------------

		private function onEnterFrame( event:Event ):void {
			spinner.rotation += 2;
		}

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			stage.addEventListener( MouseEvent.MOUSE_UP, onMouseUp );
		}

		private function onMouseUp( event:MouseEvent ):void {
			foldUp();
		}

		private function onMouseDown( event:MouseEvent ):void {
			foldDown();
		}
	}
}
