package net.psykosoft.psykopaint2.book.views.book
{
	import away3d.core.managers.Stage3DProxy;

	import flash.display.BitmapData;
	import flash.html.script.Package;

	import net.psykosoft.psykopaint2.book.BookImageSource;
	import net.psykosoft.psykopaint2.book.signals.NotifyAnimateBookOutCompleteSignal;
	import net.psykosoft.psykopaint2.book.signals.NotifyImageSelectedFromBookSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestAnimateBookOutSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestSetBookBackgroundSignal;
	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedTexture;

	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderManager;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderingStepType;

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

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();

			registerEnablingState( NavigationStateType.BOOK_STANDALONE );
			// TODO: Probably a "book" state is plenty; get image source from set up command
			registerEnablingState( NavigationStateType.BOOK_PICK_SAMPLE_IMAGE );
			registerEnablingState( NavigationStateType.BOOK_PICK_USER_IMAGE_IOS );

			view.stage3dProxy = stage3dProxy;

			view.enabledSignal.add(onEnabled);
			view.disabledSignal.add(onDisabled);
			view.bookHasClosedSignal.add(onAnimateOutComplete);

		}

		private function onEnabled() : void
		{
			view.imageSelectedSignal.add(onImageSelected);
			requestAnimateBookOutSignal.add(onRequestAnimateBookOutSignal);
			requestSetBookBackgroundSignal.add(onRequestSetBookBackgroundSignal);
			GpuRenderManager.addRenderingStep( view.renderScene, GpuRenderingStepType.NORMAL );
		}

		private function onDisabled() : void
		{
			view.imageSelectedSignal.remove(onImageSelected);
			requestAnimateBookOutSignal.remove(onRequestAnimateBookOutSignal);
			requestSetBookBackgroundSignal.remove(onRequestSetBookBackgroundSignal);
			GpuRenderManager.removeRenderingStep( view.renderScene, GpuRenderingStepType.NORMAL );
		}

		private function onRequestSetBookBackgroundSignal(texture : RefCountedTexture) : void
		{
			view.backgroundTexture = texture;
		}

		override protected function onStateChange( newState:String ):void {
			super.onStateChange( newState );

			switch( newState ) {
				// Sample images. as default
				case NavigationStateType.BOOK_STANDALONE:
				case NavigationStateType.BOOK_PICK_SAMPLE_IMAGE:
					view.layoutType = BookImageSource.SAMPLE_IMAGES;
					break;

				// User photos iOS.//defaulted to samples for now
				case NavigationStateType.BOOK_PICK_USER_IMAGE_IOS:
					view.layoutType = BookImageSource.SAMPLE_IMAGES;
					break;
			}
		}

		private function onImageSelected(selectedBmd:BitmapData):void
		{
			notifyImageSelectedFromBookSignal.dispatch( selectedBmd );
		}

		private function onRequestAnimateBookOutSignal() : void
		{
			view.book.closePages();
		}

		private function onAnimateOutComplete() : void
		{
			notifyAnimateBookOutCompleteSignal.dispatch();
		}
	}
}
