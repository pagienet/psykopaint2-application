package net.psykosoft.psykopaint2.book.config
{

	import net.psykosoft.psykopaint2.book.commands.DestroyBookModuleCommand;
	import net.psykosoft.psykopaint2.book.commands.FetchSourceImagesCommand;
	import net.psykosoft.psykopaint2.book.commands.SetUpBookModuleCommand;
	import net.psykosoft.psykopaint2.book.services.CameraRollService;
	import net.psykosoft.psykopaint2.book.services.SampleImageService;
	import net.psykosoft.psykopaint2.book.services.DummyCameraRollService;
	import net.psykosoft.psykopaint2.book.services.DummySampleImageService;
	import net.psykosoft.psykopaint2.book.signals.NotifyAnimateBookOutCompleteSignal;
	import net.psykosoft.psykopaint2.book.signals.NotifyBookModuleDestroyedSignal;
	import net.psykosoft.psykopaint2.book.signals.NotifyBookModuleSetUpSignal;
	import net.psykosoft.psykopaint2.book.signals.NotifyImageSelectedFromBookSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestAnimateBookOutSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestBookRootViewRemovalSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestDestroyBookModuleSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestExitBookSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestFetchSourceImagesSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestSetBookBackgroundSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestSetUpBookModuleSignal;
	import net.psykosoft.psykopaint2.book.views.base.BookRootView;
	import net.psykosoft.psykopaint2.book.views.base.BookRootViewMediator;
	import net.psykosoft.psykopaint2.book.views.book.BookSubNavView;
	import net.psykosoft.psykopaint2.book.views.book.BookSubNavViewMediator;
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
			mapNotifications();
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
			// TODO: Provide actual communicating ones
			_injector.map(CameraRollService).toSingleton(DummyCameraRollService);
			_injector.map(SampleImageService).toSingleton(DummySampleImageService);
		}

		// -----------------------
		// Notifications.
		// -----------------------

		private function mapNotifications() : void
		{
			_injector.map(NotifyBookModuleSetUpSignal).asSingleton();
			_injector.map(NotifyBookModuleDestroyedSignal).asSingleton();
			_injector.map(RequestBookRootViewRemovalSignal).asSingleton();
			_injector.map(RequestSetBookBackgroundSignal).asSingleton();
			_injector.map(NotifyImageSelectedFromBookSignal).asSingleton();
			_injector.map(RequestAnimateBookOutSignal).asSingleton();
			_injector.map(NotifyAnimateBookOutCompleteSignal).asSingleton();
			_injector.map(RequestExitBookSignal).asSingleton();

		}

		// -----------------------
		// Commands.
		// -----------------------

		private function mapCommands() : void
		{
			_commandMap.map(RequestSetUpBookModuleSignal).toCommand(SetUpBookModuleCommand);
			_commandMap.map(RequestDestroyBookModuleSignal).toCommand(DestroyBookModuleCommand);
			_commandMap.map(RequestFetchSourceImagesSignal).toCommand(FetchSourceImagesCommand);
		}

		// -----------------------
		// View mediators.
		// -----------------------

		private function mapMediators() : void
		{
			_mediatorMap.map(BookRootView).toMediator(BookRootViewMediator);
			_mediatorMap.map(BookView).toMediator(BookViewMediator);
			_mediatorMap.map(BookSubNavView).toMediator(BookSubNavViewMediator);
		}
	}
}
