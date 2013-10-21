package net.psykosoft.psykopaint2.home.views.home
{
	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.models.EaselRectModel;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingDataSetSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselUpdateSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestLoadPaintingDataFileSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestStartNewColorPaintingSignal;

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

		[Inject]
		public var requestLoadPaintingDataSignal : RequestLoadPaintingDataFileSignal;

		[Inject]
		public var requestStartNewPaintingCommand : RequestStartNewColorPaintingSignal;

		private var _selectedSurfaceID : uint;

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
			view.easelTappedSignal.add(onEaselTapped);
			requestEaselPaintingUpdateSignal.add(onEaselUpdateRequest);
			notifyPaintingDataRetrievedSignal.add(onPaintingDataRetrieved);
		}

		override public function destroy() : void
		{
			super.destroy();
			view.easelRectChanged.remove(onEaselRectChanged);
			view.easelTappedSignal.remove(onEaselTapped);
			requestEaselPaintingUpdateSignal.remove(onEaselUpdateRequest);
			notifyPaintingDataRetrievedSignal.remove(onPaintingDataRetrieved);
		}

		private function onEaselUpdateRequest(paintingVO : PaintingInfoVO, animateIn : Boolean = false, onUploadComplete : Function = null) : void
		{
			view.setContent(paintingVO, animateIn, onUploadComplete);

			// TODO: I'm not too fond of this
			if (paintingVO.id == PaintingInfoVO.DEFAULT_VO_ID)
				_selectedSurfaceID = paintingVO.surfaceID;
		}

		private function onPaintingDataRetrieved(data : Vector.<PaintingInfoVO>) : void
		{
			if (data.length > 0)
				view.setContent(data[0]);
		}

		private function onEaselTapped() : void
		{
			var paintingID : String = view.paintingID;

			if (paintingID == PaintingInfoVO.DEFAULT_VO_ID)
				requestStartNewPaintingCommand.dispatch(_selectedSurfaceID);
			else
				requestLoadPaintingDataSignal.dispatch(view.paintingID);
		}

	}
}
