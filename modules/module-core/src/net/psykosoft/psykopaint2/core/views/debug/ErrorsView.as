package net.psykosoft.psykopaint2.core.views.debug
{

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.text.TextField;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	public class ErrorsView extends Sprite
	{
		private var _errorsTextField:TextField;
		private var _errorCount:uint;
		private var _discreteErrorSpr:Sprite;

		public function ErrorsView() {
			super();

			if( CoreSettings.SHOW_DISCRETE_ERRORS ) {
				initDiscreteErrorDisplay();
			}


			if( CoreSettings.SHOW_ERRORS ) {
				initErrorDisplay();
			}

			if( CoreSettings.SHOW_ERRORS || CoreSettings.SHOW_DISCRETE_ERRORS ) {
				addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			}
		}

		private function initDiscreteErrorDisplay():void {

			_discreteErrorSpr = new Sprite();
			addChild( _discreteErrorSpr );

			_discreteErrorSpr.graphics.beginFill(0xFF0000);
			_discreteErrorSpr.graphics.drawCircle(0, 0, 15);
			_discreteErrorSpr.graphics.endFill();

			_discreteErrorSpr.x = ( 1024 - 25 ) * CoreSettings.GLOBAL_SCALING;
			_discreteErrorSpr.y = ( 25 ) * CoreSettings.GLOBAL_SCALING;

			_discreteErrorSpr.visible = false;
		}

		private function initErrorDisplay():void {

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

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			loaderInfo.uncaughtErrorEvents.addEventListener( UncaughtErrorEvent.UNCAUGHT_ERROR, onGlobalError );
		}

		private function onGlobalError( event:UncaughtErrorEvent ):void {

			_errorCount++;

			var error:Error = event.error as Error;
			if (!error) {
				if( CoreSettings.SHOW_ERRORS ) {
					_errorsTextField.htmlText += "Anonymous error: " + event.error + "<br>";
					_errorsTextField.visible = true;
				}
			}
			else {
				if( CoreSettings.SHOW_ERRORS ) {
					var stack:String = error.getStackTrace();
					_errorsTextField.htmlText += "<font color='#FF0000'><b>RUNTIME ERROR - " + _errorCount + "</b></font>: " + error + " - stack: " + stack + "<br>";
					_errorsTextField.visible = true;
				}
			}

			if( CoreSettings.SHOW_DISCRETE_ERRORS ) {
				_discreteErrorSpr.visible = true;
			}
		}

		private function onErrorsMouseUp( event:MouseEvent ):void {
			_errorsTextField.visible = false;
		}
	}
}
