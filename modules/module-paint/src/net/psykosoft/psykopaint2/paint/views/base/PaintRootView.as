package net.psykosoft.psykopaint2.paint.views.base
{

	import flash.display.Sprite;

	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.views.navigation.StateToSubNavLinker;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;
	import net.psykosoft.psykopaint2.crop.views.CropSubNavView;
	import net.psykosoft.psykopaint2.crop.views.CropView;
	import net.psykosoft.psykopaint2.paint.views.brush.EditBrushSubNavView;
	import net.psykosoft.psykopaint2.paint.views.brush.SelectBrushSubNavView;
	import net.psykosoft.psykopaint2.paint.views.brush.SelectColorSubNavView;
	import net.psykosoft.psykopaint2.paint.views.canvas.CanvasSubNavView;
	import net.psykosoft.psykopaint2.paint.views.canvas.CanvasView;
	import net.psykosoft.psykopaint2.paint.views.color.ColorStyleSubNavView;
	import net.psykosoft.psykopaint2.paint.views.color.ColorStyleView;
	import net.psykosoft.psykopaint2.paint.views.pick.image.CaptureImageSubNavView;
	import net.psykosoft.psykopaint2.paint.views.pick.image.CaptureImageView;
	import net.psykosoft.psykopaint2.paint.views.pick.image.ConfirmCaptureImageSubNavView;
	import net.psykosoft.psykopaint2.paint.views.pick.image.PickAUserImageView;
	import net.psykosoft.psykopaint2.paint.views.pick.image.PickAnImageSubNavView;

	public class PaintRootView extends Sprite
	{
		public function PaintRootView() {
			super();

			// Add main views.
			addChild( new ColorStyleView() );
			addChild( new CanvasView() );
			addChild( new CropView() );
			addChild( new PickAUserImageView() );
			addChild( new CaptureImageView() );

			// Link sub-navigation views that are created dynamically by CrNavigationView
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.COLOR_STYLE, ColorStyleSubNavView );
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.CROP, CropSubNavView );
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.PAINT, CanvasSubNavView );
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.PAINT_SELECT_BRUSH, SelectBrushSubNavView );
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.PAINT_ADJUST_BRUSH, EditBrushSubNavView );
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.PAINT_COLOR, SelectColorSubNavView );
			
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.PICK_IMAGE, PickAnImageSubNavView );
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.CAPTURE_IMAGE, CaptureImageSubNavView );
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.CONFIRM_CAPTURE_IMAGE, ConfirmCaptureImageSubNavView );
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.TRANSITION_TO_HOME_MODE, SubNavigationViewBase );
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.TRANSITION_TO_PAINT_MODE, SubNavigationViewBase );
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.PREPARE_FOR_HOME_MODE, SubNavigationViewBase );


			mouseEnabled = false;
			name = "PaintRootView";
		}
	}
}
