package net.psykosoft.psykopaint2.crop.views.base
{

	import flash.display.Sprite;

	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.views.navigation.StateToSubNavLinker;
	import net.psykosoft.psykopaint2.crop.views.crop.CropSubNavView;
	import net.psykosoft.psykopaint2.crop.views.crop.CropView;

	public class CropRootView extends Sprite
	{
		private var _cropView:CropView;

		public function CropRootView()
		{
			super();
			addChild( _cropView = new CropView() );

			StateToSubNavLinker.linkSubNavToState( NavigationStateType.CROP, CropSubNavView );

			mouseEnabled = false;
			name = "CropRootView";
		}

		public function dispose():void {

			removeChild( _cropView );
			_cropView = null;

			// Note: removing the views from display will cause the destruction of the mediators which will
			// in turn destroy the views themselves.
		}
	}
}
