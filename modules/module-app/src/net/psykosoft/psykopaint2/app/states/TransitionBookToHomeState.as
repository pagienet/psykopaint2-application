package net.psykosoft.psykopaint2.app.states
{

	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;
	import net.psykosoft.psykopaint2.book.signals.NotifyAnimateBookOutCompleteSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestAnimateBookOutSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestDestroyBookModuleSignal;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.RequestHomeViewScrollSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestSetGalleryPaintingSignal;

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

		[Inject]
		public var requestSetGalleryPaintingSignal : RequestSetGalleryPaintingSignal;

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

			if (_targetNavigationState != NavigationStateType.GALLERY_PAINTING)
				requestHomeViewScrollSignal.dispatch(1);
			else
				requestSetGalleryPaintingSignal.dispatch(_galleryImage);
		}

		override ns_state_machine function deactivate() : void
		{
			requestDestroyBookModuleSignal.dispatch();
		}
	}
}
