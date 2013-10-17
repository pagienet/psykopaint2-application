package net.psykosoft.psykopaint2.home.views.home
{
	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.models.EaselRectModel;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingDataSetSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselUpdateSignal;

	import robotlegs.bender.bundles.mvcs.Mediator;

	public class EaselViewMediator extends Mediator
	{
		[Inject]
		public var view : EaselView;

		[Inject]
		public var easelRectModel : EaselRectModel;

		[Inject]
		public var requestEaselPaintingUpdateSignal : RequestEaselUpdateSignal;

		[Inject]
		public var notifyPaintingDataRetrievedSignal : NotifyPaintingDataSetSignal;


		public function EaselViewMediator()
		{
		}

		private function onEaselRectChanged() : void
		{
			easelRectModel.absoluteScreenRect = view.easelRect;
		}

		override public function initialize() : void
		{
			super.initialize();
			view.easelRectChanged.add(onEaselRectChanged);
			requestEaselPaintingUpdateSignal.add(onEaselUpdateRequest);
			notifyPaintingDataRetrievedSignal.add(onPaintingDataRetrieved);
		}

		override public function destroy() : void
		{
			super.destroy();
			view.easelRectChanged.remove(onEaselRectChanged);
			requestEaselPaintingUpdateSignal.remove(onEaselUpdateRequest);
			notifyPaintingDataRetrievedSignal.remove(onPaintingDataRetrieved);
		}

		private function onEaselUpdateRequest(paintingVO : PaintingInfoVO, animateIn : Boolean = false, onUploadComplete : Function = null) : void
		{
			view.setContent(paintingVO, animateIn, onUploadComplete);
		}

		private function onPaintingDataRetrieved(data : Vector.<PaintingInfoVO>) : void
		{
			if (data.length > 0)
				view.setContent(data[0]);
		}

	}
}
