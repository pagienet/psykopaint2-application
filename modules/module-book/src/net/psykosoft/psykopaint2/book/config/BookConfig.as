package net.psykosoft.psykopaint2.book.config
{

	import net.psykosoft.psykopaint2.book.commands.DestroyBookModuleCommand;
	import net.psykosoft.psykopaint2.book.commands.SetUpBookModuleCommand;
	import net.psykosoft.psykopaint2.book.signals.NotifyBookModuleDestroyedSignal;
	import net.psykosoft.psykopaint2.book.signals.NotifyBookModuleSetUpSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestBookRootViewRemovalSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestDestroyBookModuleSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestSetBookBackgroundSignal;
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

		}

		// -----------------------
		// Commands.
		// -----------------------

		private function mapCommands() : void
		{
			_commandMap.map(RequestSetUpBookModuleSignal).toCommand(SetUpBookModuleCommand);
			_commandMap.map(RequestDestroyBookModuleSignal).toCommand(DestroyBookModuleCommand);
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
