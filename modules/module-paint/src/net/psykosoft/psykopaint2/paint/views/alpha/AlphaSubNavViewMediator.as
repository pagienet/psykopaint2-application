package net.psykosoft.psykopaint2.paint.views.alpha
{

	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;

	public class AlphaSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:AlphaSubNavView;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();

			// From view.


			// From app.

		}

		override protected function onButtonClicked( id:String ):void {
			switch( id ) {
				case AlphaSubNavView.ID_BACK:
					requestNavigationStateChange( NavigationStateType.PREVIOUS );
					break;
			}
		}
	}
}
