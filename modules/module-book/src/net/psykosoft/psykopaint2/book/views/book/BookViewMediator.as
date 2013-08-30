package net.psykosoft.psykopaint2.book.views.book
{

	import away3d.core.managers.Stage3DProxy;

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.book.model.SourceImageCollection;
	import net.psykosoft.psykopaint2.book.signals.NotifyAnimateBookOutCompleteSignal;
	import net.psykosoft.psykopaint2.book.signals.NotifyBookModuleDestroyedSignal;
	import net.psykosoft.psykopaint2.book.signals.NotifyImageSelectedFromBookSignal;
	import net.psykosoft.psykopaint2.book.signals.NotifySourceImagesFetchedSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestAnimateBookOutSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestSetBookBackgroundSignal;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderManager;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderingStepType;
	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedTexture;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class BookViewMediator extends MediatorBase
	{
		[Inject]
		public var view:BookView;

		[Inject]
		public var stage3dProxy:Stage3DProxy;

		[Inject]
		public var requestSetBookBackgroundSignal : RequestSetBookBackgroundSignal;

		[Inject]
		public var notifyImageSelectedFromBookSignal:NotifyImageSelectedFromBookSignal;

		[Inject]
		public var requestAnimateBookOutSignal : RequestAnimateBookOutSignal;

		[Inject]
		public var notifyAnimateBookOutCompleteSignal : NotifyAnimateBookOutCompleteSignal;

		[Inject]
		public var notifySourceImagesFetchedSignal : NotifySourceImagesFetchedSignal;

		[Inject]
		public var notifyBookModuleDestroyedSignal : NotifyBookModuleDestroyedSignal;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();

			registerEnablingState( NavigationStateType.BOOK );

			view.stage3dProxy = stage3dProxy;

			view.enabledSignal.add(onEnabled);
			view.disabledSignal.add(onDisabled);
			view.bookDisposedSignal.add( onBookDisposed );
		}

		private function onBookDisposed():void {
			notifyBookModuleDestroyedSignal.dispatch();
		}

		override public function destroy() : void
		{
			super.destroy();
			view.enabledSignal.remove(onEnabled);
			view.disabledSignal.remove(onDisabled);
		}

		private function onEnabled() : void
		{
			view.imageSelectedSignal.add(onImageSelected);
			requestAnimateBookOutSignal.add(onRequestAnimateBookOutSignal);
			requestSetBookBackgroundSignal.add(onRequestSetBookBackgroundSignal);
			notifySourceImagesFetchedSignal.add(onSourceImagesFetched);
			GpuRenderManager.addRenderingStep( view.renderScene, GpuRenderingStepType.NORMAL );
		}

		private function onDisabled() : void
		{
			view.imageSelectedSignal.remove(onImageSelected);
			requestAnimateBookOutSignal.remove(onRequestAnimateBookOutSignal);
			requestSetBookBackgroundSignal.remove(onRequestSetBookBackgroundSignal);
			notifySourceImagesFetchedSignal.remove(onSourceImagesFetched);
			GpuRenderManager.removeRenderingStep( view.renderScene, GpuRenderingStepType.NORMAL );
		}

		private function onRequestSetBookBackgroundSignal(texture : RefCountedTexture) : void
		{
			view.backgroundTexture = texture;
		}

		private function onImageSelected(selectedBmd:BitmapData):void
		{
			notifyImageSelectedFromBookSignal.dispatch( selectedBmd );
		}

		private function onRequestAnimateBookOutSignal() : void
		{
			view.bookHasClosedSignal.addOnce(onAnimateOutComplete);
			view.book.closePages();
		}

		private function onAnimateOutComplete() : void
		{
			notifyAnimateBookOutCompleteSignal.dispatch();
		}

		private function onSourceImagesFetched(collection : SourceImageCollection) : void
		{
			view.setSourceImages(collection);
		}
	}
}
