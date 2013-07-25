package net.psykosoft.psykopaint2.paint.views.brush
{

	import net.psykosoft.psykopaint2.core.drawing.modules.PaintModule;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;

	public class SelectColorSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:SelectColorSubNavView;

		[Inject]
		public var paintModule:PaintModule;
		
		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();
			view.navigation.buttonClickedCallback = onButtonClicked;

			// Post init.
			view.connectColorParameter( paintModule.getCurrentBrushParameters() );
			
		}

		private function onButtonClicked( label:String ):void {
			switch( label ) {
				case SelectColorSubNavView.LBL_BACK: 
					requestStateChange( StateType.PREVIOUS );
					break;
				
				// WARNING: be careful if another side button is added since default should only be for parameter buttons.
				default: 
					
					break;
			}
		}
		
		
	}
}
