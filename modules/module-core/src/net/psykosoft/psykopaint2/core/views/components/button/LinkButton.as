package net.psykosoft.psykopaint2.core.views.components.button
{

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.text.TextField;

	public class LinkButton extends Sprite
	{
		// Declared in Flash.
		public var tf:TextField;
		public var hit:Sprite;

		private var _defaultCt:ColorTransform;
		private var _downCt:ColorTransform;

		public function LinkButton() {
			super();

			hit.alpha = 0;

			tf.mouseEnabled = tf.selectable = false;
			tf.multiline = false;

			_defaultCt = new ColorTransform();
			_downCt = new ColorTransform( 0, 0, 0, 1, 255 );

			addEventListener(Event.ADDED_TO_STAGE, stageInitHandler);
		}

		public function dispose():void {
			hit.removeEventListener( MouseEvent.MOUSE_DOWN, onHitMouseDown );
			if( stage && stage.hasEventListener( MouseEvent.MOUSE_UP ) ) stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
		}

		private function stageInitHandler( event:Event ):void {
			removeEventListener(Event.ADDED_TO_STAGE, stageInitHandler);
			hit.addEventListener( MouseEvent.MOUSE_DOWN, onHitMouseDown );
			stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
		}

		private function onHitMouseDown( event:MouseEvent ):void {
			tf.transform.colorTransform = _downCt;
		}

		private function onStageMouseUp( event:MouseEvent ):void {
			tf.transform.colorTransform = _defaultCt;
		}

		public function set labelText( value:String ):void {
			tf.text = value;
			tf.width = tf.textWidth * 1.1;
			tf.x = hit.x = -tf.width / 2;
			hit.width = tf.width;
		}
	}
}
