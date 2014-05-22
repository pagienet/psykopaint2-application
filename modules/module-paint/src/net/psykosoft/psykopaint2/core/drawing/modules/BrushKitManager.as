package net.psykosoft.psykopaint2.core.drawing.modules
{

	import com.milkmangames.nativeextensions.ios.StoreKitProduct;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import net.psykosoft.psykopaint2.base.remote.PsykoSocket;
	import net.psykosoft.psykopaint2.base.utils.events.DataSendEvent;
	import net.psykosoft.psykopaint2.base.utils.ui.CanvasInteractionUtil;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.drawing.brushes.AbstractBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.BrushShapeLibrary;
	import net.psykosoft.psykopaint2.core.drawing.brushkits.BrushKit;
	import net.psykosoft.psykopaint2.core.drawing.data.ParameterSetVO;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureManager;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureType;
	import net.psykosoft.psykopaint2.core.managers.pen.WacomPenManager;
	import net.psykosoft.psykopaint2.core.managers.purchase.InAppPurchaseManager;
	import net.psykosoft.psykopaint2.core.model.CanvasHistoryModel;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.models.PaintMode;
	import net.psykosoft.psykopaint2.core.models.UserConfigModel;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.signals.NotifyActivateBrushChangedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyAvailableBrushTypesSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyCanvasMatrixChanged;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleChangedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyMemoryWarningSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyNavigationToggledSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyProductPriceSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyToggleLoadingMessageSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyTogglePaintingEnableSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestAddViewToMainLayerSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationToggleSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUndoSignal;
	import net.psykosoft.psykopaint2.paint.configuration.BrushKitDefaultSet;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPaintModeChangedSignal;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPickedColorChangedSignal;
	import net.psykosoft.psykopaint2.paint.signals.NotifyShowPipetteSignal;
	import net.psykosoft.psykopaint2.paint.utils.CopyColorAndSourceToBitmapDataUtil;
	
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.LongPressGesture;

	// TODO: Clean up by moving into custom stuff where not affecting brush kits
	public class BrushKitManager
	{
		[Inject]
		public var renderer : CanvasRenderer;

		[Inject]
		public var canvasModel : CanvasModel;

		[Inject]
		public var canvasHistory : CanvasHistoryModel;
		
		[Inject]
		public var paintSettingsModel : UserPaintSettingsModel;
		
		[Inject]
		public var userConfig : UserConfigModel;

		[Inject]
		public var stage3D : Stage3D;
		
		[Inject]
		public var penManager : WacomPenManager;
		
		[Inject]
		public var brushShapeLibrary : BrushShapeLibrary;

		[Inject]
		public var notifyAvailableBrushTypesSignal:NotifyAvailableBrushTypesSignal;

		[Inject]
		public var notifyActivateBrushChangedSignal:NotifyActivateBrushChangedSignal;

		[Inject]
		public var memoryWarningSignal : NotifyMemoryWarningSignal;

		[Inject]
		public var requestStateChangeSignal:RequestNavigationStateChangeSignal;

		[Inject]
		public var notifyGlobalGestureSignal : NotifyGlobalGestureSignal;
		
		[Inject]
		public var notifyCanvasMatrixChanged : NotifyCanvasMatrixChanged;
		
		[Inject]
		public var notifyPickedColorChangedSignal : NotifyPickedColorChangedSignal;
		
		[Inject]
		public var notifyShowPipetteSignal : NotifyShowPipetteSignal;
		
		[Inject]
		public var notifyColorStyleChangedSignal : NotifyColorStyleChangedSignal;
		
		[Inject]
		public var requestAddViewToMainLayerSignal:RequestAddViewToMainLayerSignal;
		
		[Inject]
		public var notifyNavigationToggledSignal:NotifyNavigationToggledSignal;
		
		[Inject]
		public var requestNavigationToggleSignal:RequestNavigationToggleSignal;
		
		[Inject]
		public var notifyTogglePaintingEnableSignal:NotifyTogglePaintingEnableSignal;
		
		[Inject]
		public var notifyPaintModeChangedSignal:NotifyPaintModeChangedSignal;
		
		[Inject]
		public var notifyToggleLoadingMessageSignal:NotifyToggleLoadingMessageSignal;
		
		[Inject]
		public var requestUndoSignal:RequestUndoSignal;
		
		[Inject]
		public var notifyFullUpgradePriceSignal:NotifyProductPriceSignal;
		
		[Inject]
		public var purchaseManager:InAppPurchaseManager;
	
		private var _view : DisplayObject;
		private var _active : Boolean;
		private var _availableBrushKits:Vector.<BrushKit>;
		private var _availableBrushKitNames:Vector.<String>;
		private var _activeBrushKit : BrushKit;
		private var _activeBrushKitName : String;
		private var _canvasMatrix : Matrix;
		private var _currentBrushColorParameter:PsykoParameter;
		private var copyColorUtil:CopyColorAndSourceToBitmapDataUtil;
		private var currentColorMap:BitmapData;
		private var pickedColorPreview:Shape;
		private var pickedColorTf:ColorTransform;
		private var singleTapDelay:int;
		private var pipetteActive:Boolean;
		private var showColorPanelTheFirstTime:Boolean;
		private var _navigationIsVisible:Boolean;
		private var _navigationWasHiddenByPainting:Boolean;
		private var _revealNavigationTimeout:uint;
		private var _activeBrushEngine:AbstractBrush;
		//public var fullUpgradePackage:StoreKitProduct;
		public var currentPurchaseOptions:Vector.<String>;
		public var availableProducts:Object = {};
		
		public function BrushKitManager()
		{
			super();
		}

		[PostConstruct]
		public function postConstruct() : void
		{
			AbstractBrush.brushShapeLibrary = brushShapeLibrary;
			memoryWarningSignal.add(onMemoryWarning);
			notifyCanvasMatrixChanged.add(onCanvasMatrixChanged);
			notifyGlobalGestureSignal.add( onGlobalGesture );
			notifyPickedColorChangedSignal.add( onPickedColorChanged );
			notifyColorStyleChangedSignal.add( onColorStyleChanged );
			notifyNavigationToggledSignal.add( onNavigationToggled );
			notifyTogglePaintingEnableSignal.add( onToggleEnablePainting );
			notifyPaintModeChangedSignal.add( onPaintModeChanged );
			notifyFullUpgradePriceSignal.add( onUpgradePriceAvailable );
			
			_navigationIsVisible = true;
		}
		
		private function onNavigationToggled( shown:Boolean ):void
		{
			_navigationIsVisible = shown;
		}
		
		private function onToggleEnablePainting( enable:Boolean ):void
		{
			if ( _activeBrushKit )
			{
				if ( enable ) 
					_activeBrushKit.brushEngine.pathManager.activate( _view, canvasModel, renderer );
				else
					_activeBrushKit.brushEngine.pathManager.deactivate();
			}
		}
		
		private function onPaintModeChanged( paintMode:int ):void
		{
			if ( _activeBrushKit )
			{
				_activeBrushKit.eraserMode = ( paintMode == PaintMode.ERASER_MODE );
			}
		}
		
		// TODO: Handle gestures somewhere else
		private function onGlobalGesture( gestureType:String, event:GestureEvent):void
		{
			if ( !pipetteActive && gestureType == GestureType.TRANSFORM_GESTURE_BEGAN )
			{
				notifyTogglePaintingEnableSignal.dispatch(false);
			}  else if (!pipetteActive &&  gestureType == GestureType.TRANSFORM_GESTURE_ENDED )
			{
				notifyTogglePaintingEnableSignal.dispatch(true);
			} else if ( gestureType == GestureType.LONG_TAP_GESTURE_BEGAN )
			{
				var clip:* = LongPressGesture(event.target).target;
				var target:Stage =  Stage( clip );
				var obj:Array = target.getObjectsUnderPoint(LongPressGesture(event.target).location);
				if (obj.length == 0 || CanvasInteractionUtil.canContentsUnderMouseBeIgnored( clip ) )
				{
					var px : Number = (_view.mouseX - _canvasMatrix.tx * 1024) / _canvasMatrix.a * CoreSettings.GLOBAL_SCALING;
					var py : Number = (_view.mouseY - _canvasMatrix.ty * 768)  / _canvasMatrix.d * CoreSettings.GLOBAL_SCALING;
					
					if ( px >= 0 && px < canvasModel.width && py >= 0 && py < canvasModel.height )
					{
						if ( !showColorPanelTheFirstTime )
						{
							showColorPanelTheFirstTime = true;
							requestStateChangeSignal.dispatch( NavigationStateType.PAINT_ADJUST_COLOR );
						}
						if ( copyColorUtil == null )
						{
							copyColorUtil = new CopyColorAndSourceToBitmapDataUtil(); 
						}
						copyColorUtil.sourceTextureAlpha = renderer.sourceTextureAlpha;
						copyColorUtil.paintAlpha = renderer.paintAlpha;
						currentColorMap = copyColorUtil.execute( canvasModel );
						
						var color:uint = currentColorMap.getPixel(px,py);
						notifyShowPipetteSignal.dispatch( _view, color,new Point(_view.mouseX,_view.mouseY - 32), true);
						notifyTogglePaintingEnableSignal.dispatch(false);
						pipetteActive = true;
					}
				}
			} else if ( gestureType == GestureType.LONG_TAP_GESTURE_ENDED )
			{
				if ( pipetteActive )
				{
					pipetteActive = false;
					notifyTogglePaintingEnableSignal.dispatch(true);
					copyColorUtil.dispose();
				}
			}
		}

		private function onCanvasMatrixChanged(matrix : Matrix) : void
		{
			_canvasMatrix = matrix;
			if (_activeBrushKit)
			{
				_activeBrushKit.setCanvasMatrix(matrix);
			}
		}
		
		private function onPickedColorChanged( newColor:int, colorMode:int, fromSlider:Boolean ):void
		{
			if ( _currentBrushColorParameter ) _currentBrushColorParameter.colorValue = paintSettingsModel.currentColor;
		}
		
		private function onColorStyleChanged( colorMatrix:Vector.<Number>, blendFactor:Number ):void
		{
			_activeBrushKit.brushEngine.setColorStrategyColorMatrix(colorMatrix,blendFactor);
		}	
	
		private function updateCurrentBrushColorParameter( ):void
		{
			var parameterSetVO:ParameterSetVO = getCurrentBrushParameters(false);
			var list:Vector.<PsykoParameter> = parameterSetVO.parameters;
			var numParameters:uint = list.length;
			for( var i:uint = 0; i < numParameters; ++i ) {
				var parameter:PsykoParameter = list[ i ];
				if( parameter.type == PsykoParameter.ColorParameter ) {
					_currentBrushColorParameter = parameter;
					return;
				} 
			}
		}
		
		public function stopAnimations() : void
		{
			if (_activeBrushKit)
				_activeBrushKit.stopProgression();
		}

		private function initializeDefaultBrushes():void {
			notifyAvailableBrushTypesSignal.dispatch( _availableBrushKitNames );
		}

		private function registerBrushKit( brushKit:BrushKit ):void {
			_availableBrushKits.push(brushKit);
			_availableBrushKitNames.push(brushKit.name);
		}
		
		public function get activeBrushKit() : String
		{
			return _activeBrushKitName;
		}

		public function set activeBrushKit( brushKitName:String ) : void
		{
			if (_activeBrushKitName == brushKitName) return;
			if ( _activeBrushKit ) deactivateBrushKit();
			
			_activeBrushKitName = brushKitName;
			_activeBrushKit = _availableBrushKits[ _availableBrushKitNames.indexOf(brushKitName)];
			if (_active) activateBrushKit();
			
			//trace( this, "activating brush kit: " + _activeBrushKitName + ", engine: " + _activeBrushKit.brushEngine + " --------------------" );
			
			notifyActivateBrushChangedSignal.dispatch( _activeBrushKit.getParameterSet( !CoreSettings.SHOW_HIDDEN_BRUSH_PARAMETERS ) );
		}

		
		public function get view() : DisplayObject
		{
			return _view;
		}

		public function set view(view : DisplayObject) : void
		{
			if (_active)
				deactivateBrushKit();

			_view = view;

			if (_active)
				activateBrushKit();
			
			if ( !CoreSettings.RUNNING_ON_iPAD )
			{
				_view.stage.addEventListener(KeyboardEvent.KEY_UP,onKeyUp);
			}
		}
		
		protected function onKeyUp(event:KeyboardEvent):void
		{
			if ( event.keyCode == Keyboard.U && GestureManager.gesturesEnabled )
			{
				requestUndoSignal.dispatch();
			}
			
		}
		
		public function activate() : void
		{
			brushShapeLibrary.init();
			
			//var brushKitDef : XML = BrushKitDefaultSet.brushKitData.copy();

			_availableBrushKits = new Vector.<BrushKit>();
			_availableBrushKitNames = new Vector.<String>();
			for ( var i:int = 0; i < BrushKitDefaultSet.brushKits.length; i++ )
			{
				registerBrushKit(BrushKitDefaultSet.brushKits[i]);
			}
			/*
			for ( var i:int = 0; i < brushKitDef.brush.length(); i++ )
				registerBrushKit( BrushKit.fromXML(brushKitDef.brush[i]), brushKitDef.brush[i].@name);
			*/
			initializeDefaultBrushes();
			
			_active = true;
			
			
			if ( CoreSettings.ENABLE_PSYKOSOCKET_CONNECTION )
			{
				PsykoSocket.sendString( '<msg src="PaintModule.activate" />' );
			}
			
			if ( !_activeBrushKit ) activeBrushKit = _availableBrushKitNames[0];
			activateBrushKit();
			paintSettingsModel.setDefaultValues();
			notifyToggleLoadingMessageSignal.dispatch(false);
		}

		public function deactivate() : void
		{
			_active = false;
			_availableBrushKits = null;
			_availableBrushKitNames = null;
			deactivateBrushKit(true);
			brushShapeLibrary.dispose();
			paintSettingsModel.dispose();
			trace("BrushKitManager deactivated");
		}

		private function activateBrushKit() : void
		{
			if ( _activeBrushKit )
			{
				_activeBrushKit.setCanvasMatrix(_canvasMatrix);
				_activeBrushKit.activate( _view, stage3D.context3D, canvasModel, renderer, paintSettingsModel);
				_activeBrushKit.brushEngine.addEventListener( AbstractBrush.STROKE_STARTED, onStrokeStarted);
				_activeBrushKit.brushEngine.addEventListener( AbstractBrush.STROKE_ENDED, onStrokeEnded );
				_activeBrushKit.addEventListener( Event.CHANGE, onActiveBrushKitChanged );
				_activeBrushKit.addEventListener( BrushKit.EVENT_BRUSH_ENGINE_CHANGE, onChangeBrushEngine );
				updateCurrentBrushColorParameter( );
				onPickedColorChanged( paintSettingsModel.currentColor, paintSettingsModel.colorMode, false );
				_activeBrushEngine = _activeBrushKit.brushEngine;
			}
		}

		private function deactivateBrushKit( dispose:Boolean = false) : void
		{
			if ( _activeBrushKit )
			{
				_activeBrushKit.deactivate();
				_activeBrushKit.brushEngine.removeEventListener(AbstractBrush.STROKE_STARTED, onStrokeStarted);
				_activeBrushKit.brushEngine.removeEventListener( AbstractBrush.STROKE_ENDED, onStrokeEnded );
				_activeBrushKit.removeEventListener( Event.CHANGE, onActiveBrushKitChanged );
				_activeBrushKit.removeEventListener( BrushKit.EVENT_BRUSH_ENGINE_CHANGE, onChangeBrushEngine );

				if ( dispose ) _activeBrushKit.dispose();
				_activeBrushKit = null;
				_activeBrushKitName = "";
				_activeBrushEngine = null;
			}
		}
		
		
		

		private function onChangeBrushEngine( event:DataSendEvent /* THE NEW ENGINE TYPE IS SENT IN THE EVENT */ ):void
		{
			var newActiveBrushEngine:AbstractBrush = event.data;
			
			//REMOVE OLD ACTIVE ENGINE EVENTS
			_activeBrushEngine.removeEventListener(AbstractBrush.STROKE_STARTED, onStrokeStarted);
			_activeBrushEngine.removeEventListener( AbstractBrush.STROKE_ENDED, onStrokeEnded );
			
			_activeBrushEngine = newActiveBrushEngine;
			//ADD NEW EVENTS
			_activeBrushEngine.addEventListener( AbstractBrush.STROKE_STARTED, onStrokeStarted);
			_activeBrushEngine.addEventListener( AbstractBrush.STROKE_ENDED, onStrokeEnded );

			trace("CHANGE BRUSH ENGINE!!!");
			
		}
		
		
		private function onActiveBrushKitChanged( event:Event ):void
		{
			notifyActivateBrushChangedSignal.dispatch(_activeBrushKit.getParameterSet( !CoreSettings.SHOW_HIDDEN_BRUSH_PARAMETERS ));
		}
		
		private function onStrokeStarted(event : Event) : void
		{
			trace("stroke started");
			clearTimeout( _revealNavigationTimeout );
			if ( _navigationIsVisible ) {
				trace("nav is visible - checking for mouse over nav");
				_view.addEventListener(Event.ENTER_FRAME, onPaintOverNavCheck );
			}
			
			
			//TRIAL: WE RECORD UNDOS ALL THE TIME EXEPT IF THE BRUSH IS PURCHASABLE AND WE DO NOT OWN IT
			//THEN IT RECORDS ONLY THE FIRST TIME
			if(!userConfig.userConfig.userOwns(_activeBrushKit.purchasePackages)  ){
				if(userConfig.userConfig.trialMode==false){
					
					userConfig.userConfig.trialMode = true;
					
				}else {
					canvasHistory.undo();
				}
			}
			
			_activeBrushKit.brushEngine.snapShot = canvasHistory.takeSnapshot();

		}
		
		private function onStrokeEnded(event : Event) : void
		{
			singleTapDelay = getTimer();
			_view.removeEventListener(Event.ENTER_FRAME, onPaintOverNavCheck );
			
			if ( !userConfig.userConfig.userOwns(_activeBrushKit.purchasePackages) ) 
			{
				// !userConfig.userConfig.hasBrushKit1 && _activeBrushKit.isPurchasable
				GestureManager.gesturesEnabled = false;
				notifyTogglePaintingEnableSignal.dispatch(false);

				clearTimeout( _revealNavigationTimeout );
				revealHiddenNavigation();
				currentPurchaseOptions = _activeBrushKit.purchasePackages;
				requestStateChangeSignal.dispatch( NavigationStateType.PAINT_BUY_UPGRADE);
				
			} else if ( _navigationWasHiddenByPainting )
			{
				clearTimeout( _revealNavigationTimeout );
				_revealNavigationTimeout = setTimeout( revealHiddenNavigation,400 );
			}
			
		
		}
		
		private function revealHiddenNavigation() : void
		{
			requestNavigationToggleSignal.dispatch(1,true, true);
			_navigationWasHiddenByPainting = false;
		}
		
		protected function onPaintOverNavCheck(event:Event):void
		{
			if (_canvasMatrix.a > 0.78 && _view.mouseY > 560 )
			{
			
				requestNavigationToggleSignal.dispatch(-1,false, true);
				_view.removeEventListener(Event.ENTER_FRAME, onPaintOverNavCheck );
				_navigationWasHiddenByPainting = true;
			}
			
		}
		
		
		public function getAvailableBrushTypes() : Vector.<String> {
			return _availableBrushKitNames;
		}

		//TODO: find out why this is called twice at initialization
		public function getCurrentBrushParameters( uiOnlyParameters:Boolean = true):ParameterSetVO {
			trace( this, "getCurrentBrushParameters() - active brush kit name: " + _activeBrushKitName  );
			return _activeBrushKit.getParameterSet( uiOnlyParameters );
		}
		
		public function update() : void
		{
			if ( _activeBrushKit ) _activeBrushKit.brushEngine.draw();
		}

		private function onMemoryWarning() : void
		{
			if ( CoreSettings.ENABLE_PSYKOSOCKET_CONNECTION )
			{
				PsykoSocket.sendString( '<msg src="PaintModule.onMemoryWarning" />' );
			}
			if (_activeBrushKit)
				_activeBrushKit.brushEngine.freeExpendableMemory();
		}
		
		private function onUpgradePriceAvailable( product:StoreKitProduct):void
		{
			availableProducts[product.productId] = product;
		}
		
	}
}