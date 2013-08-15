package net.psykosoft.psykopaint2.app.states
{
	import net.psykosoft.psykopaint2.app.signals.NotifyFrozenBackgroundCreatedSignal;
	import net.psykosoft.psykopaint2.app.signals.RequestCreateBookBackgroundSignal;
	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.book.BookImageSource;
	import net.psykosoft.psykopaint2.book.signals.NotifyBookModuleSetUpSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestSetUpBookModuleSignal;
	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedTexture;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestDestroyHomeModuleSignal;

	public class TransitionHomeToBookState extends State
	{
		[Inject]
		public var requestStateChange : RequestNavigationStateChangeSignal;

		[Inject]
		public var requestSetUpBookModuleSignal : RequestSetUpBookModuleSignal;

		[Inject]
		public var notifyBookModuleSetUpSignal : NotifyBookModuleSetUpSignal;

		[Inject]
		public var requestDestroyHomeModuleSignal : RequestDestroyHomeModuleSignal;

		[Inject]
		public var notifyBackgroundSetSignal : NotifyFrozenBackgroundCreatedSignal;

		[Inject]
		public var requestCreateBookBackgroundSignal : RequestCreateBookBackgroundSignal;

		[Inject]
		public var bookState : BookState;

		private var _source : String;
		private var _background : RefCountedTexture;

		public function TransitionHomeToBookState()
		{
		}

		/**
		 * @param data Any value in BookImageSource
		 */
		override ns_state_machine function activate(data : Object = null) : void
		{
			_source = String(data);

			notifyBookModuleSetUpSignal.addOnce(onBookModuleSetUp);
			requestSetUpBookModuleSignal.dispatch(_source);
		}

		private function onBookModuleSetUp() : void
		{
			notifyBackgroundSetSignal.addOnce(onBackgroundSet);
			requestCreateBookBackgroundSignal.dispatch();
		}

		private function onBackgroundSet(background : RefCountedTexture) : void
		{
			switch (_source) {
				case BookImageSource.SAMPLE_IMAGES:
					requestStateChange.dispatch(NavigationStateType.BOOK_PICK_SAMPLE_IMAGE);
					break;
				case BookImageSource.USER_IMAGES:
					requestStateChange.dispatch(NavigationStateType.BOOK_PICK_USER_IMAGE_IOS);
					break;
			}

			if (_background)
				_background.dispose();

			_background = background.newReference();
			stateMachine.setActiveState(bookState);
		}

		override ns_state_machine function deactivate() : void
		{
			if (_background)
				_background.dispose();
			_background = null;
			requestDestroyHomeModuleSignal.dispatch();
		}
	}
}
