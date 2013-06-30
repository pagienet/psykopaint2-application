package net.psykosoft.psykopaint2.core.views.navigation
{

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

		public function set navigation( navigation:SbNavigationView ):void {
			_navigation = navigation;
		}

		public function get navigation():SbNavigationView {
			return _navigation;
		}
	}
}
