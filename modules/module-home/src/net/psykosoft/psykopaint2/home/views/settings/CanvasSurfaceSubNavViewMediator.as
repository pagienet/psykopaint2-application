package net.psykosoft.psykopaint2.home.views.settings
{
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.core.models.CanvasSurfaceSettingsModel;

	public class CanvasSurfaceSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:CanvasSurfaceSubNavView;

		[Inject]
		public var canvasSurfaceSettingsModel:CanvasSurfaceSettingsModel;

		override public function initialize():void {
			registerView( view );
			super.initialize();
		}

		override protected function onViewSetup():void {
			super.onViewSetup();
			switch(canvasSurfaceSettingsModel.surfaceID) {
				case 0:
					view.setSelectedButton(CanvasSurfaceSubNavView.ID_CANVAS);
					break;
				case 1:
					view.setSelectedButton(CanvasSurfaceSubNavView.ID_WOOD);
					break;
			}
		}

		override protected function onButtonClicked( id:String ):void {
			switch( id ) {

				// Left.
				case WallpaperSubNavView.ID_BACK:
					requestNavigationStateChange( NavigationStateType.SETTINGS );
					break;

				case CanvasSurfaceSubNavView.ID_CANVAS:
					canvasSurfaceSettingsModel.surfaceID = 0;
					break;

				case CanvasSurfaceSubNavView.ID_WOOD:
					canvasSurfaceSettingsModel.surfaceID = 1;
					break;

				case CanvasSurfaceSubNavView.ID_PAPER:
					canvasSurfaceSettingsModel.surfaceID = 2;
					break;
			}
		}
	}
}
