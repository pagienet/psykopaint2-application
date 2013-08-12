package net.psykosoft.psykopaint2.paint.views.brush
{

	import net.psykosoft.psykopaint2.core.drawing.modules.BrushKitManager;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;

	public class SelectColorSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:SelectColorSubNavView;

		[Inject]
		public var paintModule:BrushKitManager;
		
		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();

			// Post init.
			view.connectColorParameter( paintModule.getCurrentBrushParameters(false) );
		}

		override protected function onButtonClicked( id:String ):void {
			switch( id ) {
				case SelectColorSubNavView.ID_BACK:
					requestStateChange__OLD_TO_REMOVE( NavigationStateType.PREVIOUS );
					break;
				
				// WARNING: be careful if another side button is added since default should only be for parameter buttons.
				default: 
					
					break;
			}
		}
	}
}
