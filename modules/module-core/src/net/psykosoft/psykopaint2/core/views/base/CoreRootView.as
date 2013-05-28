package net.psykosoft.psykopaint2.core.views.base
{

	import flash.display.Sprite;

	import net.psykosoft.psykopaint2.core.views.components.SbCheckBox;
	import net.psykosoft.psykopaint2.core.views.components.SbRangedSlider;
	import net.psykosoft.psykopaint2.core.views.components.SbSlider;
	import net.psykosoft.psykopaint2.core.views.components.combobox.SbComboboxView;
	import net.psykosoft.psykopaint2.core.views.navigation.SbNavigationView;

	public class CoreRootView extends Sprite
    {
        public function CoreRootView() {
            super();

            var navigationView:SbNavigationView = new SbNavigationView();

            addChild( navigationView );

            // -----------------------
            // Tests...
            // -----------------------
			return;

            // Simple slider test.
            var simpleSlider:SbSlider = new SbSlider();
            simpleSlider.x = 200;
            simpleSlider.y = 20;
            simpleSlider.setIdLabel( "mySlider" );
            addChild( simpleSlider );
            trace( "test slider dimensions: " + simpleSlider.width + ", " + simpleSlider.height );

            // Range slider test.
            var rangeSlider:SbRangedSlider = new SbRangedSlider();
            rangeSlider.x = 500;
            rangeSlider.y = 20;
            rangeSlider.setIdLabel( "myRangeSlider" );
            addChild( rangeSlider );
            trace( "test range slider dimensions: " + rangeSlider.width + ", " + rangeSlider.height );

            //CheckBox test.
            var checkbox:SbCheckBox = new SbCheckBox();
            checkbox.x = 50;
            checkbox.y = 20;
            addChild( checkbox );

             //Combobox test.
            var combobox:SbComboboxView = new SbComboboxView();
            for( var i:uint; i < 10; i++ ) {
                combobox.addItem( { label:"item_" + i } );
            }
            combobox.x = 100;
            combobox.y = 200;
            addChild( combobox );
        }
    }
}
