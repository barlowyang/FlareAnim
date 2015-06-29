package
{
	import com.bit101.components.Text;
	
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	
	import flare.core.Label3D;
	import flare.core.Mesh3D;
	import flare.core.Pivot3D;
	import flare.loaders.Flare3DLoader;
	
	[SWF(width="1200",height="800",frameRate="60")]
	public class FlareAnim extends Sprite
	{
		private static var _inst:FlareAnim;
		public static function get inst():FlareAnim
		{
			return _inst;
		}
		
		private var _scene:AnimScene;
		
		public function FlareAnim()
		{
			_inst = this;
			if (this.stage)
			{
				onInitStage(null);	
			}
			else
			{
				addEventListener(Event.ADDED_TO_STAGE, onInitStage);
			}
		}
		
		private function onInitStage(evt:Event):void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			_scene = new AnimScene(this);
			_scene.antialias = 4;
			_scene.autoResize  = true;
			_scene.camera.z = -20;
			_scene.camera.y = 5;
			
			var menu:NativeMenu = new NativeMenu();
			var menuItem:NativeMenuItem = new NativeMenuItem("打开模型");
			menuItem.addEventListener(Event.SELECT, onOpenFile);
			menu.addItem(menuItem);
			
			menuItem = new NativeMenuItem("打开动画配置");
			menuItem.addEventListener(Event.SELECT, onOpenFileCfg);
			menu.addItem(menuItem);
			
			menuItem = new NativeMenuItem("保存动画配置");
			menuItem.addEventListener(Event.SELECT, onSaveFileCfg);
			menu.addItem(menuItem);
			
			menuItem = new NativeMenuItem("打开最终");
			menuItem.addEventListener(Event.SELECT, onOpenFinish);
			menu.addItem(menuItem);
			
			menuItem = new NativeMenuItem("保存最终");
			menuItem.addEventListener(Event.SELECT, onSaveFinish);
			menu.addItem(menuItem);
			
			stage.nativeWindow.menu = menu;
			
			_animPanel = new AnimPanel(this);
			
			_info_txt = new Text(this);
			
			stage.addEventListener(Event.RESIZE, Resize);
			Resize();
		}
		
		private function onOpenFinish(evt:Event):void
		{
			_finishFile = new File();
			_finishFile.addEventListener(Event.SELECT, onSelectFinishFile);
			_finishFile.browse([new FileFilter("flare3d anim", "*.anim")]);
		}
		
		private function onSelectFinishFile(evt:Event):void
		{
			var file:File = evt.currentTarget as File;
			file.removeEventListener(Event.SELECT, onSelectFinishFile);
			
			_animPanel.reset();
			
			var fileStr:FileStream = new FileStream();
			fileStr.open(file, FileMode.READ);
			var bytes:LitterByteArray = new LitterByteArray();
			fileStr.readBytes(bytes);
			
			var anim_b:LitterByteArray = new LitterByteArray();
			var anim_len:uint = bytes.readUnsignedInt();
			bytes.readBytes(anim_b, 0, anim_len);
			parseAnim(anim_b);
			
			var cfg_len:uint = bytes.readUnsignedInt();
			var cfg_b:LitterByteArray = new LitterByteArray();
			bytes.readBytes(cfg_b, 0, cfg_len);
			parseCfg(cfg_b);
		}
		
		private function parseAnim(anim_b:LitterByteArray):void
		{
			_f3d_bytes = new LitterByteArray();
			anim_b.readBytes(_f3d_bytes);
			anim_b.position = 0;
			
			var f3d:Flare3DLoader = new Flare3DLoader(anim_b);
			f3d.addEventListener(Event.COMPLETE, onLoadSurc);
			f3d.load();
		}
		
		private function parseCfg(cfg_b:LitterByteArray):void
		{
			var count:uint = cfg_b.readShort();
			for (var i:int = 0; i < count; i++)
			{
				_animPanel.addItem(new Label3D(cfg_b.readUTF(), cfg_b.readShort(), cfg_b.readShort()));
			}
		}
		
		private function onSaveFinish(evt:Event):void
		{
			if (_animPanel.itemList.length)
			{
				if (_f3d_bytes)
				{
					var bytes:LitterByteArray = new LitterByteArray();
					bytes.writeUnsignedInt(_f3d_bytes.length);
					bytes.writeBytes(_f3d_bytes);
					
					var cfg_b:LitterByteArray = cfg_bytes;
					bytes.writeUnsignedInt(cfg_b.length);
					bytes.writeBytes(cfg_b);
					
					trace(bytes.length);
					bytes.compress();
					trace(bytes.length);
					bytes.compress();
					trace(bytes.length);
					
					if (_finishFile)
					{
						var fileStr:FileStream = new FileStream();
						fileStr.open(_finishFile, FileMode.WRITE);
						//fileStr.writeBytes(bytes);
					}
					else
					{
						_finishFile = new File();
						//_finishFile.save(bytes, ".anim");
					}
				}
				else
				{
					showInfo("没有动作模型!");
				}
			}
			else
			{
				showInfo("没有动作标签!");
			}
		}
		
		private var _animPanel:AnimPanel;
		private var _info_txt:Text;
		
		private function Resize(e:Event = null):void
		{
			var sw:int = stage.stageWidth;
			var sh:int = stage.stageHeight;
			var pw:int = _animPanel.width;
			var vw:int = sw - pw;
			
			_animPanel.x = vw;
			_animPanel.height = sh;
			
			_info_txt.setSize(vw, 50);
			_info_txt.x = 0;
			_info_txt.y = sh - 50;
			
			_scene.setViewport(0, 0, vw, sh);
		}
		
		private function get cfg_bytes():LitterByteArray
		{
			var list:Array = _animPanel.itemList;
			var bytes:LitterByteArray = new LitterByteArray();
			bytes.writeShort(list.length);
			for each (var label3d:Label3D in list)
			{
				bytes.writeUTF(label3d.name);
				bytes.writeShort(label3d.from);
				bytes.writeShort(label3d.to);
			}
			return bytes;
		}
		
		private function onSaveFileCfg(evt:Event):void
		{
			var list:Array = _animPanel.itemList;
			if (list.length)
			{
				if (_cfgFile)
				{
					var fileStr:FileStream = new FileStream();
					fileStr.open(_cfgFile, FileMode.WRITE);
					fileStr.writeBytes(cfg_bytes);
				}
				else
				{
					_cfgFile = new File();
//					file.addEventListener(Event.SELECT, onSelectFileCfg);
					_cfgFile.save(cfg_bytes, ".animcfg");
				}
//				_animPanel.reset();
			}
			else
			{
				showInfo("没有数据需要保存！");
			}
		}
		
		private var _cfgFile:File;
		private var _finishFile:File;
		
		private function onOpenFileCfg(evt:Event):void
		{
			_cfgFile = new File();
			_cfgFile.addEventListener(Event.SELECT, onSelectFileCfg);
			_cfgFile.browse([new FileFilter("flare3d anim cfg", "*.animcfg")]);
		}
		
		private function onSelectFileCfg(evt:Event):void
		{
			var file:File = evt.currentTarget as File;
			file.removeEventListener(Event.SELECT, onSelectFileCfg);
			
			_animPanel.reset();
			
			var fileStr:FileStream = new FileStream();
			fileStr.open(file, FileMode.READ);
			var bytes:LitterByteArray = new LitterByteArray();
			fileStr.readBytes(bytes);
			
			parseCfg(bytes);
		}
		
		private function onOpenFile(evt:Event):void
		{
			var file:File = new File();
			file.addEventListener(Event.SELECT, onSelectFile);
			file.browse([new FileFilter("flare3d", "*.f3d;*.zf3d")]);
		}
		
		private var _f3d_bytes:LitterByteArray = new LitterByteArray();
		
		private function onSelectFile(evt:Event):void
		{
			var file:File = evt.currentTarget as File;
			file.removeEventListener(Event.SELECT, onSelectFile);
			
			var fileStr:FileStream = new FileStream();
			fileStr.open(file, FileMode.READ);
			var bytes:LitterByteArray = new LitterByteArray();
			fileStr.readBytes(bytes);
			
			parseAnim(bytes);
		}
		
		private function onLoadSurc(evt:Event):void
		{
			var list_ren:Vector.<Pivot3D> = _scene.children;
			for each (var tmp_pivot:Pivot3D in list_ren)
			{
				_scene.removeChild(tmp_pivot);
			}
			
			var f3d:Flare3DLoader = evt.currentTarget as Flare3DLoader;
			f3d.removeEventListener(Event.COMPLETE, onLoadSurc);
			
			var mesh:Pivot3D;
			mesh = f3d.getChildByName( "anim" ) as Mesh3D;
			if (mesh == null)
			{
				mesh = f3d.children[0];
			}
			
			/*
			mesh.addLabel( new Label3D( "run", 0, 22, 10 ) );
			mesh.addLabel( new Label3D( "jump", 22, 65 ) );
			
			setTimeout(function ():void
			{
			mesh.gotoAndPlay("jump");
			}, 1000);*/
			
			_scene.addChild(f3d);
			
			_animPanel.anim = mesh;
		}
		
		public function showInfo(msg:String):void
		{
			_info_txt.text = msg;
		}
	}
}