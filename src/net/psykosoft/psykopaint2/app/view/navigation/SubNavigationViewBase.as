package net.psykosoft.psykopaint2.app.view.navigation
{

	import com.greensock.TweenLite;
	import com.greensock.easing.Expo;
	
	import feathers.controls.Button;
	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;
	
	import net.psykosoft.psykopaint2.app.config.Settings;
	import net.psykosoft.psykopaint2.app.view.base.StarlingViewBase;
	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonDefinitionVO;
	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonGroupDefinitionVO;
	import net.psykosoft.psykopaint2.ui.extensions.buttons.CompoundButton;
	import net.psykosoft.psykopaint2.ui.theme.data.ButtonSkinType;
	
	import org.osflash.signals.Signal;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.RenderTexture;

	public class SubNavigationViewBase extends StarlingViewBase
	{
		private var _scrollContainer:ScrollContainer;
		private var _header:Button;
		private var _title:String;
		private var _frontLayer:Sprite; // TODO: do we still need layers given that the edge buttons have been moved out of this abstract class?
		private var _backLayer:Sprite;

		public var buttonPressedSignal:Signal;

		public function SubNavigationViewBase( title:String ) {
			super();
			buttonPressedSignal = new Signal();
			_title = title;
			trace( this, "sub-navigation view created." );
		}

		// ---------------------------------------------------------------------
		// Overrides.
		// ---------------------------------------------------------------------

		override protected function onEnabled():void {

			addChild( _backLayer = new Sprite() );
			addChild( _frontLayer = new Sprite() );

			_header = new Button();
			_header.nameList.add( ButtonSkinType.LABEL );
			_header.label = _title;
			_header.isEnabled = false;
			_header.addEventListener( Event.RESIZE, onHeaderResized );
			_header.validate();
			_frontLayer.addChild( _header );
		}

		override protected function onDisabled():void {

			clearCenterButtons();

			if( _header ) {
				_frontLayer.removeChild( _header );
				_header.dispose();
				_header = null;
			}

			if( _frontLayer ) {
				removeChild( _frontLayer );
				_frontLayer.dispose();
				_frontLayer = null;
			}

			if( _backLayer ) {
				removeChild( _backLayer );
				_backLayer.dispose();
				_backLayer = null;
			}
		}

		// -----------------------------------------------------------------------------------------------------------------------
		// Settings center buttons.
		// -----------------------------------------------------------------------------------------------------------------------

		private var _navigation:NavigationView;

		public function setNavigation( navigation:NavigationView ):void {
			_navigation = navigation;
		}

		protected function setLeftButton( label:String ):void {
			_navigation.setLeftButton( label );
		}

		protected function setRightButton( label:String ):void {
			_navigation.setRightButton( label );
		}

		protected function setCenterButtons( definition:ButtonGroupDefinitionVO ):void {

			// Scroll capable container.
			_scrollContainer = new ScrollContainer();
//			_scrollContainer.backgroundSkin = new Quad( 100, 100, 0x222222 ); // Uncomment for visual debugging.
			_scrollContainer.horizontalScrollPolicy = Scroller.SCROLL_POLICY_AUTO;
			_scrollContainer.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_scrollContainer.height = Settings.NAVIGATION_AREA_CONTENT_HEIGHT;
			_backLayer.addChild( _scrollContainer );

			// Add buttons to the container.
			var inflate:Number = 150;
			var accumulatedContentWidth:Number = inflate;
			var len:uint = definition.buttonVOArray.length;
			var gap:Number = 15;
			for( var i:uint = 0; i < len; i++ ) {
				var vo:ButtonDefinitionVO = definition.buttonVOArray[ i ];
				var subButton:CompoundButton = new CompoundButton( vo.label, ButtonSkinType.LABEL );
				subButton.addEventListener( Event.TRIGGERED, onButtonTriggered );
				subButton.x = inflate + ( subButton.width + gap ) * i;
				subButton.y = 30;
				accumulatedContentWidth += subButton.width;
				if( i != len - 1 ) {
					accumulatedContentWidth += gap;
				}
				else if( i == len - 1 ) {
					accumulatedContentWidth += inflate;
				}
				_scrollContainer.addChild( subButton );
			}

			// Ensure that the rightmost gap is applied.
			var contentWidthEnforcer:Sprite = new Sprite();
			contentWidthEnforcer.x = accumulatedContentWidth;
			_scrollContainer.addChild( contentWidthEnforcer );

			// Center the container.
			if( accumulatedContentWidth < 1024 ) {
				_scrollContainer.width = accumulatedContentWidth;
			}
			else {
				_scrollContainer.width = 1024;
			}
			_scrollContainer.x = 1024 / 2 - _scrollContainer.width / 2;
			
			
		}

		public function clearCenterButtons():void {
			
			
			
			if( _scrollContainer ) {
				
				
				// Kill children.
				while( _scrollContainer.numChildren > 0 ) {
					var child:CompoundButton = _scrollContainer.getChildAt( 0 ) as CompoundButton;
					_scrollContainer.removeChildAt( 0 );
					if( child ) {
						// TODO: check if working
						child.removeEventListener( Event.TRIGGERED, onButtonTriggered );
						child.dispose();
						child = null;
					}
				}

				// Kill container.
				_backLayer.removeChild( _scrollContainer );
				_scrollContainer.dispose();
				_scrollContainer = null;
			}
		}

		public function notifyButtonPress( buttonLabel:String ):void {
			trace( this, "notifying button pressed: " + buttonLabel );
			buttonPressedSignal.dispatch( buttonLabel );
		}

		// ---------------------------------------------------------------------
		// Protected.
		// ---------------------------------------------------------------------

		protected function onButtonTriggered( event:Event ):void {
			var button:CompoundButton = event.currentTarget as CompoundButton;
			notifyButtonPress( button.label );
		}

		// ---------------------------------------------------------------------
		// Private.
		// ---------------------------------------------------------------------

		private function onHeaderResized( event:Event ):void {
			_header.x = stage.stageWidth / 2 - _header.width / 2;
			_header.y = -_header.height / 2+20;
		}
	}
}
