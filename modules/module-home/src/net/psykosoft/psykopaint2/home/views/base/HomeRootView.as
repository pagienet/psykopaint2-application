package net.psykosoft.psykopaint2.home.views.base
{

	import flash.display.Sprite;
	import flash.events.Event;

	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.views.navigation.StateToSubNavLinker;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;
	import net.psykosoft.psykopaint2.home.views.home.HomeSubNavView;
	import net.psykosoft.psykopaint2.home.views.home.HomeView;
	import net.psykosoft.psykopaint2.home.views.newpainting.NewPaintingSubNavView;
	import net.psykosoft.psykopaint2.home.views.pickimage.CaptureImageSubNavView;
	import net.psykosoft.psykopaint2.home.views.pickimage.CaptureImageView;
	import net.psykosoft.psykopaint2.home.views.pickimage.ConfirmCaptureImageSubNavView;
	import net.psykosoft.psykopaint2.home.views.pickimage.PickAUserImageView;
	import net.psykosoft.psykopaint2.home.views.pickimage.PickAnImageSubNavView;
	import net.psykosoft.psykopaint2.home.views.picksurface.PickSurfaceSubNavView;
	import net.psykosoft.psykopaint2.home.views.settings.SettingsSubNavView;
	import net.psykosoft.psykopaint2.home.views.settings.WallpaperSubNavView;

	import org.osflash.signals.Signal;

	public class HomeRootView extends Sprite
	{
		private var _homeView:HomeView;
		private var _pickAUserImageView:PickAUserImageView;
		private var _captureImageView:CaptureImageView;
		private var _viewReadyCount:uint;

		public var onSubViewsReady:Signal;

		public function HomeRootView() {
			super();

			onSubViewsReady = new Signal();

			// Add main views.
			// Note: if you add a view, don't forget to register it for onSubViewsReady in onAddedToStage()
			addChild( _homeView = new HomeView() );
			addChild( _pickAUserImageView = new PickAUserImageView() );
			addChild( _captureImageView = new CaptureImageView() );

			// Link sub-navigation views that are created dynamically by CrNavigationView
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.HOME, HomeSubNavView );
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.HOME_ON_EASEL, NewPaintingSubNavView );
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.SETTINGS, SettingsSubNavView );
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.SETTINGS_WALLPAPER, WallpaperSubNavView );
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.HOME_PICK_SURFACE, PickSurfaceSubNavView );
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.PREPARE_FOR_PAINT_MODE, SubNavigationViewBase );
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.PICK_IMAGE, PickAnImageSubNavView );
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.CAPTURE_IMAGE, CaptureImageSubNavView );
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.CONFIRM_CAPTURE_IMAGE, ConfirmCaptureImageSubNavView );

			name = "HomeRootView";

			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );

			_homeView.addEventListener( Event.ADDED_TO_STAGE, onViewAddedToStage );
			_pickAUserImageView.addEventListener( Event.ADDED_TO_STAGE, onViewAddedToStage );
			_captureImageView.addEventListener( Event.ADDED_TO_STAGE, onViewAddedToStage );
		}

		private function onViewAddedToStage( event:Event ):void {
			_viewReadyCount++;
			if( _viewReadyCount == numChildren ) {

				_homeView.removeEventListener( Event.ADDED_TO_STAGE, onViewAddedToStage );
				_pickAUserImageView.removeEventListener( Event.ADDED_TO_STAGE, onViewAddedToStage );
				_captureImageView.removeEventListener( Event.ADDED_TO_STAGE, onViewAddedToStage );

				onSubViewsReady.dispatch();
			}
		}

		public function dispose():void {

			removeChild( _homeView );
			removeChild( _pickAUserImageView );
			removeChild( _captureImageView );

			// Note: removing the views from display will cause the destruction of the mediators which will
			// in turn destroy the views themselves

		}
	}
}
