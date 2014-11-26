package  {
	
	import flash.display.MovieClip;
	import flash.display.Graphics;
	
	import com.alanmacdougall.underscore._;

	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	
	import flash.filesystem.File;
	import flash.net.FileFilter;

	import fl.controls.DataGrid;
	import fl.controls.Button;
	import fl.controls.TextInput;
	import flash.utils.Timer;
	
	public class BarcodeCheck extends MovieClip {
		protected var check_list:Array;
		protected var input_list:Array;
		protected var count:Number;
		
		public var code_entry:TextInput;
		public var file_picker:Button;
		public var file_saver:Button;
		public var input_items:DataGrid;
		public var check_items:DataGrid;
		
		public function BarcodeCheck():void {
			// initalize lists
			check_list = [];
			input_list = [];
			count = 0;
			input_items.addColumn("Code");
			input_items.addColumn("Name");
			check_items.addColumn("Code");
			check_items.addColumn("Name");
			// handle events
			code_entry.addEventListener(TextEvent.TEXT_INPUT, _.debounce(onTextInput, 333));
			file_picker.addEventListener(MouseEvent.CLICK, onLoadClick);
			file_saver.addEventListener(MouseEvent.CLICK, onSaveClick);
		}
		
		protected function indicate(good:Boolean):void {
			// animate indicator.
			var g:Graphics = this.graphics,
				w:Number = this.stage.stageWidth,
				h:Number = this.stage.stageHeight;
			g.clear();
			g.beginFill(good ? 0x00ff00 : 0xff0000);
			g.drawRect(0, 0, w, h);
			g.endFill();
			var toggle:Boolean = false;
			var t:Timer = new Timer(333, 3);
			t.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
				if (toggle) {
					g.beginFill(good ? 0x00ff00 : 0xff0000);
					g.drawRect(0, 0, w, h);
					g.endFill();
				} else {
					g.clear();
				}
				toggle = !toggle;
			});
			t.start();
		}
		
		protected function updateCounter(increment:int = 1):void {
			count += increment;
			counter.text = 'Counter: '+ count;
		}
		
		protected function isValid(code:String):Boolean {
			return check_list.indexOf(code) !== -1
			  	&& input_list.indexOf(code) == -1;
		}
		
		protected function onListCheck(code:String):void {
			if (isValid(code)) {
				var name:String = '';
				var d:DataGrid = check_items;
				for (var i:Number = d.length; i--;) {
					var item:* = d.getItemAt(i);
					if (item.Code == code) {
						d.removeItemAt(i);
						name = item.Name;
						break;
					}
				}
				input_items.addItem({ Code: code, Name: name });
				input_list.push(code);
				updateCounter();
				indicate(true);
			}
			else {
				indicate(false);
			}
		}
		
		protected function onListLoad(lines:Array):void {
			// check for names
			check_items.removeAll();
			check_list = _.map(lines, function(item:String):* {
				var arr:Array = item.split(/\s+(?=\w)/);
				item = arr.shift();
				if (arr.length > 0) {
					check_items.addItem({ Code: item, Name: arr.join(" ") });
				}
				else {
					check_items.addItem({ Code: item });
				}
				return item;
			});
			//check_list = lines;
			input_items.removeAll();
			input_list = [];
			count = 0;
		}
		
		protected function onLoadClick(e:MouseEvent):void {
			var f:File = new File;
			f.addEventListener(Event.COMPLETE, function(e:Event):void {
				var data:String = f.data.readUTFBytes(f.data.bytesAvailable) || "";
				onListLoad(data.split("\r").join('').split("\n"));
			});
			// what
			f.addEventListener(Event.SELECT, function(e:Event):void {
				f.load();
			});
			f.browse([new FileFilter("Text documents", "*.txt")]);
		}
		
		protected function onSaveClick(e:MouseEvent):void {
			var f:File = new File;
			var d:DataGrid = input_items;
			var data:String = '';
			for (var i:Number = 0, l:Number = d.length; i < l; ++i) {
				var item:* = d.getItemAt(i);
				data += item.Code +"\t"+ item.Name +"\r\n";
			}
			f.save("count: "+count+"\r\n\r\n"+data, "scanned_list.txt");
		}
		
		protected function onTextInput(e:TextEvent):void {
			var code:String = e.target.text;
			e.target.text = '';
			onListCheck(code);
		}
	}
	
}
