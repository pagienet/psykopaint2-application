package net.psykosoft.psykopaint2.paint.views.brush
{

	import net.psykosoft.psykopaint2.core.drawing.modules.PaintModule;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class BrushParametersSubNavViewMediator extends MediatorBase
	{
		[Inject]
		public var view:BrushParametersSubNavView;

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
				case BrushParametersSubNavView.LBL_BACK: {
					requestStateChange( StateType.STATE_PREVIOUS );
					break;
				}
			}
		}
	}
}
