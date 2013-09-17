package net.psykosoft.psykopaint2.app.states
{

	import net.psykosoft.psykopaint2.app.signals.NotifyFrozenBackgroundCreatedSignal;
	import net.psykosoft.psykopaint2.app.signals.RequestCreateBookBackgroundSignal;
	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.book.model.GalleryType;
	import net.psykosoft.psykopaint2.book.signals.NotifyBookModuleSetUpSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestSetUpBookModuleSignal;
	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedTexture;
	import net.psykosoft.psykopaint2.home.signals.RequestDestroyHomeModuleSignal;

	public class TransitionHomeToBookState extends State
	{
		[Inject]
		public var requestSetUpBookModuleSignal : RequestSetUpBookModuleSignal;

		[Inject]
		public var notifyBookModuleSetUpSignal : NotifyBookModuleSetUpSignal;

		[Inject]
		public var notifyBackgroundSetSignal : NotifyFrozenBackgroundCreatedSignal;

		[Inject]
		public var requestCreateBookBackgroundSignal : RequestCreateBookBackgroundSignal;

		[Inject]
		public var bookState : BookState;

		private var _background : RefCountedTexture;
		private var _bookSourceType:String;

		public function TransitionHomeToBookState()
		{
		}

		/**
		 * @param data Any value in BookImageSource
		 */
		override ns_state_machine function activate(data : Object = null) : void
		{
			_bookSourceType = String(data);
			notifyBookModuleSetUpSignal.addOnce(onBookModuleSetUp);
			requestSetUpBookModuleSignal.dispatch();
		}

		private function onBookModuleSetUp() : void
		{
			notifyBackgroundSetSignal.addOnce(onBackgroundSet);
			requestCreateBookBackgroundSignal.dispatch();
		}

		private function onBackgroundSet(background : RefCountedTexture) : void
		{
			if (_background)
				_background.dispose();

			_background = background.newReference();
			// for now, just get most recent to test
			stateMachine.setActiveState(bookState, {source: _bookSourceType, type: GalleryType.MOST_RECENT});
		}

		override ns_state_machine function deactivate() : void
		{
			if (_background)
				_background.dispose();
			_background = null;
		}
	}
}
