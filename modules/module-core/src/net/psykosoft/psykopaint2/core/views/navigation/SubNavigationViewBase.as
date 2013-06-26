package net.psykosoft.psykopaint2.core.views.navigation
{

	import flash.display.Bitmap;
	import flash.display.Sprite;

	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonLabelType;
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

		protected function addCenterButton( label:String,
											iconType:String = ButtonIconType.DEFAULT,
											labelType:String = ButtonLabelType.CENTER,
											icon:Bitmap = null,
											autoSelect:Boolean = true
				):void {
			_navigation.addCenterButton( label, iconType, labelType, icon, autoSelect );
		}

		protected function setLeftButton( label:String ):void {
			_navigation.setLeftButton( label );
		}

		protected function setRightButton( label:String ):void {
			_navigation.setRightButton( label );
		}

		public function toggleLeftButtonVisibility( value:Boolean ):void {
			_navigation.toggleLeftButtonVisibility( value );
		}

		public function toggleRightButtonVisibility( value:Boolean ):void {
			_navigation.toggleRightButtonVisibility( value );
		}

		protected function invalidateContent():void {
			_navigation.invalidateContent();
		}

		protected function areButtonsSelectable( value:Boolean ):void {
			_navigation.areButtonsSelectable( value );
		}

		protected function selectButtonWithLabel( value:String ):void {
			_navigation.selectButtonWithLabel( value );
		}
		
		protected function selectButtonByIndex( index:int ):void {
			_navigation.selectButtonByIndex( index );
		}
	}
}
