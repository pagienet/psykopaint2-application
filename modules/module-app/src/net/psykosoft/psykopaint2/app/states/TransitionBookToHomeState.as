package net.psykosoft.psykopaint2.app.states
{

	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.book.model.GalleryImageProxy;
	import net.psykosoft.psykopaint2.book.signals.NotifyAnimateBookOutCompleteSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestAnimateBookOutSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestDestroyBookModuleSignal;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.RequestHomeViewScrollSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;

	public class TransitionBookToHomeState extends State
	{
		// injected from HomeState due to circular dependency
		public var homeState : HomeState;

		[Inject]
		public var requestDestroyBookModuleSignal : RequestDestroyBookModuleSignal;

		[Inject]
		public var requestStateChangeSignal : RequestNavigationStateChangeSignal;

		[Inject]
		public var requestAnimateBookOutSignal : RequestAnimateBookOutSignal;

		[Inject]
		public var notifyAnimateBookOutCompleteSignal : NotifyAnimateBookOutCompleteSignal;

		[Inject]
		public var requestHomeViewScrollSignal : RequestHomeViewScrollSignal;

		private var _targetNavigationState:String;
		private var _galleryImage : GalleryImageProxy;

		public function TransitionBookToHomeState()
		{
		}

		/**
		 * @param data An object with the following layout:
		 * {
		 *  	target: a value in NavigationStateType
		 *      galleryImage: (only if target == NavigationStateType.GALLERY_PAINTING) a GalleryImageProxy object to display in the gallery
		 * }
		 */
		override ns_state_machine function activate(data : Object = null) : void
		{
			_targetNavigationState = data.target;
			if (data.galleryImage)
				_galleryImage = GalleryImageProxy(data.galleryImage);
			else
				_galleryImage = null;

			notifyAnimateBookOutCompleteSignal.addOnce(onAnimateBookOutComplete);
			requestAnimateBookOutSignal.dispatch();
		}

		private function onAnimateBookOutComplete() : void
		{
			stateMachine.setActiveState(homeState);
			requestStateChangeSignal.dispatch(_targetNavigationState);

			// always go back to easel, or depends on targetNavigationState?
			if (_targetNavigationState != NavigationStateType.GALLERY_PAINTING)
				requestHomeViewScrollSignal.dispatch(1);
		}

		override ns_state_machine function deactivate() : void
		{
			requestDestroyBookModuleSignal.dispatch();
		}
	}
}
