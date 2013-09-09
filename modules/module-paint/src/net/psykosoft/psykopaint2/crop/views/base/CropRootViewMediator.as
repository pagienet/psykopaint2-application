package net.psykosoft.psykopaint2.crop.views.base
{

	import net.psykosoft.psykopaint2.crop.signals.RequestCropRootViewRemovalSignal;

	import robotlegs.bender.bundles.mvcs.Mediator;

	public class CropRootViewMediator extends Mediator
	{
		[Inject]
		public var view:CropRootView;

		[Inject]
		public var requestCropRootViewRemovalSignal:RequestCropRootViewRemovalSignal;

		override public function initialize():void {

			// From app.
			requestCropRootViewRemovalSignal.add( onRemovalRequest );
		}

		override public function destroy():void {
			requestCropRootViewRemovalSignal.remove( onRemovalRequest );
		}

		private function onRemovalRequest():void {
			view.dispose();
			view.parent.removeChild( view );
		}
	}
}
