package net.psykosoft.psykopaint2.paint.views.brush
{

	import net.psykosoft.psykopaint2.core.drawing.modules.BrushKitManager;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPickedColorChangedSignal;

	public class SelectColorSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:SelectColorSubNavView;

		[Inject]
		public var paintModule:BrushKitManager;
		
		[Inject]
		public var notifyPickedColorChangedSignal:NotifyPickedColorChangedSignal;

		
		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();
			view.colorChangedSignal.add( onColorChanged );
		}
		
		override protected function onViewEnabled():void {
			 super.onViewEnabled();
		}

		override protected function onButtonClicked( id:String ):void {
			switch( id ) {
				case SelectColorSubNavView.ID_BACK:
					requestNavigationStateChange( NavigationStateType.PREVIOUS );
					break;
				
				// WARNING: be careful if another side button is added since default should only be for parameter buttons.
				default: 
					
					break;
			}
		}
		
		private function onColorChanged():void
		{
			notifyPickedColorChangedSignal.dispatch(view.currentColor);
		}
		
	}
}
