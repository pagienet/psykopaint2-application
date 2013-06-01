package net.psykosoft.psykopaint2.core.views.base
{

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;

	import net.psykosoft.psykopaint2.base.ui.base.ViewCore;
	import net.psykosoft.psykopaint2.core.views.components.rangeslider.SbRangedSlider;
	import net.psykosoft.psykopaint2.core.views.components.slider.SbSlider;
	import net.psykosoft.psykopaint2.core.views.navigation.SbNavigationView;

	public class CoreRootView extends Sprite
    {
		private var _mainLayer:Sprite;
		private var _memoryIcon:TextField;
		private var _memoryIconTimer:Timer;
		private var _frontLayer:Sprite;
		private var _memoryWarningCount:uint;

		public function CoreRootView() {
            super();

			_mainLayer = new Sprite();
			addChild( _mainLayer );

			_frontLayer = new Sprite();
			addChild( _frontLayer );

            var navigationView:SbNavigationView = new SbNavigationView();
            _frontLayer.addChild( navigationView );

            // -----------------------
            // Component tests...
            // -----------------------

			/*this.graphics.beginFill(0xCCCCCC, 1.0);
			this.graphics.drawRect(0, 0, 1024, 768);
			this.graphics.endFill();*/

            // Simple slider test.
            /*var simpleSlider:SbSlider = new SbSlider();
            simpleSlider.x = 200;
            simpleSlider.y = 20;
			simpleSlider.value = 0.7;
			simpleSlider.minValue = 0.5;
			simpleSlider.maxValue = 0.75;
			simpleSlider.addEventListener( Event.CHANGE, function( event:Event ):void {
				trace( ">>> simple slider change: " + simpleSlider.value );
			} );
            addChild( simpleSlider );*/

            // Range slider test.
            /*var rangeSlider:SbRangedSlider = new SbRangedSlider();
            rangeSlider.x = 200;
            rangeSlider.y = 150;
			rangeSlider.numDecimals = 3;
			rangeSlider.minValue = 0;
			rangeSlider.maxValue = 1;
			rangeSlider.value1 = 0;
			rangeSlider.value2 = 1;
			rangeSlider.addEventListener( Event.CHANGE, function( event:Event ):void {
				trace( ">>> range slider change: " + rangeSlider.value1 + ", " + rangeSlider.value2 );
			} );
            addChild( rangeSlider );*/

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

		public function flashMemoryIcon():void {
			if( !_memoryIconTimer ) {
				_memoryIconTimer = new Timer( 1000, 1 );
				_memoryIconTimer.addEventListener( TimerEvent.TIMER, onMemoryIconTimerTick );
			}
			if( !_memoryIcon ) {
				_memoryIcon = new TextField();
				_memoryIcon.selectable = _memoryIcon.mouseEnabled = false;
				_memoryIcon.defaultTextFormat = new TextFormat( null, 72 );
				_memoryIcon.text = "MEMORY WARNING";
				_memoryIcon.textColor = 0xFF0000;
				_memoryIcon.width = _memoryIcon.textWidth;
				_memoryIcon.height = _memoryIcon.textHeight;
				_memoryIcon.x = ViewCore.globalScaling * ( 1024 / 2 - _memoryIcon.width / 2 );
				_memoryIcon.y = ViewCore.globalScaling * ( 768 / 2 - _memoryIcon.height / 2 );
			   	_frontLayer.addChild( _memoryIcon );
			}
			_memoryWarningCount++;
			_memoryIconTimer.start();
			_memoryIcon.visible = true;
		}

		private function onMemoryIconTimerTick( event:TimerEvent ):void {
			_memoryIconTimer.reset();
			_memoryIcon.visible = false;
		}
	}
}
