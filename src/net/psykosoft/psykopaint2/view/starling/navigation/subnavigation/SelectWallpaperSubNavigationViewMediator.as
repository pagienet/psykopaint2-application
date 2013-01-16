package net.psykosoft.psykopaint2.view.starling.navigation.subnavigation
{

	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.model.packagedimages.vo.PackagedImageVO;
	import net.psykosoft.psykopaint2.model.state.data.States;
	import net.psykosoft.psykopaint2.model.state.vo.StateVO;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyPopUpDisplaySignal;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyPopUpMessageSignal;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyWallpaperImagesUpdatedSignal;
	import net.psykosoft.psykopaint2.signal.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.signal.requests.RequestWallpaperChangeSignal;
	import net.psykosoft.psykopaint2.signal.requests.RequestWallpaperImagesLoadSignal;
	import net.psykosoft.psykopaint2.view.starling.popups.base.PopUpType;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class SelectWallpaperSubNavigationViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:SelectWallpaperSubNavigationView;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

		[Inject]
		public var notifyPopUpDisplaySignal:NotifyPopUpDisplaySignal;

		[Inject]
		public var notifyPopUpMessageSignal:NotifyPopUpMessageSignal;

		[Inject]
		public var requestWallpaperImagesLoadSignal:RequestWallpaperImagesLoadSignal;

		[Inject]
		public var notifyWallpaperImagesUpdatedSignal:NotifyWallpaperImagesUpdatedSignal;

		[Inject]
		public var requestWallpaperChangeSignal:RequestWallpaperChangeSignal;

		private var _imageIds:Dictionary;

		override public function initialize():void {

			trace( this, "initialize" );

			// Init.
			requestWallpaperImagesLoadSignal.dispatch();

			// From app.
			notifyWallpaperImagesUpdatedSignal.add( onWallpaperImagesUpdated );

			// From view.
			view.buttonPressedSignal.add( onSubNavigationButtonPressed );

		}

		// -----------------------
		// From app.
		// -----------------------

		private function onWallpaperImagesUpdated( images:Vector.<PackagedImageVO> ):void {
			trace( this, "wallpapers fetched: " + images.length );
			_imageIds = new Dictionary();
			for( var i:uint; i < images.length; i++ ) {
				_imageIds[ images[ i ].name ] = images[ i ].id;
			}
			view.setImages( images );
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onSubNavigationButtonPressed( buttonLabel:String ):void {
			trace( this, "button pressed: " + buttonLabel);
			switch( buttonLabel ) {
				case SelectWallpaperSubNavigationView.BUTTON_LABEL_BACK:
					requestStateChangeSignal.dispatch( new StateVO( States.SETTINGS ) );
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
