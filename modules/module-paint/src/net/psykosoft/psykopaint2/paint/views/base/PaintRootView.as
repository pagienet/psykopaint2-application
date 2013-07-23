package net.psykosoft.psykopaint2.paint.views.base
{

	import net.psykosoft.psykopaint2.base.ui.base.RootViewBase;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.views.navigation.StateToSubNavLinker;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;
	import net.psykosoft.psykopaint2.paint.views.brush.EditBrushSubNavView;
	import net.psykosoft.psykopaint2.paint.views.brush.SelectBrushSubNavView;
	import net.psykosoft.psykopaint2.paint.views.brush.SelectColorSubNavView;
	import net.psykosoft.psykopaint2.paint.views.canvas.CanvasSubNavView;
	import net.psykosoft.psykopaint2.paint.views.canvas.CanvasView;
	import net.psykosoft.psykopaint2.paint.views.color.ColorStyleSubNavView;
	import net.psykosoft.psykopaint2.paint.views.color.ColorStyleView;
	import net.psykosoft.psykopaint2.paint.views.crop.CropSubNavView;
	import net.psykosoft.psykopaint2.paint.views.crop.CropView;
	import net.psykosoft.psykopaint2.paint.views.pick.image.CaptureImageSubNavView;
	import net.psykosoft.psykopaint2.paint.views.pick.image.CaptureImageView;
	import net.psykosoft.psykopaint2.paint.views.pick.image.ConfirmCaptureImageSubNavView;
	import net.psykosoft.psykopaint2.paint.views.pick.image.PickASampleImageSubNavView;
	import net.psykosoft.psykopaint2.paint.views.pick.image.PickAUserImageView;
	import net.psykosoft.psykopaint2.paint.views.pick.image.PickAnImageSubNavView;

	public class PaintRootView extends RootViewBase
	{
		public function PaintRootView() {
			super();

			// Add main views.
			addRegisteredView( new ColorStyleView(), this );
			addRegisteredView( new CanvasView(), this );
			addRegisteredView( new CropView(), this );
			addRegisteredView( new PickAUserImageView(), this );
			addRegisteredView( new CaptureImageView(), this );

			// Link sub-navigation views that are created dynamically by CrNavigationView
			StateToSubNavLinker.linkSubNavToState( StateType.COLOR_STYLE, ColorStyleSubNavView );
			StateToSubNavLinker.linkSubNavToState( StateType.CROP, CropSubNavView );
			StateToSubNavLinker.linkSubNavToState( StateType.PAINT, CanvasSubNavView );
			StateToSubNavLinker.linkSubNavToState( StateType.PAINT_SELECT_BRUSH, SelectBrushSubNavView );
			StateToSubNavLinker.linkSubNavToState( StateType.PAINT_ADJUST_BRUSH, EditBrushSubNavView );
			StateToSubNavLinker.linkSubNavToState( StateType.PAINT_COLOR, SelectColorSubNavView );
			
			StateToSubNavLinker.linkSubNavToState( StateType.PICK_IMAGE, PickAnImageSubNavView );
			StateToSubNavLinker.linkSubNavToState( StateType.PICK_SAMPLE_IMAGE, PickASampleImageSubNavView );
			StateToSubNavLinker.linkSubNavToState( StateType.CAPTURE_IMAGE, CaptureImageSubNavView );
			StateToSubNavLinker.linkSubNavToState( StateType.CONFIRM_CAPTURE_IMAGE, ConfirmCaptureImageSubNavView );
			StateToSubNavLinker.linkSubNavToState( StateType.TRANSITION_TO_HOME_MODE, SubNavigationViewBase );
			StateToSubNavLinker.linkSubNavToState( StateType.TRANSITION_TO_PAINT_MODE, SubNavigationViewBase );
			StateToSubNavLinker.linkSubNavToState( StateType.PREPARE_FOR_HOME_MODE, SubNavigationViewBase );


			mouseEnabled = false;
			name = "PaintRootView";
		}
	}
}
