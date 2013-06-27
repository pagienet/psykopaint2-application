package net.psykosoft.psykopaint2.paint.views.base
{

	import net.psykosoft.psykopaint2.base.ui.base.RootViewBase;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.views.navigation.StateToSubNavLinker;
	import net.psykosoft.psykopaint2.paint.views.brush.EditBrushSubNavView;
	import net.psykosoft.psykopaint2.paint.views.brush.SelectBrushSubNavView;
	import net.psykosoft.psykopaint2.paint.views.canvas.CanvasSubNavView;
	import net.psykosoft.psykopaint2.paint.views.canvas.CanvasView;
	import net.psykosoft.psykopaint2.paint.views.color.ColorStyleSubNavView;
	import net.psykosoft.psykopaint2.paint.views.color.ColorStyleView;
	import net.psykosoft.psykopaint2.paint.views.crop.CropSubNavView;
	import net.psykosoft.psykopaint2.paint.views.crop.CropView;
	import net.psykosoft.psykopaint2.paint.views.pick.surface.PickASurfaceSubNavView;
	import net.psykosoft.psykopaint2.paint.views.pick.image.PickAnImageView;

	public class PaintRootView extends RootViewBase
	{
		public function PaintRootView() {
			super();

			// Add main views.
			addRegisteredView( new ColorStyleView(), this );
			addRegisteredView( new CanvasView(), this );
			addRegisteredView( new CropView(), this );
			addRegisteredView( new PickAnImageView(), this );

			// Link sub-navigation views that are created dynamically by CrNavigationView
			StateToSubNavLinker.linkSubNavToState( StateType.COLOR_STYLE, ColorStyleSubNavView );
			StateToSubNavLinker.linkSubNavToState( StateType.PAINT, CanvasSubNavView );
			StateToSubNavLinker.linkSubNavToState( StateType.PAINT_SELECT_BRUSH, SelectBrushSubNavView );
			StateToSubNavLinker.linkSubNavToState( StateType.CROP, CropSubNavView );
			StateToSubNavLinker.linkSubNavToState( StateType.PAINT_ADJUST_BRUSH, EditBrushSubNavView );
			StateToSubNavLinker.linkSubNavToState( StateType.PAINT_PICK_SURFACE, PickASurfaceSubNavView );
		}
	}
}
