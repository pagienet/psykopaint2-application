package net.psykosoft.psykopaint2.crop.views.base
{

	import flash.display.Sprite;

	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.views.navigation.StateToSubNavLinker;
	import net.psykosoft.psykopaint2.crop.views.crop.CropSubNavView;
	import net.psykosoft.psykopaint2.crop.views.crop.CropView;

	public class CropRootView extends Sprite
	{
		public function CropRootView()
		{
			super();
			addChild( new CropView() );

			StateToSubNavLinker.linkSubNavToState( NavigationStateType.CROP, CropSubNavView );

			mouseEnabled = false;
			name = "CropRootView";
		}
	}
}
