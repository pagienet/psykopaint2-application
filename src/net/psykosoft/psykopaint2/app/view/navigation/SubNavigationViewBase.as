package net.psykosoft.psykopaint2.app.view.navigation
{

	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;
	
	import net.psykosoft.psykopaint2.app.config.Settings;
	import net.psykosoft.psykopaint2.app.view.base.StarlingViewBase;
	import net.psykosoft.psykopaint2.app.view.components.buttons.FooterNavButton;
	import net.psykosoft.psykopaint2.app.view.components.label.PaperHeaderLabel;
	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonDefinitionVO;
	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonGroupDefinitionVO;
	import net.psykosoft.psykopaint2.ui.theme.Psykopaint2Ui;
	import net.psykosoft.psykopaint2.ui.theme.data.ButtonSkinType;
	
	import org.osflash.signals.Signal;
	
	import starling.display.Sprite;
	import starling.events.Event;

	public class SubNavigationViewBase extends StarlingViewBase
	{
		private var _scrollContainer:ScrollContainer;
		private var _headerLabel:PaperHeaderLabel;
		private var _title:String;
		private var _frontLayer:Sprite; // TODO: do we still need layers given that the edge buttons have been moved out of this abstract class?
		private var _backLayer:Sprite;
		private var _navigation:NavigationView;

		public var buttonPressedSignal:Signal;

		public function SubNavigationViewBase( title:String = "" ) {
			super();
			buttonPressedSignal = new Signal();
			_title = title;
			trace( this, "sub-navigation view created: " + _title );
		}

		public function changeTitle( value:String ):void {
			_title = value;
			if( _headerLabel ) {
				_headerLabel.setLabel( _title );
			}
		}

		// ---------------------------------------------------------------------
		// Overrides.
		// ---------------------------------------------------------------------

		override protected function onEnabled():void {

			addChild( _backLayer = new Sprite() );
			addChild( _frontLayer = new Sprite() );

			_headerLabel = new PaperHeaderLabel();
			_headerLabel.addEventListener( Event.RESIZE, onHeaderResized );
			_headerLabel.setLabel(_title);
			_frontLayer.addChild( _headerLabel );
			_headerLabel.x = stage.stageWidth / 2 - _headerLabel.width / 2;
			_headerLabel.y = -_headerLabel.height / 2+20;
		}

		override protected function onDisabled():void {

			clearCenterButtons();

			if( _headerLabel ) {
				_frontLayer.removeChild( _headerLabel );
			}

			if( _frontLayer ) {
				removeChild( _frontLayer );
			}

			if( _backLayer ) {
				removeChild( _backLayer );
			}
		}

		override protected function onDispose():void {

			if( _headerLabel ) {
				_headerLabel.dispose();
				_headerLabel = null;
			}

			if( _frontLayer ) {
				_frontLayer.dispose();
				_frontLayer = null;
			}

			if( _backLayer ) {
				_backLayer.dispose();
				_backLayer = null;
			}

		}

		// -----------------------------------------------------------------------------------------------------------------------
		// Settings center buttons.
		// -----------------------------------------------------------------------------------------------------------------------

		public function setNavigation( navigation:NavigationView ):void {
			_navigation = navigation;
		}

		protected function setLeftButton( textureID:String,label:String ):void {
			_navigation.setLeftButton(textureID, label );
		}

		protected function setRightButton(textureID:String, label:String ):void {
			_navigation.setRightButton(textureID, label );
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
				var subButton:FooterNavButton = new FooterNavButton( Psykopaint2Ui.instance.footerAtlas.getTexture( vo.textureID  ) , vo.label, ButtonSkinType.LABEL );
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
					var child:FooterNavButton = _scrollContainer.getChildAt( 0 ) as FooterNavButton;
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
//			trace( this, ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> notifying button pressed: " + buttonLabel );
			buttonPressedSignal.dispatch( buttonLabel );
		}

		// ---------------------------------------------------------------------
		// Protected.
		// ---------------------------------------------------------------------

		protected function onButtonTriggered( event:Event ):void {
//			trace( this, "button triggered" );
			var button:FooterNavButton = event.currentTarget as FooterNavButton;
			notifyButtonPress( button.label );
		}

		// ---------------------------------------------------------------------
		// Private.
		// ---------------------------------------------------------------------

		private function onHeaderResized( event:Event ):void {
			trace("[SubNavigationView] onHeaderResized");
			
			_headerLabel.x = stage.stageWidth / 2 - _headerLabel.width / 2;
			_headerLabel.y = -_headerLabel.height / 2+20;
		}
	}
}
