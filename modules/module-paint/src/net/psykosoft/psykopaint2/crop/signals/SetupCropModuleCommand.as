package net.psykosoft.psykopaint2.crop.signals
{
	import flash.display.BitmapData;
	
	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.core.signals.RequestAddViewToMainLayerSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUpdateCropImageSignal;
	import net.psykosoft.psykopaint2.core.views.base.ViewLayerOrdering;
	import net.psykosoft.psykopaint2.crop.views.base.CropRootView;

	public class SetupCropModuleCommand extends TracingCommand
	{
		[Inject]
		public var bitmapData : BitmapData;
		
		[Inject]
		public var orientation : int;

		[Inject]
		public var notifyCropModuleSetUpSignal : NotifyCropModuleSetUpSignal;

		[Inject]
		public var requestUpdateCropImageSignal : RequestUpdateCropImageSignal;

		[Inject]
		public var requestAddViewToMainLayerSignal : RequestAddViewToMainLayerSignal;

		override public function execute() : void
		{
			super.execute();

			var cropRootView : CropRootView = new CropRootView();
			requestAddViewToMainLayerSignal.dispatch(cropRootView,ViewLayerOrdering.AT_BOTTOM_LAYER);
			requestUpdateCropImageSignal.dispatch(bitmapData, orientation);
			notifyCropModuleSetUpSignal.dispatch();
		}
	}
}
