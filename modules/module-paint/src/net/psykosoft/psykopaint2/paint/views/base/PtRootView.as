package net.psykosoft.psykopaint2.paint.views.base
{

	import flash.display.Sprite;

	import net.psykosoft.psykopaint2.core.models.CrStateType;

	import net.psykosoft.psykopaint2.core.views.navigation.CrStateToSubNavLinker;
	import net.psykosoft.psykopaint2.paint.views.brush.PtBrushParametersSubNavView;
	import net.psykosoft.psykopaint2.paint.views.brush.PtSelectBrushSubNavView;
	import net.psykosoft.psykopaint2.paint.views.brush.PtSelectShapeSubNavView;
	import net.psykosoft.psykopaint2.paint.views.canvas.PtCanvasSubNavView;

	import net.psykosoft.psykopaint2.paint.views.canvas.PtCanvasView;
	import net.psykosoft.psykopaint2.paint.views.color.PtColorStyleSubNavView;
	import net.psykosoft.psykopaint2.paint.views.color.PtColorStyleView;
	import net.psykosoft.psykopaint2.paint.views.crop.PtCropSubNavView;
	import net.psykosoft.psykopaint2.paint.views.crop.PtCropView;
	import net.psykosoft.psykopaint2.paint.views.pick.PtPickAnImageView;

	public class PtRootView extends Sprite
	{
		public function PtRootView() {
			super();

			var colorStyleView:PtColorStyleView = new PtColorStyleView();
			var canvasView:PtCanvasView = new PtCanvasView();
			var cropView:PtCropView = new PtCropView();
			var pickAnImageView:PtPickAnImageView = new PtPickAnImageView();

			addChild( colorStyleView );
			addChild( canvasView );
			addChild( cropView );
			addChild( pickAnImageView );

			// Link sub-navigation views.
			CrStateToSubNavLinker.linkSubNavToState( CrStateType.STATE_COLOR_STYLE, PtColorStyleSubNavView );
			CrStateToSubNavLinker.linkSubNavToState( CrStateType.STATE_PAINT, PtCanvasSubNavView );
			CrStateToSubNavLinker.linkSubNavToState( CrStateType.STATE_PAINT_SELECT_BRUSH, PtSelectBrushSubNavView );
			CrStateToSubNavLinker.linkSubNavToState( CrStateType.STATE_PAINT_SELECT_SHAPE, PtSelectShapeSubNavView );
			CrStateToSubNavLinker.linkSubNavToState( CrStateType.STATE_CROP, PtCropSubNavView );
			CrStateToSubNavLinker.linkSubNavToState( CrStateType.STATE_PAINT_ADJUST_BRUSH, PtBrushParametersSubNavView );
		}
	}
}
