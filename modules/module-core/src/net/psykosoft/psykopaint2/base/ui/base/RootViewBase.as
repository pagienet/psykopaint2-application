package net.psykosoft.psykopaint2.base.ui.base
{

	import flash.display.Sprite;

	import org.osflash.signals.Signal;

	public class RootViewBase extends Sprite
	{
		private var _registeredViewCount:uint;
		private var _readyViewCount:uint;

		public var allViewsReadySignal:Signal;

		public function RootViewBase() {

			super();

			allViewsReadySignal = new Signal();
			
			//not sure if this is bad, but it does not seem to be harmful either
			mouseEnabled = false;
		}

		protected function addRegisteredView( view:ViewBase, toContainer:Sprite ):void {
			trace( this, "registering view: " + view );
			_registeredViewCount++;
			view.readySignal.addOnce( onViewReady );
			toContainer.addChild( view );
		}

		private function onViewReady():void {
			_readyViewCount++;
			trace( this, "view ready: " + _readyViewCount + "/" + _registeredViewCount );
			if( _readyViewCount == _registeredViewCount ) {
				trace( this, "<<< all views ready >>>" );
				allViewsReadySignal.dispatch();
			}
		}
	}
}
