package net.psykosoft.psykopaint2.paint.views.base
{

	import flash.display.Sprite;

	import net.psykosoft.psykopaint2.core.models.StateType;

	import net.psykosoft.psykopaint2.core.views.navigation.StateToSubNavLinker;
	import net.psykosoft.psykopaint2.paint.views.brush.BrushParametersSubNavView;
	import net.psykosoft.psykopaint2.paint.views.brush.SelectBrushSubNavView;
	import net.psykosoft.psykopaint2.paint.views.brush.SelectShapeSubNavView;
	import net.psykosoft.psykopaint2.paint.views.canvas.CanvasSubNavView;

	import net.psykosoft.psykopaint2.paint.views.canvas.CanvasView;
	import net.psykosoft.psykopaint2.paint.views.color.ColorStyleSubNavView;
	import net.psykosoft.psykopaint2.paint.views.color.ColorStyleView;
	import net.psykosoft.psykopaint2.paint.views.crop.CropSubNavView;
	import net.psykosoft.psykopaint2.paint.views.crop.CropView;
	import net.psykosoft.psykopaint2.paint.views.pick.PickAnImageView;

	public class PaintRootView extends Sprite
	{
		public function PaintRootView() {
			super();

			var colorStyleView:ColorStyleView = new ColorStyleView();
			var canvasView:CanvasView = new CanvasView();
			var cropView:CropView = new CropView();
			var pickAnImageView:PickAnImageView = new PickAnImageView();

			addChild( colorStyleView );
			addChild( canvasView );
			addChild( cropView );
			addChild( pickAnImageView );

			// Link sub-navigation views that are created dynamically by CrNavigationView
			StateToSubNavLinker.linkSubNavToState( StateType.STATE_COLOR_STYLE, ColorStyleSubNavView );
			StateToSubNavLinker.linkSubNavToState( StateType.STATE_PAINT, CanvasSubNavView );
			StateToSubNavLinker.linkSubNavToState( StateType.STATE_PAINT_SELECT_BRUSH, SelectBrushSubNavView );
			StateToSubNavLinker.linkSubNavToState( StateType.STATE_PAINT_SELECT_SHAPE, SelectShapeSubNavView );
			StateToSubNavLinker.linkSubNavToState( StateType.STATE_CROP, CropSubNavView );
			StateToSubNavLinker.linkSubNavToState( StateType.STATE_PAINT_ADJUST_BRUSH, BrushParametersSubNavView );
		}
	}
}
