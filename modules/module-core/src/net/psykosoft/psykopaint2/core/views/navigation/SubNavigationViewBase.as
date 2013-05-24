package net.psykosoft.psykopaint2.core.views.navigation
{

	import flash.display.Sprite;

	import net.psykosoft.psykopaint2.core.views.components.NavigationButtonIconType;
	import net.psykosoft.psykopaint2.core.views.components.NavigationButtonLabelType;
	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;

	/*
	 * Note: Sub-navigation views, i.e. views that extend SubNavigationViewBase,
	 * are views only in the sense that they have a mediator, but they don't actually contain
	 * ui elements. They just tell it's display list parent, NavigationView, what controls
	 * to use by forwarding construction methods to it.
	 */
	public class SubNavigationViewBase extends ViewBase
	{
		private var _navigation:SbNavigationView;

		public function SubNavigationViewBase() {
			super();
		}

		public function setNavigation( navigation:SbNavigationView ):void {
			_navigation = navigation;
		}

		public function setButtonClickCallback( callback:Function ):void {
			_navigation.buttonClickedCallback = callback;
		}

		// ---------------------------------------------------------------------
		// Methods forwarded to NavigationView.
		// ---------------------------------------------------------------------

		protected function setLabel( value:String ):void {
			_navigation.setLabel( value );
		}

		protected function addCenterElement( element:Sprite ):void {
			_navigation.addCenterElement( element );
		}

		protected function addCenterButton( label:String,
											iconType:String = NavigationButtonIconType.DEFAULT,
											labelType:String = NavigationButtonLabelType.CENTER ):void {
			_navigation.addCenterButton( label, iconType, labelType );
		}

		protected function setLeftButton( label:String ):void {
			_navigation.setLeftButton( label );
		}

		protected function setRightButton( label:String ):void {
			_navigation.setRightButton( label );
		}

		protected function invalidateContent():void {
			_navigation.invalidateContent();
		}

		protected function areButtonsSelectable( value:Boolean ):void {
			_navigation.areButtonsSelectable( value );
		}
	}
}
