package net.psykosoft.psykopaint2.app.states
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.book.model.SourceImageRequestVO;
	import net.psykosoft.psykopaint2.book.signals.NotifyImageSelectedFromBookSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestExitBookSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestFetchSourceImagesSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestSetBookBackgroundSignal;
	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedTexture;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;

	public class BookState extends State
	{
		[Inject]
		public var requestStateChange : RequestNavigationStateChangeSignal;

		[Inject]
		public var notifyImageSelectedFromBookSignal : NotifyImageSelectedFromBookSignal;

		[Inject]
		public var transitionToCropState : TransitionBookToCropState;

		[Inject]
		public var transitionToHomeState : TransitionBookToHomeState;

		[Inject]
		public var requestSetBookBackgroundSignal : RequestSetBookBackgroundSignal;

		[Inject]
		public var requestExitBookSignal : RequestExitBookSignal;

		[Inject]
		public var requestFetchSourceImagesSignal : RequestFetchSourceImagesSignal;

		private var _background : RefCountedTexture;

		public function BookState()
		{
		}

		[PostConstruct]
		public function init() : void
		{
			requestSetBookBackgroundSignal.add(onRequestSetCropBackgroundSignal);
		}

		private function onRequestSetCropBackgroundSignal(background : RefCountedTexture) : void
		{
			if (_background)
				_background.dispose();

			if (background)
				_background = background.newReference();
			else
				_background = null;
		}

		/**
		 *
		 * @param data A String value of BookImageSource
		 */
		override ns_state_machine function activate(data : Object = null) : void
		{
			requestStateChange.dispatch(NavigationStateType.BOOK);
			requestFetchSourceImagesSignal.dispatch(new SourceImageRequestVO(String(data), 0, 0));
			notifyImageSelectedFromBookSignal.add(onImageSelectedFromBookSignal);
			requestExitBookSignal.add(onRequestExitBookSignal);
		}

		override ns_state_machine function deactivate() : void
		{
			if (_background)
				_background.dispose();
			_background = null;
			notifyImageSelectedFromBookSignal.remove(onImageSelectedFromBookSignal);
			requestExitBookSignal.remove(onRequestExitBookSignal);
		}

		private function onRequestExitBookSignal() : void
		{
			stateMachine.setActiveState(transitionToHomeState);
		}

		private function onImageSelectedFromBookSignal(bitmapData : BitmapData) : void
		{
			stateMachine.setActiveState(transitionToCropState, {bitmapData: bitmapData, background: _background.newReference()});
		}
	}
}
