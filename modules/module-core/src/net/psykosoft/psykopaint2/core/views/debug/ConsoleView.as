package net.psykosoft.psykopaint2.core.views.debug
{

	import flash.display.Sprite;
	import flash.text.TextField;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	public class ConsoleView extends Sprite
	{
		private var _tf:TextField;

		private static var _instance:ConsoleView;

		public function ConsoleView() {
			super();

			_tf = new TextField();
			_tf.name = "errors text field";
			_tf.scaleX = _tf.scaleY = CoreSettings.GLOBAL_SCALING;
			_tf.width = 1024 * CoreSettings.GLOBAL_SCALING;
			_tf.height = 250 * CoreSettings.GLOBAL_SCALING;
			_tf.background = true;
			_tf.border = true;
			_tf.multiline = true;
			_tf.wordWrap = true;
			_tf.mouseEnabled = _tf.selectable = false;
			_tf.backgroundColor = 0;
			_tf.textColor = 0xFFFFFF;
			_tf.alpha = 0.5;
			addChild( _tf );

			_instance = this;

			log( this, CoreSettings.NAME + " - " + CoreSettings.VERSION );
		}

		public static function get instance():ConsoleView {
			return _instance;
		}

		public function log( ...args ):void {
			var msg:String = "";
			var len:uint = args.length;
			for( var i:uint; i < len; i++ ) {
				msg += args[ i ];
				if( len > 1 && i != len - 1 ) msg += ", ";
			}
			msg += "\n";
			_tf.appendText( msg );
		}
	}
}
