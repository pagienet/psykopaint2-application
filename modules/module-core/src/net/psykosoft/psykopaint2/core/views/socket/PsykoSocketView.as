package net.psykosoft.psykopaint2.core.views.socket
{

	import com.bit101.components.InputText;
	import com.bit101.components.PushButton;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.NetStatusEvent;
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Keyboard;

	import net.psykosoft.psykopaint2.base.remote.PsykoSocket;
	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;

	public class PsykoSocketView extends ViewBase
	{
		private var _tf:InputText;
		private var _cookie:SharedObject;

		public function PsykoSocketView() {
			super();
		}

		override protected function onSetup():void {

			var container:Sprite = new Sprite();
			addChild( container );

			_tf = new InputText( container, 0, 0, "ip address" );
			_tf.textField.addEventListener( KeyboardEvent.KEY_DOWN, onTfKeyDown );
			var format:TextFormat = _tf.textField.defaultTextFormat;
			format.align = TextFormatAlign.CENTER;
			_tf.textField.defaultTextFormat = format;

			var btn:PushButton = new PushButton( container, _tf.width + 5, 0, "connect", onBtnPressed );
			_tf.height = btn.height;

			container.x = 1024 / 2 - container.width / 2;
			container.y = 5;

			retrieveCookie();
		}

		private function onTfKeyDown( event:KeyboardEvent ):void {
			if( event.keyCode == Keyboard.ENTER ) {
				trace( this, "enter pressed" );
				updateSocket();
			}
		}

		private function retrieveCookie():void {
			_cookie = SharedObject.getLocal( "psykosocket-ip" );
			trace( this, "cookie: " + _cookie.data.savedValue );
			if( _cookie && _cookie.data.savedValue != undefined ) {
				_tf.text = _cookie.data.savedValue;
			}
		}

		private function storeCookie():void {
			_cookie.data.savedValue = _tf.text;
			var flushStatus:String = null;
			try {
				flushStatus = _cookie.flush( 10000 );
			} catch( error:Error ) {
				trace( this, "Error... Could not write ip to disk." );
			}
			if( flushStatus != null ) {
				switch( flushStatus ) {
					case SharedObjectFlushStatus.PENDING:
						trace( this, "Requesting permission to save ip..." );
						_cookie.addEventListener( NetStatusEvent.NET_STATUS, onFlushStatus );
						break;
					case SharedObjectFlushStatus.FLUSHED:
						trace( this, "IP flushed to disk." );
						break;
				}
			}
		}

		private function onFlushStatus( event:NetStatusEvent ):void {
			trace( this, "User closed permission dialog...\n" );
			switch( event.info.code ) {
				case "SharedObject.Flush.Success":
					trace( this, "User granted permission -- ip saved.\n" );
					break;
				case "SharedObject.Flush.Failed":
					trace( this, "User denied permission -- ip not saved.\n" );
					break;
			}
			_cookie.removeEventListener( NetStatusEvent.NET_STATUS, onFlushStatus );
		}

		private function onBtnPressed( event:Event ):void {
			updateSocket();
		}

		private function updateSocket():void {
			trace( this, "connecting to: " + _tf.text );
			PsykoSocket.init( _tf.text );
			storeCookie();
		}
	}
}
