package net.psykosoft.psykopaint2.paint.views.brush
{

	import net.psykosoft.psykopaint2.core.drawing.modules.PaintModule;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class EditBrushSubNavViewMediator extends MediatorBase
	{
		[Inject]
		public var view:EditBrushSubNavView;

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
//			view.setAvailableShapes( paintModule.getCurrentBrushShapes() );
//			view.setSelectedShape( paintModule.activeBrushKitShape );
			view.setParameters( paintModule.getCurrentBrushParameters() );

			// From view.
			view.brushParameterChangedSignal.add( onBrushParameterChanged );
			view.shapeChangedSignal.add( onShapeChanged );
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onShapeChanged( shapeName:String ):void {
			paintModule.setBrushShape( shapeName );
		}

		private function onBrushParameterChanged( parameter:XML ):void {
//			trace( this, "param changed: " + parameter.toXMLString() );
			paintModule.setBrushParameter( parameter );
		}

		private function onButtonClicked( label:String ):void {
			switch( label ) {
				case EditBrushSubNavView.LBL_BACK: {
					requestStateChange( StateType.STATE_PREVIOUS );
					break;
				}
				// WARNING: be careful if another side button is added since default should only be for parameter buttons.
				default: {
					view.openParameter( label );
				}
			}
		}
	}
}
