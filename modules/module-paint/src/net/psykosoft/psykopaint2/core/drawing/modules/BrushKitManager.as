package net.psykosoft.psykopaint2.core.drawing.modules
{

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import net.psykosoft.psykopaint2.base.remote.PsykoSocket;
	import net.psykosoft.psykopaint2.base.utils.ui.CanvasInteractionUtil;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.drawing.brushes.AbstractBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.BrushShapeLibrary;
	import net.psykosoft.psykopaint2.core.drawing.brushkits.BrushKit;
	import net.psykosoft.psykopaint2.core.drawing.data.ParameterSetVO;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureType;
	import net.psykosoft.psykopaint2.core.managers.pen.WacomPenManager;
	import net.psykosoft.psykopaint2.core.model.CanvasHistoryModel;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.signals.NotifyActivateBrushChangedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyAvailableBrushTypesSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyCanvasMatrixChanged;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleChangedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyMemoryWarningSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyNavigationToggledSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestAddViewToMainLayerSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationToggleSignal;
	import net.psykosoft.psykopaint2.paint.configuration.BrushKitDefaultSet;
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
			_navigationIsVisible = true;
		}
		
		private function onNavigationToggled( shown:Boolean ):void
		{
			_navigationIsVisible = shown;
		}
		
		// TODO: Handle gestures somewhere else
		private function onGlobalGesture( gestureType:String, event:GestureEvent):void
		{
			if ( !pipetteActive && gestureType == GestureType.TRANSFORM_GESTURE_BEGAN )
			{
				_activeBrushKit.brushEngine.pathManager.deactivate();
			}  else if (!pipetteActive &&  gestureType == GestureType.TRANSFORM_GESTURE_ENDED )
			{
				_activeBrushKit.brushEngine.pathManager.activate( _view, canvasModel, renderer );
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
						_activeBrushKit.brushEngine.pathManager.deactivate();
						pipetteActive = true;
					}
				}
			} else if ( gestureType == GestureType.LONG_TAP_GESTURE_ENDED )
			{
				if ( pipetteActive )
				{
					pipetteActive = false;
					_activeBrushKit.brushEngine.pathManager.activate(_view, canvasModel, renderer );
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

		private function registerBrushKit( brushKit:BrushKit, kitName:String ):void {
			_availableBrushKits.push(brushKit);
			_availableBrushKitNames.push(kitName);
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
		}

		public function activate() : void
		{
			brushShapeLibrary.init();
			
			var brushKitDef : XML = BrushKitDefaultSet.brushKitData.copy();

			_availableBrushKits = new Vector.<BrushKit>();
			_availableBrushKitNames = new Vector.<String>();

			for ( var i:int = 0; i < brushKitDef.brush.length(); i++ )
				registerBrushKit( BrushKit.fromXML(brushKitDef.brush[i]), brushKitDef.brush[i].@name);

			initializeDefaultBrushes();

			_active = true;
			
			
			if ( CoreSettings.ENABLE_PSYKOSOCKET_CONNECTION )
			{
				PsykoSocket.sendString( '<msg src="PaintModule.activate" />' );
			}
			
			if ( !_activeBrushKit ) activeBrushKit = _availableBrushKitNames[0];
			activateBrushKit();
			
			
		}

		public function deactivate() : void
		{
			_active = false;
			_availableBrushKits = null;
			_availableBrushKitNames = null;
			deactivateBrushKit();
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
				updateCurrentBrushColorParameter( );
				onPickedColorChanged( paintSettingsModel.currentColor, paintSettingsModel.colorMode, false );
			}
		}

		private function deactivateBrushKit() : void
		{
			if ( _activeBrushKit )
			{
				_activeBrushKit.deactivate();
				_activeBrushKit.brushEngine.removeEventListener(AbstractBrush.STROKE_STARTED, onStrokeStarted);
				_activeBrushKit.brushEngine.removeEventListener( AbstractBrush.STROKE_ENDED, onStrokeEnded );
				_activeBrushKit.removeEventListener( Event.CHANGE, onActiveBrushKitChanged );
				_activeBrushKit = null;
				_activeBrushKitName = "";
			}
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
			
			_activeBrushKit.brushEngine.snapShot = canvasHistory.takeSnapshot();
			
		}
		
		private function onStrokeEnded(event : Event) : void
		{
			singleTapDelay = getTimer();
			_view.removeEventListener(Event.ENTER_FRAME, onPaintOverNavCheck );
			if ( _navigationWasHiddenByPainting )
			{
				clearTimeout( _revealNavigationTimeout );
				_revealNavigationTimeout = setTimeout( revealHiddenNavigation,400 );
			}
		
		}
		
		private function revealHiddenNavigation() : void
		{
			requestNavigationToggleSignal.dispatch(1);
			_navigationWasHiddenByPainting = false;
		}
		
		protected function onPaintOverNavCheck(event:Event):void
		{
			if ( _view.mouseY > 550 )
			{
				requestNavigationToggleSignal.dispatch(-1);
				_view.removeEventListener(Event.ENTER_FRAME, onPaintOverNavCheck );
				_navigationWasHiddenByPainting = true;
			}
			
		}
		
		
		public function getAvailableBrushTypes() : Vector.<String> {
			return _availableBrushKitNames;
		}

		
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
		
	}
}