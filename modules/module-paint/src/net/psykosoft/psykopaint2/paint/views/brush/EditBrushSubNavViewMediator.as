package net.psykosoft.psykopaint2.paint.views.brush
{

	import net.psykosoft.psykopaint2.core.drawing.data.ParameterSetVO;
	import net.psykosoft.psykopaint2.core.drawing.modules.BrushKitManager;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyActivateBrushChangedSignal;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;

	public class EditBrushSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:EditBrushSubNavView;

		[Inject]
		public var paintModule:BrushKitManager;
		
		[Inject]
		public var notifyActivateBrushChangedSignal:NotifyActivateBrushChangedSignal;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();

			// From view.
			view.enabledSignal.add( onViewEnabled );

			// From app.
			notifyActivateBrushChangedSignal.add( onBrushParameterChangedFromOutside );
		}

		override protected function onViewEnabled():void {
			super.onViewEnabled();
			view.setParameters( paintModule.getCurrentBrushParameters() );
		}

		override protected function onButtonClicked( id:String ):void {
			trace( this, "button clicked - id: " + id );
			switch( id ) {
				case EditBrushSubNavView.ID_BACK:
					requestNavigationStateChange( NavigationStateType.PREVIOUS );
					break;
				default:
					view.openParameterWithId( id );
					break;
			}
		}
		
		private function onBrushParameterChangedFromOutside( parameterSetVO:ParameterSetVO ):void {
			view.updateParameters( parameterSetVO );
		}
	}
}
