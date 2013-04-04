package net.psykosoft.psykopaint2.app.view.settings
{

	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.app.data.types.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpDisplaySignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpMessageSignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyWallpaperImagesUpdatedSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestWallpaperChangeSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestWallpaperThumbsLoadSignal;
	import net.psykosoft.psykopaint2.app.view.base.StarlingMediatorBase;

	public class SelectWallpaperSubNavigationViewMediator extends StarlingMediatorBase
	{
		[Inject]
		public var view:SelectWallpaperSubNavigationView;

		[Inject]
		public var notifyPopUpDisplaySignal:NotifyPopUpDisplaySignal;

		[Inject]
		public var notifyPopUpMessageSignal:NotifyPopUpMessageSignal;

		[Inject]
		public var requestWallpaperImagesLoadSignal:RequestWallpaperThumbsLoadSignal;

		[Inject]
		public var notifyWallpaperImagesUpdatedSignal:NotifyWallpaperImagesUpdatedSignal;

		[Inject]
		public var requestWallpaperChangeSignal:RequestWallpaperChangeSignal;

		private var _imageIds:Dictionary;

		override public function initialize():void {

			super.initialize();
			manageMemoryWarnings = false;
			manageStateChanges = false;

			// Init.
			requestWallpaperImagesLoadSignal.dispatch();

			// From app.
//			notifyWallpaperImagesUpdatedSignal.add( onWallpaperImagesUpdated );

			// From view.
			view.buttonPressedSignal.add( onSubNavigationButtonPressed );

		}

		// -----------------------
		// From app.
		// -----------------------

		/*private function onWallpaperImagesUpdated( images:Vector.<PackagedImageVO> ):void {
			trace( this, "wallpapers fetched: " + images.length );
			_imageIds = new Dictionary();
			for( var i:uint; i < images.length; i++ ) {
				_imageIds[ images[ i ].name ] = images[ i ].id;
			}
			view.setImages( images );
		}*/

		// -----------------------
		// From view.
		// -----------------------

		private function onSubNavigationButtonPressed( buttonLabel:String ):void {
			trace( this, "button pressed: " + buttonLabel);
			switch( buttonLabel ) {
				case SelectWallpaperSubNavigationView.BUTTON_LABEL_BACK:
					requestStateChange( new StateVO( ApplicationStateType.SETTINGS ) );
					break;
				default:
					var id:String = _imageIds[ buttonLabel ];
					trace( "id: " + id );
					requestWallpaperChangeSignal.dispatch( id );
					break;
			}
		}
	}
}
