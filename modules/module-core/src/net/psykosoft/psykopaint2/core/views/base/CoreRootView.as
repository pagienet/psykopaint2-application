package net.psykosoft.psykopaint2.core.views.base
{

	import flash.display.Sprite;

	import net.psykosoft.psykopaint2.core.views.components.SbCheckBox;
	import net.psykosoft.psykopaint2.core.views.components.SbRangedSlider;
	import net.psykosoft.psykopaint2.core.views.components.SbSlider;
	import net.psykosoft.psykopaint2.core.views.navigation.SbNavigationView;

	public class CoreRootView extends Sprite
	{
		[Inject]
		public var view:CoreRootView;

		public function CoreRootView() {
			super();

			var navigationView:SbNavigationView = new SbNavigationView();

			addChild( navigationView );

			// -----------------------
			// Tests...
			// -----------------------
//			return;

			// Simple slider test.
			var simpleSlider:SbSlider = new SbSlider();
			simpleSlider.x = 100;
			simpleSlider.y = 100;
			simpleSlider.setIdLabel( "mySlider" );
			addChild( simpleSlider );
			trace( "test slider dimensions: " + simpleSlider.width + ", " + simpleSlider.height );

            // Range slider test.
			var rangeSlider:SbRangedSlider = new SbRangedSlider();
			rangeSlider.x = 100;
			rangeSlider.y = 200;
			rangeSlider.setIdLabel( "myRangeSlider" );
			addChild( rangeSlider );
			trace( "test range slider dimensions: " + rangeSlider.width + ", " + rangeSlider.height );

            //CheckBox test.
            var checkbox:SbCheckBox = new SbCheckBox();
            checkbox.x = 100;
			checkbox.y = 300;
            addChild( checkbox );
		}
	}
}
