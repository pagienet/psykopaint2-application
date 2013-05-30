package net.psykosoft.psykopaint2.core.views.base
{

	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import net.psykosoft.psykopaint2.core.views.components.SbCheckBox;
	import net.psykosoft.psykopaint2.core.views.components.SbRangedSlider;
	import net.psykosoft.psykopaint2.core.views.components.SbSlider;
	import net.psykosoft.psykopaint2.core.views.components.combobox.SbComboboxView;
	import net.psykosoft.psykopaint2.core.views.navigation.SbNavigationView;

	public class CoreRootView extends Sprite
    {
		private var _mainLayer:Sprite;

        public function CoreRootView() {
            super();

			_mainLayer = new Sprite();
			addChild( _mainLayer );

			var frontLayer:Sprite = new Sprite();
			addChild( frontLayer );

            var navigationView:SbNavigationView = new SbNavigationView();
            frontLayer.addChild( navigationView );

            // -----------------------
            // Tests...
            // -----------------------
			return;

            // Simple slider test.
            /*var simpleSlider:SbSlider = new SbSlider();
            simpleSlider.x = 200;
            simpleSlider.y = 20;
            simpleSlider.setIdLabel( "mySlider" );
            addChild( simpleSlider );
            trace( "test slider dimensions: " + simpleSlider.width + ", " + simpleSlider.height );*/

            // Range slider test.
			/*var container:Sprite = new Sprite();
			container.scaleX = container.scaleY = 2;
			addChild( container );
            var rangeSlider:SbRangedSlider = new SbRangedSlider();
            rangeSlider.x = 1024 / 2 - rangeSlider.width / 2;
            rangeSlider.y = 560;
            rangeSlider.setIdLabel( "myRangeSlider" );
            container.addChild( rangeSlider );
            trace( "test range slider dimensions: " + rangeSlider.width + ", " + rangeSlider.height );*/

            //CheckBox test.
           /* var checkbox:SbCheckBox = new SbCheckBox();
            checkbox.x = 50;
            checkbox.y = 20;
            addChild( checkbox );*/

             //Combobox test.
            /*var combobox:SbComboboxView = new SbComboboxView();
            for( var i:uint; i < 10; i++ ) {
                combobox.addItem( { label:"item_" + i } );
            }
            combobox.x = 100;
            combobox.y = 200;
            addChild( combobox );*/
        }

		public function addToMainLayer( child:DisplayObject ):void {
			_mainLayer.addChild( child );
		}
	}
}
