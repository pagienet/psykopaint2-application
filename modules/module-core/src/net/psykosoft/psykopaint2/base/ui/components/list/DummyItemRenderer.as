package net.psykosoft.psykopaint2.base.ui.components.list
{

	import flash.display.Sprite;
	import flash.text.TextField;

	public class DummyItemRenderer extends Sprite
	{
		private static var _numCreatedRenderers:uint;

		private var _label:String;
		private var _tf:TextField;
		private var _instanceIndex:uint;

		public function DummyItemRenderer() {
			super();

			this.graphics.beginFill( 0xFFFFFF, 1.0 );
			this.graphics.drawRect( -50, -50, 100, 100 );
			this.graphics.endFill();

			_tf = new TextField();
			_tf.x = -50;
			_tf.y = -50;
			_tf.width = 100;
			_tf.mouseEnabled = _tf.selectable = false;
			addChild( _tf );

			_instanceIndex = _numCreatedRenderers;
			_numCreatedRenderers++;
		}

		public function get label():String {
			return _label;
		}

		public function set label( value:String ):void {
			_label = value;
			_tf.text = _label + ", ins: " + _instanceIndex;
		}
	}
}
