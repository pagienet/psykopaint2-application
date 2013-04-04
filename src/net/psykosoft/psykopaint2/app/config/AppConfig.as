package net.psykosoft.psykopaint2.app.config
{

	import com.junkbyte.console.Cc;

	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;

	import net.psykosoft.psykopaint2.app.config.configurators.CommandsConfig;
	import net.psykosoft.psykopaint2.app.config.configurators.IncludeClassesConfig;
	import net.psykosoft.psykopaint2.app.config.configurators.ModelsConfig;
	import net.psykosoft.psykopaint2.app.config.configurators.NotificationsConfig;
	import net.psykosoft.psykopaint2.app.config.configurators.ServicesConfig;
	import net.psykosoft.psykopaint2.app.config.configurators.SingletonsConfig;
	import net.psykosoft.psykopaint2.app.config.configurators.ViewMediatorsConfig;
	import net.psykosoft.psykopaint2.app.utils.DebuggingConsole;
	import net.psykosoft.psykopaint2.app.view.rootsprites.Away3dRootSprite;
	import net.psykosoft.robotlegs.bundles.SignalCommandMapBundle;

	import org.swiftsuspenders.Injector;

	import robotlegs.bender.bundles.mvcs.MVCSBundle;
	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;
	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.impl.Context;
	import robotlegs.extensions.starlingViewMap.StarlingViewMapExtension;

	import starling.core.Starling;

	public class AppConfig
	{
		protected var _context:IContext;
		protected var _injector:Injector;
		protected var _mediatorMap:IMediatorMap;
		protected var _commandMap:ISignalCommandMap;
		protected var _display:DisplayObjectContainer;

		public function AppConfig( display:DisplayObjectContainer, starling:Starling ):void {

			// Debug utility.
			if( Settings.ENABLE_DEBUG_CONSOLE ) {
				new DebuggingConsole( display );
				Cc.log( this, "configuring app - " + Settings.NAME + " " + Settings.VERSION );
			}

			// Initialize robotlegs elements.
			_display = display;
			_context = new Context();
			_context.install( MVCSBundle, StarlingViewMapExtension, SignalCommandMapBundle );
			_context.configure( display, starling );
			_context.configure( new ContextView( display ) );
			_injector = _context.injector;
			_mediatorMap = _injector.getInstance( IMediatorMap );
			_commandMap = _injector.getInstance( ISignalCommandMap );

			// Run dedicated configurators.
			new IncludeClassesConfig();
			new CommandsConfig( _commandMap );
			new NotificationsConfig( _injector );
			new ViewMediatorsConfig( _mediatorMap );
			new ModelsConfig( _injector );
			new ServicesConfig( _injector );
			new SingletonsConfig( _injector );

			_injector.map( Stage ).toValue(display.stage);
		}

		public function initialize3dDisplayTree():void {
			// Note: the 2d display tree ( StarlingRootSprite.as ) is initialized in PsykoPaint2.as,
			// with the creation of the Starling root sprite object, which requires it at that time.
			_display.addChild( new Away3dRootSprite() );
		}

		public function get injector():Injector {
			return _injector;
		}
	}
}
