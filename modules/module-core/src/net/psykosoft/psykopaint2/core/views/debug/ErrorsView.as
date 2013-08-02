package net.psykosoft.psykopaint2.core.views.debug
{

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	public class ErrorsView extends Sprite
	{
		private var _errorsTextField:TextField;
		private var _errorCount:uint;
		private var _playedSound:Boolean;

		public function ErrorsView() {
			super();

			if( CoreSettings.SHOW_ERRORS ) {
				initErrorDisplay();
				loaderInfo.uncaughtErrorEvents.addEventListener( UncaughtErrorEvent.UNCAUGHT_ERROR, onGlobalError );
			}
		}

		private function initErrorDisplay():void {
			if( CoreSettings.SHOW_ERRORS ) {
				_errorsTextField = new TextField();
				_errorsTextField.name = "errors text field";
				_errorsTextField.scaleX = _errorsTextField.scaleY = CoreSettings.GLOBAL_SCALING;
				_errorsTextField.addEventListener( MouseEvent.MOUSE_UP, onErrorsMouseUp );
				_errorsTextField.width = 520 * CoreSettings.GLOBAL_SCALING;
				_errorsTextField.height = 250 * CoreSettings.GLOBAL_SCALING;
				_errorsTextField.x = ( 1024 - 520 - 1 ) * CoreSettings.GLOBAL_SCALING;
				_errorsTextField.y = CoreSettings.GLOBAL_SCALING;
				_errorsTextField.background = true;
				_errorsTextField.border = true;
				_errorsTextField.borderColor = 0xFF0000;
				_errorsTextField.multiline = true;
				_errorsTextField.wordWrap = true;
				_errorsTextField.visible = false;
				addChild( _errorsTextField );
			}
		}

		private function onGlobalError( event:UncaughtErrorEvent ):void {
			_errorCount++;
			var error:Error = event.error as Error;
			if (!error) {
				_errorsTextField.htmlText += "Anonymous error: " + event.error + "<br>";
				_errorsTextField.visible = true;
			}
			else {
				var stack:String = error.getStackTrace();
				_errorsTextField.htmlText += "<font color='#FF0000'><b>RUNTIME ERROR - " + _errorCount + "</b></font>: " + error + " - stack: " + stack + "<br>";
				_errorsTextField.visible = true;
			}

			// Comment to mute sound!
//			if( !_playedSound ) {
//				playPsychoSound();
//				_playedSound = true;
//			}
		}

		private function playPsychoSound():void {
			var newClipClass:Class = Class( getDefinitionByName( "psycho" ) );
			var hh:MovieClip = new newClipClass();
			hh.play();
		}

		private function onErrorsMouseUp( event:MouseEvent ):void {
			_errorsTextField.visible = false;
		}
	}
}
