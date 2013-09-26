package net.psykosoft.psykopaint2.home.views.base
{

	import flash.display.Sprite;
	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.views.navigation.StateToSubNavLinker;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;
	import net.psykosoft.psykopaint2.home.views.gallery.GalleryBrowseSubNavView;
	import net.psykosoft.psykopaint2.home.views.gallery.GalleryPaintingSubNavView;
	import net.psykosoft.psykopaint2.home.views.home.HomeSubNavView;
	import net.psykosoft.psykopaint2.home.views.home.HomeView;
	import net.psykosoft.psykopaint2.home.views.newpainting.NewPaintingSubNavView;
	import net.psykosoft.psykopaint2.home.views.pickimage.CaptureImageSubNavView;
	import net.psykosoft.psykopaint2.home.views.pickimage.CaptureImageView;
	import net.psykosoft.psykopaint2.home.views.pickimage.PickAUserImageView;
	import net.psykosoft.psykopaint2.home.views.pickimage.PickAnImageSubNavView;
	import net.psykosoft.psykopaint2.home.views.picksurface.PickSurfaceSubNavView;
	import net.psykosoft.psykopaint2.home.views.settings.SettingsSubNavView;
	import net.psykosoft.psykopaint2.home.views.settings.WallpaperSubNavView;

	public class HomeRootView extends Sprite
	{
		private var _homeView:HomeView;
		private var _pickAUserImageView:PickAUserImageView;
		private var _captureImageView:CaptureImageView;

		public function HomeRootView() {
			super();

			// Add main views.
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
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.BOOK_GALLERY, GalleryBrowseSubNavView );
//			StateToSubNavLinker.linkSubNavToState( NavigationStateType.GALLERY_LOADING, SubNavigationViewBase );
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.GALLERY_PAINTING, GalleryPaintingSubNavView );
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.CAPTURE_IMAGE, CaptureImageSubNavView );

			name = "HomeRootView";
		}

		public function dispose():void {

			removeChild( _homeView );
			removeChild( _pickAUserImageView );
			removeChild( _captureImageView );

			// Note: removing the views from display will cause the destruction of the mediators which will
			// in turn destroy the views themselves.
		}

	}
}
