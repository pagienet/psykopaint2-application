package net.psykosoft.psykopaint2.core.views.navigation
{

	import com.greensock.TweenLite;
	import com.greensock.easing.Quad;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	
	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.base.ui.components.NavigationButton;
	import net.psykosoft.psykopaint2.base.utils.misc.ClickUtil;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.components.button.LeftButton;
	import net.psykosoft.psykopaint2.core.views.components.button.RightButton;
	
	import org.osflash.signals.Signal;

	public class NavigationView extends ViewBase
	{
		// Declared in Flash.
		public var bg:NavigationBg;
		public var header:NavigationHeader;
		public var leftBtnSide:Sprite;
		public var rightBtnSide:Sprite;
		public var loadingView:LoadingView

		public var buttonClickedSignal:Signal;

		private var _leftButton:LeftButton;
		private var _rightButton:RightButton;
		private var _currentSubNavView:SubNavigationViewBase;

		private var _panel:NavigationPanel;
		private var _clickedButton:NavigationButton;
		private var _previousSubNavView:Object;

		public function NavigationView() {
			super();

			buttonClickedSignal = new Signal();

			_leftButton = leftBtnSide.getChildByName( "btn" ) as LeftButton;
			_rightButton = rightBtnSide.getChildByName( "btn" ) as RightButton;

			initializePanel();

			setBgType( NavigationBg.BG_TYPE_ROPE );
		}

		override protected function onSetup():void {
			_leftButton.addEventListener( MouseEvent.CLICK, onButtonClicked );
			_rightButton.addEventListener( MouseEvent.CLICK, onButtonClicked );
			visible = false;
			loadingView.visible=false;
		}

		// ---------------------------------------------------------------------
		// Container/panel.
		// ---------------------------------------------------------------------

		private function initializePanel():void {
			_panel = new NavigationPanel();
			_panel.addChild( bg );
			_panel.addChild( leftBtnSide );
			_panel.addChild( rightBtnSide );
			addChildAt( _panel, 0 );
		}

		// ---------------------------------------------------------------------
		// Sub-navigation.
		// ---------------------------------------------------------------------

		public function updateSubNavigation( subNavType:Class ):void {

			//THE DIRECTION OF THE TRANSITION CHANGE IF WE CLICK ON BACK BUTTON
			var tweenDirection:int = (_clickedButton && _clickedButton.id =="Back")?-1:1;
			
			var navigationView:NavigationView = this;
			
			
			// Keep current nav when incoming class is the abstract one.
			// TODO: review...
			if( subNavType == SubNavigationViewBase ) {
				//loadingView.visible = true;
				return;
			}

			trace( this, "updating sub-nav: " + subNavType );
			
			//HIDE PREVIOUS VIEW
			if (_currentSubNavView){
				
				/*
				var snapShotContainer:Sprite = new Sprite();
				var matrix:Matrix = new Matrix();
				
				//MAKE A SNAPSHOT, SHOW IT AS SAME POSITION AND TWEEN IT
				//MATHIEU THIS TRANSITION LOOKS GOOD BUT IS TOO SLOW BECAUSE OF REGULAR DISPLAY LIST
				var snapshotBmd:BitmapData = new BitmapData(1024,this.height,true,0x00000000);
				matrix.ty =- this.getBounds(this).y;
				
				snapshotBmd.draw(this,matrix);
				var snapShotBm:Bitmap = new Bitmap(snapshotBmd);
				snapShotBm.y = this.y - matrix.ty;
				snapShotContainer.addChild(snapShotBm);
				
				var previousSubNavView:SubNavigationViewBase = _currentSubNavView;
				previousSubNavView.scrollerButtonClickedSignal.remove( onSubNavigationScrollerButtonClicked );
				_currentSubNavView = null;
				

				previousSubNavView.disable();
				previousSubNavView.parent.removeChild( previousSubNavView );
				
				// SHOW NEW NAVIGATION
				showNewSubNavigationView(subNavType);
				
				//TAKE AN OTHER SNAPSHOT OF THE NEW NAVIGATION VIEW
				var newSubNavViewBmd:BitmapData = new BitmapData(1024,this.height,true,0x00000000);
				matrix.ty =- this.getBounds(this).y;
				
				newSubNavViewBmd.draw(this,matrix);
				var newSubNavViewBm:Bitmap = new Bitmap(newSubNavViewBmd);
				newSubNavViewBm.y = this.y - matrix.ty;
				newSubNavViewBm.x =  (_clickedButton && _clickedButton.id =="Back")?-1024: 1024;
				//newSubNavViewBm.x *= CoreSettings.GLOBAL_SCALING;
				snapShotContainer.addChild(newSubNavViewBm);
				
				this.stage.addChild(snapShotContainer);
				snapShotContainer.scaleX = snapShotContainer.scaleY = CoreSettings.GLOBAL_SCALING;
				
				navigationView.visible=false;
				
				
				TweenLite.to(snapShotContainer,0.3,{ease:Quad.easeOut,x:-1024*tweenDirection*CoreSettings.GLOBAL_SCALING,onComplete:function():void{
					
					
					navigationView.visible=true;
					
					//REMOVE SNAPSHOTS
					snapShotContainer.parent.removeChild(snapShotContainer);
					
					newSubNavViewBmd.dispose();
					newSubNavViewBm.parent.removeChild(newSubNavViewBm);

					snapshotBmd.dispose();
					snapShotBm.parent.removeChild(snapShotBm);
					
					
				}});*/
				
				
				
				var previousSubNavView:SubNavigationViewBase = _currentSubNavView;
				previousSubNavView.scrollerButtonClickedSignal.remove( onSubNavigationScrollerButtonClicked );
				_currentSubNavView = null;
				previousSubNavView.disable();
				previousSubNavView.parent.removeChild( previousSubNavView );
				
				// SHOW NEW NAVIGATION
				showNewSubNavigationView(subNavType);
				
			}
			else {
				showNewSubNavigationView(subNavType);
				//loadingView.visible=false;
			}
		
			
		}
		
		private function showNewSubNavigationView(subNavType:Class):void{
			//THE DIRECTION OF THE TRANSITION CHANGE IF WE CLICK ON BACK BUTTON
			var tweenDirection:int = (_clickedButton && _clickedButton.id =="Back")?-1:1;
			
			// Defaults to rope bg.
			setBgType( NavigationBg.BG_TYPE_ROPE );
			
			// Reset.
			leftBtnSide.visible = false;
			rightBtnSide.visible = false;
			
			if( !subNavType ) {
				header.setTitle( "" );
				return;
			} else {
				setChildIndex(header,0);
			}
			
			
			
			trace( this, "creating new sub navigation view" );
			_currentSubNavView = new subNavType();
			_currentSubNavView.setNavigation( this );
			_panel.addChildAt( _currentSubNavView, 1 );
			_currentSubNavView.enable();
			_currentSubNavView.scrollerButtonClickedSignal.add( onSubNavigationScrollerButtonClicked );
			
			
			
		}
		

		private function disposeSubNavigation():void {
			if( _currentSubNavView ) {
				_currentSubNavView.scrollerButtonClickedSignal.remove( onSubNavigationScrollerButtonClicked );
				_currentSubNavView.disable();
				// Note: we don't dispose it here, as soon as the view is removed from display, its mediator will notice and dispose it.
				_panel.removeChild( _currentSubNavView );
				_currentSubNavView = null;
			}
		}
		
		
	

		// ---------------------------------------------------------------------
		// Side buttons.
		// ---------------------------------------------------------------------

		public function setLeftButton( id:String, label:String, iconType:String = ButtonIconType.BACK, showBackground:Boolean = true ):void {
			_leftButton.id = id;
			_leftButton.labelText = label;
			_leftButton.iconType = iconType;
			_leftButton.visible = true;
			leftBtnSide.visible = true;
			leftBtnSide.getChildByName( "clipOverlay" ).visible = leftBtnSide.getChildByName( "paperbg").visible = showBackground;
		}

		public function setRightButton( id:String, label:String, iconType:String = ButtonIconType.CONTINUE, labelVisible : Boolean = false ):void {
			_rightButton.id = id;
			_rightButton.labelText = label;
			_rightButton.iconType = iconType;
			_rightButton.visible = true;
			_rightButton.label.visible = labelVisible;
			rightBtnSide.visible = true;
		}

		public function showLeftButton( value:Boolean ):void {
			_leftButton.visible = value;
			leftBtnSide.visible = value;
		}

		public function showRightButton( value:Boolean ):void {
			_rightButton.visible = value;
			rightBtnSide.visible = value;
		}

		public function getButtonIconForRightButton():Sprite {
			if( _rightButton.icon.numChildren < 2 ) return null;
			return _rightButton.icon.getChildAt( 1 ) as Sprite;
		}

		// ---------------------------------------------------------------------
		// Button clicks.
		// ---------------------------------------------------------------------

		// Sub-navigation scroller clicks are routed here.
		private function onSubNavigationScrollerButtonClicked( event:MouseEvent ):void {
			onButtonClicked( event );
		}

		private function onButtonClicked( event:MouseEvent ):void {

			var clickedButton:NavigationButton = ClickUtil.getObjectOfClassInHierarchy( event.target as DisplayObject, NavigationButton ) as NavigationButton;
			if( !clickedButton ) throw new Error( "unidentified button clicked." );

			_clickedButton = clickedButton;
			trace( this, "button clicked - id: " + clickedButton.id + ", label: " + clickedButton.labelText );
			buttonClickedSignal.dispatch( clickedButton.id );
		}

		// ---------------------------------------------------------------------
		// Bg.
		// ---------------------------------------------------------------------

		public function setBgType( type:String ):void {
			bg.setBgType( type );
			if( type == NavigationBg.BG_TYPE_ROPE ) {
				_panel.contentHeight = 140;
				header.lowerEdge = 768;
			} else if ( type == NavigationBg.BG_TYPE_WOOD_LOW  ){
				_panel.contentHeight = 140;
				header.lowerEdge = 630;
			} else {
				_panel.contentHeight = 215;
				header.lowerEdge = 600;
			}
		}

		// ---------------------------------------------------------------------
		// Getters.
		// ---------------------------------------------------------------------

		public function get panel():NavigationPanel {
			return _panel;
		}

		public function setRightButtonBitmap(bitmap:Bitmap):void
		{
			_rightButton.iconBitmap = bitmap;
		}

		public function getRightButton():Sprite
		{
			return _rightButton;
		}
	}
}
