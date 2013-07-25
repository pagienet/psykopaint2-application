package net.psykosoft.psykopaint2.paint.views.brush
{

	import net.psykosoft.psykopaint2.core.drawing.data.ParameterSetVO;
	import net.psykosoft.psykopaint2.core.drawing.modules.PaintModule;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyActivateBrushChangedSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class EditBrushSubNavViewMediator extends MediatorBase
	{
		[Inject]
		public var view:EditBrushSubNavView;

		[Inject]
		public var paintModule:PaintModule;
		
		[Inject]
		public var notifyActivateBrushChangedSignal:NotifyActivateBrushChangedSignal;

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
			manageStateChanges = false;
			manageMemoryWarnings = false;
			view.navigation.buttonClickedCallback = onButtonClicked;

			// Post init.
			view.setParameters( paintModule.getCurrentBrushParameters() );

			notifyActivateBrushChangedSignal.add( onBrushParameterChangedFromOutside );
		}

		private function onButtonClicked( label:String ):void {
			switch( label ) {
				case EditBrushSubNavView.LBL_BACK: 
					requestStateChange__OLD_TO_REMOVE( StateType.PREVIOUS );
					break;
				case EditBrushSubNavView.LBL_COLOR: 
					requestStateChange__OLD_TO_REMOVE( StateType.PAINT_COLOR);
					break;
				// WARNING: be careful if another side button is added since default should only be for parameter buttons.
				default: 
					view.openParameter( label );
					break;
			}
		}
		
		private function onBrushParameterChangedFromOutside( parameterSetVO:ParameterSetVO ):void {
			view.updateParameters( parameterSetVO );
		}
	}
}
