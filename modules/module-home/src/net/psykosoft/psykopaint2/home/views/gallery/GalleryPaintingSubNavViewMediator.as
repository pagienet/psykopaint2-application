package net.psykosoft.psykopaint2.home.views.gallery
{
	import net.psykosoft.psykopaint2.core.models.GalleryType;
	import net.psykosoft.psykopaint2.core.signals.NotifyLovePaintingFailedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyLovePaintingSucceededSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestLovePaintingSignal;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.home.model.ActiveGalleryPaintingModel;
	import net.psykosoft.psykopaint2.home.signals.RequestBrowseGallerySignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHomePanningToggleSignal;

	public class GalleryPaintingSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view : GalleryPaintingSubNavView;

		[Inject]
		public var requestHomePanningToggleSignal:RequestHomePanningToggleSignal;

		[Inject]
		public var requestBrowseGallery : RequestBrowseGallerySignal;

		[Inject]
		public var requestLovePaintingSignal : RequestLovePaintingSignal;

		[Inject]
		public var notifyLovePaintingSucceededSignal : NotifyLovePaintingSucceededSignal;

		[Inject]
		public var notifyLovePaintingFailedSignal : NotifyLovePaintingFailedSignal;

		[Inject]
		public var activeGalleryPaintingModel : ActiveGalleryPaintingModel;


		public function GalleryPaintingSubNavViewMediator()
		{
			super();
		}

		override public function initialize() : void
		{
			// Init.
			registerView(view);
			super.initialize();
			if (activeGalleryPaintingModel.activePainting)
				updateLoveButton();
			activeGalleryPaintingModel.onChange.add(onActivePaintingChanged);
		}

		override public function destroy() : void
		{
			activeGalleryPaintingModel.onChange.remove(onActivePaintingChanged);
			super.destroy();
		}

		private function onActivePaintingChanged() : void
		{
			updateLoveButton();
		}

		private function updateLoveButton() : void
		{
			view.enableButtonWithId(GalleryPaintingSubNavView.ID_LOVE, !activeGalleryPaintingModel.activePainting.isFavorited);
		}

		override protected function onButtonClicked(id : String) : void
		{
			switch (id) {
				case GalleryBrowseSubNavView.ID_BACK:
					requestHomePanningToggleSignal.dispatch(-1);
					// TODO:Should go back to previously active book state
					requestBrowseGallery.dispatch(GalleryType.MOST_RECENT);
					break;
				case GalleryPaintingSubNavView.ID_LOVE:
					view.enableButtonWithId(GalleryPaintingSubNavView.ID_LOVE, false);
					notifyLovePaintingFailedSignal.add(onLovePaintingFailed);
					notifyLovePaintingSucceededSignal.add(onLovePaintingSucceeded);
					requestLovePaintingSignal.dispatch(activeGalleryPaintingModel.activePainting.id);
					break;
			}
		}

		private function onLovePaintingSucceeded() : void
		{
			// put here just in case we want to give feedback in the button
		}

		private function onLovePaintingFailed(amfErrorCode : uint) : void
		{
			// TODO: Display whoops message

			// do not simply set to true, you never know...
			updateLoveButton();
		}
	}
}
