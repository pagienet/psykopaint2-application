package net.psykosoft.psykopaint2.book.config
{

	import net.psykosoft.psykopaint2.book.commands.DestroyBookModuleCommand;
	import net.psykosoft.psykopaint2.book.commands.FetchGalleryImagesCommand;
	import net.psykosoft.psykopaint2.book.commands.FetchSourceImagesCommand;
	import net.psykosoft.psykopaint2.book.commands.SetUpBookModuleCommand;
	import net.psykosoft.psykopaint2.book.services.ANECameraRollService;
	import net.psykosoft.psykopaint2.book.services.CameraRollService;
	import net.psykosoft.psykopaint2.book.services.SampleImageService;
	import net.psykosoft.psykopaint2.book.services.XMLSampleImageService;
	import net.psykosoft.psykopaint2.book.signals.NotifyAnimateBookOutCompleteSignal;
	import net.psykosoft.psykopaint2.book.signals.NotifyBookModuleDestroyedSignal;
	import net.psykosoft.psykopaint2.book.signals.NotifyBookModuleSetUpSignal;
	import net.psykosoft.psykopaint2.book.signals.NotifyGalleryImageSelectedFromBookSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestOpenBookSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyGalleryImagesFailedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyGalleryImagesFetchedSignal;
	import net.psykosoft.psykopaint2.book.signals.NotifySourceImageSelectedFromBookSignal;
	import net.psykosoft.psykopaint2.book.signals.NotifySourceImagesFetchedSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestAnimateBookOutSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestBookRootViewRemovalSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestDestroyBookModuleSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestFetchGalleryImagesSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestFetchSourceImagesSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestSetUpBookModuleSignal;
	import net.psykosoft.psykopaint2.book.views.base.BookRootView;
	import net.psykosoft.psykopaint2.book.views.base.BookRootViewMediator;
	import net.psykosoft.psykopaint2.book.views.book.BookView;
	import net.psykosoft.psykopaint2.book.views.book.BookViewMediator;

	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;
	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;
	import robotlegs.bender.framework.api.IInjector;

	public class BookConfig
	{
		private var _injector : IInjector;
		private var _mediatorMap : IMediatorMap;
		private var _commandMap : ISignalCommandMap;

		public function BookConfig(injector : IInjector)
		{
			super();

			_injector = injector;
			_mediatorMap = _injector.getInstance(IMediatorMap);
			_commandMap = _injector.getInstance(ISignalCommandMap);

			mapMediators();
			mapCommands();
			mapSignals();
			mapSingletons();
			mapServices();
			mapModels();
		}

		public function get injector() : IInjector
		{
			return _injector;
		}

		// -----------------------
		// Models.
		// -----------------------

		private function mapModels() : void
		{

		}

		// -----------------------
		// Services.
		// -----------------------

		private function mapServices() : void
		{

		}

		// -----------------------
		// Singletons.
		// -----------------------

		private function mapSingletons() : void
		{
			_injector.map(CameraRollService).toSingleton(ANECameraRollService);
			_injector.map(SampleImageService).toSingleton(XMLSampleImageService);
		}

		// -----------------------
		// Notifications.
		// -----------------------

		private function mapSignals() : void
		{
			_injector.map(NotifyBookModuleSetUpSignal).asSingleton();
			_injector.map(NotifyBookModuleDestroyedSignal).asSingleton();
			_injector.map(RequestBookRootViewRemovalSignal).asSingleton();
			_injector.map(NotifySourceImageSelectedFromBookSignal).asSingleton();
			_injector.map(RequestAnimateBookOutSignal).asSingleton();
			_injector.map(NotifyAnimateBookOutCompleteSignal).asSingleton();
			_injector.map(NotifySourceImagesFetchedSignal).asSingleton();
			_injector.map(NotifyGalleryImagesFetchedSignal).asSingleton();
			_injector.map(NotifyGalleryImagesFailedSignal).asSingleton();
			_injector.map(NotifyGalleryImageSelectedFromBookSignal).asSingleton();
			_injector.map(RequestOpenBookSignal).asSingleton();

		}

		// -----------------------
		// Commands.
		// -----------------------

		private function mapCommands() : void
		{
			_commandMap.map(RequestSetUpBookModuleSignal).toCommand(SetUpBookModuleCommand);
			_commandMap.map(RequestDestroyBookModuleSignal).toCommand(DestroyBookModuleCommand);
			_commandMap.map(RequestFetchSourceImagesSignal).toCommand(FetchSourceImagesCommand);
			_commandMap.map(RequestFetchGalleryImagesSignal).toCommand(FetchGalleryImagesCommand);
		}

		// -----------------------
		// View mediators.
		// -----------------------

		private function mapMediators() : void
		{
			_mediatorMap.map(BookRootView).toMediator(BookRootViewMediator);
			_mediatorMap.map(BookView).toMediator(BookViewMediator);
		}
	}
}
