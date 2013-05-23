package net.psykosoft.psykopaint2.paint.views.brush
{

	import net.psykosoft.psykopaint2.core.drawing.modules.PaintModule;
	import net.psykosoft.psykopaint2.core.models.CrStateType;
	import net.psykosoft.psykopaint2.core.views.base.CrMediatorBase;

	public class PtBrushParametersSubNavViewMediator extends CrMediatorBase
	{
		[Inject]
		public var view:PtBrushParametersSubNavView;

		[Inject]
		public var paintModule:PaintModule;

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
			manageStateChanges = false;
			manageMemoryWarnings = false;
			view.setButtonClickCallback( onButtonClicked );

			// Post init.
			view.setParameters( paintModule.getCurrentBrushParameters() );

			// From view.
			view.brushParameterChangedSignal.add( onBrushParameterChanged );
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onBrushParameterChanged( parameter:XML ):void {
			paintModule.setBrushParameter( parameter );
		}

		private function onButtonClicked( label:String ):void {
			switch( label ) {
				case PtBrushParametersSubNavView.LBL_BACK: {
					requestStateChange( CrStateType.STATE_PREVIOUS );
					break;
				}
			}
		}
	}
}
