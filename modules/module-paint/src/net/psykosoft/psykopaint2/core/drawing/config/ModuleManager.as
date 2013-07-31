package net.psykosoft.psykopaint2.core.drawing.config
{

	import flash.display.BitmapData;
	import flash.utils.Dictionary;
	
	import net.psykosoft.psykopaint2.base.utils.images.BitmapDataUtils;
	import net.psykosoft.psykopaint2.core.drawing.data.ModuleType;
	import net.psykosoft.psykopaint2.core.drawing.modules.ColorStyleModule;
	import net.psykosoft.psykopaint2.core.drawing.modules.CropModule;
	import net.psykosoft.psykopaint2.core.drawing.modules.IModule;
	import net.psykosoft.psykopaint2.core.drawing.modules.BrushKitManager;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyCropCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyNavigationHideSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal_OLD_TO_REMOVE;

	import org.osflash.signals.Signal;

	public class ModuleManager
	{
		[Inject]
		public var paintModule:BrushKitManager;

		[Inject]
		public var cropModule:CropModule;

		[Inject]
		public var colorStyleModule:ColorStyleModule;

		[Inject]
		public var notifyCropCompleteSignal:NotifyCropCompleteSignal;

		[Inject]
		public var notifyColorStyleCompleteSignal:NotifyColorStyleCompleteSignal;

		[Inject]
		public var notifyNavigationHideSignal:NotifyNavigationHideSignal;

		[Inject]
		public var requestStateChangeSignal : RequestNavigationStateChangeSignal_OLD_TO_REMOVE;

		private var _activeModule:IModule;
		private var _lastActiveModuleType:String = ModuleType.NONE;
		private var _concatenatingTypes:Dictionary;
		private var _latestBmd:BitmapData; // TODO: this is a hack by Li, core guys, please review

		public function ModuleManager() {
			_concatenatingTypes = new Dictionary();
		}

		public function setSourceImage( bitmapData:BitmapData ):void {
			bitmapData = BitmapDataUtils.getLegalBitmapData(bitmapData);
			setActiveModule( cropModule, bitmapData );
		}

		public function setActiveModule( module:IModule, bitmapData:BitmapData = null ):void {

			if( bitmapData ) _latestBmd = bitmapData;
			else bitmapData = _latestBmd;

			if( _activeModule ) {
				_activeModule.deactivate();
				_lastActiveModuleType = _activeModule.type();
			}

			_activeModule = module;
			_activeModule.activate( bitmapData );

			// TEMPORARY!
			requestStateChangeSignal.dispatch( _activeModule.stateType );
		}
	}
}
