package net.psykosoft.psykopaint2.core.views.base
{

	import flash.display.Sprite;

	import net.psykosoft.psykopaint2.core.views.components.CrSbCheckBox;
	import net.psykosoft.psykopaint2.core.views.components.CrSbRangedSlider;
	import net.psykosoft.psykopaint2.core.views.components.CrSbSlider;
	import net.psykosoft.psykopaint2.core.views.navigation.CrSbNavigationView;

	public class CrRootView extends Sprite
	{
		[Inject]
		public var view:CrRootView;

		public function CrRootView() {
			super();

			var navigationView:CrSbNavigationView = new CrSbNavigationView();

			addChild( navigationView );

			// -----------------------
			// Tests...
			// -----------------------
//			return;

			// Simple slider test.
			var simpleSlider:CrSbSlider = new CrSbSlider();
			simpleSlider.x = 100;
			simpleSlider.y = 100;
			simpleSlider.setIdLabel( "mySlider" );
			addChild( simpleSlider );
			trace( "test slider dimensions: " + simpleSlider.width + ", " + simpleSlider.height );

            // Range slider test.
			var rangeSlider:CrSbRangedSlider = new CrSbRangedSlider();
			rangeSlider.x = 100;
			rangeSlider.y = 200;
			rangeSlider.setIdLabel( "myRangeSlider" );
			addChild( rangeSlider );
			trace( "test range slider dimensions: " + rangeSlider.width + ", " + rangeSlider.height );

            //CheckBox test.
            var checkbox:CrSbCheckBox = new CrSbCheckBox();
            checkbox.x = 100;
			checkbox.y = 300;
            addChild( checkbox );
		}
	}
}
