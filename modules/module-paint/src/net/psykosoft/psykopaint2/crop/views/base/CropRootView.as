package net.psykosoft.psykopaint2.crop.views.base
{
	import flash.display.Sprite;

	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.views.navigation.StateToSubNavLinker;

	import net.psykosoft.psykopaint2.crop.views.CropSubNavView;

	import net.psykosoft.psykopaint2.crop.views.CropView;
	import net.psykosoft.psykopaint2.crop.views.pick.image.CaptureImageSubNavView;
	import net.psykosoft.psykopaint2.crop.views.pick.image.CaptureImageView;
	import net.psykosoft.psykopaint2.crop.views.pick.image.ConfirmCaptureImageSubNavView;
	import net.psykosoft.psykopaint2.crop.views.pick.image.PickAUserImageView;
	import net.psykosoft.psykopaint2.crop.views.pick.image.PickAnImageSubNavView;

	public class CropRootView extends Sprite
	{
		public function CropRootView()
		{
			super();
			addChild( new CropView() );
			addChild( new PickAUserImageView() );
			addChild( new CaptureImageView() );

			StateToSubNavLinker.linkSubNavToState( NavigationStateType.CROP, CropSubNavView );
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.PICK_IMAGE, PickAnImageSubNavView );
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.CAPTURE_IMAGE, CaptureImageSubNavView );
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.CONFIRM_CAPTURE_IMAGE, ConfirmCaptureImageSubNavView );

			mouseEnabled = false;
			name = "CropRootView";
		}
	}
}
